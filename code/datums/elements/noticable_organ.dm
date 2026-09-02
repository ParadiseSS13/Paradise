/**
 * noticable organ element; which makes organs have a special description added to the person with the organ, if certain body zones aren't covered.
 *
 * Used for infused mutant organs
 */
/datum/element/noticable_organ
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///Shows on examining someone with an infused organ.
	var/infused_desc
	/// Which body zone has to be exposed. If none is set, this is always noticable.
	var/body_zone

/datum/element/noticable_organ/Attach(obj/item/organ/target, infused_desc, body_zone)
	. = ..()

	if(!is_organ(target))
		return ELEMENT_INCOMPATIBLE

	src.infused_desc = infused_desc
	src.body_zone = body_zone

	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(enable_description))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	if(target.owner)
		enable_description(target, target.owner)

/datum/element/noticable_organ/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(target.owner)
		UnregisterSignal(target.owner, COMSIG_PARENT_EXAMINE)
	return ..()

/// Proc that returns true or false if the organ should show its examine check.
/datum/element/noticable_organ/proc/should_show_text(mob/living/carbon/examined)
	if(body_zone && (body_zone in examined.get_covered_body_zones()))
		return FALSE
	return TRUE

/datum/element/noticable_organ/proc/enable_description(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER // COMSIG_ORGAN_IMPLANTED

	RegisterSignal(receiver, COMSIG_PARENT_EXAMINE, PROC_REF(on_receiver_examine))

/datum/element/noticable_organ/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER // COMSIG_ORGAN_REMOVED

	UnregisterSignal(loser, COMSIG_PARENT_EXAMINE)

/datum/element/noticable_organ/proc/on_receiver_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER // COMSIG_PARENT_EXAMINE

	if(!should_show_text(A))
		return

	examine_list += infused_desc
