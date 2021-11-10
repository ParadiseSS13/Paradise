/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats and trenchcoats."
	icon = 'icons/hispania/obj/coatrack.dmi'
	icon_state = "coatrack"
	var/obj/item/clothing/coat
	var/obj/item/clothing/coat2
	var/list/allowed = list(/obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/suit/storage/det_suit, /obj/item/clothing/suit/armor/hos, /obj/item/clothing/suit/captunic/capjacket, /obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/suit/tracksuit, /obj/item/clothing/suit/hooded/hoodie,
							/obj/item/clothing/suit/storage/blueshield, /obj/item/clothing/suit/jacket, /obj/item/clothing/suit/tracksuit, /obj/item/clothing/suit/jacket/miljacket, /obj/item/clothing/suit/tailcoat, /obj/item/clothing/suit/victcoat, /obj/item/clothing/suit/blacktrenchcoat, /obj/item/clothing/head/hooded/winterhood)

/obj/structure/coatrack/Initialize()
	. = ..()
	if(coat)
		coat = new coat
		coat.loc = src
		update_icon()
	if(coat2)
		coat2 = new coat2
		coat2.loc = src
		update_icon()

/obj/structure/coatrack/examine(mob/living/M)
	. = ..()
	if (coat)
		var/image = image(coat.icon, icon_state = initial(coat.icon_state))
		. += "<span class='notice'>There's an [coat.name] [bicon(image)] hanging.</span>"
	if (coat2)
		var/image = image(coat2.icon, icon_state = initial(coat2.icon_state))
		. += "<span class='notice'>There's an [coat2.name] [bicon(image)] hanging.</span>"

/obj/structure/coatrack/attack_hand(mob/user as mob) // Lazy code
	if(coat && coat2)
		var/choice = input(user, "Which one?", "coat rack") as null|anything in list(coat.name,coat2.name)
		if(!choice) return
		if(choice == coat.name)
			user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src]")
			if(!user.put_in_active_hand(coat))
				coat.loc = get_turf(user)
			coat = null
			update_icon()
		else
			user.visible_message("[user] takes [coat2] off \the [src].", "You take [coat2] off the \the [src]")
			if(!user.put_in_active_hand(coat2))
				coat2.loc = get_turf(user)
			coat2 = null
			update_icon()
		return
	if(coat)
		user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src]")
		if(!user.put_in_active_hand(coat))
			coat.loc = get_turf(user)
		coat = null
		update_icon()
	else if(coat2)
		user.visible_message("[user] takes [coat2] off \the [src].", "You take [coat2] off the \the [src]")
		if(!user.put_in_active_hand(coat2))
			coat2.loc = get_turf(user)
		coat2 = null
		update_icon()

/obj/structure/coatrack/attackby(obj/item/W as obj, mob/user as mob, params)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(W,T))
			can_hang = TRUE
	if(can_hang && !coat)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src]")
		coat = W
		user.drop_item(src)
		coat.loc = src
		update_icon()
	else if(can_hang && !coat2)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src]")
		coat2 = W
		user.drop_item(src)
		coat2.loc = src
		update_icon()
	else
		return ..()

/obj/structure/coatrack/CanPass(atom/movable/mover, turf/target, height=0)
	var/can_hang = 0
	for(var/T in allowed)
		if(istype(mover,T))
			can_hang = 1

	if(can_hang && !coat)
		src.visible_message("[mover] lands on \the [src].")
		coat = mover
		coat.loc = src
		update_icon()
		return FALSE
	else if(can_hang && !coat2)
		src.visible_message("[mover] lands on \the [src].")
		coat2 = mover
		coat2.loc = src
		update_icon()
		return FALSE
	else
		return TRUE

/obj/structure/coatrack/update_icon()
	overlays.Cut()
	if(coat)
		var/icon_state_coat = initial(coat.item_state)
		icon_state_coat = copytext(icon_state_coat, 1, findtext(icon_state_coat, "_open"))
		icon_state_coat = copytext(icon_state_coat, 1, findtext(icon_state_coat, "_hood"))
		overlays += image(icon, icon_state_coat)
	if(coat2)
		var/icon_state_coat2 = initial(coat2.item_state)
		icon_state_coat2 = copytext(icon_state_coat2, 1, findtext(icon_state_coat2, "_open"))
		icon_state_coat2 = copytext(icon_state_coat2, 1, findtext(icon_state_coat2, "_hood"))
		var/icon/realicon_state_coat2 = icon(icon, icon_state=icon_state_coat2)
		realicon_state_coat2.Flip(WEST)
		realicon_state_coat2.Shift(WEST, 1)
		overlays += realicon_state_coat2
