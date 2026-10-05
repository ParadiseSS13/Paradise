// Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	new_attack_chain = TRUE

/obj/item/bodybag/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	transfer_fingerprints_to(R)
	R.add_fingerprint(user)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	enable_door_overlay = FALSE
	door_anim_time = 0
	density = FALSE
	integrity_failure = 0
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	var/item_path = /obj/item/bodybag

/obj/structure/closet/body_bag/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_pen(used))
		return ..()
	var/new_name = rename_interactive(user, used)
	if(isnull(new_name))
		return ITEM_INTERACT_COMPLETE
	cut_overlays()
	if(new_name)
		add_overlay("bodybag_label")
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/structure/closet/body_bag/wirecutter_act(mob/user, obj/item/used)
	if(!istype(used, /obj/item/wirecutters))
		return
	if(name == initial(name))
		return
	user.visible_message(
		SPAN_NOTICE("[user] cuts the tag off the body bag."),
		SPAN_NOTICE("You cut the tag off the body bag."),
		SPAN_HEAR("You hear a little snip.")
	)
	name = initial(name)
	cut_overlays()
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/structure/closet/body_bag/welder_act(mob/user, obj/item/I)
	return // Can't weld a body bag shut.

/obj/structure/closet/body_bag/close()
	if(..())
		density = FALSE
		return TRUE
	return FALSE

/obj/structure/closet/body_bag/update_overlays()
	. = ..()
	if(name != initial(name))
		. += "bodybag_label"

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr) || opened || length(contents))
			return FALSE
		visible_message(SPAN_NOTICE("[usr] folds up [src]."))
		var/obj/item/bodybag/new_bag = new item_path(get_turf(src))
		transfer_fingerprints_to(new_bag)
		new_bag.add_fingerprint(usr)
		qdel(src)
		return
	. = ..()

/obj/structure/closet/body_bag/relaymove(mob/user)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums.
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/structure/crematorium)))
		if(!open())
			to_chat(user, SPAN_NOTICE("It won't budge!"))

/obj/structure/closet/body_bag/shove_impact(mob/living/target, mob/living/attacker)
	// No, you can't shove people into a body bag.
	return FALSE
