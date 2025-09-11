#define OLD_CRIT_TRAIT "old-crit"

/datum/component/softcrit
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/softcrit/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	softcrit_entered()

/datum/component/softcrit/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(check_health))
	RegisterSignal(parent, COMSIG_LIVING_HANDLE_MESSAGE_MODE, PROC_REF(force_whisper))

/datum/component/softcrit/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)
	UnregisterSignal(parent, COMSIG_LIVING_HANDLE_MESSAGE_MODE)

/datum/component/softcrit/proc/softcrit_entered()
	SIGNAL_HANDLER
	ADD_TRAIT(parent, TRAIT_FLOORED, OLD_CRIT_TRAIT)
	ADD_TRAIT(parent, TRAIT_HANDS_BLOCKED, OLD_CRIT_TRAIT)

/datum/component/softcrit/proc/softcrit_removed()
	SIGNAL_HANDLER
	REMOVE_TRAIT(parent, TRAIT_FLOORED, OLD_CRIT_TRAIT)
	REMOVE_TRAIT(parent, TRAIT_HANDS_BLOCKED, OLD_CRIT_TRAIT)
	qdel(src)
	return

/datum/component/softcrit/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/owner = parent
	if(owner.stat == CONSCIOUS)
		examine_list += span_warning("<B>[owner] с трудом держится в сознании.\n</B>")

/datum/component/softcrit/proc/check_health()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/owner = parent
	if(owner.health > HEALTH_THRESHOLD_CRIT)
		softcrit_removed()

/datum/component/softcrit/proc/force_whisper(mob/source, message_mode, list/message_pieces, verb, used_radios)
	SIGNAL_HANDLER
	return COMPONENT_FORCE_WHISPER

#undef OLD_CRIT_TRAIT
