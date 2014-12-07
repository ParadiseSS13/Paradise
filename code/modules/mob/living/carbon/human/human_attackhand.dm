/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	var/datum/organ/external/temp = M:organs_by_name["r_hand"]
	if (M.hand)
		temp = M:organs_by_name["l_hand"]
	if(temp && !temp.is_usable())
		M << "\red You can't use your [temp.display_name]."
		return

	..()

	if((M != src) && check_shields(0, M.name))
		add_logs(src, M, "attempted to touch")
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing/hologlove))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[M] has attempted to punch [src]!</B>")
				return 0
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(M_HULK in M.mutations)			damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[M] has punched [src]!</B>")

			apply_damage(damage, HALLOSS, affecting, armor_block)
			if(damage >= 9)
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)

			return
	else
		if(istype(M,/mob/living/carbon))
//      log_debug("No gloves, [M] is truing to infect [src]")
			M.spread_disease_to(src, "Contact")

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
			if(M == src || anchored)
				return 0
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			if(buckled)
				M << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
			if(!G)  //the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			add_logs(src, M, "grabbed", addition="passively")
			return 1

		if("harm")
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

			add_logs(src, M, "[pick(attack.attack_verb)]ed")

			if(!iscarbon(M))
				LAssailant = null
			else
				LAssailant = M

			var/damage = rand(0, M.species.max_hurt_damage)//BS12 EDIT
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1, -1)
				visible_message("\red <B>[M] tried to [pick(attack.attack_verb)] [src]!</B>")
				return 0


			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")

			if(M_HULK in M.mutations)			damage += 5


			playsound(loc, attack.attack_sound, 25, 1, -1)

			visible_message("\red <B>[M] [pick(attack.attack_verb)]ed [src]!</B>")
			//Rearranged, so claws don't increase weaken chance.
			if(damage >= 5 && prob(50))
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(2, WEAKEN, armor_block)

			damage += attack.damage
			apply_damage(damage, BRUTE, affecting, armor_block, sharp=attack.sharp, edge=attack.edge)


		if("disarm")
			add_logs(src, M, "disarmed")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/organ/external/affecting = get_organ(ran_zone(M.zone_sel.selecting))
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

			if(randn <= 45 && !lying)
				if(head)
					var/obj/item/clothing/head/H = head
					if(!istype(H) || prob(H.loose))
						drop_from_inventory(H)
						if(prob(60))
							step_away(H,M)
						visible_message("<span class='warning'>[M] has knocked [src]'s [H] off!</span>",
										"<span class='warning'>[M] knocked \the [H] clean off your head!</span>")

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
						del(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("\red <b>[M] has broken [src]'s grip on [rgrab.affecting]!</B>")
						talked = 1
					spawn(1)
						del(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					drop_item()
					visible_message("\red <B>[M] has disarmed [src]!</B>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return