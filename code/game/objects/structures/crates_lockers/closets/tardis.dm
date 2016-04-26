var/global/obj/structure/closet/tardis/the_tardis
var/global/obj/effect/tardis_exit/the_tardis_exit

/obj/structure/closet/tardis
	name = "T.A.R.D.I.S."
	desc = "Bigger on the inside than on the outside."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/structure/closet/tardis/New()
	..()
	the_tardis = src

/obj/structure/closet/tardis/close()
	. = ..()
	var/obj/effect/landmark/W
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "tardistele")
			W = L
			break
	
	for(var/atom/movable/A as obj|mob in src)
		A.forceMove(get_turf(W))
		if(ismob(A))
			var/mob/M = A
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
	if(.)
		if(sound)
			playsound(the_tardis_exit.loc, src.sound, 15, 1, -3)
		else
			playsound(the_tardis_exit.loc, 'sound/machines/click.ogg', 15, 1, -3)

/obj/structure/closet/tardis/open()
	. = ..()
	if(.)
		if(sound)
			playsound(the_tardis_exit.loc, src.sound, 15, 1, -3)
		else
			playsound(the_tardis_exit.loc, 'sound/machines/click.ogg', 15, 1, -3)

/obj/structure/closet/tardis/toggle(user)
	..()
	if(the_tardis_exit)
		the_tardis_exit.update_icon()

/obj/effect/tardis_exit
	name = "T.A.R.D.I.S."
	desc = "Bigger on the inside than on the outside"
	icon = 'icons/obj/doors/Doorcomglass.dmi'
	icon_state = "door_closed"
	opacity = 1
	anchored = 1
	density = 1

/obj/effect/tardis_exit/New()
	..()
	the_tardis_exit = src

/obj/effect/tardis_exit/update_icon()
	if(the_tardis.opened)
		icon_state = "door_open"
		set_opacity(0)
	else
		icon_state = "door_closed"
		set_opacity(1)

/obj/effect/tardis_exit/attack_hand(mob/user as mob)
	if(!the_tardis)
		return
	the_tardis.add_fingerprint(user)
	the_tardis.toggle(user)

/obj/effect/tardis_exit/Bumped(atom/movable/A)
	if(!the_tardis || (!the_tardis.opened && !the_tardis.open()))
		if(istype(A, /mob))
			to_chat(A, "<span class='notice'>It won't budge!</span>")
		return
	update_icon()
	A.forceMove(get_turf(the_tardis))
