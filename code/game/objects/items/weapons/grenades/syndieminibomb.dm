/obj/item/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc, 1, 2, 4, flame_range = 2)
	qdel(src)

/obj/item/grenade/syndieminibomb/concussion
	name = "HE Grenade"
	desc = "A compact shrapnel grenade meant to devastate nearby organisms and cause some damage in the process. Pull pin and throw opposite direction."
	icon_state = "concussion"

/obj/item/grenade/syndieminibomb/concussion/prime()
	update_mob()
	explosion(src.loc, 0, 2, 3, flame_range = 3)
	qdel(src)

/obj/item/grenade/syndieminibomb/concussion/frag
	name = "frag grenade"
	desc = "Fire in the hole."
	icon_state = "frag"