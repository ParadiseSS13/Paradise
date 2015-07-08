var/global/list/body_accessory_datums = list()

/hook/startup/proc/init_body_accessory_datums()
	for(var/T in typesof(/datum/body_accessory) - /datum/body_accessory - /datum/body_accessory/body)
		body_accessory_datums += new T

	for(var/datum/body_accessory/BA in body_accessory_datums)
		body_accessory_datums -= BA
		body_accessory_datums["[BA.name]"] = BA

	return 1

/proc/assign_body_accessory(var/mob/living/carbon/human/H)
	if(!istype(H))	return 0

	if(H.species && H.species.tail)
		if(!H.body_accessory)
			H.body_accessory = body_accessory_datums["[H.species.tail]"]
			H.update_tail_showing()
			return 1
	return 0

/datum/body_accessory
	var/name
	var/icon_file = 'icons/effects/species.dmi'
	var/icon_state
	var/animated_state
	var/base_type = 1
	var/list/species = list()
	var/shift_x_size = 0
	var/icon_blend_mode = ICON_ADD
	var/admin_restricted = 0

/datum/body_accessory/proc/return_icon_state()
	return "[icon_state]_s"

/datum/body_accessory/proc/return_animated_state()
	if(!animated_state)
		return "[icon_state]_s"
	return "[animated_state]w_s"