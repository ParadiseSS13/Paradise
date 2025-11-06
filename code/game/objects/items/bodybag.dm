//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bodybag/attack_self__legacy__attackchain(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

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

/obj/structure/closet/body_bag/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(is_pen(I))
		var/t = rename_interactive(user, I)
		if(isnull(t))
			return ITEM_INTERACT_COMPLETE
		cut_overlays()
		if(t)
			add_overlay("bodybag_label")
		return ITEM_INTERACT_COMPLETE
	if(istype(I, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")
		name = initial(name)
		cut_overlays()
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/closet/body_bag/welder_act(mob/user, obj/item/I)
	return // Can't weld a body bag shut

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
		visible_message("<span class='notice'>[usr] folds up [src].</span>")
		new item_path(get_turf(src))
		qdel(src)
		return
	. = ..()

/obj/structure/closet/body_bag/relaymove(mob/user)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/structure/crematorium)))
		if(!open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/body_bag/shove_impact(mob/living/target, mob/living/attacker)
	// no, you can't shove people into a body bag
	return FALSE
