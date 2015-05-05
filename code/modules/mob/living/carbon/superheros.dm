/datum/superheros
	var/name
	var/list/default_genes = list()
	var/list/default_spells = list()


/datum/superheros/proc/equip(var/mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, name)
	for(var/obj/item/W in H)
		if(istype(W,/obj/item/organ)) continue
		H.unEquip(W)

/datum/superheros/proc/assign_genes(var/mob/living/carbon/human/H)
	if(default_genes.len)
		for(var/gene in default_genes.len)
			H.mutations |= gene
		H.update_mutations()
	return

/datum/superheros/proc/assign_spells(var/mob/living/carbon/human/H)
	return


/datum/superheros/owlman
	name = "Owlman"
	default_genes = list(LASER, RESIST_COLD, RESIST_HEAT, REGEN, NO_BREATH)

/datum/superheros/owlman/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/owl(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask(H), slot_wear_mask)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Superhero)"
	W.access = get_all_accesses()
	W.assignment = "Superhero"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()


/datum/superheros/griffin
	name = "The Griffin"
	default_genes = list(LASER, RESIST_COLD, RESIST_HEAT, REGEN, NO_BREATH)

/datum/superheros/griffin/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/griffin(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/griffin(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings/griffinwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/griffin(H), slot_head)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Supervillain)"
	W.access = get_all_accesses()
	W.assignment = "Supervillain"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()

/*		Dont fill out until ready (sprites + powers)
/datum/superheros/lightnian
	name = "LightnIan"
*/
