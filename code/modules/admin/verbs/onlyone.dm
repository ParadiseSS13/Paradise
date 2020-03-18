/client/proc/only_one()
	if(!SSticker)
		alert("The game hasn't started yet!")
		return

	var/list/incompatible_species = list(/datum/species/plasmaman, /datum/species/vox)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		if(is_special_character(H))
			continue
		if(is_type_in_list(H.dna.species, incompatible_species))
			H.set_species(/datum/species/human)
			var/datum/preferences/A = new()	// Randomize appearance
			A.copy_to(H)

		SSticker.mode.traitors += H.mind
		H.mind.special_role = SPECIAL_ROLE_TRAITOR

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		to_chat(H, "<B>You are a Highlander. Kill all other Highlanders. There can be only one.</B>")
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

		for(var/obj/item/I in H)
			if(istype(I, /obj/item/implant))
				continue
			if(istype(I, /obj/item/organ))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/claymore/highlander(H), slot_r_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/pinpointer(H.loc), slot_l_store)

		var/obj/item/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)
		H.dna.species.after_equip_job(null, H)
		H.regenerate_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ONE! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used there can be only one.")
	nologevent = 1
	world << sound('sound/music/thunderdome.ogg')

/client/proc/only_me()
	if(!SSticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		SSticker.mode.traitors += H.mind
		H.mind.special_role = "[H.real_name] Prime"

		var/datum/objective/hijackclone/hijack_objective = new /datum/objective/hijackclone
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		to_chat(H, "<B>You are the multiverse summoner. Activate your blade to summon copies of yourself from another universe to fight by your side.</B>")
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
			obj_count++

		var/obj/item/slot_item_ID = H.get_item_by_slot(slot_wear_id)
		qdel(slot_item_ID)
		var/obj/item/slot_item_hand = H.get_item_by_slot(slot_r_hand)
		H.unEquip(slot_item_hand)

		var /obj/item/multisword/pure_evil/multi = new(H)
		H.equip_to_slot_or_del(multi, slot_r_hand)

		var/obj/item/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Multiverse Summoner"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)

		H.update_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ME! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used there can be only me.")
	nologevent = 1
	world << sound('sound/music/thunderdome.ogg')
