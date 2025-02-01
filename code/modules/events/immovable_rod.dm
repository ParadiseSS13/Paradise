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
	var/turf/startT = pick_edge_loc(startside, level_name_to_num(MAIN_STATION))
	var/turf/endT = pick_edge_loc(REVERSE_DIR(startside), level_name_to_num(MAIN_STATION))
	new /obj/effect/immovablerod/event(startT, endT)

/obj/effect/immovablerod
	name = "\improper Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = TRUE
	anchored = TRUE
	var/z_original = 0
	var/notify = TRUE
	var/move_delay = 1
	var/atom/start
	var/atom/end
	/// The minimum amount of damage dealt to walls, relative to their max HP.
	var/wall_damage_min_fraction = 0.9
	/// The maximum amount of damage dealt to walls, relative to their max HP. Values over 1 are useful for adjusting the probability of destroying the wall.
	var/wall_damage_max_fraction = 1.4

/obj/effect/immovablerod/New(atom/_start, atom/_end, delay)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_EDGE_TRANSITIONS, ROUNDSTART_TRAIT)
	start = _start
	end = _end
	loc = start
	z_original = z
	move_delay = delay
	if(notify)
		notify_ghosts("\A [src] is inbound!",
				enter_link="<a href=byond://?src=[UID()];follow=1>(Click to follow)</a>",
				source = src, action = NOTIFY_FOLLOW)
	GLOB.poi_list |= src
	head_towards_dest()

/obj/effect/immovablerod/proc/head_towards_dest()
	if(end?.z == z_original)
		walk_towards(src, end, move_delay)

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

/obj/effect/immovablerod/Move(turf/newloc, direction)
	if(!istype(newloc))
		return ..()

	if(!direction)
		direction = get_dir(src, newloc)
	forceMove(newloc)
	setDir(direction)

	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		audible_message("CLANG")

	clong_turf(newloc)
	if(isnull(newloc))
		// The turf is dead, long live the turf!
		newloc = loc

	while(TRUE)
		var/hit_something_dense = FALSE
		for(var/atom/victim as anything in newloc)
			clong_thing(victim)
			if(victim.density)
				hit_something_dense = TRUE

		// Keep hitting stuff until there's nothing dense or we randomly go through it.
		if(!hit_something_dense || prob(25))
			break

/obj/effect/immovablerod/proc/clong_turf(turf/victim)
	if(!victim.density)
		return

	if(iswallturf(victim))
		var/turf/simulated/wall/W = victim
		W.take_damage(rand(W.damage_cap * wall_damage_min_fraction, W.damage_cap * wall_damage_max_fraction))
	else
		victim.ex_act(EXPLODE_LIGHT)

/obj/effect/immovablerod/proc/clong_thing(atom/victim)
	if(isobj(victim) && victim.density)
		victim.ex_act(EXPLODE_HEAVY)
	else if(ismob(victim))
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			H.visible_message("<span class='danger'>[H.name] is penetrated by an immovable rod!</span>",
				"<span class='userdanger'>The rod penetrates you!</span>",
				"<span class ='danger'>You hear a CLANG!</span>")
			H.adjustBruteLoss(160)
		if(victim.density || prob(10))
			victim.ex_act(EXPLODE_HEAVY)

/obj/effect/immovablerod/event
	wall_damage_min_fraction = 0.33
	wall_damage_max_fraction = 1.33
	// The base chance to "damage" the floor when passing. This is not guaranteed to cause a full on hull breach.
	// Chance to expose the tile to space is like 60% of this value.
	var/floor_rip_chance = 40
	// Chance to damage the floor if we didn't rip it.
	var/floor_graze_chance = 50

/obj/effect/immovablerod/event/Move()
	. = ..()
	if(loc == end)
		qdel(src)

/obj/effect/immovablerod/event/clong_turf(turf/victim)
	if(!isfloorturf(victim))
		return ..()

	var/turf/simulated/floor/T = victim
	if(prob(floor_rip_chance))
		T.ex_act(EXPLODE_HEAVY)
	else if(prob(floor_graze_chance))
		T.ex_act(EXPLODE_LIGHT)

/obj/effect/immovablerod/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 6 SECONDS)
	return AddComponent(/datum/component/deadchat_control/immovable_rod, mode, list(), cooldown)

/obj/effect/immovablerod/smite
	/// The target that we're gonna aim for between start and end
	var/obj/effect/portal/exit

/obj/effect/immovablerod/smite/New(atom/_start, atom/_end)
	new /obj/effect/portal(start, lifespan = 2 SECONDS)
	return ..()

/obj/effect/immovablerod/smite/Move()
	. = ..()
	if(get_turf(src) == get_turf(end))
		// our exit condition: get outta there kowalski
		var/target_turf = get_ranged_target_turf(src, dir, rand(1, 10))
		start = loc
		walk(src, 0)
		exit = new /obj/effect/portal(target_turf, lifespan = 2 SECONDS)
		walk_towards(src, exit, move_delay)
	else if(locate(exit) in get_turf(src))
		QDEL_NULL(exit)
		qdel(src)

/**
 * Rod will walk towards edge turf in the specified direction.
 *
 * Arguments:
 * * direction - The direction to walk the rod towards: NORTH, SOUTH, EAST, WEST.
 */
/obj/effect/immovablerod/proc/walk_in_direction(direction)
	end = get_edge_target_turf(src, direction)
	walk_towards(src, end, move_delay)
