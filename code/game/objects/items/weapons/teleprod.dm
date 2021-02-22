/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	base_icon = "teleprod"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"

/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(!turned_on)
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>",
			"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce * 3)
		deductcharge(hitcost)
		do_teleport(user, get_turf(user), 50)//honk honk
	else if(iscarbon(M) && !M.anchored)
		do_teleport(M, get_turf(M), 15)
