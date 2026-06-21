/obj/item/grenade/empgrenade
	name = "classic EMP grenade"
	desc = "Upon detonation, releases a powerful EMP that will wreak havoc on electronic systems."
	icon_state = "emp"
	inhand_icon_state = "emp"
	origin_tech = "magnets=3;combat=2"

/obj/item/grenade/empgrenade/prime()
	update_mob()
	empulse(src, 4, 10, 1)
	qdel(src)
