/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats and trenchcoats."
	icon = 'icons/hispania/obj/coatrack.dmi'
	icon_state = "coatrack0"
	var/obj/item/clothing/suit/coat
	var/list/allowed = list(/obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/suit/storage/det_suit, /obj/item/clothing/suit/armor/hos, /obj/item/clothing/suit/captunic/capjacket, /obj/item/clothing/suit/storage/lawyer, /obj/item/clothing/suit/tracksuit, /obj/item/clothing/suit/hooded/hoodie,
							/obj/item/clothing/suit/storage/blueshield, /obj/item/clothing/suit/jacket/pilot, /obj/item/clothing/suit/jacket/miljacket, /obj/item/clothing/suit/tailcoat, /obj/item/clothing/suit/victcoat, /obj/item/clothing/suit/blacktrenchcoat, /obj/item/clothing/head/hooded/winterhood)

/obj/structure/coatrack/attack_hand(mob/user as mob)
	user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src]")
	if(!user.put_in_active_hand(coat))
		coat.loc = get_turf(user)
	coat = null
	update_icon()

/obj/structure/coatrack/attackby(obj/item/W as obj, mob/user as mob, params)
	var/can_hang = 0
	for(var/T in allowed)
		if(istype(W,T))
			can_hang = 1
	if(can_hang && !coat)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src]")
		coat = W
		user.drop_item(src)
		coat.loc = src
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
		return 0
	else
		return 1

/obj/structure/coatrack/update_icon()
	overlays.Cut()
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat))
		overlays += image(icon, icon_state = "coat_lab")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/cmo))
		overlays += image(icon, icon_state = "coat_cmo")
	if(istype(coat, /obj/item/clothing/suit/storage/det_suit))
		overlays += image(icon, icon_state = "coat_det")
	if(istype(coat, /obj/item/clothing/suit/armor/hos))
		overlays += image(icon, icon_state = "hos2")
	if(istype(coat, /obj/item/clothing/suit/armor/hos/alt))
		overlays += image(icon, icon_state = "hos")
	if(istype(coat, /obj/item/clothing/suit/jacket/miljacket))
		overlays += image(icon, icon_state = "jacket")
	if(istype(coat, /obj/item/clothing/suit/storage/lawyer))
		overlays += image(icon, icon_state = "iaa")
	if(istype(coat, /obj/item/clothing/head/hooded/winterhood))
		overlays += image(icon, icon_state = "fluffy")
	if(istype(coat, /obj/item/clothing/suit/captunic/capjacket))
		overlays += image(icon, icon_state = "cap")
	if(istype(coat, /obj/item/clothing/suit/jacket/pilot))
		overlays += image(icon, icon_state = "bomber")
	if(istype(coat, /obj/item/clothing/suit/tailcoat))
		overlays += image(icon, icon_state = "victorian")
	if(istype(coat, /obj/item/clothing/suit/victcoat))
		overlays += image(icon, icon_state = "victorian")
	if(istype(coat, /obj/item/clothing/suit/storage/blueshield))
		overlays += image(icon, icon_state = "blueshield")
	if(istype(coat, /obj/item/clothing/suit/blacktrenchcoat))
		overlays += image(icon, icon_state = "iaa")
	if(istype(coat, /obj/item/clothing/suit/tracksuit))
		overlays += image(icon, icon_state = "iaa")
	if(istype(coat, /obj/item/clothing/suit/hooded/hoodie))
		overlays += image(icon, icon_state = "iaa")
