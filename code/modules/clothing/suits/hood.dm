//Hoods for winter coats and dark robes etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle)
	var/obj/item/clothing/head/hooded/hood
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	/// If this variable is true, the hood can not be removed if the hood is nodrop
	var/respects_nodrop = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	MakeHood()

/obj/item/clothing/suit/hooded/Destroy()
	QDEL_NULL(hood)
	. = ..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/hooded/W = new hoodtype(src)
		W.suit = src
		hood = W

/obj/item/clothing/suit/hooded/clean_blood(radiation_clean)
	. = ..()
	hood.clean_blood()

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_OUTER_SUIT)
		return 1

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != ITEM_SLOT_OUTER_SUIT)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	if(isnull(hood))
		return
	icon_state = "[initial(icon_state)]"
	suit_adjusted = 0
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.transfer_item_to(hood, src, force = TRUE)
		H.update_inv_wear_suit()
	else
		hood.forceMove(src)
	update_action_buttons()

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(!suit_adjusted)
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.wear_suit != src)
				to_chat(H,"<span class='warning'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H,"<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(hood, ITEM_SLOT_HEAD, FALSE, FALSE))
				suit_adjusted = 1
				icon_state = "[initial(icon_state)]_hood"
				H.update_inv_wear_suit()
				update_action_buttons()
	else
		if((hood?.flags & NODROP) && respects_nodrop)
			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				to_chat(H, "<span class='warning'>[hood] is stuck to your head!</span>")
			return
		RemoveHood()

/obj/item/clothing/head/hooded
	var/obj/item/clothing/suit/hooded/suit

/obj/item/clothing/head/hooded/Destroy()
	suit = null
	return ..()

/obj/item/clothing/head/hooded/dropped()
	..()
	if(suit)
		suit.RemoveHood()

/obj/item/clothing/head/hooded/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHood()
		else
			qdel(src)

/obj/item/clothing/head/hooded/screened_niqab
	name = "screened niqab"
	desc = "A niqab with an eye mesh for additional concealment. The wearer can see you, but you can't see them."
	icon_state = "abaya_hood"
	cold_protection = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS | HIDEMASK | HIDEFACE | HIDEEYES
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
		)

/obj/item/clothing/head/hooded/screened_niqab/red
	name = "red niqab"
	icon_state = "redabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/orange
	name = "orange niqab"
	icon_state = "orangeabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/yellow
	name = "yellow niqab"
	icon_state = "yellowabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/green
	name = "green niqab"
	icon_state = "greenabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/blue
	name = "blue niqab"
	icon_state = "blueabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/purple
	name = "purple niqab"
	icon_state = "purpleabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/white
	name = "white niqab"
	icon_state = "whiteabaya_hood"

/obj/item/clothing/head/hooded/screened_niqab/rainbow
	name = "rainbow niqab"
	icon_state = "rainbowabaya_hood"
