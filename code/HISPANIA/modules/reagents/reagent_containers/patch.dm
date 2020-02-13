//////Delay de aplicacion parches////

/obj/item/reagent_containers/food/pill/patch/attack(mob/living/carbon/M, mob/user)
	var/self_delay = 20
	bitesize = reagents.total_volume //Los parches son comida
	if(!istype(M))//No podemos aplicar parches en mobs
		return 0
	if(user != M)//Delay al aplicarlo a alguien mas
		if(M.eat(src, user))
			spawn(0)
				qdel(src)
			return 1
	if(M == user)	//Delay para uno mismo
		M.visible_message("<span class='notice'>[user] attempts to apply [src].</span>")
		if(self_delay) ///Evita aplicar parches al tirarlos
			if(!do_mob(user, M, self_delay))
				return FALSE
		M.eat(src, user)
		qdel(src)
		to_chat(M, "<span class='notice'>You [apply_method] [src].</span>")
		return 1
	return 0