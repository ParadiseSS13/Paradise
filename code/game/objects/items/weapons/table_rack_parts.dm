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
	var/upgradable = 1
	var/result = /obj/structure/table
	var/parts = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/metal)

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	materials = list(MAT_METAL=8000)
	flags = CONDUCT
	upgradable = 0
	result = /obj/structure/table/reinforced
	parts = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/rods)

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null
	upgradable = 0
	burn_state = FLAMMABLE
	result = /obj/structure/table/woodentable
	parts = list(
		/obj/item/stack/sheet/wood,
		/obj/item/stack/sheet/wood)

/obj/item/weapon/table_parts/glass
	name = "glass table parts"
	desc = "fragile!"
	icon_state = "glass_tableparts"
	flags = null
	upgradable = 0
	result = /obj/structure/glasstable_frame
	parts = list(
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/metal)

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
	if(istype(W, /obj/item/weapon/wrench))
		for(var/p in parts)
			new p(user.loc)
		qdel(src)
	else if(upgradable && istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if(R.amount >= 4)
			new /obj/item/weapon/table_parts/reinforced(user.loc)
			to_chat(user, "<span class=notice>You reinforce the [name].</span>")
			R.use(4)
			qdel(src)
		else
			to_chat(user, "<span class=warning>You need at least four rods to do this.</span>")

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	for(var/obj/structure/table/T in user.loc)
		to_chat(user, "<span class=warning>You can't build tables on top of tables!</span>")
		return
	new result(user.loc)
	user.drop_item()
	qdel(src)

/*
 * Rack Parts
 */
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal(user.loc)
		qdel(src)

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
	R.add_fingerprint(user)
	user.drop_item()
	qdel(src)