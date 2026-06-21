/datum/spell/aoe/conjure/void_conduit
	name = "Void Conduit"
	desc = "Opens a gate to the Void; it releases an intermittent pulse that damages windows and airlocks, \
		while afflicting Heathens with void chill. \
		Affected Heretics instead receive low pressure resistance."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "void_rift"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	base_cooldown = 2 MINUTES

	sound = null
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	invocation = "MBR'C' TH' V''D!"
	invocation_type = INVOCATION_SHOUT
	aoe_range = 0

	summon_type = list(/obj/structure/void_conduit)

/obj/structure/void_conduit
	name = "Void Conduit"
	desc = "An open gate which leads to nothingness. Releases pulses which you do not want to get hit by."
	icon = 'icons/effects/effects.dmi'
	icon_state = "void_conduit"
	anchored = TRUE
	obj_integrity = 150
	///Overlay to apply to the tiles in range of the conduit
	/// List of possible overlays to apply to the tiles in range of the conduit
	var/static/list/overlay_list = list()
	///List of tiles that we added an overlay to, so we can clear them when the conduit is deleted
	var/list/overlayed_turfs = list()
	///How many tiles far our effect is
	var/effect_range = 8
	///id of the deletion timer
	var/timerid
	///Audio loop for the rift being alive
	var/datum/looping_sound/void_conduit/soundloop

/obj/structure/void_conduit/Initialize(mapload)
	. = ..()
	soundloop = new(src, start_immediately = TRUE)
	timerid = QDEL_IN(src, 1 MINUTES)
	START_PROCESSING(SSobj, src)
	if(!length(overlay_list))
		overlay_list += image(icon = 'icons/turf/overlays.dmi', icon_state = "voidtile_1", layer = ABOVE_OPEN_TURF_LAYER)
		overlay_list += image(icon = 'icons/turf/overlays.dmi', icon_state = "voidtile_2", layer = ABOVE_OPEN_TURF_LAYER)
		overlay_list += image(icon = 'icons/turf/overlays.dmi', icon_state = "voidtile_3", layer = ABOVE_OPEN_TURF_LAYER)
	build_view_turfs()

/obj/structure/void_conduit/proc/build_view_turfs()
	for(var/turf/affected_turf as anything in overlayed_turfs)
		affected_turf.cut_overlay(overlay_list)

	for(var/turf/affected_turf as anything in view(effect_range, src))
		if(!isfloorturf(affected_turf))
			continue
		var/image/void_overlay = pick(overlay_list)
		void_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		void_overlay.alpha = 180

		affected_turf.add_overlay(void_overlay)
		overlayed_turfs += affected_turf

/obj/structure/void_conduit/Destroy(force)
	QDEL_NULL(soundloop)
	deltimer(timerid)
	STOP_PROCESSING(SSobj, src)
	for(var/turf/affected_turf as anything in overlayed_turfs) // If the portal is moved, the overlays don't stick around
		affected_turf.cut_overlay(overlay_list)
	var/turf/extra_overlay = get_turf(src)
	extra_overlay.cut_overlay(overlay_list)
	return ..()

/obj/structure/void_conduit/process(seconds_per_tick)
	build_view_turfs()
	do_conduit_pulse()

///Sends out a pulse
/obj/structure/void_conduit/proc/do_conduit_pulse()
	var/list/turfs_to_affect = list()
	for(var/turf/affected_turf as anything in view(effect_range, loc))
		var/distance = get_dist(loc, affected_turf)
		if(!turfs_to_affect["[distance]"])
			turfs_to_affect["[distance]"] = list()
		turfs_to_affect["[distance]"] += affected_turf

	for(var/distance in 0 to effect_range)
		if(!turfs_to_affect["[distance]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(handle_effects), turfs_to_affect["[distance]"]), (1 SECONDS) * distance)

	new /obj/effect/temp_visual/circle_wave/void_conduit(get_turf(src))

///Applies the effects of the pulse "hitting" something. Freezes non-heretic, destroys airlocks/windows
/obj/structure/void_conduit/proc/handle_effects(list/turfs)
	for(var/turf/affected_turf as anything in turfs)
		for(var/atom/thing_to_affect as anything in affected_turf.contents)

			if(isliving(thing_to_affect))
				var/mob/living/affected_mob = thing_to_affect
				if(affected_mob.can_block_magic(MAGIC_RESISTANCE))
					continue
				if(IS_HERETIC_OR_MONSTER(affected_mob) || HAS_TRAIT(affected_mob, TRAIT_MANSUS_TOUCHED))
					affected_mob.apply_status_effect(/datum/status_effect/void_conduit)
				else
					affected_mob.apply_status_effect(/datum/status_effect/void_chill, 1)
				continue

			if(istype(thing_to_affect, /obj/structure/window) || istype(thing_to_affect, /obj/machinery/door))
				var/list/list_turfs = get_adjacent_turfs(thing_to_affect)
				var/findspace = FALSE
				for(var/turf/T in list_turfs) // no breaking space-facing things
					if(istype(T, /turf/space))
						findspace = TRUE
				if(findspace)
					continue
			if(istype(thing_to_affect, /obj/machinery/door))
				var/obj/machinery/door/affected_door = thing_to_affect
				affected_door.disable_door_sparks()
				affected_door.take_damage(rand(15, 30))

			if(istype(thing_to_affect, /obj/structure/window) || istype(thing_to_affect, /obj/structure/grille) || istype(thing_to_affect, /obj/structure/door_assembly) || istype(thing_to_affect, /obj/structure/firelock_frame))
				var/obj/structure/affected_structure = thing_to_affect
				affected_structure.take_damage(rand(10, 20))

/datum/looping_sound/void_conduit
	mid_sounds = 'sound/ambience/ambiatm1.ogg'
	mid_length = 1 SECONDS
	extra_range = 10
	volume = 40
	falloff_distance = 5
	falloff_exponent = 20

/datum/status_effect/void_conduit
	id = "void_conduit"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/void_conduit/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, type)
	return TRUE

/datum/status_effect/void_conduit/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, type)


/// Visual effect from tg's bioscrambler anomaly
/obj/effect/temp_visual/circle_wave
	icon = 'icons/effects/64x64.dmi'
	icon_state = "circle_wave"
	pixel_x = -16
	pixel_y = -16
	duration = 0.5 SECONDS
	color = COLOR_LIME
	var/max_alpha = 255
	///How far the effect would scale in size
	var/amount_to_scale = 2

/obj/effect/temp_visual/circle_wave/Initialize(mapload)
	transform = matrix().Scale(0.1)
	animate(src, transform = matrix().Scale(amount_to_scale), time = duration, flags = ANIMATION_PARALLEL)
	animate(src, alpha = max_alpha, time = duration * 0.6, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = duration * 0.4)
	apply_wibbly_filters(src)
	return ..()

/obj/effect/temp_visual/circle_wave/void_conduit
	color = COLOR_FULL_TONER_BLACK
	duration = 12 SECONDS
	amount_to_scale = 12
