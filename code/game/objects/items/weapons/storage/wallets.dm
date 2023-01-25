/obj/item/storage/wallet
	name = "leather wallet"
	desc = "Made from genuine leather, it is of the highest quality."
	storage_slots = 10
	icon = 'icons/obj/wallets.dmi'
	icon_state = "brown_wallet"
	item_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	can_hold = list(
		/obj/item/stack/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/screwdriver,
		/obj/item/stamp,
		/obj/item/encryptionkey)
	slot_flags = SLOT_ID

	var/obj/item/card/id/front_id = null
	var/image/front_id_overlay = null

/obj/item/storage/wallet/proc/id_check()
	front_id = (locate(/obj/item/card/id) in contents)
	if(!front_id)
		name = "[item_color] leather wallet"
		return FALSE
	name = "[item_color] leather wallet with [front_id] on the front"
	return TRUE


/obj/item/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/swap_items(obj/item/item_1, obj/item/item_2, mob/user)
	. = ..(item_1, item_2, user)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/update_icon()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.wear_id == src)
			H.sec_hud_set_ID()
	overlays -= front_id_overlay
	if(!front_id)
		front_id_overlay = null
		return
	var/front_id_icon_state_holder = front_id.icon_state
	if (copytext(front_id_icon_state_holder,1,4) == "ERT")
		front_id_icon_state_holder = "ERT"
	else if(!(front_id_icon_state_holder in icon_states(src.icon)))
		front_id_icon_state_holder = "id"
	front_id_overlay = image('icons/obj/wallets.dmi', front_id_icon_state_holder)
	overlays += front_id_overlay

/obj/item/storage/wallet/GetID()
	return front_id ? front_id : ..()

/obj/item/storage/wallet/GetAccess()
	return front_id ? front_id.GetAccess() : ..()

/obj/item/storage/wallet/random/New()
	..()
	var/item1_type = pick(/obj/item/stack/spacecash,
		/obj/item/stack/spacecash/c10,
		/obj/item/stack/spacecash/c100,
		/obj/item/stack/spacecash/c500,
		/obj/item/stack/spacecash/c1000)
	var/item2_type
	if(prob(50))
		item2_type = pick(/obj/item/stack/spacecash,
		/obj/item/stack/spacecash/c10,
		/obj/item/stack/spacecash/c100,
		/obj/item/stack/spacecash/c500,
		/obj/item/stack/spacecash/c1000)
	var/item3_type = pick( /obj/item/coin/silver, /obj/item/coin/silver, /obj/item/coin/gold, /obj/item/coin/iron, /obj/item/coin/iron, /obj/item/coin/iron )

	spawn(2)
		if(item1_type)
			new item1_type(src)
		if(item2_type)
			new item2_type(src)
		if(item3_type)
			new item3_type(src)

//////////////////////////////////////
//			Color Wallets			//
//////////////////////////////////////

/obj/item/storage/wallet/color
	name = "cheap wallet"
	desc = "A cheap wallet from the arcade."
	storage_slots = 5		//smaller storage than normal wallets
	icon = 'icons/obj/wallets.dmi'
	item_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	can_hold = list(
		/obj/item/stack/spacecash,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/screwdriver,
		/obj/item/stamp,
		/obj/item/encryptionkey)
	slot_flags = SLOT_ID



/obj/item/storage/wallet/color/New()
	..()
	if(!item_color)
		var/color_wallet = pick(subtypesof(/obj/item/storage/wallet/color))
		new color_wallet(src.loc)
		qdel(src)
		return
	UpdateDesc()

/obj/item/storage/wallet/color/proc/UpdateDesc()
	name = "[item_color] wallet"
	desc = "[item_color] wallet made from... leather?"
	icon_state = "[item_color]_wallet"


/obj/item/storage/wallet/color/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/color/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/color/swap_items(obj/item/item_1, obj/item/item_2, mob/user)
	. = ..(item_1, item_2, user)
	if(.)
		id_check()
		update_icon()

/obj/item/storage/wallet/color/blue
	item_color = "blue"

/obj/item/storage/wallet/color/red
	item_color = "red"

/obj/item/storage/wallet/color/yellow
	item_color = "yellow"

/obj/item/storage/wallet/color/green
	item_color = "green"

/obj/item/storage/wallet/color/pink
	item_color = "pink"

/obj/item/storage/wallet/color/black
	item_color = "black"
