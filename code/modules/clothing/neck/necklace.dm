/obj/item/clothing/neck/necklace
	desc = "A simple necklace."
	icon_state = "necklace"

/obj/item/clothing/neck/necklace/long
	name = "large necklace"
	desc = "A large necklace."
	icon_state = "necklacelong"

/obj/item/clothing/neck/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon_state = "bling"

/obj/item/clothing/neck/necklace/locket
	name = "gold locket"
	desc = "A gold locket that seems to have space for a photo within."
	icon_state = "locketgold"
	var/base_icon
	var/open
	/// Item inside locket.
	var/obj/item/held

/obj/item/clothing/neck/necklace/locket/Destroy()
	QDEL_NULL(held)
	return ..()


/obj/item/clothing/neck/necklace/locket/attack_self__legacy__attackchain(mob/user)
	if(!base_icon)
		base_icon = icon_state

	if(!("[base_icon]_open" in icon_states(icon)))
		to_chat(user, "[src] doesn't seem to open.")
		return

	open = !open
	to_chat(user, "You flip [src] [open ? "open" : "closed"].")
	if(open)
		icon_state = "[base_icon]_open"
		if(held)
			to_chat(user, "<span class='warning'>[held] falls out!</span>")
			held.forceMove(get_turf(user))
			held = null
	else
		icon_state = "[base_icon]"

/obj/item/clothing/neck/necklace/locket/attackby__legacy__attackchain(obj/item/O, mob/user)
	if(!open)
		to_chat(user, "You have to open it first.")
		return

	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo))
		if(held)
			to_chat(usr, "[src] already has something inside it.")
		else
			to_chat(usr, "You slip [O] into [src].")
			user.drop_item()
			O.forceMove(src)
			held = O
	else
		return ..()

/obj/item/clothing/neck/necklace/locket/silver
	name = "silver locket"
	desc = "A silver locket that seems to have space for a photo within."
	icon_state = "locketsilver"
