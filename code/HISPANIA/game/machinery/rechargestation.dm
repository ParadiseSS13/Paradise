/obj/machinery/recharge_station/MouseDrop_T(atom/movable/O as mob|obj, mob/user)
	var/can_accept_user = FALSE
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(!ishuman(user) && !isrobot(user) && !(istype(user, /mob/living/simple_animal/spiderbot)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		to_chat(user, "<span class='warning'>The cell is already occupied!</span>")
		return
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[L] will not fit into [src] because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head.</span>")
		return
	if(isrobot(L))
		var/mob/living/silicon/robot/R = O
		if(!R.cell)
			to_chat(user, "<span class='warning'>Without a power cell, [R] can't be recharged.</span>")
		can_accept_user = TRUE
	if(ishuman(L))
		if(isrobot(L))
			can_accept_user = TRUE
		else if(!L.get_int_organ(/obj/item/organ/internal/cell))
			to_chat(user, "<span class='notice'>Only non-organics may enter the recharger!</span>")
			return
		can_accept_user = TRUE
	if(istype(L, /mob/living/simple_animal/spiderbot))
		can_accept_user = TRUE
	if(!can_accept_user)
		to_chat(user, "<span class='notice'>Only non-organics may enter the recharger!</span>")
		return
	if(L == user)
		visible_message("[user] starts climbing into the recharger.")
	else
		visible_message("[user] starts putting [L.name] into the recharger.")

	if(do_after(user, 10, target = L))
		if(occupant)
			to_chat(user, "<span class='warning'>The cell is already occupied!</span>")
			return
		if(!L) return
		L.forceMove(src)
		occupant = L
		icon_state = "borgcharger1"
		add_fingerprint(user)
		if(user.pulling == L)
			user.stop_pulling()
		return
	return
