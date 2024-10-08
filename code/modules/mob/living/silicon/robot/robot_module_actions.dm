/datum/action/innate/robot_sight
	var/sight_mode = null
	button_overlay_icon = 'icons/obj/decals.dmi'
	button_overlay_icon_state = "securearea"

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
	button_overlay_icon = 'icons/obj/clothing/glasses.dmi'
	button_overlay_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	button_overlay_icon = 'icons/mob/alien.dmi'
	button_overlay_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Meson Vision"
	sight_mode = BORGMESON
	button_overlay_icon = 'icons/obj/clothing/glasses.dmi'
	button_overlay_icon_state = "meson"

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define RAD_RANGE 5

/datum/action/innate/robot_sight/engineering_scanner
	name = "Engineering Scanner Vision"
	sight_mode = BORGMESON
	button_overlay_icon = 'icons/obj/clothing/glasses.dmi'
	button_overlay_icon_state = "trayson-meson"
	var/list/mode_list = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE

/datum/action/innate/robot_sight/engineering_scanner/Activate()
	var/mob/living/silicon/robot/R = owner
	mode = mode_list[mode]
	to_chat(owner, "<span class='notice'>You turn your enhanced optics [mode ? "to [mode] mode." : "off."]</span>")
	button_overlay_icon_state = "trayson-[mode]"

	if(mode == MODE_MESON)
		R.sight_mode |= sight_mode
	else
		R.sight_mode &= ~sight_mode
	R.update_sight()

	if(mode != (MODE_NONE || MODE_MESON))
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/datum/action/innate/robot_sight/engineering_scanner/Deactivate()
	return

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
#undef RAD_RANGE

/datum/action/innate/robot_magpulse
	name = "Magnetic pulse"
	button_overlay_icon = 'icons/obj/clothing/shoes.dmi'
	button_overlay_icon_state = "magboots0"
	var/slowdown_active = 2 // Same as magboots

/datum/action/innate/robot_magpulse/Activate()
	ADD_TRAIT(owner, TRAIT_MAGPULSE, "innate boots")
	to_chat(owner, "You turn your magboots on.")
	var/mob/living/silicon/robot/robot = owner
	robot.speed += slowdown_active
	button_overlay_icon_state = "magboots1"
	active = TRUE

/datum/action/innate/robot_magpulse/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_MAGPULSE, "innate boots")
	to_chat(owner, "You turn your magboots off.")
	var/mob/living/silicon/robot/robot = owner
	robot.speed -= slowdown_active
	button_overlay_icon_state = initial(button_overlay_icon_state)
	active = FALSE
