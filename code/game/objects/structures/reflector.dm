/obj/structure/reflector
	name = "reflector base"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_map"
	desc = "A frame to create a reflector.\n<span class='notice'>Use <b>5</b> sheets of <b>glass</b> to create a 1 way reflector.\nUse <b>10</b> sheets of <b>reinforced glass</b> to create a 2 way reflector.\nUse <b>1 diamond</b> to create a reflector cube.</span>"
	anchored = 0
	density = 0
	layer = 3
	var/deflector_icon_state
	var/image/deflector_overlay
	var/finished = 0
	var/admin = FALSE //Can't be rotated or deconstructed
	var/can_rotate = TRUE
	var/list/allowed_projectile_typecache = list(/obj/item/projectile/beam)
	var/rotation_angle = -1

/obj/structure/reflector/Initialize()
	. = ..()
	icon_state = "reflector_base"
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(deflector_icon_state)
		deflector_overlay = image(icon, deflector_icon_state)
		add_overlay(deflector_overlay)

	if(rotation_angle == -1)
		setAngle(dir2angle(dir))
	else
		setAngle(rotation_angle)

	if(admin)
		can_rotate = FALSE

/obj/structure/reflector/examine(mob/user)
	..()
	if(finished)
		to_chat(user, "It is set to [rotation_angle] degrees, and the rotation is [can_rotate ? "unlocked" : "locked"].")
		if(!admin)
			if(can_rotate)
				to_chat(user, "<span class='notice'>Alt-click to adjust its direction.</span>")
			else
				to_chat(user, "<span class='notice'>Use screwdriver to unlock the rotation.</span>")

/obj/structure/reflector/Moved()
	setAngle(dir_map_to_angle(dir))
	return ..()

/obj/structure/reflector/proc/dir_map_to_angle(dir)
	return dir2angle(dir)

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/pdir = P.dir
	var/pangle = P.Angle
	var/ploc = get_turf(P)
	if(!finished || !allowed_projectile_typecache[P.type] || !(P.dir in cardinal))
		return ..()
	if(auto_reflect(P, pdir, ploc, pangle) != -1)
		return ..()
	return -1

/obj/structure/reflector/proc/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	P.firer = src
	P.ignore_source_check = TRUE
	P.range = P.decayedRange
	P.decayedRange = max(P.decayedRange--, 0)
	return -1

/obj/structure/reflector/attackby(obj/item/W, mob/user, params)
	if(isscrewdriver(W))
		can_rotate = !can_rotate
		to_chat(user, "<span class='notice'>You [can_rotate ? "unlock" : "lock"] [src]'s rotation.</span>")
		playsound(src, W.usesound, 50, 1)
		return
	if(iswrench(W))
		if(anchored)
			to_chat(user, "Unweld [src] first!")
			return
		playsound(user, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "You begin to dismantle [src].")
		if(do_after(user, 80, target = src))
			playsound(user, 'sound/items/Ratchet.ogg', 50, 1)
			to_chat(user, "You dismantle [src].")
			new /obj/item/stack/sheet/metal(src.loc, 5)
			qdel(src)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(!anchored)
			if(WT.remove_fuel(0,user))
				playsound(user, 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("[user.name] starts to weld [src.name] to the floor.", \
					"<span class='notice'>You start to weld [src] to the floor...</span>", \
					"<span class='italics'>You hear welding.</span>")
				if(do_after(user,20, target = src))
					if(!src || !WT.isOn())
						return
					anchored = 1
					to_chat(user, "<span class='notice'>You weld [src] to the floor.</span>")
		else
			if(WT.remove_fuel(0,user))
				playsound(user, 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("[user] starts to cut [src] free from the floor.", \
					"<span class='notice'>You start to cut [src] free from the floor...</span>", \
					"<span class='italics'>You hear welding.</span>")
				if(do_after(user,20, target = src))
					if(!src || !WT.isOn())
						return
					anchored  = 0
					to_chat(user, "<span class='notice'>You cut [src] free from the floor.</span>")
	//Finishing the frame
	if(istype(W,/obj/item/stack/sheet))
		if(finished)
			return
		var/obj/item/stack/sheet/S = W
		if(istype(W, /obj/item/stack/sheet/glass))
			if(S.get_amount() < 5)
				to_chat(user, "<span class='warning'>You need five sheets of glass to create a reflector!</span>")
				return
			else
				S.use(5)
				new /obj/structure/reflector/single (src.loc)
				qdel(src)
		if(istype(W,/obj/item/stack/sheet/rglass))
			if(S.get_amount() < 10)
				to_chat(user, "<span class='warning'>You need ten sheets of reinforced glass to create a double reflector!</span>")
				return
			else
				S.use(10)
				new /obj/structure/reflector/double (src.loc)
				qdel(src)
		if(istype(W, /obj/item/stack/sheet/mineral/diamond))
			if(S.get_amount() >= 1)
				S.use(1)
				new /obj/structure/reflector/box (src.loc)
				qdel(src)

/obj/structure/reflector/proc/get_reflection(srcdir,pdir)
	return 0


/obj/structure/reflector/proc/rotate(mob/user)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	var/new_angle = input(user, "Input a new angle for primary reflection face.", "Reflector Angle", rotation_angle) as null|num
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!isnull(new_angle))
		setAngle(SIMPLIFY_DEGREES(new_angle))
	return TRUE

/obj/structure/reflector/proc/setAngle(new_angle)
	if(can_rotate)
		rotation_angle = new_angle
		if(deflector_overlay)
			cut_overlay(deflector_overlay)
			deflector_overlay.transform = turn(matrix(), new_angle)
			add_overlay(deflector_overlay)


/obj/structure/reflector/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else if (finished)
		rotate(user)


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	deflector_icon_state = "reflector"
	desc = "An angled mirror for reflecting laser beams."
	density = TRUE
	finished = 1

/obj/structure/reflector/single/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	if(abs(incidence) > 90 && abs(incidence) < 270)
		return FALSE
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.setAngle(new_angle)
	return ..()

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	deflector_icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting laser beams."
	density = TRUE
	finished = 1


/obj/structure/reflector/double/auto_reflect(obj/item/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.setAngle(new_angle)
	return ..()


//BOX

/obj/structure/reflector/box
	name = "reflector box"
	deflector_icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser beams in a single direction."
	density = TRUE
	finished = 1

/obj/structure/reflector/box/auto_reflect(obj/item/projectile/P)
	P.Angle = rotation_angle
	return ..()