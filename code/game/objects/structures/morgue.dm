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

 // TODO:
 // Crematorium requires plasma tank to operate
 // Morgue new icons + morgue directional icons

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue_empty"
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
	var/list/morgue_content = get_all_contents() - src - connected
	var/list/morgue_mob = get_all_contents_type(/mob/living)

	if(connected)
		icon_state = "morgue_connected"
		desc = initial(desc) + "\n[status_descriptors[1]]"
		return

	if(!length(morgue_content))
		icon_state = "morgue_empty"
		desc = initial(desc) + "\n[status_descriptors[2]]"
		return

	// If no mobs inside
	if(!length(morgue_mob))
		icon_state = "morgue_no_mobs"
		desc = initial(desc) + "\n[status_descriptors[5]]"
		return

	// If player is online and didn't suicide
	if(morgue_mob)
		var/mob/living/entity       = locate() in morgue_content
		var/mob/dead/observer/ghost = entity.get_ghost()
		// Clone-ready entity
		if(entity.client)
			icon_state = "morgue_clone_ready"
			desc = initial(desc) + "\n[status_descriptors[4]]"

		//There is a ghost and it is connected to the server
		else if(ghost && ghost.client)
			icon_state = "morgue_soul_away"
			desc = initial(desc) + "\n[status_descriptors[6]]"

		else
			icon_state = "morgue_unclonable"
			desc = initial(desc) + "\n[status_descriptors[3]]"

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
		connected = new /obj/structure/m_tray( loc )
		step(connected, dir)
		connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, dir)
		if(T.contents.Find(connected))
			connected.connected = src
			icon_state = "morgue_connected"
			for(var/atom/movable/A in src)
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
		var/t = rename_interactive(user, P)
		if(isnull(t))
			return
		cut_overlays()
		if(t)
			add_overlay(image(icon, "morgue_label"))
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
		icon_state = "morgue_connected"
		for(var/atom/movable/A in src)
			A.forceMove(connected.loc)
		connected.icon_state = "morguet"
	else
		QDEL_NULL(connected)
	return

/obj/structure/morgue/Destroy()
	if(!connected)
		var/turf/T = loc
		for(var/atom/movable/A in src)
			A.forceMove(T)
	else
		QDEL_NULL(connected)
	return ..()

/obj/structure/morgue/container_resist(var/mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, span_alert("You attempt to slide yourself out of \the [src]..."))
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
		playsound(loc, connected.open_sound, 50, 1)
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
		user.visible_message(span_warning("[user] stuffs [O] into [src]!"))
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
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/*
 * Crematorium
 */

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema_default"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = FALSE
	var/id = 1
	var/locked = FALSE
	var/open_sound = 'sound/items/deconstruct.ogg'

/// Updates crematorium icon state
/obj/structure/crematorium/proc/update_icon_state()
	if(connected)
		icon_state = "crema_connected"
	else if(cremating)
		icon_state = "crema_cremating"
	else if(length(contents))
		icon_state = "crema_active"
	else
		icon_state = "crema_default"

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
	return

/obj/structure/crematorium/attack_hand(mob/user as mob)
	if(cremating)
		to_chat(usr, span_warning("It's locked."))
		return
	if((connected) && (locked == 0))
		for(var/atom/movable/A in connected.loc)
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
			icon_state = "crema_connected"
			for(var/atom/movable/A in src)
				A.forceMove(connected.loc)
			connected.icon_state = "crema_tray"
		else
			QDEL_NULL(connected)
	add_fingerprint(user)
	update_icon_state()

/obj/structure/crematorium/attackby(P as obj, mob/user as mob, params)
	if(istype(P, /obj/item/pen))
		rename_interactive(user, P)
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
		icon_state = "crema_connected"
		for(var/atom/movable/A in src)
			A.forceMove(connected.loc)
		connected.icon_state = "crema_tray"
	else
		QDEL_NULL(connected)
	return

/obj/structure/crematorium/proc/cremate(mob/user as mob)
	if(locked)
		return //don't let you cremate something twice or w/e

	// Crema_tray doesn't count as content
	var/list/crema_content = get_all_contents() - src - connected

	if(!length(crema_content))
		audible_message(span_warning("Вы слышите глухой треск."))
		return

	// Ash piles are not crematable
	if(locate(/obj/effect/decal/cleanable/ash) in crema_content)
		audible_message(span_warning("Крематорий разгорается на несколько секунд и затухает."))
		return

	else
		audible_message(span_warning("Запустив крематорий, вы слышите рёв."))

		cremating = TRUE
		locked = TRUE
		update_icon_state()

		for(var/mob/living/entity in crema_content)
			if(QDELETED(entity))
				continue
			if(entity.stat != DEAD)
				entity.emote("scream")
			if(user)
				add_attack_logs(user, entity, "Cremated")

			entity.death(1)

			// If there are mobs deleting themselfes, why do we need to check them?
			if(entity)
				entity.ghostize()
				qdel(entity)

		for(var/obj/target in crema_content)
			qdel(target)

		// No more ash stock-piling
		if(!locate(/obj/effect/decal/cleanable/ash) in get_step(src, dir))
			new/obj/effect/decal/cleanable/ash/(src)

		sleep(30)

		if(!QDELETED(src))
			locked = FALSE
			cremating = FALSE
			update_icon_state()
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)

/obj/structure/crematorium/Destroy()
	if(!connected)
		var/turf/T = loc
		for(var/atom/movable/A in src)
			A.forceMove(T)
	else
		QDEL_NULL(connected)
	return ..()

/obj/structure/crematorium/container_resist(var/mob/living/L)
	var/mob/living/carbon/CM = L
	if(!istype(CM))
		return
	if(CM.stat || CM.restrained())
		return

	to_chat(CM, span_alert("You attempt to slide yourself out of \the [src]..."))
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
	icon_state = "crema_tray"
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
		connected.update_icon_state()
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
		user.visible_message(span_warning("[user] stuffs [O] into [src]!"))
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
	icon = 'icons/obj/engines_and_power/power.dmi'
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
		to_chat(usr, span_warning("Access denied."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)

/mob/proc/update_morgue()
	if(stat == DEAD)
		var/obj/structure/morgue/morgue
		var/mob/living/creature = src
		var/mob/dead/observer/ghost = src
		if(istype(ghost) && ghost.can_reenter_corpse && ghost.mind) //We're a ghost, let's find our corpse
			creature = ghost.mind.current
		if(istype(creature)) //We found our corpse, is it inside a morgue?
			morgue = get(creature.loc, /obj/structure/morgue)
			if(morgue)
				morgue.update()
