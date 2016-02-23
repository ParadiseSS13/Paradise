/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if(frozen)
		M << "\red Do not touch Admin-Frozen people."
		return

	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
		if (H.hand)
			temp = H.organs_by_name["l_hand"]
		if(!temp || !temp.is_usable())
			H << "\red You can't use your hand."
			return

	..()

	if((M != src) && check_shields(0, M.name))
		add_logs(src, M, "attempted to touch")
		M.do_attack_animation(src)
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[M] has attempted to punch [src]!</B>")
				return 0
			var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations)
				damage += 5
				Weaken(4)

			playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[M] has punched [src]!</B>")

			apply_damage(damage, STAMINA, affecting, armor_block)
			if(damage >= 9)
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)

			return
	else
		if(istype(M,/mob/living/carbon))
//      log_debug("No gloves, [M] is truing to infect [src]")
			M.spread_disease_to(src, "Contact")

	var/datum/martial_art/attacker_style = M.martial_art

	species.handle_attack_hand(src,M)

	switch(M.a_intent)
		if(I_HELP)
			if(can_operate(src))
				if(health >= config.health_threshold_crit)
					if(src.surgeries.len)
						for(var/datum/surgery/S in src.surgeries)
							if(istype(S.get_surgery_step(), /datum/surgery_step/cavity/place_item) || istype(S.get_surgery_step(),/datum/surgery_step/remove_object))
								if(S.next_step(M, src))
									return 1
							else
								help_shake_act(M)
								add_logs(src, M, "shaked")
								return 1
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				add_logs(src, M, "shaked")
				return 1
			if(!H.check_has_mouth())
				H << "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>"
				return
			if(!check_has_mouth())
				H << "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>"
				return
			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH) && !M.wear_mask.mask_adjusted))
				M << "<span class='warning'>Remove your mask!</span>"
				return 0
			if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH) && !wear_mask.mask_adjusted))
				M << "<span class='warning'>Remove his mask!</span>"
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

					src << "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>"
					M << "<span class='alert'>Repeat at least every 7 seconds."
					add_logs(src, M, "CPRed")
					return 1
			else
				M << "<span class='danger'>You need to stay still while performing CPR!</span>"

		if(I_GRAB)
			if(attacker_style && attacker_style.grab_act(H, src))
				return 1
			else
				src.grabbedby(M)
				return 1

		if(I_HARM)
			if(attacker_style && attacker_style.harm_act(H, src))
				return 1
			else
				var/datum/unarmed_attack/attack = M.species.unarmed

				//Vampire code
				if(M.zone_sel && M.zone_sel.selecting == "head" && src != M)
					if(M.mind && M.mind.vampire && (M.mind in ticker.mode.vampires) && !M.mind.vampire.draining)
						if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
							M << "<span class='warning'>Remove their mask!</span>"
							return 0
						if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
							M << "<span class='warning'>Remove your mask!</span>"
							return 0
						if(mind && mind.vampire && (mind in ticker.mode.vampires))
							M << "<span class='warning'>Your fangs fail to pierce [src.name]'s cold flesh</span>"
							return 0
						if(SKELETON in mutations)
							M << "<span class='warning'>There is no blood in a skeleton!</span>"
							return 0
						if(issmall(src) && !ckey) //Monkeyized humans are okay, humanized monkeys are okey, monkeys are not.
							M << "<span class='warning'>Blood from a monkey is useless!</span>"
							return 0
						//we're good to suck the blood, blaah
						M.handle_bloodsucking(src)
						add_logs(src, M, "vampirebit")
						msg_admin_attack("[key_name_admin(M)] vampirebit [key_name_admin(src)]")
						return
				//end vampire codes

				M.do_attack_animation(src)
				add_logs(src, M, "[pick(attack.attack_verb)]ed")

				if(!iscarbon(M))
					LAssailant = null
				else
					LAssailant = M

				var/damage = rand(M.species.punchdamagelow, M.species.punchdamagehigh)
				damage += attack.damage
				if(!damage)
					playsound(loc, attack.miss_sound, 25, 1, -1)
					visible_message("\red <B>[M] tried to [pick(attack.attack_verb)] [src]!</B>")
					return 0


				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				var/armor_block = run_armor_check(affecting, "melee")

				if(HULK in M.mutations)
					adjustBruteLoss(15)

				playsound(loc, attack.attack_sound, 25, 1, -1)

				visible_message("\red <B>[M] [pick(attack.attack_verb)]ed [src]!</B>")

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
				add_logs(src, M, "disarmed")

				if(w_uniform)
					w_uniform.add_fingerprint(M)
				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				var/randn = rand(1, 100)
				if (randn <= 25)
					apply_effect(2, WEAKEN, run_armor_check(affecting, "melee"))
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("\red <B>[M] has pushed [src]!</B>")
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
						visible_message("\red <b>[M] has broken [src]'s grip on [pulling]!</B>")
						talked = 1
						stop_pulling()

					//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
					if(istype(l_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/lgrab = l_hand
						if(lgrab.affecting)
							visible_message("\red <b>[M] has broken [src]'s grip on [lgrab.affecting]!</B>")
							talked = 1
						spawn(1)
							qdel(lgrab)
					if(istype(r_hand, /obj/item/weapon/grab))
						var/obj/item/weapon/grab/rgrab = r_hand
						if(rgrab.affecting)
							visible_message("\red <b>[M] has broken [src]'s grip on [rgrab.affecting]!</B>")
							talked = 1
						spawn(1)
							qdel(rgrab)
					//End BubbleWrap

					if(!talked)	//BubbleWrap
						if(drop_item())
							visible_message("\red <B>[M] has disarmed [src]!</B>")
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return