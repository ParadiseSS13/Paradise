/obj/structure/big_delivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped = null
	var/init_welded = FALSE
	var/giftwrapped = FALSE
	var/sort_tag = 1

/obj/structure/big_delivery/update_desc()
	. = ..()
	desc = initial(desc)
	if(sort_tag)
		desc += " The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sort_tag]]\"."

/obj/structure/big_delivery/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
	return ..()

/obj/structure/big_delivery/ex_act(severity)
	for(var/atom/movable/AM in contents)
		AM.ex_act()
		CHECK_TICK
	..()

/obj/structure/big_delivery/attack_hand(mob/user as mob)
	if(user in src)
		return
	open()

/obj/structure/big_delivery/container_resist(mob/living/L)
	var/breakout_time = 1 MINUTES
	to_chat(L, SPAN_NOTICE("You attempt to break the wrapping on [src]."))
	if(do_after_once(L, breakout_time, needhand = FALSE, target = src, allow_moving = TRUE, allow_moving_target = TRUE))
		open()

/obj/structure/big_delivery/proc/open()
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
	if(wrapped)
		wrapped.forceMove(get_turf(src))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = init_welded
			for(var/mob/living/stowaway in src)
				stowaway.forceMove(O)
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.loc = T
	qdel(src)

/obj/structure/big_delivery/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	. = ITEM_INTERACT_COMPLETE
	if(istype(W, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/O = W

		if(sort_tag != O.current_tag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.current_tag])
			to_chat(user, SPAN_NOTICE("*[tag]*"))
			sort_tag = O.current_tag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)
			update_appearance(UPDATE_DESC)

	else if(istype(W, /obj/item/shipping_package))
		var/obj/item/shipping_package/sp = W
		if(sp.sealed)
			return
		else
			sort_tag = sp.sort_tag
			to_chat(user, SPAN_NOTICE("You rip the label off the shipping package and affix it to [src]."))
			qdel(sp)
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
			update_appearance(UPDATE_DESC)
			add_fingerprint(user)

	else if(is_pen(W))
		rename_interactive(user, W)
		add_fingerprint(user)

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message(SPAN_NOTICE("[user] wraps the package in festive paper!"))
			giftwrapped = TRUE
			if(istype(wrapped, /obj/structure/closet/crate))
				icon_state = "giftcrate"
			else
				icon_state = "giftcloset"
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/c_tube( get_turf(user) )
		else
			to_chat(user, SPAN_NOTICE("You need more paper."))
	else
		return ..()

/obj/item/small_delivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrate2"
	var/obj/item/wrapped = null
	var/giftwrapped = FALSE
	var/sort_tag = TAGGER_LOCATION_DISPOSALS
	new_attack_chain = TRUE

/obj/item/small_delivery/update_desc()
	. = ..()
	desc = initial(desc)
	if(sort_tag)
		desc += SPAN_NOTICE("The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sort_tag]]\".")

/obj/item/small_delivery/ex_act(severity)
	for(var/atom/movable/AM in contents)
		AM.ex_act()
		CHECK_TICK
	..()

/obj/item/small_delivery/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/small_delivery/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(wrapped?.loc == src) // Sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(get_turf(src))
		if(ishuman(user))
			user.put_in_hands(wrapped)
	playsound(src, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/small_delivery/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/dest_tagger))
		var/obj/item/dest_tagger/tagger = used

		if(sort_tag == tagger.current_tag)
			return ITEM_INTERACT_COMPLETE
		var/tag = uppertext(GLOB.TAGGERLOCATIONS[tagger.current_tag])
		to_chat(user, SPAN_NOTICE("*[tag]*"))
		sort_tag = tagger.current_tag
		playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)
		update_appearance(UPDATE_DESC)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/shipping_package))
		var/obj/item/shipping_package/package = used
		if(package.sealed)
			return ITEM_INTERACT_COMPLETE

		sort_tag = package.sort_tag
		to_chat(user, SPAN_NOTICE("You rip the label off the shipping package and affix it to [src]."))
		qdel(package)
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
		update_appearance(UPDATE_DESC)
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(is_pen(used))
		rename_interactive(user, used)
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/paper_roll = used
		if(!paper_roll.use(1))
			to_chat(user, SPAN_WARNING("You need more paper to wrap this!"))
			return ITEM_INTERACT_COMPLETE
		icon_state = "giftcrate[wrapped.w_class]"
		giftwrapped = TRUE
		user.visible_message(SPAN_NOTICE("[user] wraps the package in festive paper!"))
		if(paper_roll.amount <= 0 && !paper_roll.loc) // If we used our last wrapping paper, drop a cardboard tube.
			new /obj/item/c_tube(get_turf(user))
		add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/stack/package_wrap
	name = "package wrapper"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "deliveryPaper"
	singular_name = "package wrapper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	var/wrap_time = 2 SECONDS
	var/static/list/no_wrap = list(/obj/item/small_delivery, /obj/structure/big_delivery, /obj/item/evidencebag, /obj/structure/closet/body_bag, /obj/item/envelope)

/obj/item/stack/package_wrap/pre_attack(atom/atom_target, mob/living/user, params)
	. = ..()
	if(!in_range(atom_target, user))
		return

	if(!isobj(atom_target))
		return

	var/obj/target = atom_target
	if(is_type_in_list(target, no_wrap))
		return

	if(istype(target, /obj/item/stack/package_wrap) && user.a_intent != INTENT_HARM)
		return

	if(is_type_in_list(atom_target.loc, list(/obj/item/small_delivery, /obj/structure/big_delivery)))
		return

	if(target.anchored)
		return

	if(target in user)
		return

	if(isitem(target) && !(isstorage(target) && !istype(target,/obj/item/storage/box) && !istype(target, /obj/item/shipping_package)))
		var/obj/item/O = target
		if(!use(1))
			return CONTINUE_ATTACK

		var/obj/item/small_delivery/P = new /obj/item/small_delivery(get_turf(O.loc)) //Aaannd wrap it up!
		if(!isturf(O.loc))
			if(user.client)
				user.client.screen -= O
		P.wrapped = O
		O.loc = P
		var/i = round(O.w_class)
		if(i in list(1,2,3,4,5))
			P.icon_state = "deliverycrate[i]"
			P.w_class = i
		P.add_fingerprint(user)
		O.add_fingerprint(user)
		add_fingerprint(user)

	else if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/big_delivery/D = wrap_closet(target, user)
		if(!D)
			return CONTINUE_ATTACK
		D.icon_state = "deliverycrate"

	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/C = target
		var/obj/structure/big_delivery/D = wrap_closet(target, user)
		if(!D)
			return CONTINUE_ATTACK
		D.init_welded = C.welded
		C.welded = TRUE

	else if(target.GetComponent(/datum/component/two_handed))
		to_chat(user, SPAN_NOTICE("[target] is too unwieldy to wrap effectively."))
		return CONTINUE_ATTACK

	else
		to_chat(user, SPAN_NOTICE("The object you are trying to wrap is unsuitable for the sorting machinery."))
		return CONTINUE_ATTACK

	user.visible_message(SPAN_NOTICE("[user] wraps [target]."))
	user.create_attack_log("<font color='blue'>Has used [name] on [target]</font>")
	add_attack_logs(user, target, "used [name]", ATKLOG_ALL)

	if(amount <= 0 && QDELETED(src)) //if we used our last wrapping paper, drop a cardboard tube
		var/obj/item/c_tube/T = new(get_turf(user))
		user.put_in_active_hand(T)
	return CONTINUE_ATTACK

// Separate proc to avoid copy pasting the code twice
/obj/item/stack/package_wrap/proc/wrap_closet(obj/structure/closet/C, mob/user)
	if(C.opened)
		return
	if(amount < 3)
		to_chat(user, SPAN_WARNING("You need more paper."))
		return
	if(user in C)
		to_chat(user, SPAN_WARNING("How do you plan to wrap it from the inside?"))
		return
	// Checking these again since it's after a delay
	var/wrap_do_after = wrap_time
	if(user.mind && HAS_TRAIT(user.mind, TRAIT_PACK_RAT))
		wrap_do_after *= PACK_RAT_WRAP_SPEEDUP
	if(!do_after_once(user, wrap_do_after, target = C) || C.opened || !use(3))
		return

	var/obj/structure/big_delivery/P = new(get_turf(C))
	for(var/mob/living/stowaway in C)
		stowaway.forceMove(P)
	P.wrapped = C
	C.loc = P
	return P

/obj/item/dest_tagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 250, MAT_GLASS = 150)
	///Value of the tag
	var/current_tag = 1
	//The whole system for the sort_type var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sort_type = list(1) --Superxpdude
	var/datum/ui_module/destination_tagger/destination_tagger
	new_attack_chain = TRUE

/obj/item/dest_tagger/Initialize(mapload)
	. = ..()
	destination_tagger = new(src)

/obj/item/dest_tagger/Destroy()
	QDEL_NULL(destination_tagger)
	return ..()

/obj/item/dest_tagger/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)
	ui_interact(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/dest_tagger/ui_state(mob/user)
	return GLOB.default_state

/obj/item/dest_tagger/ui_interact(mob/user, datum/tgui/ui = null)
	destination_tagger.ui_interact(user)

/obj/machinery/disposal/delivery_chute
	name = "delivery chute"
	desc = "A chute for big and small packages alike!"
	icon_state = "intake"
	required_mode_to_deconstruct = 1
	deconstructs_to = PIPE_DISPOSALS_CHUTE
	var/can_deconstruct = FALSE

/obj/machinery/disposal/delivery_chute/Initialize(mapload)
	. = ..()

	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/delivery_chute/interact()
	return

/obj/machinery/disposal/delivery_chute/update()
	return

/obj/machinery/disposal/delivery_chute/CanPass(atom/movable/mover, border_dir)
	// If the mover is a thrownthing passing through space, remove its thrown datum,
	// ingest it like normal, and mark the chute as not passible.
	// This prevents the mover from Entering the chute's turf
	// while also bypassing thrownthing's /finalize, which would
	// cause damage to the chute.
	if(mover.throwing && !has_gravity(get_turf(mover)))
		qdel(mover.throwing)
		Bumped(mover)
		return FALSE

	. = ..()

/obj/machinery/disposal/delivery_chute/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(!Adjacent(user) || !dropping.Adjacent(user) || QDELETED(dropping))
		return

	if(!isturf(dropping.loc)) // If it's in storage or held by a mob you don't need this proc.
		return

	if(!dropping.can_be_pulled(user))
		return

	dropping.add_fingerprint(user)
	dropping.forceMove(src)
	flush()
	return TRUE

/obj/machinery/disposal/delivery_chute/Bumped(atom/movable/AM) //Go straight into the chute
	if(isprojectile(AM)	|| is_ai(AM) || QDELETED(AM))
		return

	// We may already contain the object because thrown objects
	// call CanPass which has a chance to immediately forceMove
	// them into us.
	if(AM.loc == src)
		flush()
		return

	switch(dir)
		if(NORTH)
			if(AM.loc.y != loc.y + 1) return
		if(EAST)
			if(AM.loc.x != loc.x + 1) return
		if(SOUTH)
			if(AM.loc.y != loc.y - 1) return
		if(WEST)
			if(AM.loc.x != loc.x - 1) return

	if(isobj(AM))
		var/obj/O = AM
		O.loc = src
	else if(ismob(AM))
		var/mob/M = AM
		M.loc = src
	flush()

/obj/machinery/disposal/delivery_chute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/delivery_check = FALSE
	var/obj/structure/disposalholder/H = new(src)	// virtual holder object which actually
													// travels through the pipes.
	for(var/obj/structure/big_delivery/O in src)
		delivery_check = TRUE
	for(var/obj/item/small_delivery/O in src)
		delivery_check = TRUE
	for(var/obj/item/shipping_package/O in src)
		delivery_check = TRUE
		if(!O.sealed)		//unsealed shipping packages will default to disposals
			O.sort_tag = 1
	if(!delivery_check)
		H.destination_tag = TAGGER_LOCATION_DISPOSALS

	sleep(10)
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, FALSE)
		last_sound = world.time
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder
	air_contents = new() // The holder just took our gas; replace it
	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/delivery_chute/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	can_deconstruct = !can_deconstruct
	to_chat(user, "You [can_deconstruct ? "unfasten": "fasten"] the screws around the power connection.")

/obj/machinery/disposal/delivery_chute/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_deconstruct)
		return
	if(length(contents) > 0)
		to_chat(user, "Eject the items first!")
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/structure/disposalconstruct/C = new (loc)
		C.ptype = deconstructs_to
		C.update()
		C.anchored = TRUE
		C.density = TRUE
		qdel(src)

/obj/item/shipping_package
	name = "Shipping package"
	desc = "A pre-labeled package for shipping an item to coworkers."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "shippack"
	var/obj/item/object_inside = null
	var/sort_tag = 1
	var/sealed = 0
	new_attack_chain = TRUE

/obj/item/shipping_package/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(sealed)
		if(is_pen(used))
			var/str = tgui_input_text(user, "Intended recipient?", "Address", max_length = MAX_NAME_LEN)
			if(!str || !length(str))
				to_chat(user, SPAN_WARNING("Invalid text!"))
				return ITEM_INTERACT_COMPLETE
			user.visible_message(SPAN_NOTICE("[user] addresses [src] to [str]."))
			name = "Shipping package (RE: [str])"
		return ITEM_INTERACT_COMPLETE

	if(object_inside)
		to_chat(user, SPAN_WARNING("[src] already contains [object_inside]!"))
		return ITEM_INTERACT_COMPLETE

	if(!(isitem(used) && !isstorage(used) && !istype(used, /obj/item/shipping_package)))
		return ..()

	if(!user.canUnEquip(used))
		to_chat(user, SPAN_WARNING("[used] is stuck to your hand, you cannot put it in [src]!"))
		return ITEM_INTERACT_COMPLETE

	if(used.w_class > 3)
		to_chat(user, SPAN_NOTICE("[used] is too large to fit in [src]!"))
		return ITEM_INTERACT_COMPLETE

	object_inside = used
	user.transfer_item_to(used, src)
	used.add_fingerprint(usr)
	add_fingerprint(usr)
	to_chat(user, SPAN_NOTICE("You put [used] in [src]."))
	return ITEM_INTERACT_COMPLETE

/obj/item/shipping_package/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(sealed)
		to_chat(user, SPAN_NOTICE("You tear open [src], dropping the contents onto the floor."))
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
		user.unequip(src)
		object_inside.forceMove(get_turf(user))
		object_inside = null
		qdel(src)
		return ITEM_INTERACT_COMPLETE

	if(object_inside)
		switch(tgui_alert(user, "Select an action:", "Shipping", list("Remove Object", "Seal Package", "Cancel")))
			if("Remove Object")
				to_chat(user, SPAN_NOTICE("You shake out [src]'s contents onto the floor."))
				object_inside.forceMove(get_turf(user))
				object_inside = null
			if("Seal Package")
				to_chat(user, SPAN_NOTICE("You seal [src], preparing it for delivery."))
				icon_state = "shippack_sealed"
				sealed = 1
				update_appearance(UPDATE_DESC)
		return ITEM_INTERACT_COMPLETE

	if(tgui_alert(user, "Do you want to tear up the package?", "Shipping", list("Yes", "No")) != "Yes")
		return ITEM_INTERACT_COMPLETE
	to_chat(user, SPAN_NOTICE("You shred [src]."))
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
	user.drop_item_to_ground(src)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/shipping_package/update_desc()
	. = ..()
	desc = "A pre-labeled package for shipping an item to coworkers."
	if(sort_tag)
		desc += " The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sort_tag]]\"."
	if(!sealed)
		desc += " The package is not sealed."

/obj/item/shipping_package/Destroy()
	QDEL_NULL(object_inside)
	return ..()
