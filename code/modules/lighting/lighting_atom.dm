// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE	//Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.
	if(l_power != null)
		light_power = l_power

	if(l_range != null)
		light_range = l_range

	if(l_color != NONSENSICAL_VALUE)
		light_color = l_color

	SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color)

	update_light()

#undef NONSENSICAL_VALUE

/atom/proc/remove_light()
	light_power = 0
	light_range = 0
	light_color = 0
	update_light()

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE
	if(QDELETED(src))
		return

	if(!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(light)
	else
		if(!ismovable(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if(light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)

/atom/proc/extinguish_light(force = FALSE)
	return

/**
  * Updates the atom's opacity value.
  *
  * This exists to act as a hook for associated behavior.
  * It notifies (potentially) affected light sources so they can update (if needed).
  */
/atom/proc/set_opacity(new_opacity)
	if(new_opacity == opacity)
		return

	SEND_SIGNAL(src, COMSIG_ATOM_SET_OPACITY, new_opacity)
	. = opacity
	opacity = new_opacity

/atom/movable/set_opacity(new_opacity)
	. = ..()
	if(isnull(.) || !isturf(loc))
		return

	if(opacity)
		AddElement(/datum/element/light_blocking)
	else
		RemoveElement(/datum/element/light_blocking)

/turf/set_opacity(new_opacity)
	. = ..()
	if(isnull(.))
		return

	recalculate_directional_opacity()

/atom/proc/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	return

/turf/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	if(!_duration)
		stack_trace("Lighting FX obj created on a turf without a duration")
	new /obj/effect/dummy/lighting_obj (src, _color, _range, _power, _duration)

/obj/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	var/temp_color
	var/temp_power
	var/temp_range
	if(!_reset_lighting) //incase the obj already has a lighting color that you don't want cleared out after, ie computer monitors.
		temp_color = light_color
		temp_power = light_power
		temp_range = light_range
	set_light(_range, _power, _color)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), _reset_lighting ? initial(light_range) : temp_range, _reset_lighting ? initial(light_power) : temp_power, _reset_lighting ? initial(light_color) : temp_color), _duration, TIMER_OVERRIDE|TIMER_UNIQUE)

/mob/living/flash_lighting_fx(_range = FLASH_LIGHT_RANGE, _power = FLASH_LIGHT_POWER, _color = LIGHT_COLOR_WHITE, _duration = FLASH_LIGHT_DURATION, _reset_lighting = TRUE)
	mob_light(_color, _range, _power, _duration)

/mob/living/proc/mob_light(_color, _range, _power, _duration)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = new (src, _color, _range, _power, _duration)
	return mob_light_obj

/atom/proc/update_bloom()
	cut_overlay(glow_overlay)
	cut_overlay(exposure_overlay)

	if(glow_icon && glow_icon_state)
		glow_overlay = image(icon = glow_icon, icon_state = glow_icon_state, dir = dir, layer = -2)
		if(layer <= LOW_OBJ_LAYER)
			glow_overlay.plane = FLOOR_LIGHTING_LAMPS_PLANE // Yeah this sucks
		else
			glow_overlay.plane = LIGHTING_LAMPS_PLANE
		glow_overlay.blend_mode = BLEND_ADD

		if(glow_colored)
			var/datum/color_matrix/mat = new(
				light_color,
				GLOB.configuration.lighting_effects.glow_contrast_base + GLOB.configuration.lighting_effects.glow_contrast_power * light_power,
				GLOB.configuration.lighting_effects.glow_brightness_base + GLOB.configuration.lighting_effects.glow_brightness_power * light_power)
			glow_overlay.color = mat.get()
		add_overlay(glow_overlay)

	if(exposure_icon && exposure_icon_state)
		exposure_overlay = image(icon = exposure_icon, icon_state = exposure_icon_state, dir = dir, layer = -1)
		exposure_overlay.plane = LIGHTING_EXPOSURE_PLANE
		exposure_overlay.blend_mode = BLEND_ADD
		exposure_overlay.appearance_flags = RESET_ALPHA | RESET_COLOR | KEEP_APART

		var/datum/color_matrix/mat = new(
			1,
			GLOB.configuration.lighting_effects.exposure_contrast_base + GLOB.configuration.lighting_effects.exposure_contrast_power * light_power,
			GLOB.configuration.lighting_effects.exposure_brightness_base + GLOB.configuration.lighting_effects.exposure_brightness_power * light_power)
		if(exposure_colored)
			mat.set_color(
				light_color,
				GLOB.configuration.lighting_effects.exposure_contrast_base + GLOB.configuration.lighting_effects.exposure_contrast_power * light_power,
				GLOB.configuration.lighting_effects.exposure_brightness_base + GLOB.configuration.lighting_effects.exposure_brightness_power * light_power)
		exposure_overlay.color = mat.get()

		var/icon/EX = icon(icon = exposure_icon, icon_state = exposure_icon_state)
		exposure_overlay.pixel_x = 16 - EX.Width() / 2
		exposure_overlay.pixel_y = 16 - EX.Height() / 2
		add_overlay(exposure_overlay)

/atom/proc/delete_lights()
	cut_overlay(glow_overlay)
	cut_overlay(exposure_overlay)
	QDEL_NULL(glow_overlay)
	QDEL_NULL(exposure_overlay)
