/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = 1
	burn_state = FLAMMABLE


/********
* photo *
********/
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = 2
	burn_state = FLAMMABLE
	burntime = 5
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3

/obj/item/weapon/photo/attack_self(mob/user as mob)
	user.examinate(src)

/obj/item/weapon/photo/attackby(obj/item/weapon/P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	else if(istype(P, /obj/item/weapon/lighter))
		burnphoto(P, user)
	..()

/obj/item/weapon/photo/proc/burnphoto(obj/item/weapon/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/weapon/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.")

				if(user.get_inactive_hand() == src)
					user.unEquip(src)

				new /obj/effect/decal/cleanable/ash(get_turf(src))
				qdel(src)

			else
				to_chat(user, "\red You must hold \the [P] steady to burn \the [src].")

/obj/item/weapon/photo/examine(mob/user)
	if(..(user, 1) || isobserver(user))
		show(user)
	else
		to_chat(user, "<span class='notice'>It is too far away.</span>")

/obj/item/weapon/photo/proc/show(mob/user as mob)
	usr << browse_rsc(img, "tmp_photo.png")
	usr << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(usr, "[name]")
	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = sanitize(copytext(input(usr, "What would you like to label the photo?", "Photo Labelling", name) as text, 1, MAX_MESSAGE_LEN))
	//loc.loc check is for making possible renaming photos in clipboards
	if(( (loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "photo")]"
	add_fingerprint(usr)
	return


/**************
* photo album *
**************/
/obj/item/weapon/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list("/obj/item/weapon/photo")
	burn_state = FLAMMABLE

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if((istype(usr, /mob/living/carbon/human)))
		var/mob/M = usr
		if(!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if((!( M.restrained() ) && !( M.stat ) && M.back == src))
			switch(over_object.name)
				if("r_hand")
					M.unEquip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.unEquip(src)
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2
	slot_flags = SLOT_BELT
	var/list/matter = list("metal" = 2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/size = 3
	var/see_ghosts = 0 //for the spoop of it


/obj/item/device/camera/spooky/CheckParts(list/parts_list)
	..()
	var/obj/item/device/camera/C = locate(/obj/item/device/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)


var/list/SpookyGhosts = list("ghost","shade","shade2","ghost-narsie","horror","shadow","ghostian2")

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/device/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"
	var/nsize = input("Photo Size","Pick a size of resulting photo.") as null|anything in list(1,3,5,7)
	if(nsize)
		size = nsize
		to_chat(usr, "<span class='notice'>Camera will now take [size]x[size] photos.</span>")

/obj/item/device/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/device/camera/attack_self(mob/user as mob)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/device/camera/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/proc/get_icon(list/turfs, turf/center,mob/user)

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(size*32, size*32)
	// Initialize the photograph to black.
	res.Blend("#000", ICON_OVERLAY)

	var/atoms[] = list()
	for(var/turf/the_turf in turfs)
		// Add outselves to the list of stuff to draw
		atoms.Add(the_turf);
		// As well as anything that isn't invisible.
		for(var/atom/A in the_turf)
			if(A.invisibility )
				if(see_ghosts && istype(A,/mob/dead/observer))
					var/mob/dead/observer/O = A
					if(O.following)
						continue
					if(user.mind && !(user.mind.assigned_role == "Chaplain"))
						atoms.Add(image('icons/mob/mob.dmi', O.loc, pick(SpookyGhosts), 4, SOUTH))
					else
						atoms.Add(image('icons/mob/mob.dmi', O.loc, "ghost", 4, SOUTH))
				else//its not a ghost
					continue
			else//not invisable, not a spookyghost add it.
				atoms.Add(A)


	// Sort the atoms into their layers
	var/list/sorted = sort_atoms_by_layer(atoms)
	var/center_offset = (size-1)/2 * 32 + 1
	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)

			// If what we got back is actually a picture, draw it.
			if(istype(img, /icon))
				// Check if we're looking at a mob that's lying down
				if(istype(A, /mob/living) && A:lying)
					// If they are, apply that effect to their picture.
					img.BecomeLying()
				// Calculate where we are relative to the center of the photo
				var/xoff = (A.x - center.x) * 32 + center_offset
				var/yoff = (A.y - center.y) * 32 + center_offset
				if(istype(A,/atom/movable))
					xoff+=A:step_x
					yoff+=A:step_y
				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	// Lastly, render any contained effects on top.
	for(var/turf/the_turf in turfs)
		// Calculate where we are relative to the center of the photo
		var/xoff = (the_turf.x - center.x) * 32 + center_offset
		var/yoff = (the_turf.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(the_turf.loc), blendMode2iconMode(the_turf.blend_mode),xoff,yoff)
	return res


/obj/item/device/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/M in the_turf)
		if(M.invisibility)
			if(see_ghosts && istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if(O.following)
					continue
				if(!mob_detail)
					mob_detail = "You can see a g-g-g-g-ghooooost! "
				else
					mob_detail += "You can also see a g-g-g-g-ghooooost!"
			else
				continue

		var/holding = null

		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/A = M
			if(A.l_hand || A.r_hand)
				if(A.l_hand) holding = "They are holding \a [A.l_hand]"
				if(A.r_hand)
					if(holding)
						holding += " and \a [A.r_hand]"
					else
						holding = "They are holding \a [A.r_hand]"

			if(!mob_detail)
				mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/device/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = 0
	if(user.mind && !(user.mind.assigned_role == "Chaplain"))
		if(prob(24))
			handle_haunt(user)
	spawn(64)
		icon_state = icon_on
		on = 1

/obj/item/device/camera/proc/can_capture_turf(turf/T, mob/user)
	var/mob/dummy = new(T)	//Go go visibility check dummy
	var/viewer = user
	if(user.client)		//To make shooting through security cameras possible
		viewer = user.client.eye
	var/can_see = (dummy in viewers(world.view, viewer)) != null

	dummy.loc = null
	dummy = null	//Alas, nameless creature	//garbage collect it instead
	return can_see

/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag)
	printpicture(user, P)

/obj/item/device/camera/proc/createpicture(atom/target, mob/user, list/turfs, mobs, flag)
	var/icon/photoimage = get_icon(turfs, target,user)

	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

	var/datum/picture/P = new()
	if(istype(src,/obj/item/device/camera/digital))
		P.fields["name"] = input(user,"Name photo:","photo")
		P.name = P.fields["name"]//So the name is displayed on the print/delete list.
	else
		P.fields["name"] = "photo"
	P.fields["author"] = user
	P.fields["icon"] = ic
	P.fields["tiny"] = pc
	P.fields["img"] = photoimage
	P.fields["desc"] = mobs
	P.fields["pixel_x"] = rand(-10, 10)
	P.fields["pixel_y"] = rand(-10, 10)
	P.fields["size"] = size

	return P

/obj/item/device/camera/proc/printpicture(mob/user, var/datum/picture/P)
	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo()
	Photo.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)
	Photo.construct(P)

/obj/item/weapon/photo/proc/construct(var/datum/picture/P)
	name = P.fields["name"]
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]
	photo_size = P.fields["size"]

/obj/item/weapon/photo/proc/copy()
	var/obj/item/weapon/photo/p = new/obj/item/weapon/photo()

	p.icon = icon(icon, icon_state)
	p.img = icon(img)
	p.tiny = icon(tiny)
	p.name = name
	p.desc = desc
	p.scribble = scribble

	return p

/*****************
* digital camera *
******************/
/obj/item/device/camera/digital
	name = "digital camera"
	desc = "A digital camera. A small screen shows there is space for 10 photos left."
	var/list/datum/picture/saved_pictures = list()
	pictures_left = 30
	var/max_storage = 10

/obj/item/device/camera/digital/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	desc = "A digital camera. A small screen shows that there are currently [saved_pictures.len] pictures stored."
	icon_state = icon_off
	on = 0
	spawn(64)
		icon_state = icon_on
		on = 1

/obj/item/device/camera/digital/captureimage(atom/target, mob/user, flag)
	if(saved_pictures.len >= max_storage)
		to_chat(user, "<span class='notice'>Maximum photo storage capacity reached.</span>")
		return
	to_chat(user, "Picture saved.")
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag)
	saved_pictures += P

/obj/item/device/camera/digital/verb/print_picture()
	set name = "Print picture"
	set category = "Object"
	set src in usr

	if(saved_pictures.len == 0)
		to_chat(usr, "<span class='userdanger'>No images saved.</span>")
		return
	if(pictures_left == 0)
		to_chat(usr, "<span class='userdanger'>There is no film left to print.</span>")
		return

	var/datum/picture/P = null
	P = input("Select image to print:",P) as null|anything in saved_pictures
	if(P)
		printpicture(usr,P)
		pictures_left --

/obj/item/device/camera/digital/verb/delete_picture()
	set name = "Delete picture"
	set category = "Object"
	set src in usr

	if(saved_pictures.len == 0)
		to_chat(usr, "<span class='userdanger'>No images saved</span>")
		return
	var/datum/picture/P = null
	P = input("Select image to delete:",P) as null|anything in saved_pictures
	if(P)
		saved_pictures -= P

/**************
*video camera *
***************/

/obj/item/device/videocam
	name = "video camera"
	icon = 'icons/obj/items.dmi'
	desc = "video camera that can send live feed to the entertainment network."
	icon_state = "videocam"
	item_state = "videocam"
	w_class = 2
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=2000)
	var/on = 0
	var/obj/machinery/camera/camera
	var/icon_on = "videocam_on"
	var/icon_off = "videocam"
	var/canhear_range = 7

/obj/item/device/videocam/attack_self(mob/user)
	on = !on
	if(camera)
		if(on==0)
			src.icon_state = icon_off
			camera.c_tag = null
			camera.network = null
		else
			src.icon_state = icon_on
			camera.network = list("news")
			camera.c_tag = user.name
	else

		src.icon_state = icon_on
		camera = new /obj/machinery/camera(src)
		camera.network = list("news")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
	to_chat(user, "You switch the camera [on ? "on" : "off"].")

/obj/item/device/videocam/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "This video camera can send live feeds to the entertainment network. It's [camera ? "" : "in"]active.")

/obj/item/device/videocam/hear_talk(mob/M as mob, msg)
	if(camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/obj/machinery/computer/security/telescreen/T in machines)
			if(T.current == camera)
				T.audible_message("<span class='game radio'><span class='name'>(Newscaster) [M]</span> says, '[msg]'", hearing_distance = 2)

/obj/item/device/videocam/hear_message(mob/M as mob, msg)
	if(camera && on)
		for(var/obj/machinery/computer/security/telescreen/T in machines)
			if(T.current == camera)
				T.audible_message("<span class='game radio'><span class='name'>(Newscaster) [M]</span> [msg]", hearing_distance = 2)


///hauntings, like hallucinations but more spooky

/obj/item/device/camera/proc/handle_haunt(mob/user as mob)
			var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
						'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
						'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
						'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
						'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
			user << pick(creepyasssounds)
