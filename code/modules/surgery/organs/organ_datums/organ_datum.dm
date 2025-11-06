/datum/organ
	var/organ_tag // heart, brain, lungs, etc
	var/obj/item/organ/internal/linked_organ

/datum/organ/New(obj/item/organ/internal/link_em)
	..()
	linked_organ = link_em

/datum/organ/Destroy(force, ...)
	linked_organ = null
	return ..()

/// Called when the linked organ is inserted.
/datum/organ/proc/on_insert(mob/living/carbon/human/given_to)
	return

/// Called when another organ is removed, and this organ datum takes its place in the organ_owner.
/datum/organ/proc/on_replace(mob/living/carbon/human/organ_owner)
	return

/// Called when the linked organ is removed.
/datum/organ/proc/on_remove(mob/living/carbon/removed_from, special = FALSE)
	return

/datum/organ/proc/on_life()
	return

/datum/organ/proc/dead_process()
	return

/// Only called when the organ is robotic AND is not emp proof. Return true to override default functions
/datum/organ/proc/on_successful_emp()
	return FALSE

/datum/organ/proc/on_necrotize()
	return FALSE

/datum/organ/proc/on_prepare_eat(obj/item/food/organ/snorgan)
	return FALSE
