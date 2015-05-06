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
		for(var/gene in default_genes)
			H.mutations |= gene
		H.update_mutations()
	return

/datum/superheros/proc/assign_spells(var/mob/living/carbon/human/H)
	if(default_spells.len)
		for(var/spell in default_spells)
			var/obj/effect/proc_holder/spell/wizard/S = spell
			if(!S) return
			H.spell_list += new S
			H.update_power_buttons()
	return


/datum/superheros/owlman
	name = "Owlman"
	default_genes = list(REGEN, NO_BREATH)

/datum/superheros/owlman/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/owl(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/owlwings(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/owl_mask(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/bluespace/owlman(H), slot_belt)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(H), slot_glasses)

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


/datum/superheros/lightnian
	name = "LightnIan"
	default_genes = list(REGEN, NO_BREATH)
	default_spells = list(/obj/effect/proc_holder/spell/wizard/targeted/lightning)

/datum/superheros/lightnian/equip(var/mob/living/carbon/human/H)
	..()

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/brown(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/corgisuit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/corgi(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(H), slot_gloves)

	var/obj/item/weapon/card/id/syndicate/W = new(H)
	W.name = "[H.real_name]'s ID Card (Superhero)"
	W.access = get_all_accesses()
	W.assignment = "Superhero"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, slot_wear_id)

	H.regenerate_icons()
