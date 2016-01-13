/client/proc/only_one_team()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	var/list/incompatible_species = list("Plasmaman")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		if(is_special_character(H))
			continue
		if(H.species.name in incompatible_species)
			H.set_species("Human")
			var/datum/preferences/A = new()	// Randomize appearance
			A.copy_to(H)

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			if(istype (I, /obj/item/organ))
				continue
			qdel(I)

		H << "<B>You are part of the [station_name()] dodgeball tournament. Throw dodgeballs at crewmembers wearing a different color than you. OOC: Use THROW on an EMPTY-HAND to catch thrown dodgeballs.</B>"

		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/weapon/beach_ball/dodgeball(H), slot_r_hand)
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

		H.species.equip(H)
		H.regenerate_icons()

	message_admins("[key_name_admin(usr)] used DODGEBAWWWWWWWL! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used dodgeball.")
	nologevent = 1

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
		if(H.r_hand == src) return
		if(H.l_hand == src) return
		var/mob/A = H.LAssailant
		if((H in team_alpha) && (A in team_alpha))
			A << "<span class='warning'>He's on your team!</span>"
			return
		else if((H in team_bravo) && (A in team_bravo))
			A << "<span class='warning'>He's on your team!</span>"
			return
		else if(!A in team_alpha && !A in team_bravo)
			A << "<span class='warning'>You're not part of the dodgeball game, sorry!</span>"
			return
		else
			playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
			visible_message("<span class='danger'>[H] HAS BEEN ELIMINATED!</span>")
			H.melt()
			return
