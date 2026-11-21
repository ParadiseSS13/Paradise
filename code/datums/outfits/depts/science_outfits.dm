/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	uniform = /obj/item/clothing/under/rank/rnd/scientist
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/research
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/science)

/datum/outfit/job/scientist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CRAFTY, JOB_TRAIT)

/datum/outfit/job/scientist/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[HEAD_LAYER] = preview_head_icon(species, body_parts, null, monitor_head, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/scientist/preview_head_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	return new /icon('icons/mob/clothing/head.dmi', "metroid")

/datum/outfit/job/xenobiologist
	name = "Xenobiologist"
	jobtype = /datum/job/xenobiologist

	uniform = /obj/item/clothing/under/rank/rnd/scientist
	r_pocket = /obj/item/storage/bag/bio
	suit = /obj/item/clothing/suit/storage/labcoat/science
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	glasses = /obj/item/clothing/glasses/science
	l_ear = /obj/item/radio/headset/headset_xenobio
	id = /obj/item/card/id/xenobiology
	pda = /obj/item/pda/toxins

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel_tox
	dufflebag = /obj/item/storage/backpack/duffel/science

	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/clipboard = 1,
	)

/datum/outfit/job/xenobiologist/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(50))
		icon_layers[FACEMASK_LAYER] = preview_mask_icon(species, body_parts, null, monitor_head, joke_item = TRUE)
	if(prob(1))
		icon_layers[HEAD_LAYER] = preview_head_icon(species, body_parts, null, monitor_head, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/xenobiologist/preview_mask_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE, joke_item = FALSE)
	if(!joke_item && prob(50))
		return ..()
	var/obj/item/clothing/mask/surgical/worn_item = new()
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	var/worn_icon = listgetindex(worn_item.sprite_sheets, species) || (monitor_head ? worn_item.icon_monitor : FALSE) || worn_item.worn_icon || 'icons/mob/clothing/mask.dmi'
	var/icon/final_icon = new /icon(worn_icon, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon

/datum/outfit/job/xenobiologist/preview_head_icon(species, list/body_parts, datum/outfit/species_outfit = null, monitor_head = FALSE, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	return new /icon('icons/mob/clothing/head.dmi', "metroid")

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/storage/labcoat/robowhite
	belt = /obj/item/storage/belt/utility/full
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/roboticist
	pda = /obj/item/pda/roboticist

	backpack = /obj/item/storage/backpack/robotics
	satchel = /obj/item/storage/backpack/satchel_robo
	dufflebag = /obj/item/storage/backpack/duffel/robotics
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/robotics)

/datum/outfit/job/roboticist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_CYBORG_SPECIALIST, JOB_TRAIT)

/datum/outfit/job/roboticist/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[R_HAND_LAYER] = preview_r_hand_icon(species, body_parts, null, joke_item = TRUE) || 'icons/blanks/32x32.dmi'
	return icon_layers

/datum/outfit/job/roboticist/preview_r_hand_icon(species, list/body_parts, datum/outfit/species_outfit = null, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	if(!("r_hand" in body_parts))
		return null
	var/obj/item/storage/toolbox/mechanical/worn_item = new()
	var/worn_icon_state = worn_item.inhand_icon_state ? worn_item.inhand_icon_state : worn_item.icon_state
	var/icon/final_icon
	if(species in worn_item.sprite_sheets_inhand)
		final_icon = new /icon(worn_item.sprite_sheets_inhand[species], "[worn_icon_state]_r")
	else
		final_icon = new /icon(worn_item.righthand_file, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon

/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_sci
	id = /obj/item/card/id/geneticist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/geneticist

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel_gen
	dufflebag = /obj/item/storage/backpack/duffel/genetics
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/genetics)

/datum/outfit/job/geneticist/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	ADD_TRAIT(H.mind, TRAIT_GENETIC_BUDGET, JOB_TRAIT)

/datum/outfit/job/geneticist/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[SUIT_LAYER] = preview_suit_icon(species, body_parts, null, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/geneticist/preview_suit_icon(species, list/body_parts, datum/outfit/species_outfit = null, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	var/obj/item/clothing/suit/monkeysuit/worn_item = new()
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	var/worn_icon = listgetindex(worn_item.sprite_sheets, species) || worn_item.worn_icon || 'icons/mob/clothing/suit.dmi'
	var/icon/final_icon = new /icon(worn_icon, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon
