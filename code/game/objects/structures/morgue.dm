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

#define EXTENDED_TRAY "extended"
#define EMPTY_MORGUE "empty"
#define UNREVIVABLE "unrevivable"
#define REVIVABLE "revivable"
#define NOT_BODY "notbody"
#define GHOST_CONNECTED "ghost"

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue"
	density = TRUE
	max_integrity = 400
	dir = EAST
	var/obj/structure/m_tray/connected = null
	var/static/status_descriptors = list(
		EXTENDED_TRAY = "The tray is currently extended.",
		EMPTY_MORGUE = "The tray is currently empty.",
		UNREVIVABLE = "The tray contains an unviable body.",
		REVIVABLE = "The tray contains a body that is responsive to revival techniques.",
		NOT_BODY = "The tray contains something that is not a body.",
		GHOST_CONNECTED = "The tray contains a body that might be responsive."
	)
	anchored = TRUE
	var/open_sound = 'sound/items/deconstruct.ogg'
	var/status

/obj/structure/morgue/Initialize()
	. = ..()
	update_icon(update_state())
	set_light(1, LIGHTING_MINIMUM_POWER)

/obj/structure/morgue/proc/update_state()
	. = UPDATE_OVERLAYS

	if(connected)
		status = EXTENDED_TRAY
		return

	if(!length(contents))
		status = EMPTY_MORGUE
		return

	var/mob/living/M = locate() in contents
	var/obj/structure/closet/body_bag/B = locate() in contents

	if(!M)
		M = locate() in B

	if(!M)
		status = NOT_BODY
		return

	var/mob/dead/observer/G = M.get_ghost()

	if(M.mind && !M.mind.suicided)
		if(M.client)
			status = REVIVABLE
			return

		if(G && G.client) //There is a ghost and it is connected to the server
			status = GHOST_CONNECTED
			return

	status = UNREVIVABLE

/obj/structure/morgue/update_overlays()
	. = ..()
	underlays.Cut()

	if(!connected)
		. += "morgue_[status]"
		underlays += emissive_appearance(icon, "morgue_[status]")

	if(name != initial(name))
		. += "morgue_label"

/obj/structure/morgue/examine(mob/user)
	. = ..()
	. += "[status_descriptors[status]]"

/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return

		if(2.0)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return

		if(3.0)
			if(prob(5))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return

/obj/structure/morgue/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A in connected.loc)
			if(!( A.anchored ))
				A.forceMove(src)
		playsound(loc, open_sound, 50, 1)
		QDEL_NULL(connected)
	else
		playsound(loc, open_sound, 50, 1)
		connect()

	add_fingerprint(user)
	update_icon(update_state())
	return

/obj/structure/morgue/attackby(P as obj, mob/user as mob, params)
	if(is_pen(P))
		var/t = rename_interactive(user, P)

		if(isnull(t))
			return

		update_icon(UPDATE_OVERLAYS)
		add_fingerprint(user)
		return

	return ..()

/obj/structure/morgue/wirecutter_act(mob/user)
	if(name != initial(name))
		to_chat(user, "<span class='notice'>You cut the tag off the morgue.</span>")
		name = initial(name)
		update_icon(UPDATE_OVERLAYS)
		return TRUE

/obj/structure/morgue/relaymove(mob/user)
	if(user.stat)
		return
	connect()

/obj/structure/morgue/proc/connect()
	connected = new /obj/structure/m_tray(loc)
	step(connected, dir)
	connected.layer = BELOW_OBJ_LAYER
	var/turf/T = get_step(src, dir)

	if(T.contents.Find(connected))
		connected.connected = src

		for(var/atom/movable/A in src)
			if(A.move_resist != INFINITY)
				A.forceMove(connected.loc)

		connected.icon_state = "morgue_tray"
		connected.dir = dir
		return

	QDEL_NULL(connected)

/obj/structure/morgue/Destroy()
	if(!connected)
		var/turf/T = loc
		for(var/atom/movable/A in src)
			A.forceMove(T)
	else
		QDEL_NULL(connected)

	return ..()

/obj/structure/morgue/container_resist(mob/living/L)
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
	icon_state = "morgue_tray"
	density = TRUE
	layer = 2.0
	var/obj/structure/morgue/connected = null
	anchored = TRUE
	pass_flags = LETPASSTHROW
	max_integrity = 350

/obj/structure/m_tray/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A as mob|obj in loc)
			if(!( A.anchored ))
				A.forceMove(connected)
		connected.connected = null
		connected.update_icon(connected.update_state())
		playsound(loc, connected.open_sound, 50, 1)
		add_fingerprint(user)
		qdel(src)
		return

/obj/structure/m_tray/MouseDrop_T(atom/movable/O, mob/living/user)
	if((!(istype(O, /atom/movable)) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return

	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return

	if(!ismob(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	O.forceMove(loc)

	if(user != O)
		user.visible_message("<span class='warning'>[user] stuffs [O] into [src]!</span>")


/obj/structure/m_tray/Destroy()
	if(connected && connected.connected == src)
		connected.connected = null

	connected = null
	return ..()

/obj/structure/tray/m_tray/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return TRUE

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

	return FALSE

/obj/structure/tray/m_tray/CanPathfindPass(obj/item/card/id/ID, dir, caller, no_id = FALSE)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/*
 * Crematorium
 */

GLOBAL_LIST_EMPTY(crematoriums)
// These have so much copypasted code from the above that they should really be made into subtypes
// Someone please I beg
/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema"
	density = TRUE
	var/obj/structure/c_tray/connected = null
	anchored = TRUE
	var/cremating = FALSE
	var/id = 1
	var/locked = FALSE
	var/open_sound = 'sound/items/deconstruct.ogg'

/obj/structure/crematorium/Initialize(mapload)
	. = ..()
	GLOB.crematoriums += src
	update_icon(UPDATE_OVERLAYS)

/obj/structure/crematorium/update_overlays()
	. = ..()
	if(connected)
		return

	. += "crema_closed"

	if(cremating)
		. += "crema_active"
		return

	if(length(contents))
		. += "crema_full"

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A in src)
				A.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return

		if(2.0)
			if(prob(50))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return

		if(3.0)
			if(prob(5))
				for(var/atom/movable/A in src)
					A.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return

/obj/structure/crematorium/attack_hand(mob/user as mob)
	if(cremating)
		to_chat(usr, "<span class='warning'>It's locked.</span>")
		return

	if(connected && !locked)
		for(var/atom/movable/A in connected.loc)
			if(!(A.anchored) && A.move_resist != INFINITY)
				A.forceMove(src)

		playsound(loc, open_sound, 50, 1)
		QDEL_NULL(connected)

	else if(!locked)
		playsound(loc, open_sound, 50, 1)
		connect()

	add_fingerprint(user)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/crematorium/attackby(P as obj, mob/user as mob, params)
	if(is_pen(P))
		rename_interactive(user, P)
		add_fingerprint(user)
		return

	return ..()

/obj/structure/crematorium/relaymove(mob/user as mob)
	if(user.stat || locked)
		return

	connect()


/obj/structure/crematorium/proc/connect()
	connected = new /obj/structure/c_tray(loc)
	step(connected, SOUTH)
	connected.layer = BELOW_OBJ_LAYER

	var/turf/T = get_step(src, SOUTH)

	if(T.contents.Find(connected))
		connected.connected = src
		update_icon(UPDATE_OVERLAYS)

		for(var/atom/movable/A in src)
			A.forceMove(connected.loc)

		connected.icon_state = "crema_tray"
		return

	QDEL_NULL(connected)

/obj/structure/crematorium/proc/cremate(mob/user as mob)
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(!length(contents))
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>You hear a hollow crackle.</span>", EMOTE_VISIBLE)

		return


	for(var/mob/M in viewers(src))
		M.show_message("<span class='warning'>You hear a roar as the crematorium activates.</span>", EMOTE_VISIBLE)

	cremating = TRUE
	locked = TRUE
	update_icon(UPDATE_OVERLAYS)

	for(var/mob/living/M in search_contents_for(/mob/living))
		if(QDELETED(M))
			continue

		if(M.stat != DEAD)
			M.emote("scream")

		if(istype(user))
			add_attack_logs(user, M, "Cremated")

		M.death(TRUE)

		if(QDELETED(M))
			continue // Re-check for mobs that delete themselves on death

		M.ghostize()
		qdel(M)

	for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
		qdel(O)

	new /obj/effect/decal/cleanable/ash(src)
	sleep(30)
	cremating = FALSE
	locked = FALSE
	update_icon(UPDATE_OVERLAYS)
	playsound(loc, 'sound/machines/ding.ogg', 50, 1)


/obj/structure/crematorium/Destroy()
	GLOB.crematoriums -= src

	if(!connected)
		var/turf/T = loc
		for(var/atom/movable/A in src)
			A.forceMove(T)
	else
		QDEL_NULL(connected)

	return ..()

/obj/structure/crematorium/container_resist(mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, "<span class='alert'>You attempt to slide yourself out of \the [src]...</span>")
	attack_hand(CM)

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
	icon_state = "crema_tray"
	density = TRUE
	layer = 2.0
	var/obj/structure/crematorium/connected = null
	anchored = TRUE
	pass_flags = LETPASSTHROW

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if(connected)
		for(var/atom/movable/A in loc)
			if(!A.anchored)
				A.forceMove(connected)

		connected.connected = null
		connected.update_icon(UPDATE_OVERLAYS)
		add_fingerprint(user)
		qdel(src)


/obj/structure/c_tray/MouseDrop_T(atom/movable/O, mob/living/user)
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
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
	power_channel = EQUIP
	idle_power_consumption = 100
	active_power_consumption = 5000
	anchored = TRUE
	req_access = list(ACCESS_CREMATORIUM)
	/// ID of the crematorium to hook into
	var/id = 1

/obj/machinery/crema_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/crema_switch/attack_hand(mob/user)
	if(!has_power(power_channel)) // Do we have power?
		return

	if(!(allowed(usr) || user.can_advanced_admin_interact()))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return

	use_power(400000)
	for(var/obj/structure/crematorium/C in GLOB.crematoriums)
		if(C.id == id && !C.cremating)
			C.cremate(user)


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
				morgue.update_icon(UPDATE_OVERLAYS)

#undef EXTENDED_TRAY
#undef EMPTY_MORGUE
#undef UNREVIVABLE
#undef REVIVABLE
#undef NOT_BODY
#undef GHOST_CONNECTED
