/datum/spell/bloodcrawl/mirror_walk
	name = "Mirror Walk"
	desc = "Allows you to traverse invisibly and freely across the station within the realm of the mirror. \
		You can only enter and exit the realm of mirrors when nearby reflective surfaces and items, \
		such as windows, mirrors, and reflective walls or equipment."

	base_cooldown = 10 SECONDS // We need this else they'll instantly teleport out
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"

	is_a_heretic_spell = TRUE

	allowed_type = /turf

	/// Static typecache of types that are counted as reflective.
	var/static/list/special_reflective_surfaces = typecacheof(list(
		/obj/structure/window,
		/obj/structure/mirror,
		/obj/structure/sink/puddle
	))


/datum/spell/bloodcrawl/mirror_walk/valid_target(turf/target, mob/user)
	var/turf/phase_turf = get_turf(user)
	// It would likely be a bad idea to teleport into an ai monitored area (ai sat)
	var/area/phase_area = get_area(phase_turf)
	if(istype(phase_area, /area/station/ai_monitored) && user.loc != phase_turf)
		to_chat(user, SPAN_WARNING("It's probably not a very wise idea to exit the mirror's realm here."))
		return FALSE
	if(is_reflection_nearby(phase_turf))
		return TRUE
	to_chat(user, "There are no reflective surfaces nearby to use the mirror's realm here!")
	return FALSE

/datum/spell/bloodcrawl/mirror_walk/rise_message(atom/A)
	return

/datum/spell/bloodcrawl/mirror_walk/rise_animation(turf/tele_loc, mob/living/L, atom/A)
	var/atom/nearby_reflection = is_reflection_nearby(tele_loc)
	if(!nearby_reflection) // Should only be true if you're forced out somehow, like by having the spell removed
		return
	L.visible_message(
		SPAN_BOLDWARNING("[L] phases into reality before your very eyes!"),
		SPAN_NOTICE("You jump out of the reflection coming off of [nearby_reflection], exiting the mirror's realm."),
	)

/datum/spell/bloodcrawl/mirror_walk/handle_consumption(mob/living/L, mob/living/victim, atom/A, obj/effect/dummy/slaughter/holder)
	return

/datum/spell/bloodcrawl/mirror_walk/sink_animation(atom/A, mob/living/L)
	var/atom/nearby_reflection = is_reflection_nearby(L)
	L.visible_message(
		SPAN_BOLDWARNING("[L] phases out of reality, vanishing before your very eyes!"),
		SPAN_NOTICE("You jump into the reflection coming off of [nearby_reflection], entering the mirror's realm."),
	)

/**
 * Goes through all nearby atoms in sight of the
 * passed caster and determines if they are "reflective"
 * for the purpose of us being able to utilize it to enter or exit.
 *
 * Returns an object reference to a "reflective" object in view if one was found,
 * or null if no object was found that was determined to be "reflective".
 */
/datum/spell/bloodcrawl/mirror_walk/proc/is_reflection_nearby(atom/caster)
	for(var/atom/thing as anything in view(2, caster))
		if(isitem(thing))
			var/obj/item/item_thing = thing
			if(item_thing.IsReflect())
				return thing

		if(ishuman(thing))
			var/mob/living/carbon/human/human_thing = thing
			if(human_thing.check_reflect())
				return thing

		if(isturf(thing))
			var/turf/turf_thing = thing
			if(turf_thing.flags & BLESSED_TILE)
				continue
			if(turf_thing.flags_ricochet & RICOCHET_SHINY)
				return thing

		if(is_type_in_typecache(thing, special_reflective_surfaces))
			return thing

	return null
