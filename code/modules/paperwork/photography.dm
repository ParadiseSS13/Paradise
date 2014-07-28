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
	w_class = 1.0


/********
* photo *
********/
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = 1.0
	var/icon/img		//Big photo image
	var/scribble		//Scribble on the back.

	autoignition_temperature = 530 // Kelvin


/obj/item/weapon/photo/attack_self(mob/user as mob)
	examine()

/obj/item/weapon/photo/attackby(obj/item/weapon/P as obj, mob/user as mob)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text)
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == 0)
			scribble = txt
	..()

/obj/item/weapon/photo/examine()
	set src in oview(1)
	if(in_range(usr, src))
		show(usr)
		usr << desc
	else
		usr << "<span class='notice'>It is too far away.</span>"

/obj/item/weapon/photo/proc/show(mob/user as mob)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[scribble ? "<div> Written on the back:<br><i>[scribble]</i>" : ]"\
		+ "</body></html>", "window=book;size=200x[scribble ? 400 : 200]")
	onclose(user, "[name]")
	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(( (loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == 0))
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
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
	can_hold = list("/obj/item/weapon/photo",)

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if((istype(usr, /mob/living/carbon/human) || (ticker && ticker.mode.name == "monkey")))
		var/mob/M = usr
		if(!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if((!( M.restrained() ) && !( M.stat ) && M.back == src))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.u_equip(src)
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
	w_class = 2.0
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BELT
	m_amt = 2000
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"


/obj/item/device/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/device/camera/attack_self(mob/user as mob)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	user << "You switch the camera [on ? "on" : "off"]."
	return

/obj/item/device/camera/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/device/camera_film))
		if(pictures_left)
			user << "<span class='notice'>[src] still has some film in it!</span>"
			return
		user << "<span class='notice'>You insert [I] into [src].</span>"
		user.drop_item()
		del(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/device/camera/proc/get_icon(turf/the_turf as turf)
	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")

	world.log << "***Calling build composite..." //#JMO
	//var/icon/turficon = build_composite_icon(the_turf)
	res.Blend(getFlatIcon(the_turf), blendMode2iconMode(the_turf.blend_mode),33,33)
	world.log << "***Exiting build composite..." //#JMO
	//res.Blend(turficon, ICON_OVERLAY, 33, 33)

	var/atoms[] = list()
	for(var/atom/A in the_turf)
		if(A.invisibility) continue
		atoms.Add(A)

	//Sorting icons based on levels.
	//JMO: I have no idea what they were doing here before, but the magic number alone
	// was worth replacing it over. "gap = round(gap / 1.247330950103979)" really?
	var/list/sorted = list()
	var/j
	for(var/i = 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)

	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(A)
			world.log << "**Calling getFlatIcon to render [A.type]" //#JMO
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)
			if(istype(A, /mob/living) && A:lying)
				world.log << "[A.type] is lying down. Making it look as such..." // #JMO;
				img.BecomeLying()

			//if(istype(img, /icon))
			res.Blend(img, blendMode2iconMode(A.blend_mode), 33 + A.pixel_x, 33 + A.pixel_y)
	return res


/obj/item/device/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
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

	var/x_c = target.x - 1
	var/y_c = target.y + 1
	var/z_c	= target.z

	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	var/icon/black = icon('icons/turf/space.dmi', "black")
	var/mobs = ""
	world << "Proof that this thing is alive! 1.0" // #JMO
	for(var/i = 1; i <= 3; i++)
		for(var/j = 1; j <= 3; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			var/mob/dummy = new(T)	//Go go visibility check dummy
			var/viewer = user
			if(user.client)		//To make shooting through security cameras possible
				viewer = user.client.eye
			if(dummy in viewers(world.view, viewer))
				temp.Blend(get_icon(T), ICON_OVERLAY, 32 * (j-1-1), 32 - 32 * (i-1))
			else
				temp.Blend(black, ICON_OVERLAY, 32 * (j-1), 64 - 32 * (i-1))
			mobs += get_mobs(T)
			dummy.loc = null
			dummy = null	//Alas, nameless creature	//garbage collect it instead
			x_c++
		y_c--
		x_c = x_c - 3

	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	P.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	user << "<span class='notice'>[pictures_left] photos left.</span>"
	icon_state = icon_off
	on = 0
	spawn(64)
		icon_state = icon_on
		on = 1


/**************
*video camera *
***************/

/obj/item/device/videocam
	name = "video camera"
	icon = 'icons/obj/items.dmi'
	desc = "video camera that can send live feed to the entertainment network."
	icon_state = "videocam"
	item_state = "videocam"
	w_class = 2.0
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BELT
	m_amt = 2000
	var/on = 0
	var/obj/machinery/camera/camera
	var/icon_on = "videocam_on"
	var/icon_off = "videocam"
	var/canhear_range = 7
	var/watcherslist = list()

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
	user << "You switch the camera [on ? "on" : "off"]."

/obj/item/device/videocam/examine()
	..()
	if(get_dist(usr,src) <= 1)
		usr << "This video camera can send live feeds to the entertainment network. It's [camera ? "" : "in"]active."


/obj/item/device/videocam/hear_talk(mob/M as mob, msg)
	if (camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/mob/living/carbon/human/H in watcherslist)
			H.show_message(text("\blue (Newscaster) [] says, '[]'",M,msg), 1)
