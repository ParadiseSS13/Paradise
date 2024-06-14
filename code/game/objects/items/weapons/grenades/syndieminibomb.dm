/obj/item/grenade/syndieminibomb
	name = "syndicate minibomb"
	desc = "A syndicate manufactured explosive used to sow destruction and chaos."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "grenade"
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(loc, 1, 2, 4, flame_range = 2)
	qdel(src)

/obj/item/grenade/syndieminibomb/cmag_act(mob/user)
	to_chat(user, "<span class='warning'>You drip some yellow ooze into [src]. [src] suddenly doesn't want to leave you...</span>")
	AddComponent(/datum/component/boomerang, throw_range, TRUE)

/obj/item/grenade/syndieminibomb/fake

/obj/item/grenade/syndieminibomb/pen
	name = "pen"
	desc = "It's a normal black ink pen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"

/obj/item/grenade/syndieminibomb/pen/attack_self(mob/user)
	if(!active)
		visible_message("<span class='notice'>[user] fumbles with [src]!</span>")
	. = ..()
