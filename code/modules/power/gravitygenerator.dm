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
	pixel_x = -32
	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_2 = NO_MALF_EFFECT_2

/obj/machinery/gravity_generator/ex_act(severity)
	if(severity == EXPLODE_DEVASTATE) // Very sturdy.
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
// Generator which spawns with the station.
//

/obj/machinery/gravity_generator/main/station/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/multitile, list(
		list(1, 1,		   1),
		list(1, MACH_CENTER, 1),
	))

	var/area/machine_area = get_area(src)
	parent_area_type = machine_area.get_top_parent_type()
	if(parent_area_type)
		areas = typesof(parent_area_type)
		// Holodecks have thier own areas and we don't have a way of knowing if we have one.
		// This means the grav gen will affect all holodeck areas in the Z-level, regardless of where in it they are.
		areas |= typesof(/area/holodeck)
	update_gen_list()
	set_power()

//
// Main Generator with the main code
// With the multitile component it's dubious to still have this and not merge it with the `/obj/machinery/gravity_generator` itself

/obj/machinery/gravity_generator/main
	icon_state = "generator_body"
	layer = MOB_LAYER + 0.1
	active_power_consumption = 3000
	power_channel = PW_CHANNEL_ENVIRONMENT
	power_state = IDLE_POWER_USE
	/// Is the generator producing gravity
	var/on = TRUE
	/// Is the breaker switch turned on
	var/breaker_on = TRUE
	/// Charging state (Idle, Charging, Discharging)
	var/charging_state = GRAV_POWER_IDLE
	/// Charge percentage
	var/charge_count = 100
	var/current_overlay = null
	var/construction_state = GRAV_NEEDS_WELDING
	var/overlay_state = "activated"
	var/parent_area_type
	var/areas = list()

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
	investigate_log("was destroyed!", INVESTIGATE_GRAVITY)
	on = FALSE
	update_gen_list()
	for(var/area/A in world)
		if(!is_station_level(A.z))
			continue
		A.gravitychange(FALSE, A)
	shake_everyone()
	return ..()

/obj/machinery/gravity_generator/main/set_broken()
	..()
	charging_state = GRAV_POWER_IDLE
	overlay_state = null
	charge_count = 0
	breaker_on = FALSE
	update_icon()
	set_gravity(FALSE)
	investigate_log("has broken down.", INVESTIGATE_GRAVITY)

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
/obj/machinery/gravity_generator/main/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(construction_state != GRAV_NEEDS_PLASTEEL)
		return ..()

	if(istype(used, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/PS = used
		if(PS.amount < 10)
			to_chat(user, "<span class='warning'>You need 10 sheets of plasteel.</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You add new plating to the framework.</span>")
		construction_state = GRAV_NEEDS_WRENCH
		update_icon()
		return ITEM_INTERACT_COMPLETE

	return ..()

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
/obj/machinery/gravity_generator/main/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/gravity_generator/main/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui && !(stat & BROKEN))
		ui = new(user, src, "GravityGen", name)
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
		investigate_log("was toggled [breaker_on ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [usr.key].", INVESTIGATE_GRAVITY)
		set_power()

// Power and Icon States

/obj/machinery/gravity_generator/main/power_change()
	if(!..())
		return
	investigate_log("has [stat & NOPOWER ? "lost" : "regained"] power.", INVESTIGATE_GRAVITY)
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

	investigate_log("is now [charging_state == GRAV_POWER_UP ? "charging" : "discharging"].", INVESTIGATE_GRAVITY)
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
		if(generators_in_area() == 0) // And there's no other gravity generators on this z level
			alert = TRUE
			investigate_log("was brought online and is now producing gravity for this level.", INVESTIGATE_GRAVITY)
			message_admins("The gravity generator was brought online. (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[src_area.name]</a>)")
			for(var/area/A in world)
				if((A.type in areas) && A.z == z)
					A.gravitychange(TRUE, A)

	else if(generators_in_area() == 1) // Turned off, and there is only one gravity generator on the Z level
		alert = TRUE
		investigate_log("was brought offline and there is now no gravity for this level.", INVESTIGATE_GRAVITY)
		message_admins("The gravity generator was brought offline with no backup generator. (<A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>[src_area.name]</a>)")
		for(var/area/A in world)
			if((A.type in areas) && A.z == z)
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
	radiation_pulse(src, 2400, BETA_RAD)
	for(var/mob/living/L in view(7, src)) //Windows kinda make it a non threat, no matter how much I amp it up, so let us cheat a little
		radiation_pulse(get_turf(L), 2400, BETA_RAD)

/**
  * Shake everyone on the area list and play an alarm to let them know that gravity was enagaged/disenagaged.
  */
/obj/machinery/gravity_generator/main/proc/shake_everyone()
	var/turf/our_turf = get_turf(src)
	new /obj/effect/warp_effect/gravity_generator(our_turf)
	var/sound/alert_sound = sound('sound/effects/alert.ogg')
	for(var/shaken in GLOB.mob_list)
		var/mob/M = shaken
		var/turf/their_turf = get_turf(M)
		if(their_turf && ((get_area(their_turf)).type in typesof(parent_area_type)) && (M.z == z))
			M.update_gravity(M.mob_has_gravity())
			if(M.client)
				shake_camera(M, 15, 1)
				M.playsound_local(our_turf, null, 100, TRUE, 0.5, S = alert_sound)

/obj/machinery/gravity_generator/main/proc/update_gen_list()
	if(parent_area_type)
		if(!GLOB.gravity_generators["[parent_area_type]"])
			GLOB.gravity_generators["[parent_area_type]"] = list()
		if(on)
			GLOB.gravity_generators["[parent_area_type]"] |= src
		else
			GLOB.gravity_generators["[parent_area_type]"] -= src

/obj/machinery/gravity_generator/main/proc/generators_in_area()
	if(!parent_area_type)
		return FALSE
	if(GLOB.gravity_generators["[parent_area_type]"])
		return length(GLOB.gravity_generators["[parent_area_type]"])
	return FALSE

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
