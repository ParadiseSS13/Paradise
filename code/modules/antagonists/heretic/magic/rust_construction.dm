/datum/spell/pointed/rust_construction
	name = "Rust Formation"
	desc = "Transforms a rusted floor into a full wall of rust. Creating a wall underneath a mob will harm it."

	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "shield"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 8 SECONDS
	clothes_req = FALSE
	cast_range = 4

	/// How long does the filter last on walls we make?
	var/filter_duration = 2 MINUTES

/datum/spell/pointed/rust_construction/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.range = cast_range
	T.allowed_type = /turf/simulated
	T.use_turf_of_user = TRUE
	return T

/datum/spell/pointed/rust_construction/valid_target(target, user)
	if(!isliving(user))
		return

	var/mob/living/living_owner = user
	var/turf/cast_on = target
	if(!isturf(cast_on))
		to_chat(living_owner, SPAN_WARNING("That is not a wall or a floor!"))
		return FALSE

	if(!HAS_TRAIT(cast_on, TRAIT_RUSTY))
		if(living_owner)
			to_chat(living_owner, SPAN_WARNING("The target is not rusted!"))
			return
	living_owner.visible_message(SPAN_DANGER("<b>[living_owner]</b> drags [living_owner.p_their()] hand upwards as a wall of rust rises out of [cast_on]!"),
	SPAN_NOTICE("You drag a hand upwards as a wall of rust rises out of [cast_on]."))
	return TRUE

/datum/spell/pointed/rust_construction/cast(list/targets, mob/user)
	. = ..()
	var/turf/cast_on = targets[1]
	var/rises_message = "rises out of [cast_on]"

	// If we casted at a wall we'll try to rust it. In the case of an enchanted wall it'll deconstruct it
	if(iswallturf(cast_on))
		cast_on.visible_message(SPAN_WARNING("\The [cast_on] quakes as the rust causes it to crumble!"))
		var/mob/living/living_owner = user
		living_owner?.do_rust_heretic_act(cast_on)
		// ref transfers to floor
		cast_on.Shake(duration = 0.5 SECONDS)
		// which we need to re-rust
		living_owner?.do_rust_heretic_act(cast_on)
		playsound(cast_on, 'sound/effects/bang.ogg', 50, vary = TRUE)
		return TRUE

	var/turf/simulated/wall/new_wall = cast_on.ChangeTurf(/turf/simulated/wall)
	if(!istype(new_wall))
		return TRUE

	playsound(new_wall, 'sound/effects/constructform.ogg', 50, TRUE)
	new_wall.rust_heretic_act()
	new_wall.name = "\improper enchanted [new_wall.name]"
	new_wall.hardness = 60
	new_wall.sheet_amount = 0
	new_wall.girder_type = null

	// I wanted to do a cool animation of a wall raising from the ground
	// but I guess a fading filter will have to do for now as walls have 0 depth (currently)
	new_wall.add_filter("rust_wall", 2, list("type" = "outline", "color" = "#85be299c", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(fade_wall_filter), new_wall), filter_duration * 0.5)
	addtimer(CALLBACK(src, PROC_REF(remove_wall_filter), new_wall), filter_duration)

	var/message_shown = FALSE
	for(var/mob/living/living_mob in cast_on)
		message_shown = TRUE
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == user)
			living_mob.visible_message(
				SPAN_WARNING("\A [new_wall] [rises_message] and pushes along [living_mob]!"),
				SPAN_NOTICE("\A [new_wall] [rises_message] beneath your feet and pushes you along!"),
			)
		else
			living_mob.visible_message(
				SPAN_WARNING("\A [new_wall] [rises_message] and slams into [living_mob]!"),
				SPAN_USERDANGER("\A [new_wall] [rises_message] beneath your feet and slams into you!"),
			)
			living_mob.apply_damage(10, BRUTE)
			living_mob.KnockDown(5 SECONDS)
		living_mob.SpinAnimation(5, 1)

		// If we're not throw them to a nearby (open) turf
		var/list/turfs_by_us = get_adjacent_open_turfs(cast_on)
		// If there is no side by us, hardstun them
		if(!length(turfs_by_us))
			living_mob.Weaken(3 SECONDS)
			continue

		// If there's an open turf throw them to the side
		living_mob.throw_at(pick(turfs_by_us), 1, 3, spin = FALSE)

	if(!message_shown)
		new_wall.visible_message(SPAN_WARNING("\A [new_wall] [rises_message]!"))

/datum/spell/pointed/rust_construction/proc/fade_wall_filter(turf/simulated/wall)
	if(QDELETED(wall))
		return

	var/rust_filter = wall.get_filter("rust_wall")
	if(!rust_filter)
		return

	animate(rust_filter, alpha = 0, time = filter_duration * (9/20))

/datum/spell/pointed/rust_construction/proc/remove_wall_filter(turf/simulated/wall)
	if(QDELETED(wall))
		return

	wall.remove_filter("rust_wall")
