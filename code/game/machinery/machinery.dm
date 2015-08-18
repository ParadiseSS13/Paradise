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
   New()                     'game/machinery/machine.dm'

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
	pressure_resistance = 10
	var/stat = 0
	var/emagged = 0
	var/use_power = 1
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
	var/use_log = list()
	var/list/settagwhitelist = list()//WHITELIST OF VARIABLES THAT THE set_tag HREF CAN MODIFY, DON'T PUT SHIT YOU DON'T NEED ON HERE, AND IF YOU'RE GONNA USE set_tag (format_tag() proc), ADD TO THIS LIST.

/obj/machinery/New()
	addAtProcessing()
	return ..()

/obj/machinery/proc/addAtProcessing()
	if (use_power)
		myArea = get_area_master(src)

	machines += src

/obj/machinery/proc/removeAtProcessing()
	if (myArea)
		myArea = null

	machines -= src

/obj/machinery/Destroy()
	if (src in machines)
		removeAtProcessing()

	return ..()

/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			pulse2.delete()
	..()

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(src.use_power == 1)
		use_power(idle_power_usage,power_channel, 1)
	else if(src.use_power >= 2)
		use_power(active_power_usage,power_channel, 1)
	return 1

/obj/machinery/proc/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	if("set_id" in href_list)
		if(!("id_tag" in vars))
			warning("set_id: [type] has no id_tag var.")
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			src:id_tag = newid
			return MT_UPDATE|MT_REINIT
	if("set_freq" in href_list)
		if(!("frequency" in vars))
			warning("set_freq: [type] has no frequency var.")
			return 0
		var/newfreq=src:frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, src:frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				src:frequency = newfreq
				return MT_UPDATE|MT_REINIT
	return 0

/obj/machinery/proc/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)
	if(!allowed(user))//no, not even HREF exploits
		return 0
	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu=0
		var/re_init=0
		if("set_tag" in href_list)
			if(!(href_list["set_tag"] in settagwhitelist))//I see you're trying Href exploits, I see you're failing, I SEE ADMIN WARNING. (seriously though, this is a powerfull HREF, I originally found this loophole, I'm not leaving it in on my PR)
				message_admins("set_tag HREF (var attempted to edit: [href_list["set_tag"]]) exploit attempted by [key_name_admin(user)] on [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				return 1
			if(!(href_list["set_tag"] in vars))
				usr << "<span class='warning'>Something went wrong: Unable to find [href_list["set_tag"]] in vars!</span>"
				return 1
			var/current_tag = src.vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new value", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				re_init=1

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if (!idx)
				return 1

			var/obj/O = getLink(idx)
			if(!O)
				return 1
			if(!canLink(O))
				usr << "\red You can't link with that device."
				return 1

			if(unlinkFrom(usr, O))
				usr << "\blue A green light flashes on \the [P], confirming the link was removed."
			else
				usr << "\red A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices."
			update_mt_menu=1

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return 1
			if(!canLink(O,href_list))
				usr << "\red You can't link with that device."
				return 1
			if (isLinkedWith(O))
				usr << "\red A red light flashes on \the [P]. The two devices are already linked."
				return 1

			if(linkWith(usr, O, href_list))
				usr << "\blue A green light flashes on \the [P], confirming the link was added."
			else
				usr << "\red A red light flashes on \the [P].  It appears something went wrong when linking the two devices."
			update_mt_menu=1

		if("buffer" in href_list)
			P.buffer = src
			usr << "\blue A green light flashes, and the device appears in the multitool buffer."
			update_mt_menu=1

		if("flush" in href_list)
			usr << "\blue A green light flashes, and the device disappears from the multitool buffer."
			P.buffer = null
			update_mt_menu=1

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret == MT_ERROR)
			return 1
		if(ret & MT_UPDATE)
			update_mt_menu=1
		if(ret & MT_REINIT)
			re_init=1

		if(re_init)
			initialize()
		if(update_mt_menu)
			//usr.set_machine(src)
			update_multitool_menu(usr)
			return 1

/obj/machinery/Topic(href, href_list, var/nowindow = 0, var/datum/topic_state/state = default_state)
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

/obj/machinery/CouldUseTopic(var/mob/user)
	..()
	user.set_machine(src)

/obj/machinery/CouldNotUseTopic(var/mob/user)
	usr.unset_machine()

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_ai(var/mob/user as mob)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(!interact_offline && stat & (NOPOWER|BROKEN|MAINT))
		return 1
	if(user.lying || user.stat)
		return 1
	if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon)))
		usr << "\red You don't have the dexterity to do this!"
		return 1
/*
	//distance checks are made by atom/proc/DblClick
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
*/
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("\red [H] stares cluelessly at [src] and drools.")
			return 1
		else if(prob(H.getBrainLoss()))
			user << "\red You momentarily forget how to use [src]."
			return 1

	src.add_fingerprint(user)

	return 0

/obj/machinery/CheckParts()
	RefreshParts()
	return

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return
	return 0

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_deconstruction_crowbar(var/obj/item/weapon/crowbar/C, var/ignore_panel = 0)
	if(istype(C) && (panel_open || ignore_panel))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/item/I in component_parts)
			if(I.reliability != 100 && crit_fail)
				I.crit_fail = 1
			I.loc = src.loc
		qdel(src)

/obj/machinery/proc/default_deconstruction_screwdriver(var/mob/user, var/icon_state_open, var/icon_state_closed, var/obj/item/weapon/screwdriver/S)
	if(istype(S))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = icon_state_closed
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(var/mob/user, var/obj/item/weapon/wrench/W)
	if(panel_open && istype(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		dir = pick(WEST,EAST,SOUTH,NORTH)
		user << "<span class='notice'>You clumsily rotate [src].</span>"
		return 1
	return 0

/obj/machinery/proc/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	if(istype(W))
		user << "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, time))
			user << "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>"
			anchored = !anchored
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		return 1
	return 0

/obj/machinery/proc/state(var/msg)
  for(var/mob/O in hearers(src, null))
    O.show_message("\icon[src] <span class = 'notice'>[msg]</span>", 2)

/obj/machinery/proc/ping(text=null)
  if (!text)
    text = "\The [src] pings."

  state(text, "blue")
  playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/machinery/proc/exchange_parts(mob/user, obj/item/weapon/storage/part_replacer/W)
	var/shouldplaysound = 0
	if(istype(W) && component_parts)
		if(panel_open)
			var/obj/item/weapon/circuitboard/CB = locate(/obj/item/weapon/circuitboard) in component_parts
			var/P
			for(var/obj/item/weapon/stock_parts/A in component_parts)
				for(var/D in CB.req_components)
					if(ispath(A.type, D))
						P = D
						break
				for(var/obj/item/weapon/stock_parts/B in W.contents)
					if(istype(B, P) && istype(A, P))
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							user << "<span class='notice'>[A.name] replaced with [B.name].</span>"
							shouldplaysound = 1
							break
			RefreshParts()
		else
			user << "<span class='notice'>Following parts detected in the machine:</span>"
			for(var/var/obj/item/C in component_parts)
				user << "<span class='notice'>    [C.name]</span>"
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	else
		return 0

/obj/machinery/proc/dismantle()
	playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
	var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
	M.state = 2
	M.icon_state = "box_1"
	for(var/obj/I in component_parts)
		if(I.reliability != 100 && crit_fail)
			I.crit_fail = 1
		I.loc = loc
	qdel(src)
	return 1

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
	var/obj/item/weapon/card/id/id = GetIdCard(perp)
	if(id && istype(id, /obj/item/weapon/card/id/syndicate))
		threatcount -= 2
	// A proper	CentCom id is hard currency.
	else if(id && istype(id, /obj/item/weapon/card/id/centcom))
		threatcount -= 2

	if(check_access && !allowed(perp))
		threatcount += 4		
		
	if(auth_weapons && !src.allowed(perp))
		if(istype(perp.l_hand, /obj/item/weapon/gun) || istype(perp.l_hand, /obj/item/weapon/melee))
			threatcount += 4

		if(istype(perp.r_hand, /obj/item/weapon/gun) || istype(perp.r_hand, /obj/item/weapon/melee))
			threatcount += 4

		if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
			threatcount += 2

		if(perp.species.name != "Human") //beepsky so racist.
			threatcount += 2

	if(check_records || check_arrest)
		var/perpname = perp.name
		if(id)
			perpname = id.registered_name

		var/datum/data/record/R = find_security_record("name", perpname)
		if(check_records && !R)
			threatcount += 4

		if(check_arrest && R && (R.fields["criminal"] == "*Arrest*"))
			threatcount += 4

	return threatcount
	

/obj/machinery/proc/shock(mob/user, prb)
	if(inoperable())
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		if(user.stunned)
			return 1
	return 0
