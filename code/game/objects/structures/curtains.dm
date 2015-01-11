/obj/structure/curtain
	icon = 'icons/obj/curtain.dmi'
	name = "curtain"
	icon_state = "closed"
	layer = MOB_LAYER + 0.1
	opacity = 1
	density = 0

/obj/structure/curtain/open
	icon_state = "open"
	layer = OBJ_LAYER
	opacity = 0

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears [src] down!</span>")
		del(src)
	else
		..(P, def_zone)

/obj/structure/curtain/attack_hand(mob/user)
	playsound(get_turf(loc), "rustle", 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/proc/toggle()
	opacity = !opacity
	if(opacity)
		icon_state = "closed"
		layer = MOB_LAYER + 0.1
	else
		icon_state = "open"
		layer = OBJ_LAYER

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
