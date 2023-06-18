/// Global list of all active gravity generators. Keyed by the Z level
GLOBAL_LIST_EMPTY(gravity_generators)

#define GRAV_POWER_IDLE 0
#define GRAV_POWER_UP 1
#define GRAV_POWER_DOWN 2

#define GRAV_NEEDS_WELDING "welding"
#define GRAV_NEEDS_PLASTEEL "plasteel"
#define GRAV_NEEDS_WRENCH "wrench"
#define GRAV_NEEDS_SCREWDRIVER "screwdriver"

//
// Abstract Generator
//

/obj/machinery/gravity_generator
	name = "gravitational generator"
	desc = "A device which produces a graviton field when set up."
	icon = 'icons/obj/machines/gravity_generator.dmi'
	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/gravity_generator/ex_act(severity)
	if(severity == 1) // Very sturdy.
		set_broken()

/obj/machinery/gravity_generator/blob_act(obj/structure/blob/B)
	if(prob(20))
		set_broken()

/obj/machinery/gravity_generator/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

/obj/machinery/gravity_generator/proc/get_status()
	return "off"

// You aren't allowed to move.
/obj/machinery/gravity_generator/Move()
	. = ..()
	qdel(src)

/obj/machinery/gravity_generator/proc/set_broken()
	stat |= BROKEN

/obj/machinery/gravity_generator/proc/set_fix()
	stat &= ~BROKEN

//
// Part generator which is mostly there for collision
//

/obj/machinery/gravity_generator/part
	invisibility = INVISIBILITY_ABSTRACT

//
// Generator which spawns with the station.
//

/obj/machinery/gravity_generator/main/station/Initialize(mapload)
	. = ..()
	setup_parts()
	update_gen_list()
	set_power()

//
// Main Generator with the main code
//

/obj/machinery/gravity_generator/main
	icon_state = "generator_body"
	layer = MOB_LAYER + 0.1
	active_power_consumption = 3000
	power_channel = PW_CHANNEL_ENVIRONMENT
	power_state = IDLE_POWER_USE
	interact_offline = TRUE
	/// Is the generator producing gravity
	var/on = TRUE
	/// Is the breaker switch turned on
	var/breaker_on = TRUE
	/// Generator parts on adjacent tiles
	var/list/parts = list()
	/// Charging state (Idle, Charging, Discharging)
	var/charging_state = GRAV_POWER_IDLE
	/// Charge percentage
	var/charge_count = 100
	var/current_overlay = null
	var/construction_state = GRAV_NEEDS_WELDING
	var/overlay_state = "activated"

/obj/machinery/gravity_generator/main/examine(mob/user)
	. = ..()
	if(!(stat & BROKEN))
		return

	switch(construction_state)
		if(GRAV_NEEDS_WELDING)
			. += "<span class='notice'>The framework is damaged, and needs welding.</span>"
		if(GRAV_NEEDS_PLASTEEL)
			. += "<span class='notice'>The framework needs new plasteel plating.</span>"
		if(GRAV_NEEDS_WRENCH)
			. += "<span class='notice'>The plating needs wrenching into place.</span>"
		if(GRAV_NEEDS_SCREWDRIVER)
			. += "<span class='notice'>The cover screws are loose.</span>"

/obj/machinery/gravity_generator/main/Destroy() // If we somehow get deleted, remove all of our other parts.
	investigate_log("was destroyed!", "gravity")
	on = FALSE
	update_gen_list()
	for(var/obj/machinery/gravity_generator/part/O in parts)
		qdel(O)
	for(var/area/A in world)
		if(!is_station_level(A.z))
			continue
		A.gravitychange(FALSE, A)
	shake_everyone()
	return ..()

/obj/machinery/gravity_generator/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom left of the block
	var/list/spawn_turfs = block(locate(our_turf.x + 2, our_turf.y + 2, our_turf.z), locate(our_turf.x, our_turf.y, our_turf.z))
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Main body, skip it
			continue
		var/obj/machinery/gravity_generator/part/part = new(T)
		if(count <= 3) // That section is the top part of the generator
			part.density = FALSE
		parts += part

/obj/machinery/gravity_generator/main/set_broken()
	..()
	charging_state = GRAV_POWER_IDLE
	overlay_state = null
	charge_count = 0
	breaker_on = FALSE
	update_icon()
	set_gravity(FALSE)
	investigate_log("has broken down.", "gravity")

/obj/machinery/gravity_generator/main/set_fix()
	..()
	construction_state = initial(construction_state)
	update_icon()
	set_power()

// Interaction

//		REPAIRS		//
// Step 1
/obj/machinery/gravity_generator/main/welder_act(mob/user, obj/item/I)
	if(construction_state != GRAV_NEEDS_WELDING)
		return
	. = TRUE
	if(!I.use_tool(src, user, null, 1, I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You mend the damaged framework.</span>")
	construction_state = GRAV_NEEDS_PLASTEEL
	update_icon()

// Step 2
/obj/machinery/gravity_generator/main/attackby(obj/item/I, mob/user, params)
	if(construction_state != GRAV_NEEDS_PLASTEEL)
		return ..()
	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = I
		if(PS.amount < 10)
			to_chat(user, "<span class='warning'>You need 10 sheets of plasteel.</span>")
			return

		to_chat(user, "<span class='notice'>You add new plating to the framework.</span>")
		construction_state = GRAV_NEEDS_WRENCH
		update_icon()

// Step 3
/obj/machinery/gravity_generator/main/wrench_act(mob/living/user, obj/item/I)
	if(construction_state != GRAV_NEEDS_WRENCH)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You secure the plating to the framework.</span>")
	construction_state = GRAV_NEEDS_SCREWDRIVER
	update_icon()

// Step 4
/obj/machinery/gravity_generator/main/screwdriver_act(mob/living/user, obj/item/I)
	if(!(stat & BROKEN)) // Not actually broken
		return
	if(construction_state != GRAV_NEEDS_SCREWDRIVER)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You screw the covers back into place.</span>")
	set_fix()

/obj/machinery/gravity_generator/main/attack_hand(mob/user)
	if(!..())
		return ui_interact(user)

/obj/machinery/gravity_generator/main/attack_ai(mob/user)
	return TRUE

/obj/machinery/gravity_generator/main/attack_ghost(mob/user)
	return ui_interact(user)

// tgui\packages\tgui\interfaces\GravityGen.js
/obj/machinery/gravity_generator/main/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui && !(stat & BROKEN))
		ui = new(user, src, ui_key, "GravityGen", name, 350, 250, master_ui, state)
		ui.open()

/obj/machinery/gravity_generator/main/ui_data(mob/user)
	var/list/data = list()
	data["charging_state"] = charging_state
	data["charge_count"] = charge_count
	data["breaker"] = breaker_on
	data["ext_power"] = on
	return data

/obj/machinery/gravity_generator/main/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	if(action == "breaker")
		breaker_on = !breaker_on
		investigate_log("was toggled [breaker_on ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [usr.key].", "gravity")
		set_power()

// Power and Icon States

/obj/machinery/gravity_generator/main/power_change()
	if(!..())
		return
	investigate_log("has [stat & NOPOWER ? "lost" : "regained"] power.", "gravity")
	set_power()

/obj/machinery/gravity_generator/main/get_status()
	if(stat & BROKEN)
		return "generator_[construction_state]"
	if(on || charging_state != GRAV_POWER_IDLE)
		return "on"
	else
		return "off"

/obj/machinery/gravity_generator/main/update_overlays()
	. = ..()
	if(get_status() != "generator_welding" && get_status() != "generator_plasteel")
		. += "generator_part"
	if(get_status() == "off")
		return
	. += "[get_status()]"
	. += "[overlay_state]"

/**
  * Set the charging state based on external power and the breaker state.
  */
/obj/machinery/gravity_generator/main/proc/set_power()
	if(stat & (NOPOWER|BROKEN) || !breaker_on)
		charging_state = GRAV_POWER_DOWN
	else if(breaker_on)
		charging_state = GRAV_POWER_UP

	investigate_log("is now [charging_state == GRAV_POWER_UP ? "charging" : "discharging"].", "gravity")
	update_icon()

/**
  * Set the state of gravity on the z-level.
  *
  * * enable - `TRUE` to enable gravity, `FALSE` to disable gravity
  */
/obj/machinery/gravity_generator/main/proc/set_gravity(gravity)
	var/alert = FALSE // Sound the alert if gravity was just enabled or disabled.
	var/area/src_area = get_area(src)
	on = gravity
	change_power_mode(on ? ACTIVE_POWER_USE : IDLE_POWER_USE)

	if(gravity) // If we turned on
		if(generators_in_level() == FALSE) // And there's no gravity
			alert = TRUE
			investigate_log("was brought online and is now producing gravity for this level.", "gravity")
			message_admins("The gravity generator was brought online. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[src_area.name]</a>)")
			for(var/area/A in world)
				if(!is_station_level(A.z))
					continue
				A.gravitychange(TRUE, A)

	else if(generators_in_level() == TRUE) // Turned off, and there is gravity
		alert = TRUE
		investigate_log("was brought offline and there is now no gravity for this level.", "gravity")
		message_admins("The gravity generator was brought offline with no backup generator. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[src_area.name]</a>)")
		for(var/area/A in world)
			if(!is_station_level(A.z))
				continue
			A.gravitychange(FALSE, A)

	update_icon()
	update_gen_list()
	if(alert)
		shake_everyone()

// Charge/Discharge and turn on/off gravity when you reach 0/100 percent.
// Also emit radiation and handle the overlays.
/obj/machinery/gravity_generator/main/process()
	if(stat & BROKEN)
		return
	if(charging_state == GRAV_POWER_IDLE)
		return

	if(charging_state == GRAV_POWER_UP && charge_count >= 100) // Fully charged
		charging_state = GRAV_POWER_IDLE
		set_gravity(TRUE)
	else if(charging_state == GRAV_POWER_DOWN && charge_count <= 0) // Fully discharged
		charging_state = GRAV_POWER_IDLE
		set_gravity(FALSE)
	else
		if(charging_state == GRAV_POWER_UP)
			charge_count += 2
		else if(charging_state == GRAV_POWER_DOWN)
			charge_count -= 2

		if(charge_count < 100 && prob(75)) // Let them know it is charging/discharging.
			playsound(loc, 'sound/effects/empulse.ogg', 100, TRUE)

		if(prob(25)) // To help stop "Your clothes feel warm" spam.
			pulse_radiation()

		switch(charge_count)
			if(0 to 20)
				overlay_state = null
			if(21 to 40)
				overlay_state = "startup"
			if(41 to 60)
				overlay_state = "idle"
			if(61 to 80)
				overlay_state = "activating"
			if(81 to 100)
				overlay_state = "activated"

		if(overlay_state != current_overlay)
			update_icon()
			current_overlay = overlay_state


/obj/machinery/gravity_generator/main/proc/pulse_radiation()
	radiation_pulse(src, 600, 2)
	for(var/mob/living/L in view(7, src)) //Windows kinda make it a non threat, no matter how much I amp it up, so let us cheat a little
		radiation_pulse(get_turf(L), 600, 2)

/**
  * Shake everyone on the z level and play an alarm to let them know that gravity was enagaged/disenagaged.
  */
/obj/machinery/gravity_generator/main/proc/shake_everyone()
	var/turf/our_turf = get_turf(src)
	new /obj/effect/warp_effect/gravity_generator(our_turf)
	var/sound/alert_sound = sound('sound/effects/alert.ogg')
	for(var/shaken in GLOB.mob_list)
		var/mob/M = shaken
		var/turf/their_turf = get_turf(M)
		if(their_turf?.z == our_turf.z)
			M.update_gravity(M.mob_has_gravity())
			if(M.client)
				shake_camera(M, 15, 1)
				M.playsound_local(our_turf, null, 100, TRUE, 0.5, S = alert_sound)

// TODO: Make the gravity generator cooperate with the space manager
/obj/machinery/gravity_generator/main/proc/generators_in_level()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(GLOB.gravity_generators["[T.z]"])
		return length(GLOB.gravity_generators["[T.z]"])
	return FALSE

/obj/machinery/gravity_generator/main/proc/update_gen_list()
	var/turf/T = get_turf(src)
	if(T)
		if(!GLOB.gravity_generators["[T.z]"])
			GLOB.gravity_generators["[T.z]"] = list()
		if(on)
			GLOB.gravity_generators["[T.z]"] |= src
		else
			GLOB.gravity_generators["[T.z]"] -= src

// Misc

/obj/effect/warp_effect/gravity_generator

/obj/effect/warp_effect/gravity_generator/Initialize(mapload)
	. = ..()
	var/matrix/M = matrix() * 0.5
	transform = M
	animate(src, transform = M * 40, time = 0.8 SECONDS, alpha = 128)
	QDEL_IN(src, 0.8 SECONDS)


/obj/item/paper/gravity_gen
	name = "paper - 'Generate your own gravity!'"
	info = {"<h1>Generating Gravity For Dummies</h1>
	<p>Surprisingly, gravity isn't that hard to make! All you have to do is inject deadly radioactive minerals into a ball of
	energy and you have yourself gravity! You can turn the machine on or off when required but you must remember that the generator
	will EMIT RADIATION when charging or discharging, you can tell it is charging or discharging by the noise it makes, so please WEAR PROTECTIVE CLOTHING.</p>
	<br>
	<h3>It blew up!</h3>
	<p>Don't panic! The gravity generator was designed to be easily repaired. If, somehow, the sturdy framework did not survive then
	please proceed to panic; otherwise follow these steps.</p><ol>
	<li>Mend the damaged framework with a welding tool.</li>
	<li>Add additional plasteel plating.</li>
	<li>Secure the additional plating with a wrench.</li>
	<li>Secure the cover screws with a screwdriver.</li></ol>"}

#undef GRAV_POWER_IDLE
#undef GRAV_POWER_UP
#undef GRAV_POWER_DOWN

#undef GRAV_NEEDS_WELDING
#undef GRAV_NEEDS_PLASTEEL
#undef GRAV_NEEDS_WRENCH
#undef GRAV_NEEDS_SCREWDRIVER
