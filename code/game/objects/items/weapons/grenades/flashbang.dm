/obj/item/grenade/flashbang
	name = "flashbang"
	desc = "A less-than-lethal grenade designed for crowd control. Blinds all unprotected targets in range and disrupts their balance, sending them falling to the floor."
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	belt_icon = "flashbang"
	origin_tech = "materials=2;combat=3"
	light_power = 10
	light_color = LIGHT_COLOR_WHITE

	/// The duration the area is illuminated.
	var/light_time = 0.2 SECONDS
	/// The range in tiles of the flashbang.
	var/range = 7

/obj/item/grenade/flashbang/prime()
	update_mob()
	var/turf/T = get_turf(src)
	if(T)
		// VFX and SFX
		do_sparks(rand(5, 9), FALSE, src)
		playsound(T, 'sound/effects/bang.ogg', 100, TRUE)
		new /obj/effect/dummy/lighting_obj(T, light_color, range + 2, light_power, light_time)
		// Blob damage
		for(var/obj/structure/blob/B in hear(range + 1, T))
			var/damage = round(30 / (get_dist(B, T) + 1))
			B.take_damage(damage, BURN, MELEE, FALSE)

		// Stunning & damaging mechanic
		bang(T, src, range)
	qdel(src)

/obj/item/grenade/flashbang/screwdriver_act(mob/living/user, obj/item/I)
	switch(det_time)
		if(0.1 SECONDS)
			det_time = 3 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for 3 second detonation time.</span>")
		if(3 SECONDS)
			det_time = 5 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for 5 second detonation time.</span>")
		if(5 SECONDS)
			det_time = 0.1 SECONDS
			to_chat(user, "<span class='notice'>You set [src] for instant detonation.</span>")
	add_fingerprint(user)
	return TRUE

/**
  * Creates a flashing effect that blinds and deafens mobs within range
  *
  * Arguments:
  * * T - The turf to flash
  * * A - The flashing atom
  * * range - The range in tiles of the flash
  * * flash - Whether to flash (blind)
  * * bang - Whether to bang (deafen)
  */
/proc/bang(turf/T, atom/A, range = 7, flash = TRUE, bang = TRUE)

	// Flashing mechanic
	var/turf/source_turf = get_turf(A)
	for(var/mob/living/M in hearers(range, T))
		if(M.stat == DEAD)
			continue
		M.show_message("<span class='warning'>BANG</span>", 2)
		var/mobturf = get_turf(M)

		var/distance = max(1, get_dist(source_turf, mobturf))
		var/status_duration = max(10 SECONDS / distance, 4 SECONDS)

		// Flash
		if(flash)
			if(M.flash_eyes(affect_silicon = TRUE))
				M.Confused(status_duration * 2)

		// Bang
		if(!bang)
			continue
		var/ear_safety = M.check_ear_prot()
		//Atmosphere affects sound
		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = source_turf.get_readonly_air()
		var/datum/gas_mixture/source_env = T.get_readonly_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE - 10) //-10 KPA as a nice soft zone before we start losing power
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE) / (ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //space
			pressure_factor = 0

		if(distance <= 1)
			pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

		if(source_turf == mobturf) // Holding on person or being exactly where lies is significantly more dangerous and voids protection
			M.KnockDown(10 SECONDS)
			M.Deaf(15 SECONDS)
		if(ear_safety)
			continue
		M.KnockDown(status_duration * pressure_factor)
		M.Deaf(30 SECONDS * pressure_factor)
		if(!iscarbon(M))
			continue
		var/mob/living/carbon/C = M
		var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
		if(istype(ears))
			ears.receive_damage(5 * pressure_factor)
			if(ears.damage >= 15)
				to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
				if(prob(ears.damage - 5))
					to_chat(M, "<span class='warning'>You can't hear anything!</span>")
			else if(ears.damage >= 5)
				to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
