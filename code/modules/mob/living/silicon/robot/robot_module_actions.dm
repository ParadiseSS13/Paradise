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

/datum/action/innate/robot_magpulse
	name = "Magnetic pulse"
	icon_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
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

/datum/action/innate/return_to_modsuit
	name = "Return"
	desc = "Return to your linked MODsuit!"
	icon_icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	button_icon_state = "engineering-control"

/datum/action/innate/return_to_modsuit/Trigger(left_click) // Not `Activate()` because it's not a toggle
	if(!..())
		return FALSE
	if(istype(owner.loc, /obj/item/mod/control))
		return FALSE
	var/mob/living/silicon/robot/drone/drone = owner
	drone.return_to_modsuit()

/datum/action/innate/drop_out_of_modsuit
	name = "Leave MODsuit"
	desc = "Leave the MODsuit you are stored in!"
	icon_icon = 'icons/mob/screen_gen.dmi'
	button_icon_state = "arrow"

/datum/action/innate/drop_out_of_modsuit/Trigger(left_click)
	if(!..())
		return FALSE
	if(!istype(owner.loc, /obj/item/mod/control))
		return FALSE
	var/turf/drop_turf = get_turf(owner.loc)
	if(!drop_turf) // This should rarely happen but whatever
		return FALSE
	owner.forceMove(drop_turf)
