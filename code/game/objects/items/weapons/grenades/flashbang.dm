/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	belt_icon = "flashbang"
	origin_tech = "materials=2;combat=3"
	light_power = 10
	light_color = LIGHT_COLOR_WHITE

	var/light_time = 0.2 SECONDS // The duration the area is illuminated
	var/range = 7 // The range in tiles of the flashbang

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
	var/source_turf = get_turf(A)
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
		var/ear_safety = M.check_ear_prot()
		if(bang)
			if(source_turf == mobturf) // Holding on person or being exactly where lies is significantly more dangerous and voids protection
				M.KnockDown(10 SECONDS)
			if(!ear_safety)
				M.KnockDown(status_duration)
				M.Deaf(30 SECONDS)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
					if(istype(ears))
						ears.receive_damage(5)
						if(ears.damage >= 15)
							to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
							if(prob(ears.damage - 5))
								to_chat(M, "<span class='warning'>You can't hear anything!</span>")
						else if(ears.damage >= 5)
							to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
