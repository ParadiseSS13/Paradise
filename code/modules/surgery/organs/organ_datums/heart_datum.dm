/datum/organ/heart
	organ_tag = ORGAN_DATUM_HEART
	var/beating = TRUE
	var/always_beating = FALSE

/datum/organ/heart/on_remove(mob/living/carbon/removed_from, special = FALSE)
	. = ..()
	if(ishuman(removed_from))
		var/mob/living/carbon/human/H = removed_from
		if(H.stat == DEAD)
			change_beating(FALSE)
			return

	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 12 SECONDS)

/datum/organ/heart/proc/change_beating(change_to = FALSE)
	if(always_beating)
		beating = TRUE
		return
	beating = change_to
	linked_organ.update_icon()

/datum/organ/heart/on_successful_emp()
	change_beating(FALSE)
	return TRUE

/datum/organ/heart/on_necrotize()
	change_beating(FALSE)
	return TRUE

/datum/organ/heart/proc/try_restart(duration = 8 SECONDS)
	if(beating)
		return
	change_beating(TRUE)
	addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), duration)

/datum/organ/heart/proc/stop_if_unowned()
	if(!linked_organ.owner)
		change_beating(FALSE)

/datum/organ/heart/on_prepare_eat(obj/item/food/organ/snorgan)
	snorgan.icon_state = linked_organ.dead_icon

/// A subtype that is always beating. Abductor glands and demon hearts use this.
/datum/organ/heart/always_beating
	always_beating = TRUE
