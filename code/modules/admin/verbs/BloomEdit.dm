/client/proc/debug_bloom() // todo: make this hidden under debug verbs, we can't trust admins
	set name = "Bloom Edit"
	set category = "Debug"

	if(!check_rights(R_VAREDIT)) // todo: debug
		return

	if(!holder.debug_bloom)
		holder.debug_bloom = new /datum/bloom_edit(src)

	holder.debug_bloom.ui_interact(usr)

	message_admins("[key_name(src)] opened Bloom Edit panel.")
	log_admin("[key_name(src)] opened Bloom Edit panel.")

/datum/bloom_edit

/datum/bloom_edit/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BloomEdit", "Bloom Edit")
		ui.open()

/datum/bloom_edit/ui_data(mob/user)
	var/list/data = list()

	data["glow_brightness_base"] = global.GLOW_BRIGHTNESS_BASE
	data["glow_brightness_power"] = global.GLOW_BRIGHTNESS_POWER
	data["glow_contrast_base"] = global.GLOW_CONTRAST_BASE
	data["glow_contrast_power"] = global.GLOW_CONTRAST_POWER
	data["exposure_brightness_base"] = global.EXPOSURE_BRIGHTNESS_BASE
	data["exposure_brightness_power"] = global.EXPOSURE_BRIGHTNESS_POWER
	data["exposure_contrast_base"] = global.EXPOSURE_CONTRAST_BASE
	data["exposure_contrast_power"] = global.EXPOSURE_CONTRAST_POWER

	return data

/datum/bloom_edit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("glow_brightness_base")
			global.GLOW_BRIGHTNESS_BASE = clamp(params["value"], -10, 10)
		if("glow_brightness_power")
			global.GLOW_BRIGHTNESS_POWER = clamp(params["value"], -10, 10)
		if("glow_contrast_base")
			global.GLOW_CONTRAST_BASE = clamp(params["value"], -10, 10)
		if("glow_contrast_power")
			global.GLOW_CONTRAST_POWER = clamp(params["value"], -10, 10)
		if("exposure_brightness_base")
			global.EXPOSURE_BRIGHTNESS_BASE = clamp(params["value"], -10, 10)
		if("exposure_brightness_power")
			global.EXPOSURE_BRIGHTNESS_POWER = clamp(params["value"], -10, 10)
		if("exposure_contrast_base")
			global.EXPOSURE_CONTRAST_BASE = clamp(params["value"], -10, 10)
		if("exposure_contrast_power")
			global.EXPOSURE_CONTRAST_POWER = clamp(params["value"], -10, 10)
		if("default")
			global.GLOW_BRIGHTNESS_BASE = initial(global.GLOW_BRIGHTNESS_BASE)
			global.GLOW_BRIGHTNESS_POWER = initial(global.GLOW_BRIGHTNESS_POWER)
			global.GLOW_CONTRAST_BASE = initial(global.GLOW_CONTRAST_BASE)
			global.GLOW_CONTRAST_POWER = initial(global.GLOW_CONTRAST_POWER)
			global.EXPOSURE_BRIGHTNESS_BASE = initial(global.EXPOSURE_BRIGHTNESS_BASE)
			global.EXPOSURE_BRIGHTNESS_POWER = initial(global.EXPOSURE_BRIGHTNESS_POWER)
			global.EXPOSURE_CONTRAST_BASE = initial(global.EXPOSURE_CONTRAST_BASE)
			global.EXPOSURE_CONTRAST_POWER = initial(global.EXPOSURE_CONTRAST_POWER)
		if("update_lamps") // todo: make this update all objects with glow
			for(var/obj/machinery/light/L in GLOB.machines)
				if(L.glow_overlay || L.exposure_overlay)
					//L.update_light() // does nothing
					L.set_light(0) // so we make this ugly way
					L.update()

	return TRUE

/datum/bloom_edit/ui_state(mob/user)
	return GLOB.admin_state
