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

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// Check first if they have a Living Heart. If it's missing, we should
	// throw a fail to show the heretic that there's no point in rerolling
	// if you don't have a heart to track the targets in the first place.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		to_chat(user, SPAN_HIEROPHANT("The ritual failed, you have no living heart!"))
		return FALSE

	return TRUE

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	for(var/mob/living/carbon/human/target as anything in heretic_datum.sac_targets)
		heretic_datum.remove_sacrifice_target(target)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user, heretic_datum = heretic_datum))
		to_chat(user, SPAN_HIEROPHANT("The ritual failed, there were no targets found!"))
		return FALSE

	return TRUE

// This is automatically gained after the knowledge ritual.
/datum/heretic_knowledge/unsealed_art
	name = "The Arts Unsealed"
	desc = "Open yourself to the influences of the manuses, gleaning what you have learned to \
	create a magnum opus of art. A masterpiece above all others, that exudes its own unique influence."
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book_open"
	abstract_parent_type = /datum/heretic_knowledge/unsealed_art
	required_atoms = list()
	priority = 20 // fairly low priority
	var/was_completed = FALSE

/datum/heretic_knowledge/unsealed_art/New()
	var/static/list/potential_organs = list(
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/lungs,
	)

	var/static/list/potential_uncommoner_items = list(
		/obj/item/food/monkeycube,
		/obj/item/megaphone,
		/obj/item/toy/figure,
		/obj/item/multitool,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/melee/baton,
		/obj/item/reagent_containers/drinks/mug,
		)

	var/static/list/paint_item = list(
		list(/obj/item/toy/crayon),
		list(/obj/item/pen),
		/obj/item/pen/red,
		/obj/item/pen/blue,
		/obj/item/pen/fancy,
		/obj/item/painter,
		/obj/item/reagent_containers/glass/paint,
	)

	required_atoms[pick(potential_organs)] += 1
	required_atoms[pick(potential_uncommoner_items)] += 1
	required_atoms[pick(paint_item)] += 1
	required_atoms[pick(paint_item)] += 1
	required_atoms[pick(paint_item)] += 1
	required_atoms[/obj/item/stack/sheet/cloth] += 1

/datum/heretic_knowledge/unsealed_art/can_be_invoked(datum/antagonist/heretic/invoker)
	return !was_completed

/datum/heretic_knowledge/unsealed_art/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/our_turf)
	return !was_completed

/datum/heretic_knowledge/unsealed_art/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	var/art = pick(subtypesof(/obj/structure/unsealed_art))
	new art(our_turf)
	to_chat(user, SPAN_HIEROPHANT("We open ourself to otherworldly influences, and through them we glean inspiration for a masterpiece!"))
	was_completed = TRUE
	log_heretic_knowledge("[key_name(user)] completed a [name] at [worldtime2text()].")
	return TRUE
