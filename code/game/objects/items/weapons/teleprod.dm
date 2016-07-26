/obj/item/weapon/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"

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

/obj/item/weapon/melee/baton/cattleprod/attackby(obj/item/I, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(istype(I, /obj/item/weapon/ore/bluespace_crystal))
		if(!bcell)
			var/obj/item/weapon/melee/baton/cattleprod/teleprod/S = new /obj/item/weapon/melee/baton/cattleprod/teleprod
			if(!remove_item_from_storage(user))
				user.unEquip(src)
			user.unEquip(I)
			user.put_in_hands(S)
			to_chat(user, "<span class='notice'>You clamp the bluespace crystal securely with the wirecutters.</span>")
			qdel(I)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You can't put the crystal onto the stunprod while it has a power cell installed!</span>")
	else
		return ..()
