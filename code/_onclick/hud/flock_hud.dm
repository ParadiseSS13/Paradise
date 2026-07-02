/datum/hud/flockdrone/New(mob/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/flockdrone_part/converter(null, src)
	static_inventory += using

	using = new /atom/movable/screen/flockdrone_part/incapacitator(null, src)
	static_inventory += using

	using = new /atom/movable/screen/flockdrone_part/absorber(null, src)
	static_inventory += using

	using = new /atom/movable/screen/flockphasing()
	using.icon_state = (HAS_TRAIT(mymob, TRAIT_FLOCKPHASE) ? "running" : "walking")
	infodisplay += using

	using = new /atom/movable/screen/act_intent/flock()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	mymob.healths = new /atom/movable/screen/healths/flockdrone_health(null, src)
	infodisplay += mymob.healths

	mymob.pullin = new /atom/movable/screen/pull/flock()
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	hotkeybuttons += mymob.pullin

	zone_select = new /atom/movable/screen/zone_sel/flock()
	zone_select.hud = src
	zone_select.update_icon(UPDATE_OVERLAYS)
	static_inventory += zone_select

// Used for flock traces and the overmind
/datum/hud/flockghost

/atom/movable/screen/healths/flockdrone_health
	icon = 'icons/goonstation/hud/flock_ui.dmi'
	icon_state = "health1"
	screen_loc = UI_BORG_HEALTH

/atom/movable/screen/pull/flock
	icon = 'icons/goonstation/hud/flock_ui.dmi'
	icon_state = "pull0"
	screen_loc = UI_MOVI

/atom/movable/screen/act_intent/flock
	icon = 'icons/goonstation/hud/flock_ui.dmi'

/atom/movable/screen/act_intent/flock/Click(location, control, params)
	var/_x = text2num(params2list(params)["icon-x"])
	var/_y = text2num(params2list(params)["icon-y"])
	if(_x<=16 && _y<=16)
		usr.a_intent_change(INTENT_GRAB)
	else if(_x<=16 && _y>=17)
		usr.a_intent_change(INTENT_HELP)
	else if(_x>=17 && _y<=16)
		usr.a_intent_change(INTENT_HARM)
	else if(_x>=17 && _y>=17)
		usr.a_intent_change(INTENT_DISARM)

/atom/movable/screen/flockphasing

	icon = 'icons/goonstation/hud/flock_ui.dmi'
	name = "flockphase toggle"
	icon_state = "walking"
	screen_loc = UI_MOVI

/atom/movable/screen/flockphasing/Click(location, control, params)
	var/mob/living/basic/flock/drone/M = usr
	if(!istype(M))
		return
	if(HAS_TRAIT(M, TRAIT_FLOCKPHASE))
		M.stop_flockphase()
	else
		if(M.can_flockphase() && M.flockphase_tax())
			M.start_flockphase()

/atom/movable/screen/zone_sel/flock
	icon = 'icons/goonstation/hud/flock_ui.dmi'
	overlay_file = 'icons/goonstation/hud/flock_ui.dmi'

/atom/movable/screen/flockdrone_part
	icon = 'icons/goonstation/hud/flock_ui.dmi'
	var/active_state = ""
	var/inactive_state = ""

	var/part_type
	var/datum/flockdrone_part/part_ref

/atom/movable/screen/flockdrone_part/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/basic/flock/drone/drone = usr
	for(var/datum/flockdrone_part/part in drone.parts)
		if(istype(part, part_type))
			part_ref = part
			break
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

	var/mob/living/basic/flock/drone/drone = usr
	drone.set_active_part(part_ref)

/atom/movable/screen/flockdrone_part/converter
	name = "converter"
	active_state = "converter1"
	inactive_state = "converter0"
	desc = "Converters are an integrated multitool in every flockdrone's arsenal. On help and disarm intent, it will build structures, open lockers, and convert turfs. On harm or grab intent, it will deconstruct or cage things."

	screen_loc = "CENTER-1:16,SOUTH:5"

	part_type = /datum/flockdrone_part/converter

/atom/movable/screen/flockdrone_part/incapacitator
	name = "incapacitator"
	active_state = "incapacitor1"
	inactive_state = "incapacitor0"
	desc = "Incapacitators are the primary weapon system of every flockdrone. They fire enhanced stunning rounds capable of disrupting electronics. They will recharge slowly on their own."
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
	managed_vis_overlays += charge_overlay

	overlay_mask = icon('icons/goonstation/hud/flock_ui.dmi', "darkener")
	charge_overlay.add_filter("mask", 1, alpha_mask_filter(0, 0, overlay_mask))

/atom/movable/screen/flockdrone_part/incapacitator/Destroy()
	managed_vis_overlays -= charge_overlay
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
	desc = "Absorbers are a key piece of any flockdrone's toolkit. They will pickup items and deconstruct them for substrate - the primary building material of any flock device."

	screen_loc = "CENTER+1:16,SOUTH:5"

	part_type = /datum/flockdrone_part/absorber
