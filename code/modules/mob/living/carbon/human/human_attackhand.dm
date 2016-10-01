/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	if(frozen)
		to_chat(M, "\red Do not touch Admin-Frozen people.")
		return

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
		if(H.hand)
			temp = H.organs_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			to_chat(H, "<span class='warning'>You can't use your hand.</span>")
			return

	..()

	if((M != src) && M.a_intent != "help" && check_shields(0, M.name, attack_type = UNARMED_ATTACK))
		add_logs(M, src, "attempted to touch")
		visible_message("<span class='warning'>[M] attempted to touch [src]!</span>")
		return 0

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
				return 0
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations)
				damage += 5
				Weaken(4)

			playsound(loc, "punch", 25, 1, -1)

			visible_message("<span class='danger'>[M] has punched [src]!</span>")

			apply_damage(damage, STAMINA, affecting, armor_block)
			if(damage >= 9)
				visible_message("<span class='danger'>[M] has weakened [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)

			return

	var/datum/martial_art/attacker_style = M.martial_art

	species.handle_attack_hand(src,M)

	switch(M.a_intent)
		if(I_HELP)
			if(attacker_style && attacker_style.help_act(H, src))//adminfu only...
				return 1
			if(can_operate(src))
				if(health >= config.health_threshold_crit)
					if(src.surgeries.len)
						for(var/datum/surgery/S in src.surgeries)
							if(S.next_step(M, src))
								return 1
						help_shake_act(M)
						add_logs(M, src, "shaked")
						return 1
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				add_logs(M, src, "shaked")
				return 1
			if(!H.check_has_mouth())
				to_chat(H, "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>")
				return
			if(!check_has_mouth())
				to_chat(H, "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>")
				return
			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH) && !M.wear_mask.mask_adjusted))
				to_chat(M, "<span class='warning'>Remove your mask!</span>")
				return 0
			if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH) && !wear_mask.mask_adjusted))
				to_chat(M, "<span class='warning'>Remove his mask!</span>")
				return 0

			M.visible_message("<span class='danger'>\The [M] is trying to perform CPR on \the [src]!</span>", \
							  "<span class='danger'>You try to perform CPR on \the [src]!</span>")
			if(do_mob(M, src, 40))
				if(health > config.health_threshold_dead && health <= config.health_threshold_crit)
					var/suff = min(getOxyLoss(), 7)
					adjustOxyLoss(-suff)
					updatehealth()
					M.visible_message("<span class='danger'>\The [M] performs CPR on \the [src]!</span>", \
									  "<span class='notice'>You perform CPR on \the [src].</span>")

					to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
					to_chat(M, "<span class='alert'>Repeat at least every 7 seconds.")
					add_logs(M, src, "CPRed")
					return 1
			else
				to_chat(M, "<span class='danger'>You need to stay still while performing CPR!</span>")

		if(I_GRAB)
			if(attacker_style && attacker_style.grab_act(H, src))
				return 1
			else
				src.grabbedby(M)
				return 1

		if(I_HARM)
			//Vampire code
			if(M.mind && M.mind.vampire && (M.mind in ticker.mode.vampires) && !M.mind.vampire.draining && M.zone_sel && M.zone_sel.selecting == "head" && src != M)
				if(species && species.flags & NO_BLOOD)//why this hell were we never checkinf for this?
					to_chat(M, "<span class='warning'>They have no blood!</span>")
					return
				if(mind && mind.vampire && (mind in ticker.mode.vampires))
					to_chat(M, "<span class='warning'>Your fangs fail to pierce [src.name]'s cold flesh</span>")
					return
				if(SKELETON in mutations)
					to_chat(M, "<span class='warning'>There is no blood in a skeleton!</span>")
					return
				if(issmall(src) && !ckey) //Monkeyized humans are okay, humanized monkeys are okey, monkeys are not.
					to_chat(M, "<span class='warning'>Blood from a monkey is useless!</span>")
					return
				//we're good to suck the blood, blaah
				M.mind.vampire.handle_bloodsucking(src)
				add_logs(M, src, "vampirebit")
				msg_admin_attack("[key_name_admin(M)] vampirebit [key_name_admin(src)]")
				return
				//end vampire codes
			if(attacker_style && attacker_style.harm_act(H, src))
				return 1
			else
				var/datum/unarmed_attack/attack = M.species.unarmed

				M.do_attack_animation(src)
				add_logs(M, src, "[pick(attack.attack_verb)]ed")

				if(!iscarbon(M))
					LAssailant = null
				else
					LAssailant = M

				var/damage = rand(M.species.punchdamagelow, M.species.punchdamagehigh)
				damage += attack.damage
				if(!damage)
					playsound(loc, attack.miss_sound, 25, 1, -1)
					visible_message("<span class='danger'>[M] tried to [pick(attack.attack_verb)] [src]!</span>")
					return 0


				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				var/armor_block = run_armor_check(affecting, "melee")

				if(HULK in M.mutations)
					adjustBruteLoss(15)

				playsound(loc, attack.attack_sound, 25, 1, -1)

				visible_message("<span class='danger'>[M] [pick(attack.attack_verb)]ed [src]!</span>")

				apply_damage(damage, BRUTE, affecting, armor_block, sharp=attack.sharp, edge=attack.edge) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
				if((stat != DEAD) && damage >= M.species.punchstunthreshold)
					visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
									"<span class='userdanger'>[M] has weakened [src]!</span>")
					apply_effect(4, WEAKEN, armor_block)
					forcesay(hit_appends)
				else if(lying)
					forcesay(hit_appends)


		if(I_DISARM)
			if(attacker_style && attacker_style.disarm_act(H, src))
				return 1
			else
				add_logs(M, src, "disarmed")

				if(w_uniform)
					w_uniform.add_fingerprint(M)
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				var/randn = rand(1, 100)
				if(randn <= 25)
					apply_effect(2, WEAKEN, run_armor_check(affecting, "melee"))
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has pushed [src]!</span>")
					M.attack_log += text("\[[time_stamp()]\] <font color='red'>Pushed [src.name] ([src.ckey])</font>")
					src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been pushed by [M.name] ([M.ckey])</font>")
					if(!iscarbon(M))
						LAssailant = null
					else
						LAssailant = M

					log_attack("[M.name] ([M.ckey]) pushed [src.name] ([src.ckey])")
					return

				var/talked = 0	// BubbleWrap

				if(randn <= 60)
					//BubbleWrap: Disarming breaks a pull
					if(pulling)
						visible_message("<span class='danger'>[M] has broken [src]'s grip on [pulling]!</span>")
						talked = 1
						stop_pulling()

					//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
					if(istype(l_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/lgrab = l_hand
						if(lgrab.affecting)
							visible_message("<span class='danger'>[M] has broken [src]'s grip on [lgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(lgrab)
					if(istype(r_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/rgrab = r_hand
						if(rgrab.affecting)
							visible_message("<span class='danger'>[M] has broken [src]'s grip on [rgrab.affecting]!</span>")
							talked = 1
						spawn(1)
							qdel(rgrab)
					//End BubbleWrap

					if(!talked)	//BubbleWrap
						if(drop_item())
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>")
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] attempted to disarm [src]!</span>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return
