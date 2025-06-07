/datum/action/innate/robot_sight
	var/sight_mode = null
	button_icon = 'icons/obj/decals.dmi'
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
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	button_icon = 'icons/mob/alien.dmi'
	button_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "meson"

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define MODE_PRESSURE "pressure"
#define RAD_RANGE 5

/datum/action/innate/robot_sight/engineering_scanner
	name = "Engineering Scanner Vision"
	sight_mode = BORGMESON
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "trayson-meson"
	var/list/mode_list = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_PRESSURE, MODE_PRESSURE = MODE_NONE)
	var/mode = MODE_NONE

/datum/action/innate/robot_sight/engineering_scanner/Activate()
	var/mob/living/silicon/robot/R = owner
	mode = mode_list[mode]
	to_chat(owner, "<span class='notice'>You turn your enhanced optics [mode ? "to [mode] mode." : "off."]</span>")
	button_icon_state = "trayson-[mode]"

	if(mode == MODE_MESON)
		R.sight_mode |= sight_mode
	else
		R.sight_mode &= ~sight_mode
	R.update_sight()

	if(mode != (MODE_NONE || MODE_MESON))
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

	if(mode == MODE_PRESSURE)
		ADD_TRAIT(R, TRAIT_PRESSURE_VISION, "borgsight")
	else
		REMOVE_TRAIT(R, TRAIT_PRESSURE_VISION, "borgsight")

/datum/action/innate/robot_sight/engineering_scanner/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_PRESSURE_VISION, "borgsight")

/datum/action/innate/robot_sight/engineering_scanner/process()
	var/mob/living/silicon/robot/user = owner
	if(!user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user)
		if(MODE_RAD)
			user.show_rads(RAD_RANGE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_PRESSURE
#undef RAD_RANGE

/datum/action/innate/robot_magpulse
	name = "Magnetic pulse"
	button_icon = 'icons/obj/clothing/shoes.dmi'
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

/datum/action/innate/robot_override_lock
	name = "Override lockdown"
	button_icon_state = "unlock_self"

/datum/action/innate/robot_override_lock/Activate()
	to_chat(owner, "<span class='danger'>HARDWARE_OVERRIDE_SYNDICATE: Lockdown lifted. Connection to NT systems severed.</span>")
	var/mob/living/silicon/robot/robot = owner
	robot.UnlinkSelf()
