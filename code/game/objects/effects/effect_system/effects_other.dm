/datum/effect_system/trail_follow
	var/turf/oldposition
	var/active = FALSE
	var/allow_overlap = FALSE
	var/auto_process = TRUE
	var/qdel_in_time = 10
	var/nograv_required = FALSE

/datum/effect_system/trail_follow/set_up(atom/atom)
	attach(atom)
	oldposition = get_turf(atom)

/datum/effect_system/trail_follow/Destroy()
	oldposition = null
	stop()
	return ..()

/datum/effect_system/trail_follow/proc/stop()
	oldposition = null
	STOP_PROCESSING(SSfastprocess, src)
	active = FALSE
	return TRUE

/datum/effect_system/trail_follow/start()
	oldposition = get_turf(holder)
	if(!check_conditions())
		return FALSE
	if(auto_process)
		START_PROCESSING(SSfastprocess, src)
	active = TRUE
	return TRUE

/datum/effect_system/trail_follow/process()
	generate_effect()

/datum/effect_system/trail_follow/generate_effect()
	if(!check_conditions())
		return stop()
	if(oldposition && !(oldposition == get_turf(holder)))
		if(!has_gravity(oldposition) || !nograv_required)
			var/obj/effect/E = new effect_type(oldposition)
			set_dir(E)
			if(qdel_in_time)
				QDEL_IN(E, qdel_in_time)
	oldposition = get_turf(holder)

/datum/effect_system/trail_follow/proc/check_conditions()
	if(!get_turf(holder))
		return FALSE
	return TRUE

/// Ion trails for jetpacks, ion thrusters and other space-flying things
/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_fade"

/obj/effect/particle_effect/ion_trails/Initialize(mapload, targetdir)
	. = ..()
	dir = targetdir
	QDEL_IN(src, 0.6 SECONDS)

/datum/effect_system/trail_follow/ion
	effect_type = /obj/effect/particle_effect/ion_trails
	nograv_required = TRUE
	qdel_in_time = 20

/datum/effect_system/trail_follow/proc/set_dir(obj/effect/particle_effect/ion_trails/I)
	I.setDir(holder.dir)

/datum/effect_system/trail_follow/ion/grav_allowed
	nograv_required = FALSE

//Reagent-based explosion effect
/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

/datum/effect_system/reagents_explosion/set_up(amt, loca, flash = 0, flash_fact = 0)
	amount = amt
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	flashing = flash
	flashing_factor = flash_fact


/datum/effect_system/reagents_explosion/start()
	if(amount <= 2)
		do_sparks(2, 1, location)

		for(var/mob/M in viewers(5, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")
		for(var/mob/living/L in viewers(1, location))
			if(prob(50 * amount))
				to_chat(L, "<span class='warning'>The explosion knocks you down.</span>")
				L.Weaken(rand(2 SECONDS, 10 SECONDS))
		return
	else
		var/devastation = -1
		var/heavy = -1
		var/light = -1
		var/flash = -1

		// We dont need to clamp here. It gets clamped inside explosion()
		if(round(amount/12) > 0)
			devastation += round(amount/12)

		if(round(amount/6) > 0)
			heavy += round(amount/6)

		if(round(amount/3) > 0)
			light += round(amount/3)

		if(flashing && flashing_factor)
			flash += (round(amount/4) * flashing_factor)

		for(var/mob/M in viewers(8, location))
			to_chat(M, "<span class='warning'>The solution violently explodes.</span>")

		explosion(location, devastation, heavy, light, flash, cause = "Reagents Explosion")

/datum/effect_system/reagents_explosion/proc/holder_damage(atom/holder)
	if(holder)
		var/dmglevel = 4

		if(round(amount/8) > 0)
			dmglevel = 1
		else if(round(amount/4) > 0)
			dmglevel = 2
		else if(round(amount/2) > 0)
			dmglevel = 3

		if(dmglevel<4)
			holder.ex_act(dmglevel)
