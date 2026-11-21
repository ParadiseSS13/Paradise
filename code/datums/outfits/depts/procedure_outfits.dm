/datum/outfit/job/judge
	name = "Magistrate"
	jobtype = /datum/job/judge
	uniform = /obj/item/clothing/under/rank/procedure/magistrate
	suit = /obj/item/clothing/suit/magirobe
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/heads/magistrate/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/magistrate
	l_pocket = /obj/item/flash
	r_pocket = /obj/item/clothing/accessory/legal_badge
	pda = /obj/item/pda/heads/magistrate
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/bar)

/datum/outfit/job/judge/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)
	ADD_TRAIT(H.mind, TRAIT_COFFEE_SNOB, JOB_TRAIT)

/datum/outfit/job/iaa
	name = "Internal Affairs Agent"
	jobtype = /datum/job/iaa
	uniform = /obj/item/clothing/under/rank/procedure/iaa
	suit = /obj/item/clothing/suit/storage/iaa/blackjacket
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/headset_iaa/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/internalaffairsagent
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/legal_badge/iaa
	l_hand = /obj/item/storage/briefcase
	pda = /obj/item/pda/iaa
	backpack_contents = list(
		/obj/item/flash = 1
	)
	bio_chips = list(/obj/item/bio_chip/mindshield)
	satchel = /obj/item/storage/backpack/satchel_sec
	dufflebag = /obj/item/storage/backpack/duffel/security
	species_outfits = list("Plasmaman" = /datum/outfit/plasmaman/bar)

/datum/outfit/job/iaa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/sop_legal)
	add_verb(H, /mob/living/carbon/human/proc/space_law)

	if(visualsOnly)
		return

	INVOKE_ASYNC(src, PROC_REF(give_gaze), H)

/datum/outfit/job/iaa/preview_layered_icon(species, body_parts, backpack_choice = GBACKPACK, monitor_head = FALSE)
	var/list/icon/icon_layers = ..()
	if(prob(1))
		icon_layers[SUIT_LAYER] = preview_suit_icon(species, body_parts, null, joke_item = TRUE)
	return icon_layers

/datum/outfit/job/iaa/preview_suit_icon(species, list/body_parts, datum/outfit/species_outfit = null, joke_item = FALSE)
	if(!joke_item && prob(99))
		return ..()
	var/obj/item/clothing/suit/worn_item = new suit()
	worn_item.suit_adjusted = !worn_item.suit_adjusted
	worn_item.update_icon(UPDATE_ICON_STATE)
	var/worn_icon_state = worn_item.worn_icon_state ? worn_item.worn_icon_state : worn_item.icon_state
	var/worn_icon = listgetindex(worn_item.sprite_sheets, species) || worn_item.worn_icon || 'icons/mob/clothing/suit.dmi'
	var/icon/final_icon = new /icon(worn_icon, worn_icon_state)
	if(worn_item.color)
		final_icon.Blend(worn_item.color, ICON_MULTIPLY)
	qdel(worn_item)
	return final_icon
