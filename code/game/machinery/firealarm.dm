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
	icon_state = "firealarm_on"
	/// Whether or not the fire alarm will sound the alarm if its temperature rises above 200C
	var/detecting = TRUE
	var/working = TRUE
	var/time = 10.0
	var/timing = 0.0
	anchored = TRUE
	max_integrity = 250
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, rad = 100, fire = 90, acid = 30)
	idle_power_consumption = 2
	active_power_consumption = 6
	power_channel = PW_CHANNEL_ENVIRONMENT
	resistance_flags = FIRE_PROOF

	light_power = LIGHTING_MINIMUM_POWER
	light_range = 7
	light_color = "#ff3232"

	var/wiresexposed = FALSE
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

	var/report_fire_alarms = TRUE // Should triggered fire alarms also trigger an actual alarm?
	var/show_alert_level = TRUE // Should fire alarms display the current alert level?

	var/last_time_pulled //used to prevent pulling spam by same persons

/obj/machinery/firealarm/no_alarm
	report_fire_alarms = FALSE

/obj/machinery/firealarm/syndicate
	report_fire_alarms = FALSE
	show_alert_level = FALSE

/obj/machinery/firealarm/update_icon_state()
	if(wiresexposed)
		icon_state = "firealarm_b[buildstage]"
		return
	if(stat & BROKEN)
		icon_state = "firealarm_broken"
		return
	if(stat & NOPOWER)
		icon_state = "firealarm_off"
		return

	var/area/area = get_area(src)
	if(area.fire)
		icon_state = "firealarm_alarming"
		return
	if(!detecting)
		icon_state = "firealarm_detect"
		return
	else
		icon_state = "firealarm_on"

/obj/machinery/firealarm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return

	if(is_station_contact(z) && show_alert_level)
		. += "overlay_[get_security_level()]"
		underlays += emissive_appearance(icon, "firealarm_overlay_lightmask")

	if(!wiresexposed)
		underlays += emissive_appearance(icon, "firealarm_lightmask")

/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of [src]!</span>",
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
	if(user.can_advanced_admin_interact())
		toggle_alarm(user)

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
					to_chat(user, "<span class='warning'>You need a total of five cables to wire [src]!</span>")
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
		LAZYREMOVE(get_area(src).firealarms, src)
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

/obj/machinery/firealarm/proc/update_fire_light(fire)
	if(stat & NOPOWER)
		set_light(0)
		return
	else if(GLOB.security_level == SEC_LEVEL_EPSILON)
		set_light(2, 1, COLOR_WHITE)
		return
	else if(fire == !!light_power || fire == !!(light_power - 0.1))
		return  // do nothing if we're already active

	if(fire)
		set_light(l_power = 0.8)
	else
		set_light(l_power = LIGHTING_MINIMUM_POWER)

/obj/machinery/firealarm/proc/update_fire_sound(fire)
	var/area/A = get_area(src)
	if(stat & NOPOWER)
		GLOB.firealarm_soundloop.stop(src, TRUE)
	else if(A.fire)
		GLOB.firealarm_soundloop.start(src)

/obj/machinery/firealarm/power_change()
	if(!..())
		return
	update_fire_light()
	update_icon()
	update_fire_sound()

/obj/machinery/firealarm/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN) || buildstage != 2)
		return 1

	if(user.incapacitated())
		return 1

	if(fingerprintslast == user.ckey && world.time < last_time_pulled + 2 SECONDS) //no spamming >:C
		to_chat(user, "<span class='warning'>[src] is still processing your earlier command.</span>")
		return

	toggle_alarm(user)


/obj/machinery/firealarm/proc/toggle_alarm(mob/user)
	var/area/A = get_area(src)
	if(istype(A))
		add_fingerprint(user)
		last_time_pulled = world.time
		if(A.fire)
			reset()
		else
			alarm()

/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(FIRE_ALARM_FRAME)
			. += "<span class='notice'>It's missing a <i>circuit board<i> and the <b>bolts</b> are exposed.</span>"
		if(FIRE_ALARM_UNWIRED)
			. += "<span class='notice'>The control board needs <i>wiring</i> and can be <b>pried out</b>.</span>"
		if(FIRE_ALARM_READY)
			if(wiresexposed)
				. += "<span class='notice'>The fire alarm's <b>wires</b> are exposed by the <i>unscrewed</i> panel.</span>"
				. += "<span class='notice'>The detection circuitry can be turned <b>[detecting ? "off" : "on"]</b> by <i>pulsing</i> the board.</span>"

	. += "It shows the alert level as: <B><U>[capitalize(get_security_level())]</U></B>."

/obj/machinery/firealarm/proc/reset()
	if(!working || !report_fire_alarms)
		return
	var/area/A = get_area(src)
	A.firereset(src)

/obj/machinery/firealarm/proc/alarm()
	if(!working || !report_fire_alarms)
		return
	var/area/A = get_area(src)
	if(!A)
		return
	A.firealert(src) // Manually trigger alarms if the alarm isn't reported

/obj/machinery/firealarm/New(location, direction, building)
	. = ..()

	if(building)
		buildstage = 0
		wiresexposed = TRUE
		setDir(direction)
		set_pixel_offsets_from_dir(26, -26, 26, -26)

	LAZYADD(get_area(src).firealarms, src)

/obj/machinery/firealarm/Initialize(mapload)
	. = ..()
	name = "fire alarm"
	set_light(1, LIGHTING_MINIMUM_POWER) //for emissives
	update_icon()

/obj/machinery/firealarm/Destroy()
	LAZYREMOVE(GLOB.firealarm_soundloop.output_atoms, src)
	LAZYREMOVE(get_area(src).firealarms, src)
	return ..()

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
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

#undef FIRE_ALARM_FRAME
#undef FIRE_ALARM_UNWIRED
#undef FIRE_ALARM_READY
