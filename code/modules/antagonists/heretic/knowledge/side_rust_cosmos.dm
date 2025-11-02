/datum/heretic_knowledge_tree_column/rust_to_cosmic
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/rust
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/cosmic

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/essence
	tier2 = /datum/heretic_knowledge/dummy_rust_to_cosmos
	tier3 = /datum/heretic_knowledge/summon/rusty

// Sidepaths for knowledge between Rust and Cosmos.

/datum/heretic_knowledge/dummy_rust_to_cosmos
	name = "Cosmic and Rust ways"
	desc = "Research this to gain access to the other path"
	gain_text = "Rust is but the stardust of metal."
	cost = 1

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a Flask of Eldritch Essence. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me. \
		Created by the Priest - the Liquid that both was and is not."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/drinks/bottle/eldritch)
	cost = 1


	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"

/datum/heretic_knowledge/entropy_pulse
	name = "Pulse of Entropy"
	desc = "Allows you to transmute 10 iron sheets and a garbage item to fill the surrounding vicinity of the rune with rust."
	gain_text = "Reality begins to whisper to me. To give it its entropic end."
	required_atoms = list(
		/obj/item/stack/sheet/metal = 10,
		/obj/item/trash = 1,
	)

	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "corrode"
	research_tree_icon_frame = 10

	var/rusting_range = 8

/datum/heretic_knowledge/entropy_pulse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/our_turf)
	for(var/turf/nearby_turf in view(rusting_range, our_turf))
		if(get_dist(nearby_turf, our_turf) <= 1) //tiles on rune should always be rusted
			nearby_turf.rust_heretic_act()
		//we exclude closed turf to avoid exposing cultist bases
		if(prob(60) || iswallturf(nearby_turf))
			continue
		nearby_turf.rust_heretic_act()
	return TRUE


/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "Allows you to transmute a pool of vomit, some cable coil, and 10 sheets of iron into a Rust Walker. \
		Rust Walkers excel at spreading rust and are moderately strong in combat."
	gain_text = "I combined my knowledge of creation with my desire for corruption. The Marshal knew my name, and the Rusted Hills echoed out."

	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/rust_spirit
	cost = 1



