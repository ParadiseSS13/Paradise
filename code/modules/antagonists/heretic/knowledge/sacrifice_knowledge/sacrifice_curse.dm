/// A curse given to people to disencourage them from retaliating against someone who sacrificed them
/datum/status_effect/heretic_curse
	id = "heretic_curse"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// Who cursed us?
	var/mob/living/the_curser
	/// Don't experience bad things too often
	COOLDOWN_DECLARE(consequence_cooldown)

/datum/status_effect/heretic_curse/on_creation(mob/living/new_owner, mob/living/curser)
	the_curser = curser
	return ..()

/datum/status_effect/heretic_curse/Destroy()
	the_curser = null
	return ..()

/datum/status_effect/heretic_curse/on_apply()
	if(isnull(the_curser) || !iscarbon(owner))
		return FALSE
	if(!COOLDOWN_FINISHED(src, consequence_cooldown))
		return FALSE
	COOLDOWN_START(src, consequence_cooldown, 20 SECONDS)
	playsound(the_curser, 'sound/magic/repulse.ogg', 75, TRUE)
	owner.visible_message(SPAN_HIEROPHANT("Vile magic lashes out at [owner] as their curse activates!"), SPAN_HIEROPHANT_WARNING("Your body recoils as your curse punishes you for your attack!"))
	if(prob(25))
		owner.AdjustJitter(1 MINUTES, 1 MINUTES, 3 MINUTES)
		owner.AdjustConfused(1 MINUTES, 1 MINUTES, 3 MINUTES)
		return TRUE
	if(prob(25))
		owner.AdjustJitter(1 MINUTES, 1 MINUTES, 3 MINUTES)
		owner.AdjustDizzy(1 MINUTES, 1 MINUTES, 3 MINUTES)
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			C.vomit(50, TRUE)
		return TRUE
	if(prob(25))
		var/fling_dir = REVERSE_DIR(owner.dir)
		var/turf/general_direction = get_edge_target_turf(owner, fling_dir)
		owner.throw_at(general_direction, 5, 3)
		return TRUE

	// If nothing else procs, this happens.
	owner.KnockDown(5 SECONDS)
	owner.AdjustJitter(1 MINUTES, 1 MINUTES, 3 MINUTES)
	owner.AdjustConfused(1 MINUTES, 1 MINUTES, 3 MINUTES)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.vomit(50, TRUE)


