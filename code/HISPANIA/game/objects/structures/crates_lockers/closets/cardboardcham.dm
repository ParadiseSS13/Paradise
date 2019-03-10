/obj/structure/closet/cardboard/chameleon
	name = "large cardboard box"
	desc = "Just a box...?"
	icon = 'icons/hispania/obj/cardboards.dmi'
	icon_state = "cardboard"
	icon_opened = "cardboard_open"
	icon_closed = "cardboard"
	opened = FALSE
	var/emagged = 0

/obj/structure/closet/cardboard/chameleon/relaymove(mob/user, direction)
	alpha = 250
	..()

/obj/structure/closet/cardboard/chameleon/open()
	alpha = 250
	..()

/obj/structure/closet/cardboard/chameleon/close()
	fade()
	..()

/obj/structure/closet/cardboard/chameleon/proc/fade()
	spawn(emagged ? 15 : 35)
		if(!opened)
			alpha -= 25
			fade()

/obj/structure/closet/cardboard/chameleon/emag_act(mob/user)
	visible_message("<span class='warning'>The cardboard box sparks!</span>")
	add_fingerprint(user)
	emagged = 1
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, src)
	sparks.start()