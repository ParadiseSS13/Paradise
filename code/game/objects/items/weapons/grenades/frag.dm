/obj/item/grenade/frag
	name = "frag grenade"
	desc = "Fire in the hole."
	icon_state = "frag"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"

/obj/item/grenade/frag/prime()
	update_mob()
	explosion(loc, 0, 3, 5, breach = FALSE)
	qdel(src)