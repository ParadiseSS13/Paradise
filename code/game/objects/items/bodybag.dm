//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL

	attack_self(mob/user)
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
	sound = 'sound/items/zip.ogg'
	var/item_path = /obj/item/bodybag
	density = 0


/obj/structure/closet/body_bag/attackby(W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && src.loc != user)
			return
		t = sanitize(copytext(t,1,MAX_MESSAGE_LEN))
		if(t)
			src.name = "body bag - "
			src.name += t
			src.overlays += image(src.icon, "bodybag_label")
		else
			src.name = "body bag"
	//..() //Doesn't need to run the parent. Since when can fucking bodybags be welded shut? -Agouri
		return
	else if(istype(W, /obj/item/wirecutters))
		to_chat(user, "You cut the tag off the bodybag")
		src.name = "body bag"
		src.overlays.Cut()
		return


/obj/structure/closet/body_bag/close()
	if(..())
		density = 0
		return 1
	return 0


/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))	return
		if(opened)	return 0
		if(contents.len)	return 0
		visible_message("[usr] folds up the [src.name]")
		new item_path(get_turf(src))
		spawn(0)
			qdel(src)
		return

/obj/structure/closet/body_bag/relaymove(mob/user as mob)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/structure/crematorium)))
		if(!open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")
