/obj/item/stack/light_w
	name = "wired glass tiles"
	gender = PLURAL
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60

/obj/item/stack/light_w/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/wirecutters))
		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 5
		new/obj/item/stack/sheet/glass(user.loc)
		use(1)

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		M.use(1)
		new /obj/item/stack/tile/light(user.loc)
		use(1)
