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

#define MACHINE_FLICKER_CHANCE 0.05 // roughly 1/2000 chance of a machine flickering on any given tick. That means in a two hour round each machine will flicker on average a little less than two times.

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
	atom_say_verb = "beeps"
	var/siemens_strength = 0.7 // how badly will it shock you?
	/// The frequency on which the machine can communicate. Used with `/datum/radio_frequency`.
	var/frequency = NONE
	/// A reference to a `datum/radio_frequency`. Gives the machine the ability to interact with things using radio signals.
	var/datum/radio_frequency/radio_connection
	/// This is if the machinery is being repaired
	var/being_repaired = FALSE
	/// initialize this in the overridden init_multitool_menu() proc if an object should show the multitool menu
	var/datum/multitool_menu/multitool_menu

/*
 * reimp, attempts to flicker this machinery if the behavior is supported.
 */
/obj/machinery/get_spooked()
	return flicker()

/*
 * Base class, attempt to flicker. Returns TRUE if we complete our 'flicker
 * behavior', false otherwise.
 */
/obj/machinery/proc/flicker()
	return FALSE

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

	init_multitool_menu()

/obj/machinery/proc/init_multitool_menu()
	return

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
	QDEL_NULL(multitool_menu)
	return ..()

/obj/machinery/has_prints()
	return TRUE

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/proc/set_frequency()
	return

/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos() //If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	if(use_power && !stat)
		use_power(7500/severity)
		. = TRUE
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
	if(prob(MACHINE_FLICKER_CHANCE))
		flicker()
	return 1

/obj/machinery/Topic(href, href_list, var/nowindow = 0, var/datum/ui_state/state = GLOB.default_state)
	if(..(href, href_list, nowindow, state))
		return 1
	return 0

/obj/machinery/proc/operable(var/additional_flags = 0)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(var/additional_flags = 0)
	return (stat & (NOPOWER|BROKEN|additional_flags))

/obj/machinery/ui_status(mob/user, datum/ui_state/state)
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
	if(iscogscarab(user))
		return
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
		if(has_prints())
			add_fingerprint(user)
		return FALSE

	if(!interact_offline && stat & (NOPOWER|BROKEN|MAINT))
		return TRUE

	if(has_prints())
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

/obj/machinery/attackby(obj/item/O, mob/user, params)
	if(has_prints() && !(istype(O, /obj/item/detective_scanner)))
		add_fingerprint(user)
	if(istype(O, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = O
		if(stat & BROKEN)
			to_chat(user, "<span class='notice'>[src] is too damaged to be fixed with nanopaste!</span>")
			return
		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='notice'>[src] is fully intact.</span>")
			return
		if(being_repaired)
			return
		if(N.get_amount() < 1)
			to_chat(user, "<span class='warning'>You don't have enough to complete this task!</span>")
			return
		to_chat(user, "<span class='notice'>You start applying [O] to [src].</span>")
		being_repaired = TRUE
		var/result = do_after(user, 3 SECONDS, target = src)
		being_repaired = FALSE
		if(!result)
			return
		if(!N.use(1))
			to_chat(user, "<span class='warning'>You don't have enough to complete this task!</span>") // this is here, as we don't want to use nanopaste until you finish applying
			return
		obj_integrity = min(obj_integrity + 50, max_integrity)
		user.visible_message("<span class='notice'>[user] applied some [O] at [src]'s damaged areas.</span>",\
			"<span class='notice'>You apply some [O] at [src]'s damaged areas.</span>")
	else
		return ..()
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
						if(ispath(B.type, /obj/item/stock_parts/cell))
							var/obj/item/stock_parts/cell/tA = A
							var/obj/item/stock_parts/cell/tB = B
							if(!(tB.maxcharge > tA.maxcharge) && !((tB.maxcharge == tA.maxcharge) && (tB.charge > tA.charge)))
								continue
						else if(B.rating <= A.rating)
							continue
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
				. +=  "<span class='notice'>It looks slightly damaged.</span>"
			if(25 to 50)
				. +=  "<span class='notice'>It appears heavily damaged.</span>"
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
	if(locate(/obj/item/card/id/syndicate) in perp.get_all_id_cards())
		threatcount -= 2
	// A proper	CentCom id is hard currency.
	else if(locate(/obj/item/card/id/centcom) in perp.get_all_id_cards())
		threatcount -= 2

	if(check_access && !allowed(perp))
		threatcount += 4
	if(auth_weapons && !(ACCESS_WEAPONS in perp.get_access()))
		if(check_for_weapons(perp.l_hand))
			threatcount += 4
		if(check_for_weapons(perp.r_hand))
			threatcount += 4
		if(check_for_weapons(perp.belt))
			threatcount += 4
		if(check_for_weapons(perp.s_store))
			threatcount += 4

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

/obj/machinery/proc/check_for_weapons(obj/item/slot_item)
	if(istype(slot_item) && slot_item.needs_permit)
		return TRUE
	return FALSE

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

/**
 * Alerts the AI that a hack is in progress.
 *
 * Sends all AIs a message that a hack is occurring.  Specifically used for space ninja tampering as this proc was originally in the ninja files.
 * However, the proc may also be used elsewhere.
 */
/obj/machinery/proc/AI_notify_hack()
	var/alertstr = span_userdanger("Network Alert: Hacking attempt detected[get_area(src)?" in [get_area_name(src, TRUE)]":". Unable to pinpoint location"].")
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		to_chat(AI, alertstr)


/obj/machinery/extinguish_light(force = FALSE)
	if(light_range)
		remove_light()
