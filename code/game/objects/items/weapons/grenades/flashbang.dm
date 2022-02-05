/obj/item/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
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
			B.take_damage(damage, BURN, "melee", FALSE)

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

		var/distance = max(1, get_dist(source_turf, get_turf(M)))
		var/stun_amount = max(4 / distance, 3)

		// Flash
		if(flash)
			if(M.weakeyes)
				M.visible_message("<span class='disarm'><b>[M]</b> screams and collapses!</span>")
				to_chat(M, "<span class='userdanger'><font size=3>AAAAGH!</font></span>")
				M.Weaken(15) //hella stunned
				M.Stun(15)
				if(ishuman(M))
					M.emote("scream")
					var/mob/living/carbon/human/H = M
					var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
					if(E)
						E.receive_damage(8, TRUE)
			if(M.flash_eyes(affect_silicon = TRUE))
				M.Stun(stun_amount)
				M.Weaken(stun_amount)

		// Bang
		var/ear_safety = M.check_ear_prot()
		if(bang)
			if(!distance || A.loc == M || A.loc == M.loc) // Holding on person or being exactly where lies is significantly more dangerous and voids protection
				M.Stun(10)
				M.Weaken(10)
			if(!ear_safety)
				M.Stun(stun_amount)
				M.Weaken(stun_amount)
				M.AdjustEarDamage(rand(0, 5), 15)
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
					if(istype(ears))
						if(ears.ear_damage >= 15)
							to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
							if(prob(ears.ear_damage - 5))
								to_chat(M, "<span class='warning'>You can't hear anything!</span>")
								M.BecomeDeaf()
						else if(ears.ear_damage >= 5)
							to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
