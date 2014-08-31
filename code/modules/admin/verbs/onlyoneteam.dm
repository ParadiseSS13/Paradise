/client/proc/only_one_team()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue



//		ticker.mode.traitors += H.mind


		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			del(I)

		H << "<B>You are part of the Cyberiad dodgeball tournament. Throw dodgeballs at crewmembers wearing a different color than you. OOC: Use THROW on an EMPTY-HAND to catch thrown dodgeballs.</B>"

		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_l_ear)
//		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/beach_ball/dodgeball(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)



		if(prob(50))
			team_alpha += H

			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red/dodgeball(H), slot_w_uniform)

			var/obj/item/weapon/card/id/W = new(H)
			W.name = "[H.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Professional Pee-Wee League Dodgeball Player"
			W.registered_name = H.real_name
			H.equip_to_slot_or_del(W, slot_wear_id)
			H.regenerate_icons()

		else
			team_bravo += H

			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue/dodgeball(H), slot_w_uniform)

			var/obj/item/weapon/card/id/W = new(H)
			W.name = "[H.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Professional Pee-Wee League Dodgeball Player"
			W.registered_name = H.real_name
			H.equip_to_slot_or_del(W, slot_wear_id)
			H.regenerate_icons()
	message_admins("\blue [key_name_admin(usr)] used DODGEBAWWWWWWWL! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	nologevent = 1
	log_admin("[key_name(usr)] used dodgeball.")
	world << sound('sound/music/nowyouman.ogg')

/obj/item/weapon/beach_ball/dodgeball
	name = "dodgeball"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "dodgeball"
	item_state = "basketball"
	desc = "Used for playing the most violent and degrading of childhood games."

/obj/item/weapon/beach_ball/dodgeball/throw_impact(atom/hit_atom)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/human/H = hit_atom
		if(src in H.r_hand) return
		if(src in H.l_hand) return
		var/mob/A = H.LAssailant
		if((H in team_alpha) && (A in team_alpha))
			A << "\red He's on your team!"
			return
		else if((H in team_bravo) && (A in team_bravo))
			A << "\red He's on your team!"
			return
		else if(!A in team_alpha && !A in team_bravo)
			A << "\red You're not part of the dodgeball game, sorry!"
			return
		else
			playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
			visible_message("\red [H] HAS BEEN ELIMINATED!!", 3)
			H.melt()
			return