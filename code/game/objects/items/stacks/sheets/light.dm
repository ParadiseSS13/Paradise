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

/obj/item/stack/light_w/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/stack/sheet/metal))
		return ..()

	var/obj/item/stack/sheet/metal/M = used
	M.use(1)
	new /obj/item/stack/tile/light(user.loc)
	use(1)
	return ITEM_INTERACT_COMPLETE

/obj/item/stack/light_w/wirecutter_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/wirecutters))
		return

	var/obj/item/stack/cable_coil/CC = new(user.loc)
	CC.amount = 5
	new/obj/item/stack/sheet/glass(user.loc)
	use(1)
	return ITEM_INTERACT_COMPLETE
