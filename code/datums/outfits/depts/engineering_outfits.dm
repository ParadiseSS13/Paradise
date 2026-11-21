/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	uniform = /obj/item/clothing/under/rank/engineering/engineer
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/engineering
	l_pocket = /obj/item/t_scanner
	r_pocket = /obj/item/storage/bag/construction
	pda = /obj/item/pda/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel_eng
	dufflebag = /obj/item/storage/backpack/duffel/engineering
	box = /obj/item/storage/box/engineer
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/engineering)

/datum/outfit/job/engineer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_ELECTRICAL_SPECIALIST, JOB_TRAIT)

/datum/outfit/job/engineer/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[SUIT_LAYER] = preview_suit_icon(species, body_parts, null, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/engineer/preview_suit_icon(species, list/body_parts, datum/outfit/species_outfit = null, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	var/obj/item/clothing/suit/storage/hazardvest/staff/worn_item = new()
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	var/worn_icon = listgetindex(worn_item.sprite_sheets, species) || worn_item.worn_icon || 'icons/mob/clothing/suit.dmi'
	var/icon/final_icon = new /icon(worn_icon, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon

/datum/outfit/job/atmos
	name = "Life Support Specialist"
	jobtype = /datum/job/atmos

	uniform = /obj/item/clothing/under/rank/engineering/atmospheric_technician
	r_pocket = /obj/item/storage/bag/construction
	belt = /obj/item/storage/belt/utility/atmostech
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_eng
	id = /obj/item/card/id/atmostech
	pda = /obj/item/pda/atmos

	backpack = /obj/item/storage/backpack/industrial/atmos
	satchel = /obj/item/storage/backpack/satchel_atmos
	dufflebag = /obj/item/storage/backpack/duffel/atmos
	box = /obj/item/storage/box/engineer
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/atmospherics)

/datum/outfit/job/atmos/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_FIRE_FIGHTER, JOB_TRAIT)

/datum/outfit/job/atmos/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[SUIT_LAYER] = preview_suit_icon(species, body_parts, null, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/atmos/preview_suit_icon(species, list/body_parts, datum/outfit/species_outfit = null, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	var/obj/item/clothing/suit/fire/firefighter/atmos/worn_item = new()
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	var/worn_icon = listgetindex(worn_item.sprite_sheets, species) || worn_item.worn_icon || 'icons/mob/clothing/suit.dmi'
	var/icon/final_icon = new /icon(worn_icon, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon
