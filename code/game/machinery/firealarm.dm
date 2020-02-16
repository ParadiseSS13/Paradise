/*
FIRE ALARM
*/

#define FIRE_ALARM_FRAME	0
#define FIRE_ALARM_UNWIRED	1
#define FIRE_ALARM_READY	2

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	max_integrity = 250
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	resistance_flags = FIRE_PROOF
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

	var/report_fire_alarms = TRUE // Should triggered fire alarms also trigger an actual alarm?
	var/show_alert_level = TRUE // Should fire alarms display the current alert level?

/obj/machinery/firealarm/no_alarm
	report_fire_alarms = FALSE

/obj/machinery/firealarm/syndicate
	report_fire_alarms = FALSE
	show_alert_level = FALSE

/obj/machinery/firealarm/update_icon()

	if(wiresexposed)
		switch(buildstage)
			if(2)
				icon_state="fire_b2"
			if(1)
				icon_state="fire_b1"
			if(0)
				icon_state="fire_b0"

		return

	if(stat & BROKEN)
		icon_state = "firex"
	else if(stat & NOPOWER)
		icon_state = "firep"
	else if(!detecting)
		icon_state = "fire1"
	else
		icon_state = "fire0"

/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>",
								"<span class='notice'>You emag [src], disabling its thermal sensors.</span>")
		playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	..()
	if(!emagged && detecting && temperature > T0C + 200)
		alarm()			// added check of detector status here

/obj/machinery/firealarm/attack_ai(mob/user)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/firealarm/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm(rand(30/severity, 60/severity))
	..()

/obj/machinery/firealarm/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(wiresexposed)
		if(buildstage == FIRE_ALARM_UNWIRED)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/coil = I
				if(!coil.use(5))
					to_chat(user, "<span class='warning'>You cut the wires!</span>")
					return

				buildstage = FIRE_ALARM_READY
				playsound(get_turf(src), I.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You wire [src]!</span>")
				update_icon()
		if(buildstage == FIRE_ALARM_FRAME)
			if(istype(I, /obj/item/firealarm_electronics))
				to_chat(user, "<span class='notice'>You insert the circuit!</span>")
				qdel(I)
				buildstage = FIRE_ALARM_UNWIRED
				update_icon()
		return
	return ..()

/obj/machinery/firealarm/crowbar_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_UNWIRED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume) || buildstage != FIRE_ALARM_UNWIRED)
		return
	new /obj/item/firealarm_electronics(drop_location())
	buildstage = FIRE_ALARM_FRAME
	update_icon()
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE

/obj/machinery/firealarm/multitool_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!wiresexposed)
		to_chat(user, "<span class='warning'>You need to expose the wires first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	detecting = !detecting
	if(detecting)
		user.visible_message("<span class='warning'>[user] has reconnected [src]'s detecting unit!</span>", "You have reconnected [src]'s detecting unit.")
	else
		user.visible_message("<span class='warning'>[user] has disconnected [src]'s detecting unit!</span>", "You have disconnected [src]'s detecting unit.")

/obj/machinery/firealarm/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresexposed = !wiresexposed
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()

/obj/machinery/firealarm/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_READY)
		return
	. = TRUE
	if(!wiresexposed)
		to_chat(user, "<span class='warning'>You need to expose the wires first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	var/obj/item/stack/cable_coil/new_coil = new /obj/item/stack/cable_coil(drop_location())
	new_coil.amount = 5
	buildstage = FIRE_ALARM_UNWIRED


/obj/machinery/firealarm/wrench_act(mob/user, obj/item/I)
	if(buildstage != FIRE_ALARM_FRAME)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/firealarm(get_turf(user))
	qdel(src)

/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage received
		if(obj_integrity > 0 && !(stat & BROKEN) && buildstage != 0)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/singularity_pull(S, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	..()

/obj/machinery/firealarm/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT) && buildstage != 0) //can't break the electronics if there isn't any inside.
		stat |= BROKEN
		update_icon()

/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 1)
		if(!(stat & BROKEN))
			var/obj/item/I = new /obj/item/firealarm_electronics(loc)
			if(!disassembled)
				I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(timing)
		if(time > 0)
			time = time - ((world.timeofday - last_process)/10)
		else
			alarm()
			time = 0
			timing = 0
			STOP_PROCESSING(SSobj, src)
		updateDialog()
	last_process = world.timeofday

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN) || buildstage != 2)
		return 1

	if(user.incapacitated())
		return 1

	ui_interact(user)

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, var/master_ui = null, var/datum/topic_state/state = default_state)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "firealarm.tmpl", name, 400, 400, state = state)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/firealarm/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	var/area/A = get_area(src)
	data["fire"] = A.fire
	data["timing"] = timing

	data["sec_level"] = get_security_level()

	var/second = round(time % 60)
	var/minute = round(time / 60)

	data["time_left"] = "[minute ? "[minute]:" : ""][add_zero(num2text(second), 2)]"
	return data

/obj/machinery/firealarm/Topic(href, href_list)
	if(..())
		return 1

	if(buildstage != 2)
		return 1

	add_fingerprint(usr)

	if(href_list["reset"])
		reset()
	else if(href_list["alarm"])
		alarm()
	else if(href_list["time"])
		var/oldTiming = timing
		timing = text2num(href_list["time"])
		last_process = world.timeofday
		if(oldTiming != timing)
			if(timing)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	else if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 120)

/obj/machinery/firealarm/proc/reset()
	if(!working)
		return
	var/area/A = get_area(src)
	A.fire_reset()

	for(var/obj/machinery/firealarm/FA in A)
		if(is_station_contact(z) && FA.report_fire_alarms)
			SSalarms.fire_alarm.clearAlarm(loc, FA)

/obj/machinery/firealarm/proc/alarm(var/duration = 0)
	if(!working)
		return

	var/area/A = get_area(src)
	for(var/obj/machinery/firealarm/FA in A)
		if(is_station_contact(z) && FA.report_fire_alarms)
			SSalarms.fire_alarm.triggerAlarm(loc, FA, duration)
		else
			A.fire_alert() // Manually trigger alarms if the alarm isn't reported

	update_icon()

/obj/machinery/firealarm/New(location, direction, building)
	..()

	if(building)
		buildstage = 0
		wiresexposed = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(is_station_contact(z) && show_alert_level)
		if(security_level)
			overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			overlays += image('icons/obj/monitors.dmi', "overlay_green")

	update_icon()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/machinery/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6

/obj/machinery/partyalarm/attack_hand(mob/user)
	if((user.stat && !isobserver(user)) || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = get_area(src)
	ASSERT(isarea(A))
	var/d1
	var/d2
	if(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))

		if(A.party)
			d1 = "<A href='?src=[UID()];reset=1'>No Party :(</A>"
		else
			d1 = "<A href='?src=[UID()];alarm=1'>PARTY!!!</A>"
		if(timing)
			d2 = "<A href='?src=[UID()];time=0'>Stop Time Lock</A>"
		else
			d2 = "<A href='?src=[UID()];time=1'>Initiate Time Lock</A>"
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=[UID()];tp=-30'>-</A> <A href='?src=[UID()];tp=-1'>-</A> <A href='?src=[UID()];tp=1'>+</A> <A href='?src=[UID()];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		if(A.fire)
			d1 = text("<A href='?src=[UID()];reset=1'>[]</A>", stars("No Party :("))
		else
			d1 = text("<A href='?src=[UID()];alarm=1'>[]</A>", stars("PARTY!!!"))
		if(timing)
			d2 = text("<A href='?src=[UID()];time=0'>[]</A>", stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=[UID()];time=1'>[]</A>", stars("Initiate Time Lock"))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=[UID()];tp=-30'>-</A> <A href='?src=[UID()];tp=-1'>-</A> <A href='?src=[UID()];tp=1'>+</A> <A href='?src=[UID()];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if(!( working ))
		return
	var/area/A = get_area(src)
	ASSERT(isarea(A))
	A.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if(!( working ))
		return
	var/area/A = get_area(src)
	ASSERT(isarea(A))
	A.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	..()
	if(usr.stat || stat & (BROKEN|NOPOWER))
		return
	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if(href_list["reset"])
			reset()
		else
			if(href_list["alarm"])
				alarm()
			else
				if(href_list["time"])
					timing = text2num(href_list["time"])
				else
					if(href_list["tp"])
						var/tp = text2num(href_list["tp"])
						time += tp
						time = min(max(round(time), 0), 120)
		updateUsrDialog()

		add_fingerprint(usr)
	else
		usr << browse(null, "window=partyalarm")
		return
	return


#undef FIRE_ALARM_FRAME
#undef FIRE_ALARM_UNWIRED
#undef FIRE_ALARM_READY
