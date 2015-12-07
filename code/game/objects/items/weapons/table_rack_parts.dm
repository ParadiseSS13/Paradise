/* Table parts and rack parts
 * Contains:
 *		Table Parts
 *		Reinforced Table Parts
 *		Wooden Table Parts
 *		Rack Parts
 */

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	materials = list(MAT_METAL=4000)
	flags = CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	materials = list(MAT_METAL=8000)
	flags = CONDUCT

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null

/obj/item/weapon/table_parts/glass
	name = "glass table parts"
	desc = "fragile!"
	icon_state = "glass_tableparts"
	flags = null

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL=2000)

/*
 * Table Parts
 */
/obj/item/weapon/table_parts/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		//SN src = null
		qdel(src)
	if (istype(W, /obj/item/stack/rods))
		if (W:amount >= 4)
			new /obj/item/weapon/table_parts/reinforced( user.loc )
			user << "\blue You reinforce the [name]."
			W:use(4)
			qdel(src)
		else if (W:amount < 4)
			user << "\red You need at least four rods to do this."

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	new /obj/structure/table( user.loc )
	user.drop_item()
	qdel(src)
	return


/*
 * Reinforced Table Parts
 */
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		new /obj/item/stack/rods( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user as mob)
	new /obj/structure/table/reinforced( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Wooden Table Parts
 */
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/sheet/wood(get_turf(src))
		qdel(src)

/obj/item/weapon/table_parts/wood/attack_self(mob/user as mob)
	new /obj/structure/table/woodentable( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Glass Table Parts
 */
/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		new /obj/item/stack/sheet/metal( user.loc )
		qdel(src)

/obj/item/weapon/table_parts/glass/attack_self(mob/user as mob)
	new /obj/structure/glasstable_frame( user.loc )
	user.drop_item()
	qdel(src)
	return

/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		qdel(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
	R.add_fingerprint(user)
	user.drop_item()
	qdel(src)
	return