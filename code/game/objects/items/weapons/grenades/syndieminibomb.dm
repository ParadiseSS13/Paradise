/obj/item/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(loc, 1, 2, 4, flame_range = 2)
	qdel(src)