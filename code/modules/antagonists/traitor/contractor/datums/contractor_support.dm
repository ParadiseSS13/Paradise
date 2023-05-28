/datum/antagonist/contractor_support
	name = "Contractor Support Unit"
	roundend_category = "Contractor Support"

/datum/antagonist/contractor_support/on_gain()
	var/datum/objective/generic_objective = new

	generic_objective.explanation_text = "Выполняйте приказы, получаемые от назначенного вам контрактника. Помогайте другим агентам в этом районе миссии.<br>"
	generic_objective.completed = TRUE

	objectives += generic_objective
	update_contractor_support_icons()
	SSticker.mode.support += owner
	return ..()

/datum/antagonist/contractor_support/proc/update_contractor_support_icons()
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current, null)
	set_antag_hud(owner.current, "hudsupport")


/datum/outfit/contractor_partner
	name = "Contractor Support Unit"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	mask = /obj/item/clothing/mask/cigarette/syndicate
	back = /obj/item/storage/backpack
	pda = /obj/item/pda/chameleon
	belt = /obj/item/storage/belt/utility/full/multitool
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/syndicate
	r_pocket = /obj/item/restraints/handcuffs/cable

	backpack_contents = list(
		/obj/item/storage/box/survival_syndi = 1,
		/obj/item/clothing/mask/chameleon = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter = 1,
		/obj/item/melee/baton/cattleprod = 1,
		/obj/item/stock_parts/cell/super = 1
	)
/datum/outfit/contractor_partner/post_equip(mob/living/carbon/human/partner, visualsOnly)
	. = ..()
	var/obj/item/clothing/mask/cigarette/syndicate/cig = partner.get_item_by_slot(slot_wear_mask)
	cig.light()

	var/obj/item/card/id/I = partner.wear_id
	if(istype(I))
		apply_to_card(I, partner, get_syndicate_access("Syndicate Agent"), name)



