/// Ion trails for jetpacks, ion thrusters and other space-flying things
/obj/effect/particle_effect/ion_trails
	name = "ion trails"
	icon_state = "ion_fade"

/obj/effect/particle_effect/ion_trails/Initialize(mapload, targetdir)
	. = ..()
	dir = targetdir
	QDEL_IN(src, 0.6 SECONDS)

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

		explosion(location, devastation, heavy, light, flash)

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
