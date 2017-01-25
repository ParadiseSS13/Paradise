/obj/item/weapon/storage/wallet
	name = "leather wallet"
	desc = "Made from genuine leather, it is of the highest quality."
	storage_slots = 10
	icon = 'icons/obj/wallets.dmi'
	icon_state = "wallet"
	w_class = 2
	burn_state = FLAMMABLE
	can_hold = list(
		"/obj/item/weapon/spacecash",
		"/obj/item/weapon/card",
		"/obj/item/clothing/mask/cigarette",
		"/obj/item/device/flashlight/pen",
		"/obj/item/seeds",
		"/obj/item/stack/medical",
		"/obj/item/toy/crayon",
		"/obj/item/weapon/coin",
		"/obj/item/weapon/dice",
		"/obj/item/weapon/disk",
		"/obj/item/weapon/implanter",
		"/obj/item/weapon/lighter",
		"/obj/item/weapon/match",
		"/obj/item/weapon/paper",
		"/obj/item/weapon/pen",
		"/obj/item/weapon/photo",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/stamp")
	slot_flags = SLOT_ID

	var/obj/item/weapon/card/id/front_id = null


/obj/item/weapon/storage/wallet/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..(W, new_location)
	if(.)
		if(W == front_id)
			front_id = null
			update_icon()

/obj/item/weapon/storage/wallet/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..(W, prevent_warning)
	if(.)
		if(!front_id && istype(W, /obj/item/weapon/card/id))
			front_id = W
			update_icon()

/obj/item/weapon/storage/wallet/update_icon()

	if(front_id)
		switch(front_id.icon_state)
			if("id")
				icon_state = "walletid"
				return
			if("silver")
				icon_state = "walletid_silver"
				return
			if("gold")
				icon_state = "walletid_gold"
				return
			if("centcom")
				icon_state = "walletid_centcom"
				return
	icon_state = "wallet"


/obj/item/weapon/storage/wallet/GetID()
	return front_id

/obj/item/weapon/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()

/obj/item/weapon/storage/wallet/random/New()
	..()
	var/item1_type = pick(/obj/item/weapon/spacecash,
		/obj/item/weapon/spacecash/c10,
		/obj/item/weapon/spacecash/c100,
		/obj/item/weapon/spacecash/c500,
		/obj/item/weapon/spacecash/c1000)
	var/item2_type
	if(prob(50))
		item2_type = pick(/obj/item/weapon/spacecash,
		/obj/item/weapon/spacecash/c10,
		/obj/item/weapon/spacecash/c100,
		/obj/item/weapon/spacecash/c500,
		/obj/item/weapon/spacecash/c1000)
	var/item3_type = pick( /obj/item/weapon/coin/silver, /obj/item/weapon/coin/silver, /obj/item/weapon/coin/gold, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron )

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

/obj/item/weapon/storage/wallet/color
	name = "cheap wallet"
	desc = "A cheap wallet from the arcade."
	storage_slots = 5		//smaller storage than normal wallets

/obj/item/weapon/storage/wallet/color/New()
	..()
	if(!item_color)
		var/color_wallet = pick(subtypesof(/obj/item/weapon/storage/wallet/color))
		new color_wallet(src.loc)
		qdel(src)
		return
	UpdateDesc()

/obj/item/weapon/storage/wallet/color/proc/UpdateDesc()
	name = "cheap [item_color] wallet"
	desc = "A cheap, [item_color] wallet from the arcade."
	icon_state = "[item_color]_wallet"

/obj/item/weapon/storage/wallet/color/update_icon()
	if(front_id)
		switch(front_id.icon_state)
			if("id")
				icon_state = "[item_color]_walletid"
				return
			if("silver")
				icon_state = "[item_color]_walletid_silver"
				return
			if("gold")
				icon_state = "[item_color]_walletid_gold"
				return
			if("centcom")
				icon_state = "[item_color]_walletid_centcom"
				return
	icon_state = "[item_color]_wallet"

/obj/item/weapon/storage/wallet/color/blue
	item_color = "blue"

/obj/item/weapon/storage/wallet/color/red
	item_color = "red"

/obj/item/weapon/storage/wallet/color/yellow
	item_color = "yellow"

/obj/item/weapon/storage/wallet/color/green
	item_color = "green"

/obj/item/weapon/storage/wallet/color/pink
	item_color = "pink"

/obj/item/weapon/storage/waller/color/brown
	item_color = "brown"
