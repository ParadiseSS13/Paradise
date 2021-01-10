/**
  * # Hallucination - Tripper
  *
  * A generic hallucination that causes the target to trip if they cross it.
  */
/obj/effect/hallucination/tripper
	anchored = TRUE
	/// Chance to trip when crossing.
	var/trip_chance = 100
	/// Stun to add when crossed.
	var/stun = 4 SECONDS_TO_LIFE_CYCLES
	/// Weaken to add when crossed.
	var/weaken = 4 SECONDS_TO_LIFE_CYCLES

/obj/effect/hallucination/tripper/CanPass(atom/movable/mover, turf/T)
	. = TRUE
	if(isliving(mover) && mover == target)
		var/mob/living/M = mover
		if(M.lying || !prob(trip_chance))
			return
		M.Stun(stun)
		M.Weaken(weaken)
		on_crossed()

/**
  * Called when the target crosses this hallucination.
  */
/obj/effect/hallucination/tripper/proc/on_crossed()
	return

/**
  * # Hallucination - Chaser
  *
  * A generic hallucination that chases the target.
  */
/obj/effect/hallucination/chaser
	#warn TODO
