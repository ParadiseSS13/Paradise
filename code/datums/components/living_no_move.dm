/datum/component/living_no_move

// Will make a living thing unable to move
/datum/component/living_no_move/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/M = parent
	M.canmove = FALSE
	RegisterSignal(parent, COMSIG_LIVING_UPDATE_CAN_MOVE, .proc/update_canmove)

/datum/component/living_no_move/UnregisterFromParent()
	var/mob/living/M = parent
	M.canmove = TRUE
	UnregisterSignal(parent, COMSIG_LIVING_UPDATE_CAN_MOVE)

/datum/component/living_no_move/proc/update_canmove()
	var/mob/living/M = parent
	M.canmove = FALSE