/datum/component/softcrit
	var/mob/living/carbon/human/owner

/datum/component/softcrit/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent

/datum/component/softcrit/RegisterWithParent()
	. = ..()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HEALTH_CRIT), PROC_REF(on_health_crit_trait_gain))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_HEALTH_CRIT), PROC_REF(on_health_crit_trait_loss))

/datum/component/softcrit/UnregisterFromParent()
	. = ..()
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HEALTH_CRIT))
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_HEALTH_CRIT))

/datum/component/softcrit/proc/on_health_crit_trait_gain()
	SIGNAL_HANDLER
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(check_health))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_HEALTH_CRIT)
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_HEALTH_CRIT)
	return

/datum/component/softcrit/proc/on_health_crit_trait_loss()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	UnregisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(check_health))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_HEALTH_CRIT)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_HEALTH_CRIT)
	return

/datum/component/softcrit/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(owner.stat == CONSCIOUS)
		examine_list += span_warning("<B>[owner] с трудом держится в сознании.\n</B>")

/datum/component/softcrit/proc/check_health()
	SIGNAL_HANDLER
	if(owner.health > HEALTH_THRESHOLD_CRIT)
		REMOVE_TRAIT(owner, TRAIT_HEALTH_CRIT, SOFTCRIT_REWORK_TRAIT)
