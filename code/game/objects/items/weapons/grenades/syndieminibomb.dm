/obj/item/grenade/syndieminibomb
	name = "\improper Syndicate minibomb"
	desc = "A Syndicate-manufactured high-explosive grenade used to sow destruction and chaos."
	icon_state = "syndicate"
	origin_tech = "materials=3;magnets=4;syndicate=3"
	var/explosion_cause = "Syndicate minibomb"

/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(loc, 1, 2, 4, flame_range = 2, cause = explosion_cause)
	qdel(src)

/obj/item/grenade/syndieminibomb/fake
	origin_tech = "materials=3;magnets=4;syndicate=1" // no clown, this bomb not exactly the same
	explosion_cause = "Trick Syndicate minibomb"

/obj/item/grenade/syndieminibomb/fake/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		. += "<span class='sans'>There are small glue ejectors all over the bomb.</span>"

/obj/item/grenade/syndieminibomb/fake/attack_self__legacy__attackchain(mob/user)
	if(!active)
		set_nodrop(TRUE, user)
		to_chat(user, "<span class='userdanger'>As you activate the bomb, it emits a substance that sticks to your hand! It won't come off!</span>")
		to_chat(user, "<span class='sans'>Uh oh.</span>")
	. = ..()

/obj/item/grenade/syndieminibomb/pen
	name = "pen"
	desc = "It's a normal black ink pen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	worn_icon_state = "pen"
	inhand_icon_state = "pen"
	explosion_cause = "Syndicate minibomb (disguised as a black pen)"

/obj/item/grenade/syndieminibomb/pen/attack_self__legacy__attackchain(mob/user)
	if(!active)
		visible_message("<span class='notice'>[user] fumbles with [src]!</span>")
	. = ..()
