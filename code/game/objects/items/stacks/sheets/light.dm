/obj/item/stack/light_w
	name = "wired glass tiles"
	gender = PLURAL
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby(obj/item/O, mob/user, params)
	..()
	if(istype(O,/obj/item/wirecutters))
		new /obj/item/stack/cable_coil(user.drop_location(), 5)
		amount--
		new/obj/item/stack/sheet/glass(user.drop_location())
		if(amount <= 0)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			qdel(src)

	if(istype(O,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		M.use(1)
		if(M.amount <= 0)
			user.drop_item_ground(src, force = TRUE)
			qdel(M)
		amount--
		new/obj/item/stack/tile/light(user.drop_location())
		if(amount <= 0)
			user.temporarily_remove_item_from_inventory(src, force = TRUE)
			qdel(src)
