/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	switch(M.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if(I_GRAB)
			grabbedby(M)

		if(I_HARM)
			M.do_attack_animation(src)
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>")
				return 0

			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, affecting, armor_block)
			if(damage >= 25)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
			updatehealth()

		if(I_DISARM)
			M.do_attack_animation(src)
			if(prob(80))
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				apply_effect(5, WEAKEN, run_armor_check(affecting, "melee"))
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>")
			else
				if(prob(99)) //this looks fucking stupid but it was previously 'var/randn = rand(1, 100); if(randn <= 99)'
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>")