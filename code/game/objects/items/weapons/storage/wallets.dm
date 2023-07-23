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

	// allows for clicking of stuff on our person/on the ground to put in the wallet, so easy to stick your ID in your wallet
	use_to_pickup = TRUE
	pickup_all_on_tile = FALSE


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

	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/item/storage/wallet/update_overlays()
	. = ..()
	if(!front_id)
		return
	. += mutable_appearance(front_id.icon, front_id.icon_state)
	. += front_id.overlays
	. += mutable_appearance(icon, "wallet_overlay")

	// fuck yeah, ass photo in my wallet
	var/obj/item/photo/photo = locate(/obj/item/photo) in contents
	if(!photo)
		return
	var/mutable_appearance/MA = mutable_appearance(photo.appearance)
	MA.pixel_x = 11
	MA.pixel_y = 1
	. += MA
	. += mutable_appearance(icon, "photo_overlay")

/obj/item/storage/wallet/update_name(updates)
	. = ..()
	if(front_id)
		name = "wallet displaying [front_id]"
	else
		name = initial(name)

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


// Arcade Wallet
/obj/item/storage/wallet/cheap
	name = "cheap wallet"
	desc = "A cheap and flimsy wallet from the arcade."
	storage_slots = 5		//smaller storage than normal wallets
