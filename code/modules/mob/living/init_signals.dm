/// Called on [/mob/living/Initialize(mapload)], for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT), PROC_REF(on_knockedout_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FAKEDEATH), PROC_REF(on_fakedeath_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_IMMOBILIZED), PROC_REF(on_immobilized_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_FLOORED), PROC_REF(on_floored_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(on_handsblocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_UI_BLOCKED), PROC_REF(on_ui_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CANNOT_PULL), PROC_REF(on_pull_blocked_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CANNOT_PULL), PROC_REF(on_pull_blocked_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_RESTRAINED), PROC_REF(on_restrained_trait_loss))

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

/// Called when [TRAIT_HANDS_BLOCKED] is added to the mob.
/mob/living/proc/on_handsblocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_USE | MOBILITY_PICKUP)
	on_handsblocked_start()

/mob/living/proc/on_handsblocked_start()
	drop_l_hand()
	drop_r_hand()
	ADD_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_HANDS_BLOCKED)
	ADD_TRAIT(src, TRAIT_CANNOT_PULL, TRAIT_HANDS_BLOCKED)

/// Called when [TRAIT_HANDS_BLOCKED] is removed from the mob.
/mob/living/proc/on_handsblocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= (MOBILITY_USE | MOBILITY_PICKUP)
	on_handsblocked_end()

/mob/living/proc/on_handsblocked_end()
	REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, TRAIT_HANDS_BLOCKED)
	REMOVE_TRAIT(src, TRAIT_CANNOT_PULL, TRAIT_HANDS_BLOCKED)

/// Called when [TRAIT_UI_BLOCKED] is added to the mob.
/mob/living/proc/on_ui_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	unset_machine()
	update_action_buttons_icon()

/// Called when [TRAIT_UI_BLOCKED] is removed from the mob.
/mob/living/proc/on_ui_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	update_action_buttons_icon()


/// Called when [TRAIT_CANNOT_PULL] is added to the mob.
/mob/living/proc/on_pull_blocked_trait_gain(datum/source)
	SIGNAL_HANDLER
	mobility_flags &= ~(MOBILITY_PULL)
	if(pulling)
		stop_pulling()

/// Called when [TRAIT_CANNOT_PULL] is removed from the mob.
/mob/living/proc/on_pull_blocked_trait_loss(datum/source)
	SIGNAL_HANDLER
	mobility_flags |= MOBILITY_PULL

/// Called when [TRAIT_RESTRAINED] is added to the mob.
/mob/living/proc/on_restrained_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)

/// Called when [TRAIT_RESTRAINED] is removed from the mob.
/mob/living/proc/on_restrained_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_RESTRAINED)

/// Called when [TRAIT_FAKEDEATH] is added to the mob.
/mob/living/proc/on_fakedeath_trait_gain(datum/source)
	SIGNAL_HANDLER
	ADD_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_FAKEDEATH)

/mob/living/carbon/human/on_fakedeath_trait_gain(datum/source)
	. = ..()
	stop_tail_wagging()

/// Called when [TRAIT_FAKEDEATH] is removed from the mob.
/mob/living/proc/on_fakedeath_trait_loss(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, TRAIT_FAKEDEATH)

