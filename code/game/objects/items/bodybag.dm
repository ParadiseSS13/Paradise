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


/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"

/obj/item/weapon/storage/box/bodybags/New()
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


/obj/structure/closet/body_bag/attackby(W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if(user.get_active_hand() != W)
			return
		if(!in_range(src, user) && src.loc != user)
			return
		t = sanitize_local(copytext(t,1,MAX_MESSAGE_LEN))
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


/obj/structure/closet/body_bag/close()
	if(..())
		density = 0
		return 1
	return 0


/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))
			return
		if(opened)
			return 0
		if(contents.len)
			return 0
		visible_message("[usr] folds up the [src.name]")
		new item_path(get_turf(src))
		spawn(0)
			qdel(src)

/obj/structure/closet/body_bag/relaymove(mob/user as mob)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/structure/crematorium)))
		if(!open())
			to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed for the preservation of an occupant's body by stasis. Activates on occupant's unconscious state. Can be locked with medical ID."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/cryobag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
	R.add_fingerprint(user)
	R.desc = desc
	qdel(src)

/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	var/used = 0
	req_access = list(access_medical)

/obj/structure/closet/body_bag/cryobag/dump_contents()
	for(var/atom/movable/AM in src) //To prevent something standing on body_bag being affected
		if(!ismob(AM))
			continue
		var/mob/living/M = AM
		M.in_stasis = 0
		used = 1	//We consider bag as used only if there is actual human in it
	..()

/obj/structure/closet/body_bag/cryobag/open()
	. = ..()
	if(used) //happens after dump_contents()
		var/obj/item/O = new/obj/item(src.loc)
		O.name = "used stasis bag"
		O.icon = src.icon
		O.icon_state = "bodybag_used"
		O.desc = "Pretty useless now.."
		qdel(src)


/obj/structure/closet/body_bag/cryobag/close()
	. = ..()
	for(var/atom/movable/AM in src) //Atom already forcemoved into src in parent close() so we just searching from contents of src
		if(!ismob(AM))
			continue
		var/mob/living/M = AM
		M.in_stasis = 1

/obj/structure/closet/body_bag/cryobag/toggle(mob/user)
	if(!opened && locked && !src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied. Medical access only.</span>")
		return
	..()

/obj/structure/closet/body_bag/cryobag/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))
			return
		to_chat(usr, "<span class='warning'>You can't fold that up anymore..</span>")
	..()

/obj/structure/closet/body_bag/cryobag/attackby(W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(src.allowed(user))
			src.locked = !src.locked
			to_chat(user, "The controls are now [src.locked ? "locked. Medical access only." : "unlocked."]")
		else
			to_chat(user, "<span class='warning'>Access denied. Medical access only.</span>")
		return
