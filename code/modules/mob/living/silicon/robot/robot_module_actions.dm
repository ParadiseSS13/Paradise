/datum/action/innate/robot_sight
	var/sight_mode = null
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "securearea"

/datum/action/innate/robot_sight/Activate()
	var/mob/living/silicon/robot/R = owner
	R.sight_mode |= sight_mode
	R.update_sight()
	active = TRUE

/datum/action/innate/robot_sight/Deactivate()
	var/mob/living/silicon/robot/R = owner
	R.sight_mode &= ~sight_mode
	R.update_sight()
	active = FALSE

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

/datum/action/innate/robot_sight/meson/Activate()
	. = ..()
	var/mob/living/silicon/robot/R = owner
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MESON_ADVANCED]
	H.add_hud_to(R)
	R.permanent_huds |= H

/datum/action/innate/robot_sight/meson/Deactivate()
	. = ..()
	var/mob/living/silicon/robot/R = owner
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MESON_ADVANCED]
	R.permanent_huds ^= H
	H.remove_hud_from(R)

