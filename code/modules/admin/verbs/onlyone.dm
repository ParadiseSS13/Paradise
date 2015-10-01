/client/proc/only_one()
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

		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = H.mind
		H.mind.objectives += hijack_objective

		H << "<B>You are a Highlander. Kill all other Highlanders. There can be only one.</B>"
		var/obj_count = 1
		for(var/datum/objective/OBJ in H.mind.objectives)
			H << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/weapon/implant))
				continue
			if(istype(I, /obj/item/organ))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), slot_r_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/pinpointer(H.loc), slot_l_store)

		var/obj/item/weapon/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, slot_wear_id)
		H.species.equip(H)
		H.regenerate_icons()

	message_admins("[key_name_admin(usr)] used THERE CAN BE ONLY ONE! -NO ATTACK LOGS WILL BE SENT TO ADMINS FROM THIS POINT FORTH-", 1)
	log_admin("[key_name(usr)] used there can be only one.")
	nologevent = 1
