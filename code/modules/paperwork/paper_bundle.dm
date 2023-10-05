/obj/item/paper_bundle
	name = "paper bundle"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 2
	throw_speed = 1
	pressure_resistance = 2
	attack_verb = list("bapped")
	var/amount = 0 //Amount of total items clipped to the paper. Note: If you have 2 paper, this should be 1
	var/photos = 0 //Amount of photos clipped to the paper.
	var/page = 1
	var/screen = 0
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'

/obj/item/paper_bundle/New(default_papers = TRUE)
	. = ..()
	if(default_papers) // This is to avoid runtime occuring from a paper bundle being created without a paper in it.
		new /obj/item/paper(src)
		new /obj/item/paper(src)
		amount += 1

/obj/item/paper_bundle/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	var/obj/item/paper/P
	if(istype(W, /obj/item/paper))
		P = W
		if(istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if(!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return

		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, "<span class='notice'>You add [(P.name == "paper") ? "the paper" : P.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		user.unEquip(P)
		P.loc = src
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()
	else if(istype(W, /obj/item/photo))
		amount++
		photos++
		if(screen == 2)
			screen = 1
		to_chat(user, "<span class='notice'>You add [(W.name == "photo") ? "the photo" : W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		user.unEquip(W)
		W.loc = src
	else if(istype(W, /obj/item/lighter))
		burnpaper(W, user)
	else if(istype(W, /obj/item/paper_bundle))
		user.unEquip(W)
		for(var/obj/O in W)
			O.loc = src
			O.add_fingerprint(usr)
			src.amount++
			if(screen == 2)
				screen = 1
		to_chat(user, "<span class='notice'>You add \the [W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		qdel(W)
	else
		if(is_pen(W) || istype(W, /obj/item/toy/crayon))
			usr << browse("", "window=PaperBundle[UID()]") //Closes the dialog
		P = src[page]
		P.attackby(W, user, params)

	update_icon()
	if(winget(usr, "PaperBundle[UID()]", "is-visible") == "true") // NOT MY FAULT IT IS A BUILT IN PROC PLEASE DO NOT HIT ME
		attack_self(usr) //Update the browsed page.
	add_fingerprint(usr)
	return

/obj/item/paper_bundle/proc/burnpaper(obj/item/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds [P] up to [src], it looks like [user.p_theyre()] trying to burn it!</span>", \
		"[class]You hold [P] up to [src], burning it slowly.</span>")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

				if(user.is_in_inactive_hand(src))
					user.unEquip(src)

				new /obj/effect/decal/cleanable/ash(get_turf(src))
				qdel(src)

			else
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")

/obj/item/paper_bundle/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		show_content(user)
	else
		. += "<span class='notice'>It is too far away.</span>"

/obj/item/paper_bundle/proc/show_content(mob/user as mob)
	var/dat = {"<meta charset="UTF-8">"} // SS220 EDIT - ORIGINAL: ... Empty var
	var/obj/item/W = src[page]
	switch(screen)
		if(0)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		if(1)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=[UID()];next_page=1'>Next Page</A></DIV><BR><HR>"
		if(2)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=[UID()];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=[UID()];remove=1'>Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
			dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
	if(istype(src[page], /obj/item/paper))
		var/obj/item/paper/P = W
		dat += P.show_content(usr, view = 0)
		usr << browse(dat, "window=PaperBundle[UID()]")
	else if(istype(src[page], /obj/item/photo))
		var/obj/item/photo/P = W
		usr << browse_rsc(P.img, "tmp_photo.png")
		usr << browse(dat + "<html><meta charset='utf-8'><head><title>[P.name]</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[P.scribble ? "<div><br> Written on the back:<br><i>[P.scribble]</i>" : ""]"\
		+ "</body></html>", "window=PaperBundle[UID()]")

/obj/item/paper_bundle/attack_self(mob/user as mob)
	show_content(user)
	add_fingerprint(usr)
	return

/obj/item/paper_bundle/Topic(href, href_list)
	if(..())
		return
	if(src in usr.contents)
		if(href_list["next_page"])
			if(page == amount)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount+1)
				return
			page++
			playsound(loc, "pageturn", 50, 1)

		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount+1)
				screen = 1
			page--
			playsound(loc, "pageturn", 50, 1)

		if(href_list["remove"])
			var/obj/item/W = src[page]
			usr.put_in_hands(W)
			to_chat(usr, "<span class='notice'>You remove [W] from the bundle.</span>")
			if(amount == 1)
				var/obj/item/paper/P = src[1]
				usr.unEquip(src)
				usr.put_in_hands(P)
				usr.unset_machine() // Ensure the bundle GCs
				for(var/obj/O in src) // just in case we somehow lose something (it's happened, especially with photos)
					O.forceMove(usr.loc)
					O.layer = initial(O.layer)
					O.plane = initial(O.plane)
					O.add_fingerprint(usr)
				qdel(src)
				return

			else if(page == amount)
				screen = 2

			else if(page == amount+1)
				page--

			amount--
			update_icon()
	else
		to_chat(usr, "<span class='notice'>You need to hold it in your hands to change pages.</span>")
	if(ismob(loc))
		attack_self(loc)

/obj/item/paper_bundle/AltClick(mob/user)
	if(in_range(user, src) && !user.incapacitated())
		if(is_pen(user.get_active_hand()))
			rename()
		return

	. = ..()

/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = sanitize(copytext_char(input(usr, "What would you like to label the bundle?", "Bundle Labelling", name) as text, 1, MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext
	if((loc == usr && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "paper bundle")]"

	add_fingerprint(usr)



/obj/item/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	to_chat(usr, "<span class='notice'>You loosen the bundle.</span>")

	for(var/obj/O in src)
		O.loc = usr.loc
		O.layer = initial(O.layer)
		O.plane = initial(O.plane)
		O.add_fingerprint(usr)

	usr.unEquip(src)
	qdel(src)

/obj/item/paper_bundle/update_desc()
	. = ..()
	if(amount == (photos - 1))
		desc = "[photos] photos clipped together." // In case you clip 2 photos together and remove the paper
		return

	else if(((amount + 1) - photos) >= 2) // extra papers + original paper - photos
		desc = "[(amount + 1) - photos] papers clipped to each other."

	else
		desc = "A single sheet of paper."
	if(photos)
		desc += "\nThere [photos == 1 ? "is a photo" : "are [photos] photos"] attached to it."
/obj/item/paper_bundle/update_icon_state()
	if(length(contents))
		var/obj/item/paper/P = contents[1]
		icon_state = P.icon_state // must have an icon_state to show up on clipboards

/obj/item/paper_bundle/update_overlays()
	. = ..()
	underlays.Cut()
	if(length(contents))
		var/obj/item/paper/P = contents[1]
		. += P.overlays

	var/counter = 0
	for(var/obj/O in src)
		var/image/sheet = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/paper))
			if(length(underlays) == 3)
				continue

			sheet.icon_state = O.icon_state
			sheet.pixel_x -= min(1 * counter, 2)
			sheet.pixel_y -= min(1 * counter, 2)
			pixel_x = min(0.5 * counter, 1)
			pixel_y = min(1 * counter, 2)
			underlays += sheet
			counter++

		else if(istype(O, /obj/item/photo))
			var/obj/item/photo/picture = O
			sheet = picture.tiny
			. += sheet

	. += "clip"
	update_desc()
