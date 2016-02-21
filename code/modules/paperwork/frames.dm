/obj/item/weapon/picture_frame
	name = "picture frame"
	desc = "Its patented design allows it to be folded larger or smaller to accommodate standard paper, photo, and poster sizes."
	icon = 'icons/obj/bureaucracy.dmi'

	var/icon_base
	var/obj/displayed

	var/list/wide_posters = list(
		"poster22_legit", "poster23", "poster23_legit", "poster24", "poster24_legit",
		"poster25", "poster27_legit", "poster28", "poster29")

/obj/item/weapon/picture_frame/New(loc, obj/item/weapon/D)
	..()
	if(D)
		insert(D)
	update_icon()

/obj/item/weapon/picture_frame/Destroy()
	if(displayed)
		displayed = null
		for(var/A in contents)
			qdel(A)
	..()

/obj/item/weapon/picture_frame/update_icon()
	overlays.Cut()

	if(displayed)
		overlays |= getFlatIcon(displayed)

	if(istype(displayed, /obj/item/weapon/photo))
		icon_state = "[icon_base]-photo"
	else if(istype(displayed, /obj/structure/sign/poster))
		icon_state = "[icon_base]-[(displayed.icon_state in wide_posters) ? "wposter" : "poster"]"
	else
		icon_state = "[icon_base]-paper"

	overlays |= icon_state

/obj/item/weapon/picture_frame/proc/insert(obj/D)
	if(istype(D, /obj/item/weapon/contraband/poster))
		var/obj/item/weapon/contraband/poster/P = D
		displayed = P.resulting_poster
		P.resulting_poster = null
	else
		displayed = D
	
	name = displayed.name
	displayed.pixel_x = 0
	displayed.pixel_y = 0
	displayed.forceMove(src)
	if(istype(D, /obj/item/weapon/contraband/poster))
		qdel(D)

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(displayed)
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			user.visible_message("<span class=warning>[user] unfastens \the [displayed] out of \the [src].</span>", "<span class=warning>You unfasten \the [displayed] out of \the [src].</span>")

			if(istype(displayed, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = displayed
				P.roll_and_drop(user.loc)
			else
				displayed.forceMove(user.loc)
			displayed = null
			name = initial(name)
			update_icon()
		else
			user << "<span class=notice>There is nothing to remove from \the [src].</span>"
	else if(istype(I, /obj/item/weapon/crowbar))
		playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("<span class=warning>[user] breaks down \the [src].</span>", "<span class=warning>You break down \the [src].</span>")
		for(var/A in contents)
			if(istype(A, /obj/structure/sign/poster))
				var/obj/structure/sign/poster/P = A
				P.roll_and_drop(user.loc)
			else
				var/obj/O = A
				O.forceMove(user.loc)
		displayed = null
		qdel(src)
	else if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/weapon/contraband/poster))
		if(!displayed)
			user.unEquip(I)
			insert(I)
			update_icon()
		else
			user << "<span class=notice>\The [src] already contains \a [displayed].</span>"
	else
		..()

/obj/item/weapon/picture_frame/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /turf/simulated/wall))
		place(target, user)
	else
		..()

/obj/item/weapon/picture_frame/proc/place(turf/T, mob/user)
	var/stuff_on_wall = 0
	for(var/obj/O in user.loc.contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign))
			user << "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>"
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			user << "<span class='notice'>\The [T] is far too cluttered to place \a [src]!</span>"
			return

	user << "<span class='notice'>You start place \the [src] on \the [T].</span>"

	var/px = 0
	var/py = 0

	switch(getRelativeDirection(user, T))
		if(NORTH)
			py = 32
		if(EAST)
			px = 32
		if(SOUTH)
			py = -32
		if(WEST)
			px = -32
		else
			user << "<span class='notice'>You cannot reach \the [T] from here!</span>"
			return

	user.unEquip(src)
	var/obj/structure/sign/picture_frame/PF = new(user.loc, src)
	PF.pixel_x = px
	PF.pixel_y = py

	playsound(PF.loc, 'sound/items/Deconstruct.ogg', 100, 1)

/obj/item/weapon/picture_frame/examine(mob/user, var/distance = -1, var/infix = "", var/suffix = "")
	..()
	if(displayed)
		displayed.examine(user, distance, infix, suffix)

/obj/item/weapon/picture_frame/attack_self(mob/user)
	if(displayed)
		if(istype(displayed, /obj/item))
			var/obj/item/I = displayed
			I.attack_self(user)
	else
		..()



/obj/item/weapon/picture_frame/glass
	icon_base = "glass"
	icon_state = "glass-poster"

/obj/item/weapon/picture_frame/wooden
	icon_base = "wood"
	icon_state = "wood-poster"

/obj/item/weapon/picture_frame/wooden/New()
	..()
	new /obj/item/stack/sheet/wood(src, 1)



/obj/structure/sign/picture_frame
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "glass-poster"
	var/obj/item/weapon/picture_frame/frame

/obj/structure/sign/picture_frame/New(loc, F)
	..()
	frame = F
	frame.pixel_x = 0
	frame.pixel_y = 0
	frame.forceMove(src)
	name = frame.name
	update_icon()

/obj/structure/sign/picture_frame/Destroy()
	if(frame)
		qdel(frame)
		frame = null
	..()

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
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("<span class=warning>[user] begins to unfasten \the [src] from the wall.</span>", "<span class=warning>You begin to unfasten \the [src] from the wall.</span>")
		if(do_after(user, 100, target = src))
			playsound(src, 'sound/items/Deconstruct.ogg', 100, 1)
			user.visible_message("<span class=warning>[user] unfastens \the [src] from the wall.</span>", "<span class=warning>You unfasten \the [src] from the wall.</span>")
			frame.forceMove(user.loc)
			frame = null
			qdel(src)
	else
		..()

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