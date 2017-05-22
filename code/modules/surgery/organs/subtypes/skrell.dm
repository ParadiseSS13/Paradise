/obj/item/organ/internal/liver/skrell
	alcohol_intensity = 4
	species = "Skrell"

/obj/item/organ/internal/headpocket
	name = "headpocket"
	desc = "Allows Skrell to hide tiny objects within their head tentacles."
	icon_state = "kid_lantern"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "headpocket"
	species = "Skrell"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/obj/item/weapon/storage/internal/pocket

/obj/item/organ/internal/headpocket/New()
	pocket = new /obj/item/weapon/storage/internal(src)
	pocket.storage_slots = 1
	//fit only pocket sized items
	pocket.max_w_class = 2
	pocket.max_combined_w_class = 2
	..()

/obj/item/organ/internal/headpocket/ui_action_click()
	var/obj/item/hand_item = owner.get_active_hand()
	if(hand_item)
		// Store item
		if(pocket.can_be_inserted(hand_item))
			pocket.handle_item_insertion(hand_item)
		return
	// Try to remove item
	if(pocket.contents.len)
		pocket.remove_from_storage(pocket.contents.len, get_turf(owner))
