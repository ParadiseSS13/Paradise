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

/obj/item/stack/light_w/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	..()
	if(istype(O,/obj/item/wirecutters))
		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 5
		amount--
		new/obj/item/stack/sheet/glass(user.loc)
		if(amount <= 0)
			user.unEquip(src, 1)
			qdel(src)

	if(istype(O,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = O
		M.amount--
		if(M.amount <= 0)
			user.unEquip(src, 1)
			qdel(M)
		amount--
		new/obj/item/stack/tile/light(user.loc)
		if(amount <= 0)
			user.unEquip(src, 1)
			qdel(src)
