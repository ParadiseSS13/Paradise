/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Morgue
 */

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	max_integrity = 400
	dir = EAST
	var/obj/structure/m_tray/connected = null
	var/list/status_descriptors = list(
	"The tray is currently extended.",
	"The tray is currently empty.",
	"The tray contains an unviable body.",
	"The tray contains a body that is responsive to revival techniques.",
	"The tray contains something that is not a body.",
	"The tray contains a body that might be responsive."
	)
	anchored = 1.0
	var/open_sound = 'sound/items/deconstruct.ogg'

/obj/structure/morgue/Initialize()
	. = ..()
	update()

/obj/structure/morgue/proc/update()
	if(connected)
		icon_state = "morgue0"
		desc = initial(desc) + "\n[status_descriptors[1]]"
	else
		if(contents.len)

			var/mob/living/M = locate() in contents

			var/obj/structure/closet/body_bag/B = locate() in contents
			if(M==null) M = locate() in B

			if(M)
				var/mob/dead/observer/G = M.get_ghost()

				if(M.client)
					icon_state = "morgue3"
					desc = initial(desc) + "\n[status_descriptors[4]]"
				else if(G && G.client) //There is a ghost and it is connected to the server
					icon_state = "morgue5"
					desc = initial(desc) + "\n[status_descriptors[6]]"
				else
					icon_state = "morgue2"
					desc = initial(desc) + "\n[status_descriptors[3]]"


			else
				icon_state = "morgue4"
				desc = initial(desc) + "\n[status_descriptors[5]]"
		else
			icon_state = "morgue1"
			desc = initial(desc) + "\n[status_descriptors[2]]"
	return


/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/morgue/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A as mob|obj in connected.loc)
			if(!( A.anchored ))
				A.forceMove(src)
		playsound(loc, open_sound, 50, 1)
		QDEL_NULL(connected)
	else
		playsound(loc, open_sound, 50, 1)
		connected = new /obj/structure/m_tray( loc )
		step(connected, dir)
		connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, dir)
		if(T.contents.Find(connected))
			connected.connected = src
			icon_state = "morgue0"
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(connected.loc)
			connected.icon_state = "morguet"
			connected.dir = dir
		else
			QDEL_NULL(connected)
	add_fingerprint(user)
	update()
	return

/obj/structure/morgue/attackby(P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", name), null)  as text
		if(user.get_active_hand() != P)
			return
		if((!in_range(src, usr) && loc != user))
			return
		t = sanitize(copytext(t,1,MAX_MESSAGE_LEN))
		if(t)
			name = text("Morgue- '[]'", t)
			overlays += image(icon, "morgue_label")
		else
			name = "Morgue"
			overlays.Cut()
		add_fingerprint(user)
		return
	return ..()

/obj/structure/morgue/relaymove(mob/user as mob)
	if(user.stat)
		return
	connected = new /obj/structure/m_tray( loc )
	step(connected, dir)
	connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, dir)
	if(T.contents.Find(connected))
		connected.connected = src
		icon_state = "morgue0"
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(connected.loc)
		connected.icon_state = "morguet"
	else
		QDEL_NULL(connected)
	return

/obj/structure/morgue/Destroy()
	QDEL_NULL(connected)
	return ..()

/obj/structure/morgue/container_resist(var/mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, "<span class='alert'>You attempt to slide yourself out of \the [src]...</span>")
	src.attack_hand(CM)


/obj/structure/morgue/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/*
 * Morgue tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing. May float away in no-gravity."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/structure/morgue/connected = null
	anchored = 1.0
	pass_flags = LETPASSTHROW
	max_integrity = 350


/obj/structure/m_tray/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A as mob|obj in loc)
			if(!( A.anchored ))
				A.forceMove(connected)
		connected.connected = null
		connected.update()
		add_fingerprint(user)
		qdel(src)
		return
	return

/obj/structure/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.forceMove(loc)
	if(user != O)
		user.visible_message("<span class='warning'>[user] stuffs [O] into [src]!</span>")
	return

/obj/structure/m_tray/Destroy()
	if(connected && connected.connected == src)
		connected.connected = null
	connected = null
	return ..()

/obj/structure/tray/m_tray/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return 0

/obj/structure/tray/m_tray/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/*
 * Crematorium
 */

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0
	var/open_sound = 'sound/items/deconstruct.ogg'

/obj/structure/crematorium/proc/update()
	if(connected)
		icon_state = "crema0"
	else
		if(contents.len)
			icon_state = "crema2"
		else
			icon_state = "crema1"
	return

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/crematorium/attack_hand(mob/user as mob)
	if(cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return
	if((connected) && (locked == 0))
		for(var/atom/movable/A as mob|obj in connected.loc)
			if(!( A.anchored ))
				A.forceMove(src)
		playsound(loc, open_sound, 50, 1)
		QDEL_NULL(connected)
	else if(locked == 0)
		playsound(loc, open_sound, 50, 1)
		connected = new /obj/structure/c_tray( loc )
		step(connected, SOUTH)
		connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if(T.contents.Find(connected))
			connected.connected = src
			icon_state = "crema0"
			for(var/atom/movable/A as mob|obj in src)
				A.forceMove(connected.loc)
			connected.icon_state = "cremat"
		else
			QDEL_NULL(connected)
	add_fingerprint(user)
	update()

/obj/structure/crematorium/attackby(P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", name), null)  as text
		if(user.get_active_hand() != P)
			return
		if((!in_range(src, usr) > 1 && loc != user))
			return
		t = sanitize(copytext(t,1,MAX_MESSAGE_LEN))
		if(t)
			name = text("Crematorium- '[]'", t)
		else
			name = "Crematorium"
		add_fingerprint(user)
		return
	return ..()

/obj/structure/crematorium/relaymove(mob/user as mob)
	if(user.stat || locked)
		return
	connected = new /obj/structure/c_tray( loc )
	step(connected, SOUTH)
	connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if(T.contents.Find(connected))
		connected.connected = src
		icon_state = "crema0"
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(connected.loc)
		connected.icon_state = "cremat"
	else
		QDEL_NULL(connected)
	return

/obj/structure/crematorium/proc/cremate(mob/user as mob)
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a hollow crackle.</span>", 1)
			return

	else
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", 1)

		cremating = 1
		locked = 1
		icon_state = "crema_active"

		for(var/mob/living/M in search_contents_for(/mob/living))
			if(QDELETED(M))
				continue
			if(M.stat!=2)
				M.emote("scream")
			if(istype(user))
				add_attack_logs(user, M, "Cremated")
			M.death(1)
			if(QDELETED(M))
				continue // Re-check for mobs that delete themselves on death
			M.ghostize()
			qdel(M)

		for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			qdel(O)

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		locked = 0
		update()
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return

/obj/structure/crematorium/Destroy()
	QDEL_NULL(connected)
	return ..()

/obj/structure/crematorium/container_resist(var/mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, "<span class='alert'>You attempt to slide yourself out of \the [src]...</span>")
	src.attack_hand(CM)

/obj/structure/crematorium/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/*
 * Crematorium tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/structure/crematorium/connected = null
	anchored = 1.0
	pass_flags = LETPASSTHROW

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A as mob|obj in loc)
			if(!( A.anchored ))
				A.forceMove(connected)
			//Foreach goto(26)
		connected.connected = null
		connected.update()
		add_fingerprint(user)
		qdel(src)
		return
	return

/obj/structure/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.forceMove(loc)
	if(user != O)
		user.visible_message("<span class='warning'>[user] stuffs [O] into [src]!</span>")
			//Foreach goto(99)
	return

/obj/structure/c_tray/Destroy()
	if(connected && connected.connected == src)
		connected.connected = null
	connected = null
	return ..()

// Crematorium switch
/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = 1.0
	req_access = list(ACCESS_CREMATORIUM)
	var/on = 0
	var/area/area = null
	var/otherarea = null
	var/id = 1

/obj/machinery/crema_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/crema_switch/attack_hand(mob/user)
	if(allowed(usr) || user.can_advanced_admin_interact())
		for(var/obj/structure/crematorium/C in world)
			if(C.id == id)
				if(!C.cremating)
					C.cremate(user)
	else
		to_chat(usr, "<span class='warning'>Access denied.</span>")

/mob/proc/update_morgue()
	if(stat == DEAD)
		var/obj/structure/morgue/morgue
		var/mob/living/C = src
		var/mob/dead/observer/G = src
		if(istype(G) && G.can_reenter_corpse && G.mind) //We're a ghost, let's find our corpse
			C = G.mind.current
		if(istype(C)) //We found our corpse, is it inside a morgue?
			morgue = get(C.loc, /obj/structure/morgue)
			if(morgue)
				morgue.update()
