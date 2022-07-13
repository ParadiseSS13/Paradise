/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats."
	icon = 'icons/obj/coatrack.dmi'
	icon_state = "coatrack0"
	var/obj/item/clothing/suit/coat
	var/list/allowed = list(/obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/suit/storage/det_suit)

/obj/structure/coatrack/attack_hand(mob/user as mob)
	user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src]")
	if(!user.put_in_active_hand(coat))
		coat.forceMove(get_turf(user))
	coat = null
	update_icon(UPDATE_OVERLAYS)

/obj/structure/coatrack/attackby(obj/item/W as obj, mob/user as mob, params)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(W,T))
			can_hang = TRUE
	if(can_hang && !coat)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src]")
		coat = W
		user.drop_item(src)
		coat.forceMove(src)
		update_icon(UPDATE_OVERLAYS)
		return
	return ..()

/obj/structure/coatrack/CanPass(atom/movable/mover, turf/target, height=0)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(mover,T))
			can_hang = TRUE
	if(can_hang && !coat)
		visible_message("[mover] lands on \the [src].")
		coat = mover
		coat.forceMove(src)
		update_icon(UPDATE_OVERLAYS)
		return
	return ..()

/obj/structure/coatrack/update_overlays()
	. = ..()
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat))
		. += "coat_lab"
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/cmo))
		. += "coat_cmo"
	if(istype(coat, /obj/item/clothing/suit/storage/det_suit))
		. += "coat_det"
