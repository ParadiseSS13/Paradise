/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), .proc/on_knockedout_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), .proc/on_knockedout_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), .proc/on_immobilized_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED), .proc/on_immobilized_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), .proc/on_floored_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), .proc/on_floored_trait_loss)
/*
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FORCED_STANDING), .proc/on_forced_standing_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FORCED_STANDING), .proc/on_forced_standing_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), .proc/on_handsblocked_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), .proc/on_handsblocked_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UI_BLOCKED), .proc/on_ui_blocked_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_UI_BLOCKED), .proc/on_ui_blocked_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PULL_BLOCKED), .proc/on_pull_blocked_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PULL_BLOCKED), .proc/on_pull_blocked_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), .proc/on_incapacitated_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED), .proc/on_incapacitated_trait_loss)

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), .proc/on_restrained_trait_gain)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), .proc/on_restrained_trait_loss)
*/
/mob/living
	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

/// Called when [TRAIT_KNOCKEDOUT] is added to the mob.
/mob/living/proc/on_knockedout_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(stat < UNCONSCIOUS)
		KnockOut()

/// Called when [TRAIT_KNOCKEDOUT] is removed from the mob.
/mob/living/proc/on_knockedout_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(stat <= UNCONSCIOUS)
		WakeUp()

/// Called when [TRAIT_IMMOBILIZED] is added to the mob.
/mob/living/proc/on_immobilized_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~MOBILITY_MOVE

/// Called when [TRAIT_IMMOBILIZED] is removed from the mob.
/mob/living/proc/on_immobilized_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_MOVE


/// Called when [TRAIT_FLOORED] is added to the mob.
/mob/living/proc/on_floored_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(buckled && !buckled.buckle_lying)
		return // Handled by the buckle.
	mobility_flags &= ~MOBILITY_STAND
	on_floored_start()

/mob/living/proc/on_floored_start()
	if(body_position == STANDING_UP) //force them on the ground
		fall()


/// Called when [TRAIT_FLOORED] is removed from the mob.
/mob/living/proc/on_floored_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_STAND
	on_floored_end()

/mob/living/proc/on_floored_end()
	if(!resting)
		stand_up(FALSE)
/*
/// Called when [TRAIT_HANDS_BLOCKED] is added to the mob.
/mob/living/proc/on_handsblocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	on_handsblocked_start()

/// Called when [TRAIT_HANDS_BLOCKED] is removed from the mob.
/mob/living/proc/on_handsblocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE)
	on_handsblocked_end()


/// Called when [TRAIT_UI_BLOCKED] is added to the mob.
/mob/living/proc/on_ui_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_UI)
	unset_machine()
	update_action_buttons_icon()

/// Called when [TRAIT_UI_BLOCKED] is removed from the mob.
/mob/living/proc/on_ui_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_UI
	update_action_buttons_icon()


/// Called when [TRAIT_PULL_BLOCKED] is added to the mob.
/mob/living/proc/on_pull_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_PULL)
	if(pulling)
		stop_pulling()

/// Called when [TRAIT_PULL_BLOCKED] is removed from the mob.
/mob/living/proc/on_pull_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_PULL


/// Called when [TRAIT_INCAPACITATED] is added to the mob.
/mob/living/proc/on_incapacitated_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_INCAPACITATED)
	ADD_TRAIT(src, TRAIT_PULL_BLOCKED, TRAIT_INCAPACITATED)
	update_appearance()

/// Called when [TRAIT_INCAPACITATED] is removed from the mob.
/mob/living/proc/on_incapacitated_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_INCAPACITATED)
	REMOVE_TRAIT(src, TRAIT_PULL_BLOCKED, TRAIT_INCAPACITATED)
	update_appearance()


/// Called when [TRAIT_RESTRAINED] is added to the mob.
/mob/living/proc/on_restrained_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)

/// Called when [TRAIT_RESTRAINED] is removed from the mob.
/mob/living/proc/on_restrained_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)
*/
