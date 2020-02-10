///Probabilidad de Fallo Stunprod //

/obj/item/melee/baton/cattleprod/attack(mob/M, mob/living/user)
	if(prob(5))
		user.Weaken(3)
		user.Stun(3)
		to_chat(user, "<span class='userdanger'>[src] malfunctions shocking your hand too!</span>")
		deductcharge(hitcost)
		return
	if(status && (CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	if(isrobot(M))
		..()
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(check_martial_counter(H, user))
			return

	if(!isliving(M))
		return

	var/mob/living/L = M

	if(user.a_intent != INTENT_HARM)
		if(status)
			user.do_attack_animation(L)
			baton_stun(L, user)
		else
			L.visible_message("<span class='warning'>[user] has prodded [L] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] has prodded you with [src]. Luckily it was off</span>")
			return
	else
		if(status)
			baton_stun(L, user)
		..()