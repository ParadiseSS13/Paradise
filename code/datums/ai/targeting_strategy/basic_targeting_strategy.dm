// TODO: /tg/ has factions defined at the atom level and faction_check_atom
// which allows this sort of strategy to work more broadly. A refactor here
// would be necessary to take advantage of that, but unsurprisingly it is a
// pain in the ass because there are snowflake faction checks in many spots
/datum/targeting_strategy/basic
	/// When we do our basic faction check, do we look for exact faction matches?
	var/check_factions_exactly = FALSE
	/// Whether we care for seeing the target or not
	var/ignore_sight = FALSE
	/// Blackboard key containing the minimum stat of a living mob to target
	var/minimum_stat_key = BB_TARGET_MINIMUM_STAT
	/// If this blackboard key is TRUE, makes us only target wounded mobs
	var/target_wounded_key

/datum/targeting_strategy/basic/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/our_controller = living_mob.ai_controller

	if(isnull(our_controller))
		return FALSE

	if(isturf(the_target) || isnull(the_target)) // bail out on invalids
		return FALSE

	if(isobj(the_target.loc))
		var/obj/container = the_target.loc
		if(container.resistance_flags & INDESTRUCTIBLE)
			return FALSE

	var/mob/mob_target = the_target
	if(istype(mob_target)) //Target is in godmode, ignore it.
		if(living_mob.loc == the_target)
			return FALSE // We've either been eaten or are shapeshifted, let's assume the latter because we're still alive
		if(mob_target.status_flags & GODMODE)
			return FALSE

	if(vision_range && get_dist(living_mob, the_target) > vision_range)
		return FALSE

	if(!ignore_sight && !can_see(living_mob, the_target, vision_range)) //Target has moved behind cover and we have lost line of sight to it
		return FALSE

	if(living_mob.see_invisible < the_target.invisibility) //Target's invisible to us, forget it
		return FALSE

	if(!isturf(living_mob.loc))
		return FALSE
	if(isturf(the_target.loc) && living_mob.z != the_target.z || iseffect(the_target.loc)) // z check will always fail if target is in a mech or pawn is shapeshifted or jaunting
		return FALSE

	if(isliving(the_target)) //Targeting vs living mobs
		var/mob/living/living_target = the_target
		if(faction_check(our_controller, living_mob, living_target))
			return FALSE
		if(living_target.stat > our_controller.blackboard[minimum_stat_key])
			return FALSE
		if(target_wounded_key && our_controller.blackboard[target_wounded_key] && living_target.health == living_target.maxHealth)
			return FALSE

		return TRUE

	if(ismecha(the_target)) //Targeting vs mechas
		var/obj/mecha/M = the_target
		if(can_attack(living_mob, M.occupant)) //Can we attack any of the occupants?
			return TRUE

	if(istype(the_target, /obj/machinery/porta_turret)) //Cringe turret! kill it!
		var/obj/machinery/porta_turret/P = the_target
		if(P.in_faction(living_mob)) //Don't attack if the turret is in the same faction
			return FALSE
		if(P.has_cover && !P.raised) //Don't attack invincible turrets
			return FALSE
		if(P.stat & BROKEN) //Or turrets that are already broken
			return FALSE
		return TRUE

	return FALSE

/// Returns true if the mob and target share factions
/datum/targeting_strategy/basic/proc/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if(controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || controller.blackboard[BB_TEMPORARILY_IGNORE_FACTION])
		return FALSE
	return living_mob.faction_check_mob(the_target, exact_match = check_factions_exactly)
