/// Datum for basic mobs to define what they can attack.
/// Global, just like ai_behaviors.
/// Meant to be subtyped into different kinds of targeting strategies.
/datum/targeting_strategy

/// Returns true or false depending on if the target can be attacked by the mob.
/datum/targeting_strategy/proc/can_attack(mob/living/living_mob, atom/target, vision_range)
	return

/// Returns something the target might be hiding inside of.
/datum/targeting_strategy/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	var/atom/target_hiding_location
	if(istype(target.loc, /obj/structure) || istype(target.loc, /obj/machinery))
		target_hiding_location = target.loc
	return target_hiding_location
