
/// Buffs and heals the target while standing on rust.
/datum/element/leeching_walk

/datum/element/leeching_walk/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/leeching_walk/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/element/leeching_walk/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/element/leeching_walk/proc/on_life(mob/living/source)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// Heals all damage types + Stamina
	var/need_mob_update = FALSE
	if(ishuman(source))
		var/mob/living/carbon/human/we_should_make_robotic_a_general_argument = source
		need_mob_update += we_should_make_robotic_a_general_argument.adjustBruteLoss(-3, updating_health = FALSE, robotic = TRUE)
		need_mob_update += we_should_make_robotic_a_general_argument.adjustFireLoss(-3, updating_health = FALSE, robotic = TRUE)
	need_mob_update += source.adjustBruteLoss(-3, updating_health = FALSE)
	if(iscarbon(source)) //Avoids double simple mob healing
		need_mob_update += source.adjustFireLoss(-3, updating_health = FALSE)
		need_mob_update += source.adjustToxLoss(-3, updating_health = FALSE)
		need_mob_update += source.adjustOxyLoss(-1.5, updating_health = FALSE)
		need_mob_update += source.adjustStaminaLoss(-15)
	if(need_mob_update)
		source.updatehealth()
	// Reduces duration of stuns/etc
	source.AdjustParalysis(-0.8 SECONDS)
	source.AdjustStunned(-0.8 SECONDS)
	source.AdjustWeakened(-0.8 SECONDS)
	source.AdjustKnockDown(-0.8 SECONDS)
	// Heals blood loss
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 2.5
