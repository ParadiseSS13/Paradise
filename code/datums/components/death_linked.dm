/**
 * ## Death link component
 *
 * When the owner of this component dies it also gibs a linked mob
 */
/datum/component/death_linked
	///The mob that also dies when the user dies
	var/linked_mob_uid

/datum/component/death_linked/Initialize(mob/living/target_mob)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(target_mob))
		stack_trace("[type] added to [parent] with no linked mob.")
	src.linked_mob_uid = target_mob.UID()

/datum/component/death_linked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/component/death_linked/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)

///signal called by the stat of the target changing
/datum/component/death_linked/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/mob/living/linked_mob_resolved = locateUID(linked_mob_uid)
	linked_mob_resolved?.gib()
