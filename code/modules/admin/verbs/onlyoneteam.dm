/client/proc/only_one_team()
	if(!SSticker)
		alert("The game hasn't started yet!")
		return

	var/list/incompatible_species = list(/datum/species/plasmaman, /datum/species/vox)
	var/team_toggle = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		if(is_special_character(H))
			continue
		if(is_type_in_list(H.dna.species, incompatible_species))
			H.set_species(/datum/species/human)
			var/datum/character_save/S = new	// Randomize appearance
			S.randomise()
			S.copy_to(H)

		for(var/obj/item/I in H)
			if(istype(I, /obj/item/implant))
				continue
			qdel(I)

		to_chat(H, "<B>You are part of the [station_name()] dodgeball tournament. Throw dodgeballs at crewmembers wearing a different color than you. OOC: Use THROW on an EMPTY-HAND to catch thrown dodgeballs.</B>")

		H.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/beach_ball/dodgeball_team(H), slot_r_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)

		if(!team_toggle)
			GLOB.team_alpha += H

			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red/dodgeball(H), slot_w_uniform)
			var/obj/item/card/id/W = new(H)
			W.name = "[H.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Professional Pee-Wee League Dodgeball Player"
			W.registered_name = H.real_name
			H.equip_to_slot_or_del(W, slot_wear_id)

		else
			GLOB.team_bravo += H

			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue/dodgeball(H), slot_w_uniform)
			var/obj/item/card/id/W = new(H)
			W.name = "[H.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Professional Pee-Wee League Dodgeball Player"
			W.registered_name = H.real_name
			H.equip_to_slot_or_del(W, slot_wear_id)

		team_toggle = !team_toggle
		H.dna.species.after_equip_job(null, H)
		H.regenerate_icons()

	message_admins("[key_name_admin(usr)] used DODGEBAWWWWWWWL! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used dodgeball.")
	GLOB.nologevent = 1

/obj/item/beach_ball/dodgeball_team
	name = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games."
	icon = 'icons/obj/basketball.dmi'
	icon_state = "dodgeball"
	item_state = "dodgeball"
	dribbleable = TRUE

/obj/item/beach_ball/dodgeball_team/throw_impact(atom/hit_atom)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/human/H = hit_atom
		if(H.r_hand == src)
			return
		if(H.l_hand == src)
			return
		var/mob/A = locateUID(thrownby)
		if((H in GLOB.team_alpha) && (A in GLOB.team_alpha))
			to_chat(A, "<span class='warning'>He's on your team!</span>")
			return
		else if((H in GLOB.team_bravo) && (A in GLOB.team_bravo))
			to_chat(A, "<span class='warning'>He's on your team!</span>")
			return
		else if(!(A in GLOB.team_alpha) && !(A in GLOB.team_bravo))
			to_chat(A, "<span class='warning'>You're not part of the dodgeball game, sorry!</span>")
			return
		else
			playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
			visible_message("<span class='danger'>[H] HAS BEEN ELIMINATED!</span>")
			H.melt()
