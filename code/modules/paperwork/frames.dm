/obj/item/picture_frame
	name = "picture frame"
	desc = "Its patented design allows it to be folded larger or smaller to accommodate standard paper, photo, and poster, and canvas sizes."
	icon = 'icons/obj/bureaucracy.dmi'

	usesound = 'sound/items/deconstruct.ogg'

	var/icon_base
	var/obj/displayed

	var/list/wide_posters = list(
		"poster22_legit", "poster23", "poster23_legit", "poster24", "poster24_legit",
		"poster25", "poster27_legit", "poster28", "poster29")

/obj/item/picture_frame/New(loc, obj/item/D)
	..()
	if(D)
		insert(D)
	update_icon()

/obj/item/picture_frame/Destroy()
	if(displayed)
		displayed = null
		for(var/A in contents)
			qdel(A)
	return ..()

/obj/item/picture_frame/update_icon()
	overlays.Cut()

	if(displayed)
		overlays |= getFlatIcon(displayed)

	if(istype(displayed, /obj/item/photo))
		icon_state = "[icon_base]-photo"
	else if(istype(displayed, /obj/structure/sign/poster))
		icon_state = "[icon_base]-[(displayed.icon_state in wide_posters) ? "wposter" : "poster"]"
	else
		icon_state = "[icon_base]-paper"

	overlays |= icon_state

/obj/item/picture_frame/proc/insert(obj/D)
	if(istype(D, /obj/item/poster))
		var/obj/item/poster/P = D
		displayed = P.poster_structure
		P.poster_structure = null
	else
		displayed = D

	name = displayed.name
	displayed.pixel_x = 0
	displayed.pixel_y = 0
	displayed.forceMove(src)
	if(istype(D, /obj/item/poster))
		qdel(D)

/obj/item/picture_frame/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver))
		if(displayed)
			playsound(src, I.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unfastens \the [displayed] out of \the [src].</span>", "<span class='warning'>You unfasten \the [displayed] out of \the [src].</span>")

			if(istype(displayed, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = displayed
				P.roll_and_drop(user.loc)
			else
				displayed.forceMove(user.loc)
			displayed = null
			name = initial(name)
			update_icon()
		else
			to_chat(user, "<span class='notice'>There is nothing to remove from \the [src].</span>")
	else if(istype(I, /obj/item/crowbar))
		playsound(src, I.usesound, 100, 1)
		user.visible_message("<span class='warning'>[user] breaks down \the [src].</span>", "<span class='warning'>You break down \the [src].</span>")
		for(var/A in contents)
			if(istype(A, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = A
				P.roll_and_drop(user.loc)
			else
				var/obj/O = A
				O.forceMove(user.loc)
		displayed = null
		qdel(src)
	else if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo) || istype(I, /obj/item/poster))
		if(!displayed)
			user.unEquip(I)
			insert(I)
			update_icon()
		else
			to_chat(user, "<span class='notice'>\The [src] already contains \a [displayed].</span>")
	else
		return ..()

/obj/item/picture_frame/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /turf/simulated/wall))
		place(target, user)
	else
		..()

/obj/item/picture_frame/proc/place(turf/T, mob/user)
	var/stuff_on_wall = 0
	for(var/obj/O in user.loc.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign))
			to_chat(user, "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>")
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			to_chat(user, "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>")
			return

	to_chat(user, "<span class='notice'>You start place \the [src] on \the [T].</span>")

	var/px = 0
	var/py = 0
	var/newdir = getRelativeDirection(user, T)

	switch(newdir)
		if(NORTH)
			py = 32
		if(EAST)
			px = 32
		if(SOUTH)
			py = -32
		if(WEST)
			px = -32
		else
			to_chat(user, "<span class='notice'>You cannot reach \the [T] from here!</span>")
			return

	user.unEquip(src)
	var/obj/structure/sign/picture_frame/PF = new(user.loc, src)
	PF.dir = newdir
	PF.pixel_x = px
	PF.pixel_y = py

	playsound(PF.loc, usesound, 100, 1)

/obj/item/picture_frame/examine(mob/user, var/distance = -1, var/infix = "", var/suffix = "")
	..()
	if(displayed)
		displayed.examine(user, distance, infix, suffix)

/obj/item/picture_frame/attack_self(mob/user)
	if(displayed)
		if(istype(displayed, /obj/item))
			var/obj/item/I = displayed
			I.attack_self(user)
	else
		..()



/obj/item/picture_frame/glass
	icon_base = "glass"
	icon_state = "glass-poster"
	materials = list(MAT_METAL = 25, MAT_GLASS = 75)

/obj/item/picture_frame/wooden
	icon_base = "wood"
	icon_state = "wood-poster"

/obj/item/picture_frame/wooden/New()
	..()
	new /obj/item/stack/sheet/wood(src, 1)



/obj/structure/sign/picture_frame
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "glass-poster"

	var/obj/item/picture_frame/frame
	var/obj/item/explosive

	var/tilted = 0
	var/tilt_transform = null

/obj/structure/sign/picture_frame/New(loc, F)
	..()
	frame = F
	frame.pixel_x = 0
	frame.pixel_y = 0
	frame.forceMove(src)
	name = frame.name
	update_icon()

	if(!tilt_transform)
		tilt_transform = turn(matrix(), -10)

	if(tilted)
		transform = tilt_transform
		verbs |= /obj/structure/sign/picture_frame/proc/untilt
	else
		verbs |= /obj/structure/sign/picture_frame/proc/tilt

/obj/structure/sign/picture_frame/Destroy()
	QDEL_NULL(frame)
	return ..()

/obj/structure/sign/picture_frame/update_icon()
	overlays.Cut()
	if(frame)
		icon = null
		icon_state = null
		overlays |= getFlatIcon(frame)
	else
		icon = initial(icon)
		icon_state = initial(icon_state)

/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/screwdriver))
		playsound(src, I.usesound, 100, 1)
		user.visible_message("<span class='warning'>[user] begins to unfasten \the [src] from the wall.</span>", "<span class='warning'>You begin to unfasten \the [src] from the wall.</span>")
		if(do_after(user, 100 * I.toolspeed, target = src))
			playsound(src, I.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unfastens \the [src] from the wall.</span>", "<span class='warning'>You unfasten \the [src] from the wall.</span>")
			frame.forceMove(user.loc)
			frame = null
			if(explosive)
				explosive.forceMove(user.loc)
				explosive = null
			qdel(src)
	if(istype(I, /obj/item/grenade) || istype(I, /obj/item/grenade/plastic/c4))
		if(explosive)
			to_chat(user, "<span class='warning'>There is already a device attached behind \the [src], remove it first.</span>")
			return 1
		if(!tilted)
			to_chat(user, "<span class='warning'>\The [src] needs to be already tilted before being rigged with \the [I].</span>")
			return 1
		user.visible_message("<span class='warning'>[user] is fiddling around behind \the [src].</span>", "<span class='warning'>You begin to secure \the [I] behind \the [src].</span>")
		if(do_after(user, 150, target = src))
			if(explosive || !tilted)
				return
			playsound(src, 'sound/weapons/handcuffs.ogg', 50, 1)
			user.unEquip(I)
			explosive = I
			I.forceMove(src)
			user.visible_message("<span class='notice'>[user] fiddles with the back of \the [src].</span>", "<span class='notice'>You secure \the [I] behind \the [src].</span>")

			message_admins("[key_name_admin(user)] attached [I] to a picture frame.")
			log_game("[key_name_admin(user)] attached [I] to a picture frame.")
		return 1
	else
		return ..()

/obj/structure/sign/picture_frame/examine(mob/user, var/distance = -1, var/infix = "", var/suffix = "")
	if(frame)
		frame.examine(user, distance, infix, suffix)
	else
		..()

/obj/structure/sign/picture_frame/attack_hand(mob/user)
	if(frame)
		frame.attack_self(user)
	else
		..()

/obj/structure/sign/picture_frame/ex_act(severity)
	explode()
	..(severity)

/obj/structure/sign/picture_frame/proc/explode()
	if(istype(explosive, /obj/item/grenade))
		var/obj/item/grenade/G = explosive
		explosive = null
		G.prime()

/obj/structure/sign/picture_frame/proc/toggle_tilt(mob/user)
	if(!isliving(usr) || usr.stat)
		return

	tilted = !tilted

	if(tilted)
		animate(src, transform = tilt_transform, time = 10, easing = BOUNCE_EASING)
		verbs -= /obj/structure/sign/picture_frame/proc/tilt
		verbs |= /obj/structure/sign/picture_frame/proc/untilt
	else
		animate(src, transform = matrix(), time = 10, easing = CUBIC_EASING | EASE_IN)
		verbs -= /obj/structure/sign/picture_frame/proc/untilt
		verbs |= /obj/structure/sign/picture_frame/proc/tilt
		explode()

/obj/structure/sign/picture_frame/proc/tilt()
	set name = "Tilt Picture"
	set category = "Object"
	set src in oview(1)

	toggle_tilt(usr)

/obj/structure/sign/picture_frame/proc/untilt()
	set name = "Straighten Picture"
	set category = "Object"
	set src in oview(1)

	toggle_tilt(usr)

/obj/structure/sign/picture_frame/hear_talk(mob/living/M as mob, list/message_pieces)
	..()
	for(var/obj/O in contents)
		O.hear_talk(M, message_pieces)

/obj/structure/sign/picture_frame/hear_message(mob/living/M as mob, msg)
	..()
	for(var/obj/O in contents)
		O.hear_message(M, msg)
