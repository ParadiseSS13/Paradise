/obj/item/storage/wallet
	name = "leather wallet"
	desc = "Made from genuine leather, it is of the highest quality."
	storage_slots = 10
	icon = 'icons/obj/wallets.dmi'
	icon_state = "wallet"
	w_class = WEIGHT_CLASS_SMALL
	burn_state = FLAMMABLE
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
		/obj/item/stamp)
	slot_flags = SLOT_ID

	var/obj/item/card/id/front_id = null


/obj/item/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
			update_icon()

/obj/item/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		if(!front_id && istype(W, /obj/item/card/id))
			front_id = W
			update_icon()

/obj/item/storage/wallet/update_icon()

	if(front_id)
		switch(front_id.icon_state)
			if("silver")
				icon_state = "walletid_silver"
				return
			if("gold")
				icon_state = "walletid_gold"
				return
			if("centcom")
				icon_state = "walletid_centcom"
				return
			else
				icon_state = "walletid"
				return
	icon_state = "wallet"


/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()

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

/obj/item/storage/wallet/color/New()
	..()
	if(!item_color)
		var/color_wallet = pick(subtypesof(/obj/item/storage/wallet/color))
		new color_wallet(src.loc)
		qdel(src)
		return
	UpdateDesc()

/obj/item/storage/wallet/color/proc/UpdateDesc()
	name = "cheap [item_color] wallet"
	desc = "A cheap, [item_color] wallet from the arcade."
	icon_state = "[item_color]_wallet"

/obj/item/storage/wallet/color/update_icon()
	if(front_id)
		switch(front_id.icon_state)
			if("silver")
				icon_state = "[item_color]_walletid_silver"
				return
			if("gold")
				icon_state = "[item_color]_walletid_gold"
				return
			if("centcom")
				icon_state = "[item_color]_walletid_centcom"
				return
			else
				icon_state = "[item_color]_walletid"
				return
	icon_state = "[item_color]_wallet"

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

/obj/item/storage/waller/color/brown
	item_color = "brown"
