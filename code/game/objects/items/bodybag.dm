//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = 2

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
		R.add_fingerprint(user)
		qdel(src)


/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	New()
		..()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)


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


	attackby(W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/pen))
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
		else if(istype(W, /obj/item/weapon/wirecutters))
			to_chat(user, "You cut the tag off the bodybag")
			src.name = "body bag"
			src.overlays.Cut()
			return


	close()
		if(..())
			density = 0
			return 1
		return 0


	MouseDrop(over_object, src_location, over_location)
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

/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
		R.add_fingerprint(user)
		qdel(src)



/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	var/used = 0
	var/locked = 0
	req_access = list(access_medical)

	open()
		. = ..()
		if(used)
			var/obj/item/O = new/obj/item(src.loc)
			O.name = "used stasis bag"
			O.icon = src.icon
			O.icon_state = "bodybag_used"
			O.desc = "Pretty useless now.."
			qdel(src)

	MouseDrop(over_object, src_location, over_location)
		if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
			if(!ishuman(usr))	return
			to_chat(usr, "\red You can't fold that up anymore..")
		..()

	attackby(W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
			if(src.allowed(user))
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				to_chat(user, "\red Access denied.")
			return