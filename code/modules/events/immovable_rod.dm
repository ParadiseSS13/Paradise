/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/event/immovable_rod
	announceWhen = 5

/datum/event/immovable_rod/announce()
	GLOB.minor_announcement.Announce("What the fuck was that?!", "General Alert")

/datum/event/immovable_rod/start()
	var/startside = pick(GLOB.cardinal)
	var/turf/startT = spaceDebrisStartLoc(startside, level_name_to_num(MAIN_STATION))
	var/turf/endT = spaceDebrisFinishLoc(startside, level_name_to_num(MAIN_STATION))
	new /obj/effect/immovablerod/event(startT, endT)

/obj/effect/immovablerod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = TRUE
	anchored = TRUE
	var/z_original = 0
	var/destination
	var/notify = TRUE
	var/move_delay = 1

/obj/effect/immovablerod/New(atom/start, atom/end, delay)
	. = ..()
	loc = start
	z_original = z
	destination = end
	move_delay = delay
	if(notify)
		notify_ghosts("\A [src] is inbound!",
				enter_link="<a href=byond://?src=[UID()];follow=1>(Click to follow)</a>",
				source = src, action = NOTIFY_FOLLOW)
	GLOB.poi_list |= src
	if(end?.z == z_original)
		walk_towards(src, destination, move_delay)

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["follow"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/effect/immovablerod/Destroy()
	GLOB.poi_list.Remove(src)
	return ..()

/obj/effect/immovablerod/ex_act(severity)
	return 0

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull()
	return

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message("CLANG")

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if(isturf(clong) || isobj(clong))
		if(clong.density)
			clong.ex_act(2)

	else if(ismob(clong))
		if(ishuman(clong))
			var/mob/living/carbon/human/H = clong
			H.visible_message("<span class='danger'>[H.name] is penetrated by an immovable rod!</span>" ,
				"<span class='userdanger'>The rod penetrates you!</span>" ,
				"<span class ='danger'>You hear a CLANG!</span>")
			H.adjustBruteLoss(160)
		if(clong.density || prob(10))
			clong.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/event
	// The base chance to "damage" the floor when passing. This is not guaranteed to cause a full on hull breach.
	// Chance to expose the tile to space is like 60% of this value.
	var/floor_rip_chance = 40

/obj/effect/immovablerod/event/Move()
	var/atom/oldloc = loc
	. = ..()
	if(prob(floor_rip_chance))
		var/turf/simulated/floor/T = get_turf(oldloc)
		if(istype(T))
			T.ex_act(EXPLODE_HEAVY)
	if(loc == destination)
		qdel(src)

/obj/effect/immovablerod/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 6 SECONDS)
	return AddComponent(/datum/component/deadchat_control/immovable_rod, mode, list(), cooldown)

/**
 * Rod will walk towards edge turf in the specified direction.
 *
 * Arguments:
 * * direction - The direction to walk the rod towards: NORTH, SOUTH, EAST, WEST.
 */
/obj/effect/immovablerod/proc/walk_in_direction(direction)
	destination = get_edge_target_turf(src, direction)
	walk_towards(src, destination)
