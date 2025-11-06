/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list(MELEE = 50, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 50, RAD = 100, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	var/id_tag = 1.0
	var/protected = 1

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/impassable
	name = "reinforced blast door"
	desc = "A heavy duty blast door that opens mechanically. Looks even tougher than usual."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = INFINITY

/obj/machinery/door/poddoor/impassable/gamma
	name = "gamma armory hatch"

/obj/machinery/door/poddoor/impassable/hostile_lockdown()
	return

/obj/machinery/door/poddoor/impassable/disable_lockdown()
	return

/obj/machinery/door/poddoor/bumpopen(mob/user)
	return

/obj/machinery/door/poddoor/impassable/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this door are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/door/poddoor/Bumped(atom/AM)
	if(density)
		return
	else
		return 0

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity)
	if(severity == EXPLODE_LIGHT)
		return
	..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)

/obj/machinery/door/poddoor/update_icon_state()
	if(density)
		icon_state = "closed"
	else
		icon_state = "open"

/obj/machinery/door/poddoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(mob/user, obj/item/I)
	if(!density)
		return
	if(!hasPower() && !(resistance_flags & INDESTRUCTIBLE))
		to_chat(user, "<span class='notice'>You start forcing [src] open...</span>")
		if(do_after(user, 50 * I.toolspeed, target = src))
			if(!hasPower())
				open()
			else
				to_chat(user, "<span class='warning'>[src] resists your efforts to force it!</span>")
	else
		to_chat(user, "<span class='warning'>[src] resists your efforts to force it!</span>")

 // Whoever wrote the old code for multi-tile spesspod doors needs to burn in hell. - Unknown
 // Wise words. - Bxil
/obj/machinery/door/poddoor/multi_tile
	name = "large pod door"
	icon = 'icons/obj/doors/blastdoor_1x2.dmi'
	layer = CLOSED_BLASTDOOR_LAYER
	width = 2

/obj/machinery/door/poddoor/multi_tile/triple
	icon = 'icons/obj/doors/blastdoor_1x3.dmi'
	width = 3

/obj/machinery/door/poddoor/multi_tile/quad
	icon = 'icons/obj/doors/blastdoor_1x4.dmi'
	width = 4

/obj/machinery/door/poddoor/multi_tile/impassable
	desc = "A heavy duty blast door that opens mechanically. Looks even tougher than usual."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = INFINITY

/obj/machinery/door/poddoor/multi_tile/impassable/hostile_lockdown()
	return

/obj/machinery/door/poddoor/multi_tile/impassable/disable_lockdown()
	return

/obj/machinery/door/poddoor/multi_tile/impassable/emag_act(mob/user)
	to_chat(user, "<span class='notice'>The electronic systems in this door are far too advanced for your primitive hacking peripherals.</span>")
	return

/obj/machinery/door/poddoor/multi_tile/impassable/triple
	icon = 'icons/obj/doors/blastdoor_1x3.dmi'
	width = 3

/obj/machinery/door/poddoor/multi_tile/impassable/quad
	icon = 'icons/obj/doors/blastdoor_1x4.dmi'
	width = 4
