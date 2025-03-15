#define SPACE_PHASING "space-phasing"

/**
 * ### Space Crawl
 *
 * Lets the caster enter and exit tiles of space or misc turfs.
 */
/datum/spell/bloodcrawl/space_crawl
	name = "Space Phase"
	desc = "Allows you to phase in and out of existence while in space or glass tiles."



	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "space_crawl"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	allowed_type = /turf

/datum/spell/bloodcrawl/space_crawl/valid_target(turf/target, user)
	if(isspaceturf(get_turf(user))) //qwertodo: make this work on basalt / asteroid turf, if we get a planet map
		return TRUE
	if(istype(get_turf(user), /turf/simulated/floor/transparent))
		return TRUE
	to_chat(user, "<span class='warning'>You must stand on a space or glass turf!</span>")
	return FALSE

/datum/spell/bloodcrawl/space_crawl/rise_message(atom/A)
	return

/datum/spell/bloodcrawl/space_crawl/rise_animation(turf/tele_loc, mob/living/L, atom/A)
	new /obj/effect/temp_visual/space_explosion(tele_loc)
	REMOVE_TRAIT(L, TRAIT_RESISTLOWPRESSURE, SPACE_PHASING)
	REMOVE_TRAIT(L, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	REMOVE_TRAIT(L, TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH)

/datum/spell/bloodcrawl/space_crawl/handle_consumption(mob/living/L, mob/living/victim, atom/A, obj/effect/dummy/slaughter/holder)
	return

/datum/spell/bloodcrawl/space_crawl/sink_animation(atom/A, mob/living/L)
	A.visible_message("<span class='danger'>[L] sinks into [A]...</span>")
	new /obj/effect/temp_visual/space_explosion(A)
	ADD_TRAIT(L, TRAIT_RESISTLOWPRESSURE, SPACE_PHASING)
	ADD_TRAIT(L, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	ADD_TRAIT(L, TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH)


#undef SPACE_PHASING
