// Some general sidepath options.

/datum/heretic_knowledge/reroll_targets
	name = "The Relentless Heartbeat"
	desc = "Allows you transmute a harebell, a book, and a jumpsuit while standing over a rune \
		to reroll your sacrifice targets."
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list(
		/obj/item/food/grown/harebell = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
	)
	cost = 1
	research_tree_icon_path = 'icons/mob/actions/actions_animal.dmi'
	research_tree_icon_state = "gaze"

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// Check first if they have a Living Heart. If it's missing, we should
	// throw a fail to show the heretic that there's no point in rerolling
	// if you don't have a heart to track the targets in the first place.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		to_chat(user, "<span class='warning'>The ritual failed, you have no living heart!</span>")
		return FALSE

	return TRUE

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	for(var/mob/living/carbon/human/target as anything in heretic_datum.sac_targets)
		heretic_datum.remove_sacrifice_target(target)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		to_chat(user, "<span class='warning'>The ritual failed, there were no targets found!</span>")
		return FALSE

	return TRUE
