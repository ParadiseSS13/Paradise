//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = FALSE
	integrity_failure = 0
	sound = 'sound/items/zip.ogg'
	var/item_path = /obj/item/bodybag


/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen))
		var/t = rename_interactive(user, I)
		if(isnull(t))
			return
		cut_overlays()
		if(t)
			add_overlay(image(icon, "bodybag_label"))
		return
	if(istype(I, /obj/item/wirecutters))
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")
		name = initial(name)
		cut_overlays()
		return
	return ..()

/obj/structure/closet/body_bag/welder_act(mob/user, obj/item/I)
	return // Can't weld a body bag shut

/obj/structure/closet/body_bag/close()
	if(..())
		density = 0
		return TRUE
	return FALSE


/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr) || opened || length(contents))
			return FALSE
		visible_message("[usr] folds up the [name]")
		new item_path(get_turf(src))
		qdel(src)

/obj/structure/closet/body_bag/relaymove(mob/user)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/structure/crematorium)))
		if(!open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")
