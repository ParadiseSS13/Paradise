/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

   manual (num)
      Currently unused.

Class Procs:
   initialize()                     'game/machinery/machine.dm'

   Destroy()                     'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP, autocalled)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.
      If it's autocalled then everything is normal, if something else calls use_power we are going to
      need to recalculate the power two ticks in a row.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

   process()                  'game/machinery/machine.dm'
      Called by the 'master_controller' once per game tick for each machine that is listed in the 'machines' list.


	Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	pressure_resistance = 15
	max_integrity = 200
	layer = BELOW_OBJ_LAYER
	var/stat = 0
	var/emagged = 0
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP //EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/manual = 0
	var/global/gl_uid = 1
	var/custom_aghost_alerts=0
	var/panel_open = 0
	var/area/myArea
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/list/use_log // Init this list if you wish to add logging to your machine - currently only viewable in VV
	var/list/settagwhitelist // (Init this list if needed) WHITELIST OF VARIABLES THAT THE set_tag HREF CAN MODIFY, DON'T PUT SHIT YOU DON'T NEED ON HERE, AND IF YOU'RE GONNA USE set_tag (format_tag() proc), ADD TO THIS LIST.
	atom_say_verb = "beeps"
	var/siemens_strength = 0.7 // how badly will it shock you?

/obj/machinery/Initialize(mapload)
	if(!armor)
		armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
	. = ..()
	GLOB.machines += src

	if(use_power)
		myArea = get_area(src)
	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)

	power_change()

// gotta go fast
/obj/machinery/makeSpeedProcess()
	if(speed_process)
		return
	speed_process = TRUE
	STOP_PROCESSING(SSmachines, src)
	START_PROCESSING(SSfastprocess, src)

// gotta go slow
/obj/machinery/makeNormalProcess()
	if(!speed_process)
		return
	speed_process = FALSE
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSmachines, src)

/obj/machinery/Destroy()
	if(myArea)
		myArea = null
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos() //If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && !stat)
		use_power(7500/severity)
		new /obj/effect/temp_visual/emp(loc)
	..()
/obj/machinery/default_welder_repair(mob/user, obj/item/I)
	. = ..()
	if(.)
		stat &= ~BROKEN

//sets the use_power var and then forces an area power update
/obj/machinery/proc/update_use_power(var/new_use_power)
	use_power = new_use_power

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(use_power == IDLE_POWER_USE)
		use_power(idle_power_usage,power_channel, 1)
	else if(use_power >= ACTIVE_POWER_USE)
		use_power(active_power_usage,power_channel, 1)
	return 1

/obj/machinery/proc/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	if("set_id" in href_list)
		if(!("id_tag" in vars))
			warning("set_id: [type] has no id_tag var.")
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			src:id_tag = newid
			return TRUE
	if("set_freq" in href_list)
		if(!("frequency" in vars))
			warning("set_freq: [type] has no frequency var.")
			return FALSE
		var/newfreq=src:frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, src:frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			src:frequency = sanitize_frequency(newfreq, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
			return TRUE
	return FALSE

/obj/machinery/proc/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)
	if(!allowed(user))//no, not even HREF exploits
		return FALSE
	var/obj/item/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu = FALSE
		if("set_tag" in href_list && settagwhitelist)
			if(!(href_list["set_tag"] in settagwhitelist))//I see you're trying Href exploits, I see you're failing, I SEE ADMIN WARNING. (seriously though, this is a powerfull HREF, I originally found this loophole, I'm not leaving it in on my PR)
				message_admins("set_tag HREF (var attempted to edit: [href_list["set_tag"]]) exploit attempted by [key_name_admin(user)] on [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				return FALSE
			if(!(href_list["set_tag"] in vars))
				to_chat(usr, "<span class='warning'>Something went wrong: Unable to find [href_list["set_tag"]] in vars!</span>")
				return FALSE
			var/current_tag = vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new value", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				update_mt_menu = TRUE

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if(!idx)
				return FALSE

			var/obj/O = getLink(idx)
			if(!O)
				return FALSE
			if(!canLink(O))
				to_chat(usr, "<span class='warning'>You can't link with that device.</span>")
				return FALSE

			if(unlinkFrom(usr, O))
				to_chat(usr, "<span class='notice'>A green light flashes on \the [P], confirming the link was removed.</span>")
			else
				to_chat(usr, "<span class='warning'>A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices.</span>")
			update_mt_menu = TRUE

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return FALSE
			if(!canLink(O,href_list))
				to_chat(usr, "<span class='warning'>You can't link with that device.</span>")
				return FALSE
			if(isLinkedWith(O))
				to_chat(usr, "<span class='warning'>A red light flashes on \the [P]. The two devices are already linked.</span>")
				return FALSE

			if(linkWith(usr, O, href_list))
				to_chat(usr, "<span class='notice'>A green light flashes on \the [P], confirming the link was added.</span>")
			else
				to_chat(usr, "<span class='warning'>A red light flashes on \the [P].  It appears something went wrong when linking the two devices.</span>")
			update_mt_menu = TRUE

		if("buffer" in href_list)
			P.buffer = src
			to_chat(usr, "<span class='notice'>A green light flashes, and the device appears in the multitool buffer.</span>")
			update_mt_menu = TRUE

		if("flush" in href_list)
			to_chat(usr, "<span class='notice'>A green light flashes, and the device disappears from the multitool buffer.</span>")
			P.buffer = null
			update_mt_menu = TRUE

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret)
			update_mt_menu = TRUE

		if(update_mt_menu)
			update_multitool_menu(usr)
			return TRUE

/obj/machinery/Topic(href, href_list, var/nowindow = 0, var/datum/topic_state/state = GLOB.default_state)
	if(..(href, href_list, nowindow, state))
		return 1

	handle_multitool_topic(href,href_list,usr)
	add_fingerprint(usr)
	return 0

/obj/machinery/proc/operable(var/additional_flags = 0)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(var/additional_flags = 0)
	return (stat & (NOPOWER|BROKEN|additional_flags))

/obj/machinery/CanUseTopic(var/mob/user)
	if(!interact_offline && (stat & (NOPOWER|BROKEN)))
		return STATUS_CLOSE

	return ..()

/obj/machinery/tgui_status(mob/user, datum/tgui_state/state)
	if(!interact_offline && (stat & (NOPOWER|BROKEN)))
		return STATUS_CLOSE

	return ..()

/obj/machinery/CouldUseTopic(var/mob/user)
	..()
	user.set_machine(src)

/obj/machinery/CouldNotUseTopic(var/mob/user)
	usr.unset_machine()

/obj/machinery/proc/dropContents()//putting for swarmers, occupent code commented out, someone can use later.
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_ai(mob/user)
	if(isrobot(user))// For some reason attack_robot doesn't work
		var/mob/living/silicon/robot/R = user
		if(R.client && R.client.eye == R && !R.low_power_mode)// This is to stop robots from using cameras to remotely control machines; and from using machines when the borg has no power.
			return attack_hand(user)
	else
		return attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(user.incapacitated())
		return TRUE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("<span class='warning'>[H] stares cluelessly at [src] and drools.</span>")
			return TRUE
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return TRUE

	if(panel_open)
		add_fingerprint(user)
		return FALSE

	if(!interact_offline && stat & (NOPOWER|BROKEN|MAINT))
		return TRUE

	add_fingerprint(user)

	return ..()

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		on_deconstruction()
		if(component_parts && component_parts.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
			component_parts.Cut()
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
	. = M
	M.anchored = anchored
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		stat |= BROKEN

/obj/machinery/proc/default_deconstruction_crowbar(user, obj/item/I, ignore_panel = 0)
	if(I.tool_behaviour != TOOL_CROWBAR)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if((panel_open || ignore_panel) && !(flags & NODECONSTRUCT))
		deconstruct(TRUE)
		to_chat(user, "<span class='notice'>You disassemble [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return 1
	return 0

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(I.tool_behaviour != TOOL_SCREWDRIVER)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if(!(flags & NODECONSTRUCT))
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = 0
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/I)
	if(I.tool_behaviour != TOOL_WRENCH)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if(panel_open)
		dir = turn(dir,-90)
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return TRUE
	return FALSE

/obj/machinery/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(.)
		power_change()

/obj/machinery/proc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	var/shouldplaysound = 0
	if((flags & NODECONSTRUCT))
		return FALSE
	if(istype(W) && component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/circuitboard/CB = locate(/obj/item/circuitboard) in component_parts
			var/P
			if(W.works_from_distance)
				to_chat(user, display_parts(user))
			for(var/obj/item/stock_parts/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/stock_parts/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
							shouldplaysound = 1
							break
			RefreshParts()
		else
			to_chat(user, display_parts(user))
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	else
		return 0

/obj/machinery/proc/display_parts(mob/user)
	. = list("<span class='notice'>Following parts detected in the machine:</span>")
	for(var/obj/item/C in component_parts)
		. += "<span class='notice'>[bicon(C)] [C.name]</span>"
	. = jointext(., "\n")

/obj/machinery/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		. += "<span class='notice'>It looks broken and non-functional.</span>"
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += "<span class='warning'>It's on fire!</span>"
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				. +=  "It looks slightly damaged."
			if(25 to 50)
				. +=  "It appears heavily damaged."
			if(0 to 25)
				. +=  "<span class='warning'>It's falling apart!</span>"
	if(user.research_scanner && component_parts)
		. += display_parts(user)

/obj/machinery/proc/on_assess_perp(mob/living/carbon/human/perp)
	return 0

/obj/machinery/proc/is_assess_emagged()
	return emagged

/obj/machinery/proc/assess_perp(mob/living/carbon/human/perp, var/check_access, var/auth_weapons, var/check_records, var/check_arrest)
	var/threatcount = 0	//the integer returned

	if(is_assess_emagged())
		return 10	//if emagged, always return 10.

	threatcount += on_assess_perp(perp)
	if(threatcount >= 10)
		return threatcount

	//Agent cards lower threatlevel.
	var/obj/item/card/id/id = GetIdCard(perp)
	if(id && istype(id, /obj/item/card/id/syndicate))
		threatcount -= 2
	// A proper	CentCom id is hard currency.
	else if(id && istype(id, /obj/item/card/id/centcom))
		threatcount -= 2

	if(check_access && !allowed(perp))
		threatcount += 4

	if(auth_weapons && !allowed(perp))
		if(istype(perp.l_hand, /obj/item/gun) || istype(perp.l_hand, /obj/item/melee))
			threatcount += 4

		if(istype(perp.r_hand, /obj/item/gun) || istype(perp.r_hand, /obj/item/melee))
			threatcount += 4

		if(istype(perp.belt, /obj/item/gun) || istype(perp.belt, /obj/item/melee))
			threatcount += 2

		if(!ishumanbasic(perp)) //beepsky so racist.
			threatcount += 2

	if(check_records || check_arrest)
		var/perpname = perp.get_visible_name(TRUE)

		var/datum/data/record/R = find_security_record("name", perpname)
		if(check_records && !R)
			threatcount += 4

		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if(SEC_RECORD_STATUS_EXECUTE)
					threatcount += 7
				if(SEC_RECORD_STATUS_ARREST)
					threatcount += 5

	return threatcount


/obj/machinery/proc/shock(mob/living/user, prb)
	if(!istype(user) || inoperable())
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, 1, src)
	if(electrocute_mob(user, get_area(src), src, siemens_strength, TRUE))
		return TRUE
	return FALSE

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

/obj/machinery/proc/on_deconstruction()
	return

/obj/machinery/proc/can_be_overridden()
	. = 1

/obj/machinery/tesla_act(power, explosive = FALSE)
	..()
	if(prob(85) && explosive)
		explosion(loc, 1, 2, 4, flame_range = 2, adminlog = 0, smoke = 0)
	else if(prob(50))
		emp_act(EMP_LIGHT)
	else
		ex_act(EXPLODE_HEAVY)

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)	// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8
	var/md5 = md5(AM.name)										// Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for (var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)
