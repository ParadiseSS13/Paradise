/obj/item/grenade/empgrenade
	name = "classic EMP grenade"
	desc = "It is designed to wreak havoc on electronic systems."
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "magnets=3;combat=2"

/obj/item/grenade/empgrenade/detonate()
	. = ..()
	update_mob()
	empulse(src, 4, 10, 1)
	qdel(src)
