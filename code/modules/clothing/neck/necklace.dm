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


/obj/item/clothing/neck/necklace/locket/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(!base_icon)
		base_icon = icon_state

	if(!("[base_icon]_open" in icon_states(icon)))
		to_chat(user, "[src] doesn't seem to open.")
		return ITEM_INTERACT_COMPLETE

	open = !open
	to_chat(user, "You flip [src] [open ? "open" : "closed"].")
	if(open)
		icon_state = "[base_icon]_open"
		if(held)
			to_chat(user, SPAN_WARNING("[held] falls out!"))
			held.forceMove(get_turf(user))
			held = null
	else
		icon_state = "[base_icon]"
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/neck/necklace/locket/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/item/paper) || istype(target, /obj/item/photo))
		return ..()

	if(!open)
		to_chat(user, "You have to open it first.")
		return ITEM_INTERACT_COMPLETE

	if(held)
		to_chat(usr, "[src] already has something inside it.")
		return ITEM_INTERACT_COMPLETE

	to_chat(usr, "You slip [target] into [src].")
	user.drop_item()
	var/obj/item/thing = target
	thing.forceMove(src)
	held = target
	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/neck/necklace/locket/silver
	name = "silver locket"
	desc = "A silver locket that seems to have space for a photo within."
	icon_state = "locketsilver"

/obj/item/clothing/neck/necklace/ntcharm
	name = "\improper Nanotrasen charm necklace"
	desc = "A decorative blue and white charm attached to a silver chain."
	icon_state = "ntcharm"
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/neck.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/neck.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi')
