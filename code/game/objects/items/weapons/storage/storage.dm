// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm, params)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/silent = FALSE // No message on putting items in
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)
	var/empty = FALSE // Will this spawn as an empty box
	var/max_w_class = WEIGHT_CLASS_SMALL //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/pickup_all_on_tile = TRUE  //FALSE = pick one at a time, TRUE = pick all on tile
	var/use_sound = "rustle"	//sound played when used. null for no sound.

	/// What kind of [/obj/item/stack] can this be folded into. (e.g. Boxes and cardboard)
	var/foldable = null
	/// How much of the stack item do you get.
	var/foldable_amt = 0

/obj/item/storage/MouseDrop(obj/over_object)
	if(ishuman(usr)) //so monkeys can take off their backpacks -- Urist
		var/mob/M = usr

		if(istype(M.loc,/obj/mecha) || M.incapacitated(FALSE, TRUE, TRUE)) // Stops inventory actions in a mech as well as while being incapacitated
			return

		if(over_object == M && Adjacent(M)) // this must come before the screen objects only block
			if(M.s_active)
				M.s_active.close(M)
			show_to(M)
			return

		if((istype(over_object, /obj/structure/table) || istype(over_object, /turf/simulated/floor)) \
			&& contents.len && loc == usr && !usr.stat && !usr.restrained() && usr.canmove && over_object.Adjacent(usr) \
			&& !istype(src, /obj/item/storage/lockbox))
			var/turf/T = get_turf(over_object)
			if(istype(over_object, /turf/simulated/floor))
				if(get_turf(usr) != T)
					return // Can only empty containers onto the floor under you
				if("Yes" != alert(usr,"Empty \the [src] onto \the [T]?","Confirm","Yes","No"))
					return
				if(!(usr && over_object && contents.len && loc == usr && !usr.stat && !usr.restrained() && usr.canmove && get_turf(usr) == T))
					return // Something happened while the player was thinking
			hide_from(usr)
			usr.face_atom(over_object)
			usr.visible_message("<span class='notice'>[usr] empties \the [src] onto \the [over_object].</span>",
				"<span class='notice'>You empty \the [src] onto \the [over_object].</span>")
			for(var/obj/item/I in contents)
				remove_from_storage(I, T)
			update_icon() // For content-sensitive icons
			return

		if(!(istype(over_object, /obj/screen)))
			return ..()
		if(!(loc == usr) || (loc && loc.loc == usr))
			return
		playsound(loc, "rustle", 50, TRUE, -5)
		if(!(M.restrained()) && !(M.stat))
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return

/obj/item/storage/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE, TRUE))
		show_to(user)
		playsound(loc, "rustle", 50, TRUE, -5)
		add_fingerprint(user)
	else if(isobserver(user))
		show_to(user)
	return ..()

/obj/item/storage/proc/return_inv()
	var/list/L = list()

	L += contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if(istype(G.gift, /obj/item/storage))
			L += G.gift:return_inv()
	for(var/obj/item/folder/F in src)
		L += F.contents
	return L

/obj/item/storage/proc/show_to(mob/user)
	if(!user.client)
		return
	if(user.s_active != src)
		for(var/obj/item/I in src)
			if(I.on_found(user))
				return
	orient2hud(user)  // this only needs to happen to make .contents show properly as screen objects.
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	user.client.screen += boxes
	user.client.screen += closer
	user.client.screen += contents
	user.s_active = src
	return

/obj/item/storage/proc/hide_from(mob/user)
	if(!user.client)
		return

	user.client.screen -= boxes
	user.client.screen -= closer
	user.client.screen -= contents
	if(user.s_active == src)
		user.s_active = null
	return

/obj/item/storage/proc/open(mob/user as mob)
	if(use_sound)
		playsound(loc, use_sound, 50, TRUE, -5)

	if(user.s_active)
		user.s_active.close(user)
	show_to(user)

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	user.s_active = null

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx],[ty] to [mx],[my]"
	for(var/obj/O in contents)
		O.screen_loc = "[cx],[cy]"
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx + 1],[my]"

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/storage/proc/standard_orient_objs(rows, cols, list/datum/numbered_display/display_contents)
	var/cx = 4
	var/cy = 2 + rows
	boxes.screen_loc = "4:16,2:16 to [4 + cols]:16,[2 + rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = MOUSE_OPACITY_OPAQUE
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white' face='Small Fonts'>[(ND.number > 1) ? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			ND.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4 + cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			O.mouse_opacity = MOUSE_OPACITY_OPAQUE //This is here so storage items that spawn with contents correctly have the "click around item to equip"
			O.screen_loc = "[cx]:16,[cy]:16"
			O.maptext = ""
			O.layer = ABOVE_HUD_LAYER
			O.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4 + cols))
				cx = 4
				cy--
	closer.screen_loc = "[4 + cols + 1]:16,2:16"

/datum/numbered_display
	var/obj/item/sample_object
	var/number

/datum/numbered_display/New(obj/item/sample)
	if(!istype(sample))
		qdel(src)
		return
	sample_object = sample
	number = 1

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/storage/proc/orient2hud(mob/user)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/display_contents
	if(display_contents_with_number)
		for(var/obj/O in contents)
			O.layer = initial(O.layer)
			O.plane = initial(O.plane)

		display_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in contents)
			var/found = FALSE
			for(var/datum/numbered_display/ND in display_contents)
				if(ND.sample_object.type == I.type && ND.sample_object.name == I.name)
					ND.number++
					found = TRUE
					break
			if(!found)
				adjusted_contents++
				display_contents.Add(new/datum/numbered_display(I))

	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7, storage_slots) - 1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents - 1) / 7) // 7 is the maximum allowed width.
	standard_orient_objs(row_num, col_count, display_contents)

//This proc returns TRUE if the item can be picked up and FALSE if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!istype(W) || (W.flags & ABSTRACT)) //Not an item
		return

	if(loc == W)
		return FALSE //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>[W] won't fit in [src], make some space!</span>")
		return FALSE //Storage item is full

	if(can_hold.len)
		if(!is_type_in_typecache(W, can_hold))
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	if(is_type_in_typecache(W, cant_hold)) //Check for specific items which this container can't hold.
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
		return FALSE

	if(W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[W] is too big for [src].</span>")
		return FALSE

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE

	if(W.w_class >= w_class && (istype(W, /obj/item/storage)))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W] as it's a storage item of the same size.</span>")
			return FALSE //To prevent the stacking of same sized storage items.

	if(W.flags & NODROP) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(usr, "<span class='notice'>\the [W] is stuck to your hand, you can't put it in \the [src]</span>")
		return FALSE

	return TRUE

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	if(!istype(W))
		return FALSE
	if(usr)
		if(!usr.unEquip(W))
			return FALSE
		usr.update_icons()	//update our overlays
	if(silent)
		prevent_warning = TRUE
	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		if(usr.client && usr.s_active != src)
			usr.client.screen -= W
		W.dropped(usr)
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/gun/energy/kinetic_accelerator/crossbow))
			for(var/mob/M in viewers(usr, null))
				if(M == usr)
					to_chat(usr, "<span class='notice'>You put [W] into [src].</span>")
				else if(M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>")
				else if(W && W.w_class >= WEIGHT_CLASS_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>")

		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	W.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	W.in_inventory = TRUE
	update_icon()
	return TRUE

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/W, atom/new_location)
	if(!istype(W))
		return FALSE

	if(istype(src, /obj/item/storage/fancy))
		var/obj/item/storage/fancy/F = src
		F.update_icon(TRUE)

	for(var/mob/M in range(1, loc))
		if(M.s_active == src)
			if(M.client)
				M.client.screen -= W

	if(new_location)
		if(ismob(loc))
			W.dropped(usr)
		if(ismob(new_location))
			W.layer = ABOVE_HUD_LAYER
			W.plane = ABOVE_HUD_PLANE
		else
			W.layer = initial(W.layer)
			W.plane = initial(W.plane)
		W.forceMove(new_location)
	else
		W.forceMove(get_turf(src))

	if(usr)
		orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()
	W.mouse_opacity = initial(W.mouse_opacity)
	return TRUE

/obj/item/storage/Exited(atom/A, loc)
	remove_from_storage(A, loc) //worry not, comrade; this only gets called once
	..()

/obj/item/storage/deconstruct(disassembled = TRUE)
	var/drop_loc = loc
	if(ismob(loc))
		drop_loc = get_turf(src)
	for(var/obj/item/I in contents)
		remove_from_storage(I, drop_loc)
	qdel(src)

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/hand_labeler))
		var/obj/item/hand_labeler/labeler = I
		if(labeler.mode)
			return FALSE
	. = TRUE //no afterattack
	if(isrobot(user))
		return //Robots can't interact with storage items.

	if(!can_be_inserted(I))
		if(contents.len >= storage_slots) //don't use items on the backpack if they don't fit
			return TRUE
		return FALSE

	handle_item_insertion(I)

/obj/item/storage/attack_hand(mob/user)
	playsound(loc, "rustle", 50, TRUE, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return

	orient2hud(user)
	if(loc == user)
		if(user.s_active)
			user.s_active.close(user)
		show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if(M.s_active == src)
				close(M)
	add_fingerprint(user)

/obj/item/storage/attack_ghost(mob/user)
	if(isobserver(user))
		// Revenants don't get to play with the toys.
		show_to(user)
	return ..()

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	pickup_all_on_tile = !pickup_all_on_tile
	switch(pickup_all_on_tile)
		if(TRUE)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(FALSE)
			to_chat(usr, "[src] now picks up one item at a time.")

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.stat || usr.restrained())
		return

	drop_inventory(usr)

/obj/item/storage/proc/drop_inventory(user)
	var/turf/T = get_turf(src)
	hide_from(user)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T)
		CHECK_TICK

/obj/item/storage/New()
	..()
	can_hold = typecacheof(can_hold)
	cant_hold = typecacheof(cant_hold)

	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	boxes = new /obj/screen/storage()
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE
	closer = new /obj/screen/close()
	closer.master = src
	closer.icon_state = "backpack_close"
	closer.layer = ABOVE_HUD_LAYER
	closer.plane = ABOVE_HUD_PLANE
	orient2hud()

/obj/item/storage/Destroy()
	for(var/obj/O in contents)
		O.mouse_opacity = initial(O.mouse_opacity)

	QDEL_NULL(boxes)
	QDEL_NULL(closer)
	return ..()

/obj/item/storage/emp_act(severity)
	..()
	for(var/i in contents)
		var/atom/A = i
		A.emp_act(severity)

/obj/item/storage/hear_talk(mob/living/M, list/message_pieces)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, message_pieces)

/obj/item/storage/hear_message(mob/living/M, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if allow_quick_empty is TRUE
	if(allow_quick_empty && user.is_in_active_hand(src))
		drop_inventory(user)

	else if(foldable)
		fold(user)

/obj/item/storage/proc/fold(mob/user)
	if(length(contents))
		to_chat(user, "<span class='warning'>You can't fold this [name] with items still inside!</span>")
		return
	if(!ispath(foldable))
		return

	var/found = FALSE
	for(var/mob/M in range(1))
		if(M.s_active == src) // Close any open UI windows first
			close(M)
		if(M == user)
			found = TRUE
	if(!found)	// User is too far away
		return

	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	var/obj/item/stack/I = new foldable(get_turf(src), foldable_amt)
	user.put_in_hands(I)
	qdel(src)

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/storage/serialize()
	var/data = ..()
	var/list/content_list = list()
	data["content"] = content_list
	data["slots"] = storage_slots
	data["max_w_class"] = max_w_class
	data["max_c_w_class"] = max_combined_w_class
	for(var/thing in contents)
		var/atom/movable/AM = thing
		// This code does not watch out for infinite loops
		// But then again a tesseract would destroy the server anyways
		// Also I wish I could just insert a list instead of it reading it the wrong way
		content_list.len++
		content_list[content_list.len] = AM.serialize()
	return data

/obj/item/storage/deserialize(list/data)
	if(isnum(data["slots"]))
		storage_slots = data["slots"]
	if(isnum(data["max_w_class"]))
		max_w_class = data["max_w_class"]
	if(isnum(data["max_c_w_class"]))
		max_combined_w_class = data["max_c_w_class"]
	for(var/thing in contents)
		qdel(thing) // out with the old
	for(var/thing in data["content"])
		if(islist(thing))
			list_to_object(thing, src)
		else if(thing == null)
			log_runtime(EXCEPTION("Null entry found in storage/deserialize."), src)
		else
			log_runtime(EXCEPTION("Non-list thing found in storage/deserialize."), src, list("Thing: [thing]"))
	..()

/obj/item/storage/AllowDrop()
	return TRUE

/obj/item/storage/ex_act(severity)
	for(var/atom/A in contents)
		A.ex_act(severity)
		CHECK_TICK
	..()

/obj/item/storage/proc/can_items_stack(obj/item/item_1, obj/item/item_2)
	if(!item_1 || !item_2)
		return

	return item_1.type == item_2.type && item_1.name == item_2.name

/obj/item/storage/proc/swap_items(obj/item/item_1, obj/item/item_2, mob/user = null)
	if(!(item_1.loc == src && item_2.loc == src))
		return

	var/index_1 = contents.Find(item_1)
	var/index_2 = contents.Find(item_2)

	var/list/new_contents = contents.Copy()
	new_contents.Swap(index_1, index_2)
	contents = new_contents

	if(user && user.s_active == src)
		orient2hud(user)
		show_to(user)
