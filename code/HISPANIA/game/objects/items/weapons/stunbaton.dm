///Probabilidad de Fallo Stunprod //

/obj/item/melee/baton/cattleprod/attack(mob/M, mob/living/user)
	if(prob(4))
		user.Weaken(3)
		user.Stun(3)
		to_chat(user, "<span class='userdanger'>[src] malfunctions shocking your hand too!</span>")
		deductcharge(hitcost*2)
		return
	..()
