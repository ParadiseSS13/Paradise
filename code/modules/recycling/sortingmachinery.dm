/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = 1
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/iconLabeled = "deliverycloset_labeled"
	var/obj/wrapped = null
	var/init_welded = 0
	var/giftwrapped = 0
	var/sortTag = 0

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
			O.add_fingerprint(user)
			O.welded = init_welded
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.add_fingerprint(user)
		AM.loc = T

	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/O = W

		if(sortTag != O.currTag)
			add_fingerprint(user)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			if(iconLabeled)
				icon_state = iconLabeled
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/shippingPackage))
		var/obj/item/shippingPackage/sp = W
		if(sp.sealed)
			return
		else
			add_fingerprint(user)
			sortTag = sp.sortTag
			if(iconLabeled)
				icon_state = iconLabeled
			to_chat(user, "<span class='notice'>You rip the label off the shipping package and affix it to [src].</span>")
			qdel(sp)
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)

	else if(istype(W, /obj/item/pen))
		add_fingerprint(user)
		rename_interactive(user, W)

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			add_fingerprint(user)
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			giftwrapped = 1
			if(istype(wrapped, /obj/structure/closet/crate))
				icon_state = "giftcrate"
			else
				icon_state = "giftcloset"
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				var/obj/item/c_tube/tube = new(get_turf(user))
				tube.add_fingerprint(user)
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		return ..()

/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	item_state = "deliverypackage"
	var/iconLabeled = null
	var/obj/item/wrapped = null
	var/giftwrapped = 0
	var/sortTag = 0

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
			add_fingerprint(user)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = O.currTag
			if(iconLabeled)
				icon_state = iconLabeled
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/shippingPackage))
		var/obj/item/shippingPackage/sp = W
		if(sp.sealed)
			return
		else
			add_fingerprint(user)
			sortTag = sp.sortTag
			if(iconLabeled)
				icon_state = iconLabeled
			to_chat(user, "<span class='notice'>You rip the label off the shipping package and affix it to [src].</span>")
			qdel(sp)
			playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)

	else if(istype(W, /obj/item/pen))
		add_fingerprint(user)
		rename_interactive(user, W)

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "giftcrate[wrapped.w_class]"
			giftwrapped = 1
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				var/obj/item/c_tube/tube = new(get_turf(user))
				tube.add_fingerprint(user)
		else
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else
		return ..()

/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	singular_name = "package wrapper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE
	var/static/list/no_wrap = list(
		/obj/item/shippingPackage,
		/obj/item/smallDelivery,
		/obj/structure/bigDelivery,
		/obj/item/evidencebag,
		/obj/structure/closet/body_bag,
		/obj/item/twohanded/required,
		/obj/item/storage,
		/obj/item/mecha_parts/chassis
	)


/obj/item/stack/packageWrap/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(is_type_in_list(target, no_wrap))
		return
	if(target.anchored)
		return
	if(target in user)
		return

	if(isitem(target))
		var/obj/item/item = target
		if(!use(1))
			return

		var/obj/item/smallDelivery/package = new(get_turf(item))	//Aaannd wrap it up!
		if(!isturf(item.loc) && user.client)
			user.client.screen -= item

		package.wrapped = item
		item.loc = package
		var/i = round(item.w_class)
		if(i > 5)
			package.icon_state = "deliverycrate5"
			package.iconLabeled = "deliverycrate5_labeled"
		else if(i < 1)
			package.icon_state = "deliverycrate1"
			package.iconLabeled = "deliverycrate1_labeled"
		else
			package.icon_state = "deliverycrate[i]"
			package.iconLabeled = "deliverycrate[i]_labeled"
		package.w_class = i
		package.add_fingerprint(user)
		item.add_fingerprint(user)

	else if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = target
		if(crate.opened)
			return

		if(amount < 3)
			to_chat(user, span_notice("You need more paper."))
			return

		if(!do_after_once(user, 1.5 SECONDS, target = crate))
			return

		if(crate.opened || !use(3))
			return

		var/obj/structure/bigDelivery/package = new(get_turf(crate))
		package.icon_state = "deliverycrate"
		package.iconLabeled = "deliverycrate_labeled"
		package.wrapped = crate
		crate.loc = package
		package.add_fingerprint(user)
		crate.add_fingerprint(user)

	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/closet = target
		if(closet.opened)
			return

		if(amount < 3)
			to_chat(user, span_notice("You need more paper."))
			return

		if(!do_after_once(user, 1.5 SECONDS, target = closet))
			return

		if(closet.opened || !use(3))
			return

		var/obj/structure/bigDelivery/package = new(get_turf(closet))
		package.wrapped = closet
		package.init_welded = closet.welded
		closet.welded = TRUE
		closet.loc = package
		package.add_fingerprint(user)
		closet.add_fingerprint(user)

	else
		to_chat(user, span_notice("The object you are trying to wrap is unsuitable for the sorting machinery."))
		return

	user.visible_message(span_notice("[user] wraps [target]."))
	add_attack_logs(user, target, "used [name]", ATKLOG_ALL)

	if(amount <= 0 && !src.loc) //if we used our last wrapping paper, drop a cardboard tube
		var/obj/item/c_tube/tube = new(get_turf(user))
		tube.add_fingerprint(user)


/obj/item/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/currTag = 1
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

/obj/item/destTagger/attack_self(mob/user)
	ui_interact(user)

/obj/item/destTagger/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "DestinationTagger", name, 395, 350, master_ui, state)
		ui.open()

/obj/item/destTagger/ui_data(mob/user)
	var/list/data = list()
	data["selected_destination_id"] = clamp(currTag, 1, length(GLOB.TAGGERLOCATIONS))
	return data

/obj/item/destTagger/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["destinations"] = list()
	for(var/destination_index in 1 to length(GLOB.TAGGERLOCATIONS))
		var/list/destination_data = list(
			"name" = GLOB.TAGGERLOCATIONS[destination_index],
			"id"   = destination_index,
		)
		static_data["destinations"] += list(destination_data)
	return static_data

/obj/item/destTagger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(action == "select_destination")
		var/destination_id = clamp(text2num(params["destination"]), 1, length(GLOB.TAGGERLOCATIONS))
		if(currTag != destination_id)
			currTag = destination_id
			playsound(src, "terminal_type", 25, TRUE)
			add_fingerprint(usr)

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
		if(!user.can_unEquip(O))
			to_chat(user, "<span class='warning'>[O] is stuck to your hand, you cannot put it in [src]!</span>")
			return
		if(O.w_class > 3)
			to_chat(user, "<span class='notice'>[O] is too large to fit in [src].</span>")
		else
			wrapped = O
			user.drop_transfer_item_to_loc(O, src)
			O.add_fingerprint(usr)
			add_fingerprint(usr)
			to_chat(user, "<span class='notice'>You put [O] in [src].</span>")

/obj/item/shippingPackage/attack_self(mob/user)
	if(sealed)
		to_chat(user, "<span class='notice'>You tear open [src], dropping the contents onto the floor.</span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 50, 1)
		user.temporarily_remove_item_from_inventory(src)
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
			user.temporarily_remove_item_from_inventory(src)
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
