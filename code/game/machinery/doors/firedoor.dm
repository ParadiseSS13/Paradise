#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_WIRES_EXPOSED 2 //Cover plate is removed, wires are available
#define CONSTRUCTION_GUTTED 3 //Wires are removed, circuit ready to remove
#define CONSTRUCTION_NOCIRCUIT 4 //Circuit board removed, can safely weld apart

/var/const/OPEN = 1
/var/const/CLOSED = 2

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/Doorfireglass.dmi'
	icon_state = "door_open"
	opacity = 0
	density = FALSE
	heat_proof = TRUE
	glass = TRUE
	closed_layer = 3.11
	auto_close_time = 50
	assemblytype = /obj/structure/firelock_frame
	var/can_force = TRUE
	var/force_open_time = 300
	var/can_crush = TRUE
	var/nextstate = null
	var/boltslocked = TRUE
	var/active_alarm = FALSE

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	return 0

/obj/machinery/door/firedoor/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	update_icon()

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C, mob/user, params)
	add_fingerprint(user)

	if(operating)
		return

	if(iswelder(C))
		if(!density)
			return
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			welded = !welded
			to_chat(user, "<span class='danger'>You [welded ? "welded" : "unwelded"] \the [src]</span>")
			update_icon()
			return

	if(welded)
		if(iswrench(C))
			if(boltslocked)
				to_chat(user, "<span class='notice'>There are screws locking the bolts in place!</span>")
				return
			playsound(get_turf(src), C.usesound, 50, 1)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
								 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!do_after(user, 50 * C.toolspeed, target = src))
				return
			playsound(get_turf(src), C.usesound, 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								 "<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		else if(isscrewdriver(C))
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts...</span>", \
								 "<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts...</span>")
			playsound(get_turf(src), C.usesound, 50, 1)
			boltslocked = !boltslocked
			return
		else
			to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
			return

	if(iscrowbar(C) || istype(C, /obj/item/weapon/twohanded/fireaxe))
		if(istype(C, /obj/item/weapon/twohanded/fireaxe))
			var/obj/item/weapon/twohanded/fireaxe/F = C
			if(!F.wielded)
				return

		user.visible_message("[user] forces \the [src] with [C].",
		"You force \the [src] with [C].")
		if(density)
			open()
		else
			close()

/obj/machinery/door/firedoor/attack_hand(mob/user)
	if(operating || !density)
		return

	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)

	if(can_force && (!glass || user.a_intent != INTENT_HELP))
		user.visible_message("<span class='notice'>[user] begins forcing \the [src].</span>", \
							 "<span class='notice'>You begin forcing \the [src].</span>")
		if(do_after(user, force_open_time, target = src))
			user.visible_message("<span class='notice'>[user] forces \the [src].</span>", \
								 "<span class='notice'>You force \the [src].</span>")
			open()
	else if(glass)
		user.visible_message("<span class='warning'>[user] bangs on \the [src].</span>",
							 "<span class='warning'>You bang on \the [src].</span>")
		playsound(get_turf(src), 'sound/effects/Glassknock.ogg', 10, 1)

/obj/machinery/door/firedoor/attack_ai(mob/user)
	forcetoggle()

/obj/machinery/door/firedoor/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		forcetoggle(TRUE)

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	open()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
			playsound(src, 'sound/machines/airlock_ext_open.ogg', 30, 1)
		if("closing")
			flick("door_closing", src)
			playsound(src, 'sound/machines/airlock_ext_close.ogg', 30, 1)

/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	if(active_alarm && !(stat & NOPOWER))
		overlays += image('icons/obj/doors/Doorfire.dmi', "alarmlights")
	if(density)
		icon_state = "door_closed"
		if(welded)
			overlays += "welded"
	else
		icon_state = "door_open"
		if(welded)
			overlays += "welded_open"

/obj/machinery/door/firedoor/proc/activate_alarm()
	active_alarm = TRUE
	update_icon()

/obj/machinery/door/firedoor/proc/deactivate_alarm()
	active_alarm = FALSE
	update_icon()

/obj/machinery/door/firedoor/open(auto_close = TRUE)
	if(welded)
		return
	. = ..()
	latetoggle(auto_close)

	if(auto_close)
		autoclose = TRUE

/obj/machinery/door/firedoor/close()
	. = ..()
	if(can_crush)
		crush()
	latetoggle()

/obj/machinery/door/firedoor/autoclose()
	if(active_alarm)
		. = ..()

/obj/machinery/door/firedoor/proc/latetoggle(auto_close = TRUE)
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open(auto_close)
		if(CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/proc/forcetoggle(magic = FALSE, auto_close = TRUE)
	if(!magic && (operating || stat & NOPOWER))
		return
	if(density)
		open(auto_close)
	else
		close()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(can_deconstruct)
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		if(disassembled)
			F.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
		F.update_icon()
	qdel(src)

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags = ON_BORDER
	can_crush = FALSE

/obj/machinery/door/firedoor/border_only/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = FALSE
	opacity = 1
	assemblytype = /obj/structure/firelock_frame/heavy
	can_force = FALSE

/obj/machinery/door/firedoor/heavy/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)

/obj/item/weapon/firelock_electronics
	name = "firelock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "A circuit board used in construction of firelocks."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/Deconstruct.ogg'

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	anchored = 0
	density = 1
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = 1

/obj/structure/firelock_frame/examine(mob/user)
	..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			to_chat(user, "There is a small metal plate covering the wires.")
		if(CONSTRUCTION_WIRES_EXPOSED)
			to_chat(user, "Wires are trailing from the maintenance panel.")
		if(CONSTRUCTION_GUTTED)
			to_chat(user, "The circuit board is visible.")
		if(CONSTRUCTION_NOCIRCUIT)
			to_chat(user, "There are no electronics in the frame.")
	if(reinforced)
		to_chat(user, "The frame is reinforced.")

/obj/structure/firelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/weapon/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(iscrowbar(C))
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!do_after(user, 50 * C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
									 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(iswrench(C))
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					to_chat(user, "<span class='warning'>There's already a firelock there.</span>")
					return
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!do_after(user, 30 * C.toolspeed, target = src))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message("<span class='notice'>[user] finishes the firelock.</span>", \
									 "<span class='notice'>You finish the firelock.</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] is already reinforced.</span>")
					return
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to reinforce [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins reinforcing [src]...</span>", \
									 "<span class='notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(do_after(user, 60 * C.toolspeed, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
										 "<span class='notice'>You reinforce [src].</span>")
					playsound(get_turf(src), C.usesound, 50, 1)
					P.use(2)
					reinforced = 1
				return

		if(CONSTRUCTION_WIRES_EXPOSED)
			if(iswirecutter(C))
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!do_after(user, 60 * C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
									 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
				var/obj/item/stack/cable_coil/B = new(get_turf(src))
				B.amount = 5
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(iswelder(C))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1, user))
					playsound(get_turf(src), C.usesound, 50, 1)
					user.visible_message("<span class='notice'>[user] starts welding a metal plate into [src]...</span>", \
										 "<span class='notice'>You begin welding the cover plate back onto [src]...</span>")
					if(!do_after(user, 80 * C.toolspeed, target = src))
						return
					if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
						return
					playsound(get_turf(src), C.usesound, 50, 1)
					user.visible_message("<span class='notice'>[user] welds the metal plate into [src].</span>", \
										 "<span class='notice'>You weld [src]'s cover plate into place, hiding the wires.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(iscrowbar(C))
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
									 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(!do_after(user, 50 * C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/weapon/firelock_electronics(get_turf(src))
				playsound(get_turf(src), C.usesound, 50, 1)
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(iscoil(C))
				var/obj/item/stack/cable_coil/B = C
				if(B.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need more wires to add wiring to [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
									 "<span class='notice'>You begin adding wires to [src]...</span>")
				playsound(get_turf(src), B.usesound, 50, 1)
				if(do_after(user, 60 * B.toolspeed, target = src))
					if(constructionStep != CONSTRUCTION_GUTTED || B.get_amount() < 5 || !B)
						return
					user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
										 "<span class='notice'>You wire [src].</span>")
					playsound(get_turf(src), B.usesound, 50, 1)
					B.use(5)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(iswelder(C))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1,user))
					playsound(get_turf(src), W.usesound, 50, 1)
					user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
										 "<span class='notice'>You begin slicing [src] apart...</span>")
					if(!do_after(user, 80 * W.toolspeed, target = src))
						return
					if(constructionStep != CONSTRUCTION_NOCIRCUIT)
						return
					user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into metal.</span>")
					playsound(get_turf(src), W.usesound, 50, 1)
					var/turf/T = get_turf(src)
					new /obj/item/stack/sheet/metal(T, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(T, 2)
					qdel(src)
				return
			if(istype(C, /obj/item/weapon/firelock_electronics))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
									 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(!do_after(user, 40 * C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT)
					return
				user.drop_item()
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
									 "<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()
