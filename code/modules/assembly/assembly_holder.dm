/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	inhand_icon_state = "assembly"
	flags = CONDUCT
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10

	var/secured = FALSE
	var/obj/item/assembly/a_left = null
	var/obj/item/assembly/a_right = null

/obj/item/assembly_holder/IsAssemblyHolder()
	return TRUE

/obj/item/assembly_holder/Destroy()
	if(a_left)
		a_left.holder = null
	if(a_right)
		a_right.holder = null
	return ..()

/obj/item/assembly_holder/proc/attach(obj/item/D, obj/item/D2, mob/user)
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
			user.transfer_item_to(A1, src)
		else
			A1.forceMove(src)
	if(!A2.remove_item_from_storage(src))
		if(user)
			user.transfer_item_to(A2, src)
		else
			A2.forceMove(src)
	A1.holder = src
	A2.holder = src
	a_left = A1
	a_right = A2
	name = "[A1.name]-[A2.name] assembly"
	update_icon(UPDATE_OVERLAYS)
	A1.on_attach()
	A2.on_attach()
	return TRUE

/obj/item/assembly_holder/update_overlays()
	. = ..()
	if(a_left)
		. += "[a_left.icon_state]_left"
		for(var/O in a_left.attached_overlays)
			. += "[O]_l"
	if(a_right)
		. += "[a_right.icon_state]_right"
		for(var/O in a_right.attached_overlays)
			. += "[O]_r"
	if(master)
		master.update_icon()


/obj/item/assembly_holder/examine(mob/user)
	. = ..()
	if(in_range(src, user) || loc == user)
		if(secured)
			. += "[src] is ready!"
		else
			. += "[src] can be attached!"


/obj/item/assembly_holder/HasProximity(atom/movable/AM)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)


// TODO: All these assemblies passing the crossed args around needs to be cleaned up with signals
/obj/item/assembly_holder/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(a_left)
		a_left.on_atom_entered(source, entered)
	if(a_right)
		a_right.on_atom_entered(source, entered)

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
	. = ..()
	process_movement()
	return

/obj/item/assembly_holder/pickup()
	. = ..()
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

/obj/item/assembly_holder/screwdriver_act(mob/user, obj/item/I)
	if(!a_left || !a_right)
		to_chat(user, "<span class='warning'>BUG:Assembly part missing, please report this!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	a_left.toggle_secure()
	a_right.toggle_secure()
	secured = !secured
	if(secured)
		to_chat(user, "<span class='notice'>[src] is ready!</span>")
	else
		to_chat(user, "<span class='notice'>[src] can now be taken apart!</span>")
	update_icon()

/obj/item/assembly_holder/attack_self__legacy__attackchain(mob/user)
	add_fingerprint(user)
	if(secured)
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>Assembly part missing!</span>")
			return
		if(istype(a_left, a_right.type)) // If they are the same type it causes issues due to window code
			switch(tgui_alert(user, "Which side would you like to use?", "Choose", list("Left", "Right")))
				if("Left")
					a_left.attack_self__legacy__attackchain(user)
				if("Right")
					a_right.attack_self__legacy__attackchain(user)
			return
		else
			a_left.attack_self__legacy__attackchain(user)
			a_right.attack_self__legacy__attackchain(user)
	else
		var/turf/T = get_turf(src)
		if(!T)
			return FALSE
		user.unequip(src, force = TRUE)
		if(a_left)
			a_left.on_detach()
			user.put_in_active_hand(a_left)
		if(a_right) // Right object is the secondary item, hence put in inactive hand
			a_right.on_detach()
			user.put_in_inactive_hand(a_right)
		qdel(src)


/obj/item/assembly_holder/proc/process_activation(obj/D, normal = TRUE, special = TRUE)
	if(!D)
		return FALSE
	if(normal && a_right && a_left)
		if(a_right != D)
			a_right.pulsed(0)
		if(a_left && a_left != D)  // the right pools might have sent us boom, so `a_left` can be null here
			a_left.pulsed(0)

	return TRUE
