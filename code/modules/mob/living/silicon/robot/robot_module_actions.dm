/datum/action/innate/robot_sight
	var/sight_mode = null
	icon_icon = 'icons/obj/decals.dmi'
	button_icon_state = "securearea"
	keybinding_category = AKB_CATEGORY_CYBORG

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

/datum/action/innate/robot_sight/thermal
	name = "Thermal Vision"
	desc = "Toggles your Cyborg thermal vision."
	sight_mode = BORGTHERM
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	name = "Alien Thermal Vision"
	desc = "Toggles your alien thermal vision."
	icon_icon = 'icons/mob/alien.dmi'
	button_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Meson Vision"
	desc = "Toggles your cyborg meson vision."
	sight_mode = BORGMESON
	icon_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "meson"

/datum/action/innate/robot_magpulse
	name = "Magnetic pulse"
	desc = "Toggles your cyborg magtraction. Slows you down while in use."
	icon_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	keybinding_category = AKB_CATEGORY_CYBORG
	var/slowdown_active = 2 // Same as magboots

/datum/action/innate/robot_magpulse/Activate()
	ADD_TRAIT(owner, TRAIT_MAGPULSE, "innate boots")
	to_chat(owner, "You turn your magboots on.")
	var/mob/living/silicon/robot/robot = owner
	robot.speed += slowdown_active
	button_icon_state = "magboots1"
	active = TRUE

/datum/action/innate/robot_magpulse/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_MAGPULSE, "innate boots")
	to_chat(owner, "You turn your magboots off.")
	var/mob/living/silicon/robot/robot = owner
	robot.speed -= slowdown_active
	button_icon_state = initial(button_icon_state)
	active = FALSE
