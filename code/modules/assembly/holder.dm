/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = CONDUCT
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10

	var/secured = FALSE
	var/obj/item/assembly/a_left = null
	var/obj/item/assembly/a_right = null

/obj/item/assembly_holder/proc/attach(obj/item/D, obj/item/D2, mob/user)
	return

/obj/item/assembly_holder/proc/process_activation(var/obj/item/D)
	return

/obj/item/assembly_holder/IsAssemblyHolder()
	return TRUE

/obj/item/assembly_holder/Destroy()
	if(a_left)
		a_left.holder = null
	if(a_right)
		a_right.holder = null
	return ..()

/obj/item/assembly_holder/attach(obj/item/D, obj/item/D2, mob/user)
	if(!D || !D2)
		return FALSE
	if(!isassembly(D) || !isassembly(D2))
		return FALSE
	var/obj/item/assembly/A1 = D
	var/obj/item/assembly/A2 = D2
	if(A1.secured || A2.secured)
		return FALSE
	if(!A1.remove_item_from_storage(src))
		if(user)
			user.remove_from_mob(A1)
		A1.loc = src
	if(!A2.remove_item_from_storage(src))
		if(user)
			user.remove_from_mob(A2)
		A2.loc = src
	A1.holder = src
	A2.holder = src
	a_left = A1
	a_right = A2
	name = "[A1.name]-[A2.name] assembly"
	update_icon()
	return TRUE


/obj/item/assembly_holder/update_icon()
	overlays.Cut()
	if(a_left)
		overlays += "[a_left.icon_state]_left"
		for(var/O in a_left.attached_overlays)
			overlays += "[O]_l"
	if(a_right)
		overlays += "[a_right.icon_state]_right"
		for(var/O in a_right.attached_overlays)
			overlays += "[O]_r"
	if(master)
		master.update_icon()


/obj/item/assembly_holder/examine(mob/user)
	..(user)
	if(in_range(src, user) || loc == user)
		if(secured)
			to_chat(user, "[src] is ready!")
		else
			to_chat(user, "[src] can be attached!")


/obj/item/assembly_holder/HasProximity(atom/movable/AM)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)


/obj/item/assembly_holder/Crossed(atom/movable/AM)
	if(a_left)
		a_left.Crossed(AM)
	if(a_right)
		a_right.Crossed(AM)

/obj/item/assembly_holder/on_found(mob/finder)
	if(a_left)
		a_left.on_found(finder)
	if(a_right)
		a_right.on_found(finder)


/obj/item/assembly_holder/hear_talk(mob/living/M, list/message_pieces)
	if(a_left)
		a_left.hear_talk(M, message_pieces)
	if(a_right)
		a_right.hear_talk(M, message_pieces)

/obj/item/assembly_holder/hear_message(mob/living/M, msg)
	if(a_left)
		a_left.hear_message(M, msg)
	if(a_right)
		a_right.hear_message(M, msg)

/obj/item/assembly_holder/proc/process_movement() // infrared beams and prox sensors
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()

/obj/item/assembly_holder/Move()
	..()
	process_movement()
	return

/obj/item/assembly_holder/pickup()
	..()
	process_movement()

/obj/item/assembly_holder/Bump()
	..()
	process_movement()

/obj/item/assembly_holder/throw_impact() // called when a throw stops
	..()
	process_movement()

/obj/item/assembly_holder/attack_hand()//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()
	..()
	return

/obj/item/assembly_holder/attackby(obj/item/W, mob/user, params)
	if(isscrewdriver(W))
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>BUG:Assembly part missing, please report this!</span>")
			return
		a_left.toggle_secure()
		a_right.toggle_secure()
		secured = !secured
		if(secured)
			to_chat(user, "<span class='notice'>[src] is ready!</span>")
		else
			to_chat(user, "<span class='notice'>[src] can now be taken apart!</span>")
		update_icon()
		return
	else
		..()
	return


/obj/item/assembly_holder/attack_self(mob/user)
	add_fingerprint(user)
	if(secured)
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>Assembly part missing!</span>")
			return
		if(istype(a_left, a_right.type))//If they are the same type it causes issues due to window code
			switch(alert("Which side would you like to use?",,"Left","Right"))
				if("Left")
					a_left.attack_self(user)
				if("Right")
					a_right.attack_self(user)
			return
		else
			a_left.attack_self(user)
			a_right.attack_self(user)
	else
		var/turf/T = get_turf(src)
		if(!T)
			return FALSE
		if(a_left)
			a_left.holder = null
			a_left.loc = T
		if(a_right)
			a_right.holder = null
			a_right.loc = T
		qdel(src)


/obj/item/assembly_holder/process_activation(obj/D, normal = TRUE, special = TRUE)
	if(!D)
		return FALSE
	if(normal && a_right && a_left)
		if(a_right != D)
			a_right.pulsed(0)
		if(a_left != D)
			a_left.pulsed(0)
	if(master)
		master.receive_signal()
	return TRUE

/obj/item/assembly_holder/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(25))
				qdel(src)
