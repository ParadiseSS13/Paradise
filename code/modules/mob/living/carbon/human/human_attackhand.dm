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
		if("help")
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				add_logs(src, M, "shaked")
				return 1
//			if(M.health < -75)	return 0

			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
				M << "\blue <B>Remove your mask!</B>"
				return 0
			if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
				M << "\blue <B>Remove his mask!</B>"
				return 0

			var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
			O.source = M
			O.target = src
			O.s_loc = M.loc
			O.t_loc = loc
			O.place = "CPR"
			requests += O
			spawn(0)
				O.process()
			add_logs(src, M, "CPRed")
			return 1

		if("grab")
			if(attacker_style && attacker_style.grab_act(H, src))
				return 1
			else
				src.grabbedby(M)
				return 1

		if("harm")
			if(attacker_style && attacker_style.harm_act(H, src))
				return 1
			else
				var/datum/unarmed_attack/attack = M.species.unarmed

				//Vampire code
				if(M.zone_sel && M.zone_sel.selecting == "head" && src != M)
					if(M.mind && M.mind.vampire && (M.mind in ticker.mode.vampires) && !M.mind.vampire.draining)
						if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
							M << "\red Remove their mask!"
							return 0
						if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
							M << "\red Remove your mask!"
							return 0
						if(mind && mind.vampire && (mind in ticker.mode.vampires))
							M << "\red Your fangs fail to pierce [src.name]'s cold flesh"
							return 0
						if(SKELETON in mutations)
							M << "\red There is no blood in a skeleton!"
							return 0
						//we're good to suck the blood, blaah
						M.handle_bloodsucking(src)
						add_logs(src, M, "vampirebit")
						message_admins("[M.name] ([M.ckey]) vampirebit [src.name] ([src.ckey])")
						return
				//end vampire codes

				M.do_attack_animation(src)
				add_logs(src, M, "[pick(attack.attack_verb)]ed")

				if(!iscarbon(M))
					LAssailant = null
				else
					LAssailant = M

				var/damage = rand(0, M.species.max_hurt_damage)//BS12 EDIT
				damage += attack.damage
				if(!damage)
					playsound(loc, attack.miss_sound, 25, 1, -1)
					visible_message("\red <B>[M] tried to [pick(attack.attack_verb)] [src]!</B>")
					return 0


				var/obj/item/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
				var/armor_block = run_armor_check(affecting, "melee")

				if(HULK in M.mutations)
					damage += 5
					Weaken(4)

				playsound(loc, attack.attack_sound, 25, 1, -1)

				visible_message("\red <B>[M] [pick(attack.attack_verb)]ed [src]!</B>")

				apply_damage(damage, BRUTE, affecting, armor_block, sharp=attack.sharp, edge=attack.edge) //moving this back here means Armalis are going to knock you down  70% of the time, but they're pure adminbus anyway.
				if((stat != DEAD) && damage >= 9)
					visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
									"<span class='userdanger'>[M] has weakened [src]!</span>")
					apply_effect(4, WEAKEN, armor_block)
					forcesay(hit_appends)
				else if(lying)
					forcesay(hit_appends)


		if("disarm")
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

	/*			if(randn <= 45 && !lying)
					if(head)
						var/obj/item/clothing/head/H = head
						if(!istype(H) || prob(H.loose))
							if(unEquip(H))
								if(prob(60))
									step_away(H,M)
								visible_message("<span class='warning'>[M] has knocked [src]'s [H] off!</span>",
												"<span class='warning'>[M] knocked \the [H] clean off your head!</span>") */

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