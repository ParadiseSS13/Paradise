/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Not super delicate, a container designed for holding retractible trays, primarily for body storage (or disposal).
 */

#define EXTENDED_TRAY "extended"
#define EMPTY_MORGUE "empty"
#define UNREVIVABLE "unrevivable"
#define REVIVABLE "revivable"
#define NOT_BODY "notbody"
#define GHOST_CONNECTED "ghost"

/obj/structure/body_slab
	name = "slab"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue"
	density = 1
	max_integrity = 400
	dir = EAST
	anchored = TRUE
	var/extended
	var/obj/structure/morgue_tray/connected = null
	var/open_sound = 'sound/items/deconstruct.ogg'
	var/status



/obj/structure/body_slab/Initialize()
	. = ..()
	create_tray()
	update()

/** Overridable method for creating the morgue tray */
/obj/structure/body_slab/proc/create_tray()
	connected = new /obj/structure/morgue_tray(src)
	extended = FALSE
	connected.icon_state = "morguet"
	connected.dir = dir

/obj/structure/body_slab/proc/update()
	if(extended || !connected)
		status = EXTENDED_TRAY
		desc = initial(desc) + "\nThe tray is currently extended."
	else
		status = EMPTY_MORGUE
		desc = initial(desc) + "\nThere is a tray inside."

	add_overlay("morgue_[status]")

/obj/structure/body_slab/ex_act(severity)

	switch(severity)
		if(1)
			for(var/atom/movable/A in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3)
			if(prob(5))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/body_slab/proc/toggle_tray(mob/user as mob)
	if(!connected)
		return
	if(extended)
		// Move everything inside
		for(var/atom/movable/A in connected.loc)
			if(A.move_resist < INFINITY && !A.anchored)
				A.forceMove(src)
		connected.forceMove(src)
		playsound(loc, open_sound, 50, 1)
		extended = FALSE
	else
		step(connected, dir)			// try to step forward
		var/turf/T = get_step(src, dir)
		if(T.contents.Find(connected))	// check whether the tray actually did move
			playsound(loc, open_sound, 50, 1)
			connected.connected = src
			for(var/atom/movable/A in src)
				if(A.move_resist != INFINITY)
					A.forceMove(connected.loc)
			connected.icon_state = "morgue_tray"
			connected.dir = dir
			extended = TRUE

	update()

/obj/structure/body_slab/attack_hand(mob/user)
	toggle_tray(user)
	add_fingerprint(user)

/obj/structure/body_slab/relaymove(mob/user as mob)
	if(user.stat)
		return
	if(connected && !extended)
		toggle_tray()

/obj/structure/body_slab/Destroy()
	if(!extended)
		var/turf/T = loc
		for(var/atom/movable/A in src)
			A.forceMove(T)
	QDEL_NULL(connected)
	return ..()

/obj/structure/body_slab/container_resist(mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, "<span class='alert'>You attempt to slide yourself out of \the [src]...</span>")
	src.attack_hand(CM)


/obj/structure/body_slab/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/**
 * Slabs specifically for the morgue. Show the state of the contents inside of them,
 * particularly the viability of a body inside.
 * Can also be marked by pen.
 */
/obj/structure/body_slab/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."

	var/static/status_descriptors = list(
		EXTENDED_TRAY = "The tray is currently extended.",
		EMPTY_MORGUE = "The tray is currently empty.",
		UNREVIVABLE = "The tray contains an unviable body.",
		REVIVABLE = "The tray contains a body that is responsive to revival techniques.",
		NOT_BODY = "The tray contains something that is not a body.",
		GHOST_CONNECTED = "The tray contains a body that might be responsive."
	)

/obj/structure/body_slab/morgue/proc/update()
	cut_overlays()
	if(!connected)
		if(contents.len)
			var/mob/living/M = locate() in contents
			var/obj/structure/closet/body_bag/B = locate() in contents
			if(M==null) M = locate() in B

			if(M)
				var/mob/dead/observer/G = M.get_ghost()
				if(M.mind && !M.mind.suicided)
					if(M.client)
						status = REVIVABLE
					else if(G && G.client) //There is a ghost and it is connected to the server
						status = GHOST_CONNECTED
					else
						status = UNREVIVABLE
				else
					status = UNREVIVABLE
			else
				status = NOT_BODY
		else
			status = EMPTY_MORGUE
		add_overlay("morgue_[status]")
	else
		status = EXTENDED_TRAY
	if(name != initial(name))
		add_overlay("morgue_label")

/obj/structure/body_slab/morgue/examine(mob/user)
	. = ..()
	. += "[status_descriptors[status]]"

/obj/structure/body_slab/morgue/attackby(P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/pen))
		var/t = rename_interactive(user, P)
		if(isnull(t))
			return
		cut_overlays()
		if(t)
			add_overlay(image(icon, "morgue_label"))
		add_fingerprint(user)
		return
	return ..()


/obj/structure/body_slab/morgue/wirecutter_act(mob/user)
	if(name != initial(name))
		to_chat(user, "<span class='notice'>You cut the tag off the morgue.</span>")
		name = initial(name)
		update()
		return TRUE

/*
 * Morgue tray
 */
/obj/structure/morgue_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue_tray"
	density = 1
	layer = TURF_LAYER
	var/obj/structure/body_slab/connected = null
	anchored = TRUE
	pass_flags = LETPASSTHROW
	max_integrity = 350


/obj/structure/morgue_tray/attack_hand(mob/user as mob)
	if(connected)
		connected.toggle_tray(user)

/obj/structure/morgue_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if((!(istype(O, /atom/movable)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.forceMove(loc)
	if(user != O)
		user.visible_message("<span class='warning'>[user] stuffs [O] into [src]!</span>")
	return

/obj/structure/morgue_tray/Destroy()
	if(connected && connected.connected == src)
		connected.connected = null
	connected = null
	return ..()

/obj/structure/morgue_tray/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return TRUE
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE
	else
		return FALSE

/obj/structure/morgue_tray/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/*
 * Crematorium
 */

/obj/structure/body_slab/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	var/cremating = FALSE
	icon_state = "crema"
	var/id = 1
	dir = SOUTH

/** Overridable method for creating the morgue tray */
/obj/structure/body_slab/crematorium/create_tray()
	connected = new /obj/structure/morgue_tray/crematorium(src)
	extended = FALSE
	connected.icon_state = "crema_tray"
	connected.dir = dir


/obj/structure/body_slab/crematorium/Initialize(mapload)
	. = ..()
	update()

/obj/structure/body_slab/crematorium/update()
	cut_overlays()
	if(!connected)
		add_overlay("crema_closed")
		if(cremating)
			add_overlay("crema_active")
			return
		if(contents.len)
			add_overlay("crema_full")

/obj/structure/body_slab/crematorium/attack_hand(mob/user as mob)
	if(cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return
	else
		..()

/obj/structure/body_slab/crematorium/attackby(P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/pen))
		rename_interactive(user, P)
		add_fingerprint(user)
		return
	return ..()

/obj/structure/body_slab/crematorium/relaymove(mob/user as mob)
	if(user.stat || cremating)
		return
	toggle_tray()

/obj/structure/body_slab/crematorium/proc/cremate(mob/user as mob)
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a hollow crackle.</span>", 1)
			return

	else
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", 1)

		cremating = TRUE
		update()

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
			if(O != connected)  // don't burn the tray though
				qdel(O)

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = FALSE
		update()
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)
	return

/*
 * Crematorium tray
 */
/obj/structure/morgue_tray/crematorium
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "crema_tray"
	pass_flags = LETPASSTHROW

// Crematorium switch
/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	power_channel = EQUIP
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 5000
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
	if(powered(power_channel)) // Do we have power?
		if(allowed(usr) || user.can_advanced_admin_interact())
			use_power(400000)
			for(var/obj/structure/body_slab/crematorium/C in world)
				if(C.id == id)
					if(!C.cremating)
						C.cremate(user)


		else
			to_chat(usr, "<span class='warning'>Access denied.</span>")

/mob/proc/update_morgue()
	if(stat == DEAD)
		var/obj/structure/body_slab/morgue/morgue
		var/mob/living/C = src
		var/mob/dead/observer/G = src
		if(istype(G) && G.can_reenter_corpse && G.mind) //We're a ghost, let's find our corpse
			C = G.mind.current
		if(istype(C)) //We found our corpse, is it inside a morgue?
			morgue = get(C.loc, /obj/structure/body_slab/morgue)
			if(morgue)
				morgue.update()

#undef EXTENDED_TRAY
#undef EMPTY_MORGUE
#undef UNREVIVABLE
#undef REVIVABLE
#undef NOT_BODY
#undef GHOST_CONNECTED
