#define SHOWER_OPEN_LAYER OBJ_LAYER + 0.4
#define SHOWER_CLOSED_LAYER MOB_LAYER + 0.1

/obj/structure/curtain
	icon = 'icons/obj/curtain.dmi'
	name = "curtain"
	icon_state = "closed"
	layer = SHOWER_CLOSED_LAYER
	opacity = 1
	density = 0

/obj/structure/curtain/open
	icon_state = "open"
	layer = SHOWER_OPEN_LAYER
	opacity = 0

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears [src] down!</span>")
		qdel(src)
	else
		..(P, def_zone)

/obj/structure/curtain/attack_hand(mob/user)
	playsound(get_turf(loc), "rustle", 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	if(opacity)
		icon_state = "closed"
		layer = SHOWER_CLOSED_LAYER
	else
		icon_state = "open"
		layer = SHOWER_OPEN_LAYER

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/toy/crayon))
		color = input(user, "Choose Color") as color
	else if(isscrewdriver(W))
		if(anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] unscrews [src] from the floor.</span>", "<span class='notice'>You start to unscrew [src] from the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 50 * W.toolspeed, target = src))
				if(!anchored)
					return
				anchored = FALSE
				to_chat(user, "<span class='notice'>You unscrew [src] from the floor.</span>")
		else
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] screws [src] to the floor.</span>", "<span class='notice'>You start to screw [src] to the floor...</span>", "You hear rustling noises.")
			if(do_after(user, 50 * W.toolspeed, target = src))
				if(anchored)
					return
				anchored = TRUE
				to_chat(user, "<span class='notice'>You screw [src] to the floor.</span>")
	else if(istype(W, /obj/item/wirecutters))
		if(!anchored)
			playsound(loc, W.usesound, 100, 1)
			user.visible_message("<span class='warning'>[user] cuts apart [src].</span>", "<span class='notice'>You start to cut apart [src].</span>", "You hear cutting.")
			if(do_after(user, 50 * W.toolspeed, target = src))
				if(anchored)
					return
				to_chat(user, "<span class='notice'>You cut apart [src].</span>")
				deconstruct()
	else
		. = ..()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cloth(loc, 2)
	new /obj/item/stack/sheet/plastic(loc, 2)
	new /obj/item/stack/rods(loc, 1)
	qdel(src)

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#FFA500"

/obj/structure/curtain/open/shower/security
	color = "#AA0000"

/obj/structure/curtain/open/shower/centcom
	color = "#000066"

#undef SHOWER_OPEN_LAYER
#undef SHOWER_CLOSED_LAYER
