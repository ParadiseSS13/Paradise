/obj/item/storage/wallet
	name = "leather wallet"
	desc = "Made from genuine leather, it is of the highest quality."
	storage_slots = 10
	icon = 'icons/obj/wallets.dmi'
	icon_state = "wallet"
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
		/obj/item/stamp)
	cant_hold = list(
		/obj/item/screwdriver/power
	)
	slot_flags = SLOT_ID

	var/obj/item/card/id/front_id = null


/obj/item/storage/wallet/remove_from_storage(obj/item/I, atom/new_location)
	. = ..()
	if(. && istype(I, /obj/item/card/id))
		refresh_ID()

/obj/item/storage/wallet/handle_item_insertion(obj/item/I, prevent_warning = FALSE)
	. = ..()
	if(. && istype(I, /obj/item/card/id))
		refresh_ID()

/obj/item/storage/wallet/orient2hud(mob/user)
	. = ..()
	refresh_ID()

/obj/item/storage/wallet/proc/refresh_ID()
	// Locate the first ID in the wallet
	front_id = (locate(/obj/item/card/id) in contents)

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)

/obj/item/storage/wallet/update_icon_state()
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


/obj/item/storage/wallet/update_name(updates)
	. = ..()
	if(front_id)
		name = "wallet displaying [front_id]"
	else
		name = get_empty_wallet_name()

/obj/item/storage/wallet/proc/get_empty_wallet_name()
	return initial(name)

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/GetAccess()
	var/obj/item/I = GetID()
	if(I)
		return I.GetAccess()
	else
		return ..()

/obj/item/storage/wallet/random/populate_contents()
	var/cash = pick(/obj/item/stack/spacecash,
		/obj/item/stack/spacecash/c5,
		/obj/item/stack/spacecash/c10,
		/obj/item/stack/spacecash/c50,
		/obj/item/stack/spacecash/c100)
	var/coin = pickweight(list(/obj/item/coin/iron = 3,
							/obj/item/coin/silver = 2,
							/obj/item/coin/gold = 1))

	new cash(src)
	if(prob(50)) // 50% chance of a second
		new cash(src)
	new coin(src)

//////////////////////////////////////
//			Color Wallets			//
//////////////////////////////////////

/obj/item/storage/wallet/color
	name = "cheap wallet"
	desc = "A cheap wallet from the arcade."
	storage_slots = 5		//smaller storage than normal wallets

/obj/item/storage/wallet/color/Initialize(mapload)
	. = ..()
	if(!item_color)
		var/color_wallet = pick(subtypesof(/obj/item/storage/wallet/color))
		new color_wallet(loc)
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)

/obj/item/storage/wallet/color/update_desc(updates)
	. = ..()
	desc = "A cheap, [item_color] wallet from the arcade."

/obj/item/storage/wallet/color/update_icon_state()
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

/obj/item/storage/wallet/color/get_empty_wallet_name()
	return "cheap [item_color] wallet"
