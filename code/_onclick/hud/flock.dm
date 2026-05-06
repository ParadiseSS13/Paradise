/datum/hud/flockdrone
	ui_style = 'goon/icons/hud/flock_ui.dmi'

	var/atom/movable/screen/flock_relay_status/relay_status

/datum/hud/flockdrone/New(mob/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/flockdrone_part/converter(null, src)
	static_inventory += using

	using = new /atom/movable/screen/flockdrone_part/incapacitator(null, src)
	static_inventory += using

	using = new /atom/movable/screen/flockdrone_part/absorber(null, src)
	static_inventory += using

	healthdoll = new /atom/movable/screen/flockdrone_health(null, src)
	infodisplay += healthdoll

	relay_status = new(null, src)
	infodisplay += relay_status

/datum/hud/flockdrone/Destroy()
	QDEL_NULL(relay_status)
	return ..()

// Used for flock traces and the overmind
/datum/hud/flockghost
	ui_style = 'goon/icons/hud/flock_ui.dmi'

	var/atom/movable/screen/flock_relay_status/relay_status

/datum/hud/flockghost/New(mob/owner)
	. = ..()
	relay_status = new(null, src)
	infodisplay += relay_status

/datum/hud/flockghost/Destroy()
	QDEL_NULL(relay_status)
	return ..()

/atom/movable/screen/flockdrone_health
	icon = 'goon/icons/hud/flock_ui.dmi'
	icon_state = "health1"
	screen_loc = ui_living_healthdoll

/atom/movable/screen/flockdrone_part
	icon = 'goon/icons/hud/flock_ui.dmi'
	var/active_state = ""
	var/inactive_state = ""

	var/part_type
	var/datum/flockdrone_part/part_ref

/atom/movable/screen/flockdrone_part/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/simple_animal/flock/drone/drone = hud?.mymob
	part_ref = locate(part_type) in drone?.parts // create n destroy
	part_ref?.screen_obj = src

	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/flockdrone_part/Destroy()
	part_ref?.screen_obj = null
	part_ref = null
	return ..()

/atom/movable/screen/flockdrone_part/update_icon_state()
	if(part_ref?.is_active())
		icon_state = active_state
	else
		icon_state = inactive_state
	return ..()

/atom/movable/screen/flockdrone_part/Click(location, control, params)
	. = ..()
	if(.)
		return

	var/mob/living/simple_animal/flock/drone/drone = hud?.mymob
	drone.set_active_part(part_ref)

/atom/movable/screen/flockdrone_part/converter
	name = "converter"
	active_state = "converter1"
	inactive_state = "converter0"

	screen_loc = "CENTER-1:16,SOUTH:5"

	part_type = /datum/flockdrone_part/converter

/atom/movable/screen/flockdrone_part/incapacitator
	name = "incapacitator"
	active_state = "incapacitor1"
	inactive_state = "incapacitor0"

	maptext_x = 6
	maptext_y = 6
	screen_loc = "CENTER:16,SOUTH:5"

	part_type = /datum/flockdrone_part/incapacitator

	var/icon/overlay_mask
	var/obj/effect/abstract/charge_overlay

/atom/movable/screen/flockdrone_part/incapacitator/Initialize(mapload, datum/hud/hud_owner)
	charge_overlay = new()
	. = ..()
	charge_overlay.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ICON
	charge_overlay.icon_state = "charge_overlay"
	add_viscontents(charge_overlay)

	overlay_mask = icon('goon/icons/hud/flock_ui.dmi', "darkener")
	charge_overlay.add_filter("mask", 1, alpha_mask_filter(0, 0, overlay_mask))

/atom/movable/screen/flockdrone_part/incapacitator/Destroy()
	QDEL_NULL(charge_overlay)
	return ..()

/atom/movable/screen/flockdrone_part/incapacitator/update_appearance(updates)
	. = ..()
	var/datum/flockdrone_part/incapacitator/part = part_ref
	maptext = MAPTEXT("[part?.shot_count || "0"]")

	var/datum/flockdrone_part/incapacitator/weapon = part_ref
	charge_overlay.transition_filter(
		"mask",
		0.5 SECONDS,
		list(
			"y" = -24 * (1 - round(weapon.shot_count / weapon.max_shots, 0.1))
		),
		SINE_EASING,
		FALSE
	)

/atom/movable/screen/flockdrone_part/absorber
	name = "material decompiler"
	active_state = "absorber"
	inactive_state = "absorber"

	screen_loc = "CENTER+1:16,SOUTH:5"

	part_type = /datum/flockdrone_part/absorber

/atom/movable/screen/flock_relay_status
	name = "relay progress"
	icon = 'goon/icons/hud/flock_ui.dmi'
	icon_state = "structure-relay"

	screen_loc = "EAST-1:28,CENTER-2:15"
	alpha = 0

	/// Tracks the last flock status it was aware of.
	var/flock_status = NONE

/atom/movable/screen/flock_relay_status/update_icon_state()
	switch(flock_status)
		if(NONE)
			icon_state = "structure-relay"
		if(FLOCK_ENDGAME_RELAY_BUILT, FLOCK_ENDGAME_RELAY_ACTIVATING, FLOCK_ENDGAME_VICTORY)
			icon_state = "structure-relay-glow"
	return ..()

/atom/movable/screen/flock_relay_status/update_overlays()
	. = ..()
	if(flock_status == FLOCK_ENDGAME_RELAY_ACTIVATING || flock_status == FLOCK_ENDGAME_VICTORY)
		. += image(icon, "structure-relay-sparks")
