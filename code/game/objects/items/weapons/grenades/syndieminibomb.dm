/obj/item/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "grenade"
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(loc, 1, 2, 4, flame_range = 2)
	qdel(src)

/obj/item/grenade/syndieminibomb/fake

/obj/item/grenade/syndieminibomb/fake/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		. += "<span class='sans'>There are small glue ejectors all over the bomb.</span>"

/obj/item/grenade/syndieminibomb/fake/attack_self(mob/user)
	if(!active)
		flags |= NODROP
		to_chat(user, "<span class='userdanger'>As you activate the bomb, it emits a substance that sticks to your hand! It won't come off!</span>")
		to_chat(user, "<span class='sans'>Uh oh.</span>")
	. = ..()
