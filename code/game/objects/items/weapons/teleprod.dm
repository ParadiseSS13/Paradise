/obj/item/weapon/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	item_state = "teleprod"

/obj/item/weapon/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(status)
		if((CLUMSY in user.mutations) && prob(50))
			user.visible_message("<span class='danger'>[user] accidentally hits themself with [src]!</span>", \
								"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
			user.Weaken(stunforce*3)
			deductcharge(hitcost)
			do_teleport(user, get_turf(user), 50)//honk honk
		else if(iscarbon(M) && !M.anchored)
			do_teleport(M, get_turf(M), 15)