// Может и на оффы, но пока увы. Я не против, если этот код отправит на оффы КТО угодно.
/obj/item/organ/external/head/carapace/replaced()
	. = ..()
	for(var/datum/action/action as anything in actions)
		action.Grant(owner)

/obj/item/organ/external/head/carapace/droplimb()
	. = ..()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(owner)

/obj/item/organ/external/head/carapace
	min_broken_damage = 30
	encased = CARAPACE_ENCASE_WORD
	actions_types = 		list(/datum/action/item_action/organ_action/toggle)
	action_icon = 			list(/datum/action/item_action/organ_action/toggle = 'modular_ss220/species/serpentids/icons/organs.dmi')
	action_icon_state = 	list(/datum/action/item_action/organ_action/toggle = "serpentid_eyes_0")
	var/eye_shielded = FALSE

/obj/item/organ/external/head/carapace/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/carapace, FALSE, min_broken_damage)

/obj/item/organ/external/head/carapace/ui_action_click()
	var/obj/item/organ/internal/eyes/E = owner.get_int_organ(/obj/item/organ/internal/eyes)
	eye_shielded = !eye_shielded
	E.flash_protect = eye_shielded ? FLASH_PROTECTION_WELDER : E::flash_protect
	E.tint = eye_shielded ? FLASH_PROTECTION_WELDER : E::tint
	owner.update_sight()

	for(var/datum/action/item_action/T in actions)
		T.button_overlay_icon_state ="serpentid_eyes_[eye_shielded]"
		T.UpdateButtons()
