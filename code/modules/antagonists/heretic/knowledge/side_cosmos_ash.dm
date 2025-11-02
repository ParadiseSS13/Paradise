/datum/heretic_knowledge_tree_column/cosmic_to_ash
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/ash

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/dummy_cosmic_to_ash
	tier2 = /datum/heretic_knowledge/spell/space_phase
	tier3 = /datum/heretic_knowledge/eldritch_coin


// Sidepaths for knowledge between Ash and comsic.

/datum/heretic_knowledge/dummy_cosmic_to_ash
	name = "Cosmic and Ash ways"
	desc = "Research this to gain access to the other path"
	gain_text = "Stars to stardust, to us, to Ash, back to stardust."
	cost = 1

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."

	action_to_add = /datum/spell/bloodcrawl/space_crawl
	cost = 1


	research_tree_icon_frame = 6

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma and a diamond to create an Eldritch Coin. \
		The coin will open or close nearby doors when landing on heads and toggle their bolts \
		when landing on tails. If you insert the coin into an airlock, it will be consumed \
		to fry its electronics, opening the airlock permanently unless bolted. "
	gain_text = "The Mansus is a place of all sorts of sins. But greed held a special role."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic_heretic"

