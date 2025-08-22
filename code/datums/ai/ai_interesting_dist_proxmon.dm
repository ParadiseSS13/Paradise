/// A way to see if mobs are in a nearby radius of an AI controller that is
/// almost certainly worse in terms of performance but a temporary stopgap
/// measure until we have spatialgrid.
///
/// This doesn't distinguish between living and dead living mobs because a mob
/// could die while in the vicinity or other goofy edge cases and this is just a
/// shim so I'm not going to think too hard about it.
/datum/proximity_monitor/ai_interesting_dist
	var/nearby_mob_count = 0

/datum/proximity_monitor/ai_interesting_dist/New(datum/ai_controller/controller)
	..(controller.pawn, controller.interesting_dist)

/datum/proximity_monitor/ai_interesting_dist/on_entered(atom/source, atom/movable/arrived, turf/old_loc)
	var/mob/living/living = arrived
	if(!istype(living))
		return
	if(!CLIENT_FROM_VAR(living))
		return
	nearby_mob_count = max(0, nearby_mob_count + 1)

/datum/proximity_monitor/ai_interesting_dist/on_uncrossed(atom/source, atom/movable/exited)
	var/mob/living/living = exited
	if(!istype(living))
		return
	if(!CLIENT_FROM_VAR(living))
		return
	nearby_mob_count = max(0, nearby_mob_count - 1)

