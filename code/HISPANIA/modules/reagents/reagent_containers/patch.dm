//////Delay de aplicacion parches////
/obj/item/reagent_containers/food/pill/patch/attack(mob/living/carbon/M, mob/user)
	var/self_delay = 20
	bitesize = reagents.total_volume
	if(!istype(M))
		return FALSE
	if(user != M)
		if(M.eat(src, user))
			spawn(0)
				qdel(src)
			return TRUE
	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to apply [src].</span>")
		if(self_delay) ///Evita aplicar parches al tirarlos
			if(!do_mob(user, M, self_delay))
				return FALSE
			M.eat(src, user)
			qdel(src)
		return TRUE
	return FALSE