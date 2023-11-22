/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped = null
	var/init_welded = FALSE
	var/giftwrapped = FALSE
	var/sortTag = 1

/obj/structure/bigDelivery/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
	return ..()

/obj/structure/bigDelivery/ex_act(severity)
	for(var/atom/movable/AM in contents)
		AM.ex_act()
		CHECK_TICK
	..()

/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
	if(wrapped)
		wrapped.forceMove(get_turf(src))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = init_welded
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.loc = T

	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/shippingPackage))
		var/obj/item/shippingPackage/sp = W
		if(sp.sealed)
			return
		else
			sortTag = sp.sortTag
			to_chat(user, "<span class='notice'>You rip the label off the shipping package and affix it to [src].</span>")
			qdel(sp)
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)

	else if(is_pen(W))
		rename_interactive(user, W)

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			giftwrapped = TRUE
			if(istype(wrapped, /obj/structure/closet/crate))
				icon_state = "giftcrate"
			else
				icon_state = "giftcloset"
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/c_tube( get_turf(user) )
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		return ..()

/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrate2"
	var/obj/item/wrapped = null
	var/giftwrapped = FALSE
	var/sortTag = 1

/obj/item/smallDelivery/ex_act(severity)
	for(var/atom/movable/AM in contents)
		AM.ex_act()
		CHECK_TICK
	..()

/obj/item/smallDelivery/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/smallDelivery/attack_self(mob/user)
	if(wrapped?.loc == src) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(get_turf(src))
		if(ishuman(user))
			user.put_in_hands(wrapped)
	playsound(src, 'sound/items/poster_ripped.ogg', 50, TRUE)
	qdel(src)

/obj/item/smallDelivery/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/shippingPackage))
		var/obj/item/shippingPackage/sp = W
		if(sp.sealed)
			return
		else
			sortTag = sp.sortTag
			to_chat(user, "<span class='notice'>You rip the label off the shipping package and affix it to [src].</span>")
			qdel(sp)
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)

	else if(is_pen(W))
		rename_interactive(user, W)

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "giftcrate[wrapped.w_class]"
			giftwrapped = TRUE
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/c_tube( get_turf(user) )
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		return ..()

/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "deliveryPaper"
	singular_name = "package wrapper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	var/static/list/no_wrap = list(/obj/item/smallDelivery, /obj/structure/bigDelivery, /obj/item/evidencebag, /obj/structure/closet/body_bag)

/obj/item/stack/packageWrap/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(!in_range(A, user))
		return
	if(!isobj(A))
		return
	var/obj/target = A

	if(is_type_in_list(target, no_wrap))
		return
	if(is_type_in_list(A.loc, list(/obj/item/smallDelivery, /obj/structure/bigDelivery)))
		return
	if(target.anchored)
		return
	if(target in user)
		return

	if(isitem(target) && !(isstorage(target) && !istype(target,/obj/item/storage/box) && !istype(target, /obj/item/shippingPackage)))
		var/obj/item/O = target
		if(!use(1))
			return FALSE
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc)) //Aaannd wrap it up!
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
		var/obj/structure/bigDelivery/D = wrap_closet(target, user)
		if(!D)
			return FALSE
		D.icon_state = "deliverycrate"

	else if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/C = target
		var/obj/structure/bigDelivery/D = wrap_closet(target, user)
		if(!D)
			return FALSE
		D.init_welded = C.welded
		C.welded = TRUE
	else if(target.GetComponent(/datum/component/two_handed))
		to_chat(user, "<span class='notice'>[target] is too unwieldy to wrap effectively.</span>")
		return FALSE
	else
		to_chat(user, "<span class='notice'>The object you are trying to wrap is unsuitable for the sorting machinery.</span>")
		return FALSE

	user.visible_message("<span class='notice'>[user] wraps [target].</span>")
	user.create_attack_log("<font color='blue'>Has used [name] on [target]</font>")
	add_attack_logs(user, target, "used [name]", ATKLOG_ALL)

	if(amount <= 0 && QDELETED(src)) //if we used our last wrapping paper, drop a cardboard tube
		var/obj/item/c_tube/T = new(get_turf(user))
		user.put_in_active_hand(T)
	return FALSE

// Separate proc to avoid copy pasting the code twice
/obj/item/stack/packageWrap/proc/wrap_closet(obj/structure/closet/C, mob/user)
	if(C.opened)
		return
	if(amount < 3)
		to_chat(user, "<span class='warning'>You need more paper.</span>")
		return
	if(!do_after_once(user, 1.5 SECONDS, target = C) || C.opened || !use(3)) // Checking these again since it's after a delay
		return
	var/obj/structure/bigDelivery/P = new(get_turf(C))
	P.wrapped = C
	C.loc = P
	return P

/obj/item/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"

	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	///Value of the tag
	var/currTag = 1
	//The whole system for the sort_type var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sort_type = list(1) --Superxpdude
	var/datum/ui_module/destination_tagger/destination_tagger

/obj/item/destTagger/Initialize(mapload)
	. = ..()
	destination_tagger = new(src)

/obj/item/destTagger/Destroy()
	QDEL_NULL(destination_tagger)
	return ..()

/obj/item/destTagger/attack_self(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/destTagger/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	destination_tagger.ui_interact(user)

/obj/machinery/disposal/deliveryChute
	name = "delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"
	required_mode_to_deconstruct = 1
	deconstructs_to = PIPE_DISPOSALS_CHUTE
	var/can_deconstruct = FALSE

/obj/machinery/disposal/deliveryChute/Initialize(mapload)
	. = ..()

	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/item/projectile)	|| isAI(AM) || QDELETED(AM))
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

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/deliveryCheck = 0
	var/obj/structure/disposalholder/H = new(src)	// virtual holder object which actually
													// travels through the pipes.
	for(var/obj/structure/bigDelivery/O in src)
		deliveryCheck = 1
	for(var/obj/item/smallDelivery/O in src)
		deliveryCheck = 1
	for(var/obj/item/shippingPackage/O in src)
		deliveryCheck = 1
		if(!O.sealed)		//unsealed shipping packages will default to disposals
			O.sortTag = 1
	if(deliveryCheck == 0)
		H.destinationTag = 1

	sleep(10)
	if(last_sound + DISPOSAL_SOUND_COOLDOWN < world.time)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, FALSE)
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

/obj/machinery/disposal/deliveryChute/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	can_deconstruct = !can_deconstruct
	to_chat(user, "You [can_deconstruct ? "unfasten": "fasten"] the screws around the power connection.")

/obj/machinery/disposal/deliveryChute/welder_act(mob/user, obj/item/I)
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

/obj/item/shippingPackage
	name = "Shipping package"
	desc = "A pre-labeled package for shipping an item to coworkers."
	icon = 'icons/obj/storage.dmi'
	icon_state = "shippack"
	var/obj/item/wrapped = null
	var/sortTag = 1
	var/sealed = 0

/obj/item/shippingPackage/attackby(obj/item/O, mob/user, params)
	if(sealed)
		if(is_pen(O))
			var/str = copytext(sanitize(input(user, "Intended recipient?", "Address", "")), 1, MAX_NAME_LEN)
			if(!str || !length(str))
				to_chat(user, "<span class='notice'>Invalid text.</span>")
				return
			user.visible_message("<span class='notice'>[user] addresses [src] to [str].</span>")
			name = "Shipping package (RE: [str])"
		return
	if(wrapped)
		to_chat(user, "<span class='notice'>[src] already contains \a [wrapped].</span>")
		return
	if(isitem(O) && !isstorage(O) && !istype(O, /obj/item/shippingPackage))
		if(!user.canUnEquip(O))
			to_chat(user, "<span class='warning'>[O] is stuck to your hand, you cannot put it in [src]!</span>")
			return
		if(O.w_class > 3)
			to_chat(user, "<span class='notice'>[O] is too large to fit in [src].</span>")
		else
			wrapped = O
			user.unEquip(O)
			O.forceMove(src)
			O.add_fingerprint(usr)
			add_fingerprint(usr)
			to_chat(user, "<span class='notice'>You put [O] in [src].</span>")

/obj/item/shippingPackage/attack_self(mob/user)
	if(sealed)
		to_chat(user, "<span class='notice'>You tear open [src], dropping the contents onto the floor.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
		user.unEquip(src)
		wrapped.forceMove(get_turf(user))
		wrapped = null
		qdel(src)
	else if(wrapped)
		switch(alert("Select an action:",, "Remove Object", "Seal Package", "Cancel"))
			if("Remove Object")
				to_chat(user, "<span class='notice'>You shake out [src]'s contents onto the floor.</span>")
				wrapped.forceMove(get_turf(user))
				wrapped = null
			if("Seal Package")
				to_chat(user, "<span class='notice'>You seal [src], preparing it for delivery.</span>")
				icon_state = "shippack_sealed"
				sealed = 1
				update_desc()
	else
		if(alert("Do you want to tear up the package?",, "Yes", "No") == "Yes")
			to_chat(user, "<span class='notice'>You shred [src].</span>")
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
			user.unEquip(src)
			qdel(src)

/obj/item/shippingPackage/update_desc()
	. = ..()
	desc = "A pre-labeled package for shipping an item to coworkers."
	if(sortTag)
		desc += " The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sortTag]]\"."
	if(!sealed)
		desc += " The package is not sealed."

/obj/item/shippingPackage/Destroy()
	QDEL_NULL(wrapped)
	return ..()
