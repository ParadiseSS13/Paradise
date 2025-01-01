/// Config holder for all ligting effect related things
/datum/configuration_section/lighting_effects_configuration
	/// Brightness of bloom effect independent of light_power
	var/glow_brightness_base = 0
	/// Brightness of bloom effect that depends on light_power
	var/glow_brightness_power = -0.25
	/// Contrast of bloom effect independent of light_power
	var/glow_contrast_base = 0
	/// Contrast of bloom effect that depends on light_power
	var/glow_contrast_power = 0.5
	/// Brightness of exposure effect independent of light_power
	var/exposure_brightness_base = 0.01
	/// Brightness of exposure effect that depends on light_power
	var/exposure_brightness_power = 0
	/// Contrast of exposure effect independent of light_power
	var/exposure_contrast_base = 9.5
	/// Contrast of exposure effect that depends on light_power
	var/exposure_contrast_power = 0

/datum/configuration_section/lighting_effects_configuration/load_data(list/data)
	// Use the load wrappers here. That way the default isnt made 'null' if you comment out the config line
	CONFIG_LOAD_NUM(glow_brightness_base, data["glow_brightness_base"])
	CONFIG_LOAD_NUM(glow_brightness_power, data["glow_brightness_power"])
	CONFIG_LOAD_NUM(glow_contrast_base, data["glow_contrast_base"])
	CONFIG_LOAD_NUM(glow_contrast_power, data["glow_contrast_power"])
	CONFIG_LOAD_NUM(exposure_brightness_base, data["exposure_brightness_base"])
	CONFIG_LOAD_NUM(exposure_brightness_power, data["exposure_brightness_power"])
	CONFIG_LOAD_NUM(exposure_contrast_base, data["exposure_contrast_base"])
	CONFIG_LOAD_NUM(exposure_contrast_power, data["exposure_contrast_power"])
