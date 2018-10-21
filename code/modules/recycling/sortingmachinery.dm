/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = 1
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped = null
	var/init_welded = 0
	var/giftwrapped = 0
	var/sortTag = 0


/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	if(wrapped)
		wrapped.loc = get_turf(src)
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

	else if(istype(W, /obj/item/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		user.visible_message("<span class='notice'>[user] labels [src] as [str].</span>")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			giftwrapped = 1
			if(istype(wrapped, /obj/structure/closet/crate))
				icon_state = "giftcrate"
			else
				icon_state = "giftcloset"
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/c_tube( get_turf(user) )
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")


/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/obj/item/wrapped = null
	var/giftwrapped = 0
	var/sortTag = 0


/obj/item/smallDelivery/attack_self(mob/user as mob)
	if(wrapped && wrapped.loc) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = user.loc
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.loc = get_turf(src)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
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

	else if(istype(W, /obj/item/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		user.visible_message("<span class='notice'>[user] labels [src] as [str].</span>")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "giftcrate[wrapped.w_class]"
			giftwrapped = 1
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/c_tube( get_turf(user) )
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")



/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	singular_name = "package wrapper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = FLAMMABLE


/obj/item/stack/packageWrap/afterattack(var/obj/target as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/evidencebag) || istype(target, /obj/structure/closet/body_bag))
		return
	if(target.anchored)
		return
	if(target in user)
		return



	if(istype(target, /obj/item) && !(istype(target, /obj/item/storage) && !istype(target,/obj/item/storage/box) && !istype(target, /obj/item/shippingPackage)))
		var/obj/item/O = target
		if(use(1))
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
			if(!istype(O.loc, /turf))
				if(user.client)
					user.client.screen -= O
			P.wrapped = O
			O.loc = P
			var/i = round(O.w_class)
			if(i in list(1,2,3,4,5))
				P.icon_state = "deliverycrate[i]"
				P.w_class = i
			P.add_fingerprint(usr)
			O.add_fingerprint(usr)
			add_fingerprint(usr)
		else
			return
	else if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/O = target
		if(O.opened)
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.icon_state = "deliverycrate"
			P.wrapped = O
			O.loc = P
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
			return
	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if(O.opened)
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.wrapped = O
			P.init_welded = O.welded
			O.welded = 1
			O.loc = P
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
			return
	else
		to_chat(user, "<span class='notice'>The object you are trying to wrap is unsuitable for the sorting machinery.</span>")
		return

	user.visible_message("<span class='notice'>[user] wraps [target].</span>")
	user.create_attack_log("<font color='blue'>Has used [name] on [target]</font>")

	if(amount <= 0 && !src.loc) //if we used our last wrapping paper, drop a cardboard tube
		new /obj/item/c_tube( get_turf(user) )
	return

/obj/item/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"
	var/currTag = 0
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_BELT

/obj/item/destTagger/proc/openwindow(mob/user as mob)
	var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for(var/i = 1, i <= GLOB.TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=[UID()];nextTag=[i]'>[GLOB.TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? GLOB.TAGGERLOCATIONS[currTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/destTagger/attack_self(mob/user as mob)
	openwindow(user)
	return

/obj/item/destTagger/Topic(href, href_list)
	src.add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		src.currTag = n
	openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"

	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/New()
	..()
	spawn(5)
		trunk = locate() in src.loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/item/projectile))  return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != src.loc.y+1) return
		if(EAST)
			if(AM.loc.x != src.loc.x+1) return
		if(SOUTH)
			if(AM.loc.y != src.loc.y-1) return
		if(WEST)
			if(AM.loc.x != src.loc.x-1) return

	if(istype(AM, /obj))
		var/obj/O = AM
		O.loc = src
	else if(istype(AM, /mob))
		var/mob/M = AM
		M.loc = src
	src.flush()

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/deliveryCheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
													// travels through the pipes.
	for(var/obj/structure/bigDelivery/O in src)
		deliveryCheck = 1
		if(O.sortTag == 0)
			O.sortTag = 1
	for(var/obj/item/smallDelivery/O in src)
		deliveryCheck = 1
		if(O.sortTag == 0)
			O.sortTag = 1
	for(var/obj/item/shippingPackage/O in src)
		deliveryCheck = 1
		if(!O.sealed || O.sortTag == 0)		//unsealed or untagged shipping packages will default to disposals
			O.sortTag = 1
	if(deliveryCheck == 0)
		H.destinationTag = 1

	sleep(10)
	playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
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

/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user, params)
	if(!I || !user)
		return

	if(istype(I, /obj/item/screwdriver))
		if(c_mode==0)
			c_mode=1
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(c_mode==1)
			c_mode=0
			playsound(src.loc, I.usesound, 50, 1)
			to_chat(user, "You attach the screws around the power connection.")
			return
	else if(istype(I,/obj/item/weldingtool) && c_mode==1)
		var/obj/item/weldingtool/W = I
		if(W.remove_fuel(0,user))
			playsound(src.loc, W.usesound, 100, 1)
			to_chat(user, "You start slicing the floorweld off the delivery chute.")
			if(do_after(user, 20 * W.toolspeed, target = src))
				if(!src || !W.isOn()) return
				to_chat(user, "You sliced the floorweld off the delivery chute.")
				var/obj/structure/disposalconstruct/C = new (src.loc)
				C.ptype = PIPE_DISPOSALS_CHUTE
				C.update()
				C.anchored = 1
				C.density = 1
				qdel(src)
			return
		else
			to_chat(user, "You need more welding fuel to complete this task.")
			return


/obj/item/shippingPackage
	name = "Shipping package"
	desc = "A pre-labeled package for shipping an item to coworkers."
	icon = 'icons/obj/storage.dmi'
	icon_state = "shippack"
	var/obj/item/wrapped = null
	var/sortTag = 0
	var/sealed = 0

/obj/item/shippingPackage/attackby(obj/item/O, mob/user, params)
	if(sealed)
		if(istype(O, /obj/item/pen))
			var/str = copytext(sanitize(input(user,"Intended recipient?","Address","")),1,MAX_NAME_LEN)
			if(!str || !length(str))
				to_chat(user, "<span class='notice'>Invalid text.</span>")
				return
			user.visible_message("<span class='notice'>[user] addresses [src] to [str].</span>")
			name = "Shipping package (RE: [str])"
		return
	if(wrapped)
		to_chat(user, "<span class='notice'>[src] already contains \a [wrapped].</span>")
		return
	if(istype(O, /obj/item) && !istype(O, /obj/item/storage) && !istype(O, /obj/item/shippingPackage))
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

/obj/item/shippingPackage/proc/update_desc()
	desc = "A pre-labeled package for shipping an item to coworkers."
	if(sortTag)
		desc += " The label says \"Deliver to [GLOB.TAGGERLOCATIONS[sortTag]]\"."
	if(!sealed)
		desc += " The package is not sealed."

/obj/item/shippingPackage/Destroy()
	QDEL_NULL(wrapped)
	return ..()
