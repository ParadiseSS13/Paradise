USER_VERB(debug_bloom, R_DEBUG, "Bloom Edit", "Open bloom editor panel.", VERB_CATEGORY_DEBUG)
	var/datum/bloom_edit/editor = new()
	editor.ui_interact(client.mob)

	message_admins("[key_name(client)] opened Bloom Edit panel.")
	log_admin("[key_name(client)] opened Bloom Edit panel.")

/datum/bloom_edit

/datum/bloom_edit/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BloomEdit", "Bloom Edit")
		ui.open()

/datum/bloom_edit/ui_data(mob/user)
	var/list/data = list()

	data["glow_brightness_base"] = GLOB.configuration.lighting_effects.glow_brightness_base
	data["glow_brightness_power"] = GLOB.configuration.lighting_effects.glow_brightness_power
	data["glow_contrast_base"] = GLOB.configuration.lighting_effects.glow_contrast_base
	data["glow_contrast_power"] = GLOB.configuration.lighting_effects.glow_contrast_power
	data["exposure_brightness_base"] = GLOB.configuration.lighting_effects.exposure_brightness_base
	data["exposure_brightness_power"] = GLOB.configuration.lighting_effects.exposure_brightness_power
	data["exposure_contrast_base"] = GLOB.configuration.lighting_effects.exposure_contrast_base
	data["exposure_contrast_power"] = GLOB.configuration.lighting_effects.exposure_contrast_power
	return data

/datum/bloom_edit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("glow_brightness_base")
			GLOB.configuration.lighting_effects.glow_brightness_base = clamp(params["value"], -10, 10)
		if("glow_brightness_power")
			GLOB.configuration.lighting_effects.glow_brightness_power = clamp(params["value"], -10, 10)
		if("glow_contrast_base")
			GLOB.configuration.lighting_effects.glow_contrast_base = clamp(params["value"], -10, 10)
		if("glow_contrast_power")
			GLOB.configuration.lighting_effects.glow_contrast_power = clamp(params["value"], -10, 10)
		if("exposure_brightness_base")
			GLOB.configuration.lighting_effects.exposure_brightness_base = clamp(params["value"], -10, 10)
		if("exposure_brightness_power")
			GLOB.configuration.lighting_effects.exposure_brightness_power = clamp(params["value"], -10, 10)
		if("exposure_contrast_base")
			GLOB.configuration.lighting_effects.exposure_contrast_base = clamp(params["value"], -10, 10)
		if("exposure_contrast_power")
			GLOB.configuration.lighting_effects.exposure_contrast_power = clamp(params["value"], -10, 10)
		if("default")
			GLOB.configuration.lighting_effects.glow_brightness_base = initial(GLOB.configuration.lighting_effects.glow_brightness_base)
			GLOB.configuration.lighting_effects.glow_brightness_power = initial(GLOB.configuration.lighting_effects.glow_brightness_power)
			GLOB.configuration.lighting_effects.glow_contrast_base = initial(GLOB.configuration.lighting_effects.glow_contrast_base)
			GLOB.configuration.lighting_effects.glow_contrast_power = initial(GLOB.configuration.lighting_effects.glow_contrast_power)
			GLOB.configuration.lighting_effects.exposure_brightness_base = initial(GLOB.configuration.lighting_effects.exposure_brightness_base)
			GLOB.configuration.lighting_effects.exposure_brightness_power = initial(GLOB.configuration.lighting_effects.exposure_brightness_power)
			GLOB.configuration.lighting_effects.exposure_contrast_base = initial(GLOB.configuration.lighting_effects.exposure_contrast_base)
			GLOB.configuration.lighting_effects.exposure_contrast_power = initial(GLOB.configuration.lighting_effects.exposure_contrast_power)
		if("update_lamps")
			for(var/obj/machinery/light/L in SSmachines.get_by_type(/obj/machinery/light))
				if(L.glow_overlay || L.exposure_overlay)
					L.update_bloom()
	return TRUE

/datum/bloom_edit/ui_state(mob/user)
	return GLOB.admin_state
