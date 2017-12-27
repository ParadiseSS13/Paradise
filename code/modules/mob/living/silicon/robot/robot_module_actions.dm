/datum/action/innate/robot_sight
	var/sight_mode = null
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "securearea"

/datum/action/innate/robot_sight/Activate()
	var/mob/living/silicon/robot/R = owner
	R.sight_mode |= sight_mode
	R.update_sight()
	active = 1

/datum/action/innate/robot_sight/Deactivate()
	var/mob/living/silicon/robot/R = owner
	R.sight_mode &= ~sight_mode
	R.update_sight()
	active = 0

/datum/action/innate/robot_sight/xray
	name = "X-ray Vision"
	sight_mode = BORGXRAY

/datum/action/innate/robot_sight/thermal
	name = "Thermal Vision"
	sight_mode = BORGTHERM
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	icon_icon = 'icons/mob/alien.dmi'
	button_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "meson"
