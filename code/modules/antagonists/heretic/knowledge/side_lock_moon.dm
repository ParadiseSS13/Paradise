/datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/lock

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/spell/mind_gate
	tier2 = /datum/heretic_knowledge/unfathomable_curio
	tier3 = /datum/heretic_knowledge/dummy_moon_to_lock

// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/dummy_moon_to_lock
	name = "Lock and Moon ways"
	desc = "Research this to gain access to the other path"
	gain_text = "The powers of Madness are like a wound in one's soul, and every wound can be opened and closed."
	cost = 1



/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell which inflicts hallucinations, \
		confusion, oxygen loss and insanity to its target over 10 seconds.\
		The caster's mind is likewise also inflicted with insanity in return."
	gain_text = "My mind swings open like a gate, and its insight will let me perceive the truth."

	action_to_add = /datum/spell/mind_gate
	cost = 1

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs and any belt into an Unfathomable Curio, \
			a belt that can hold blades and items for rituals. Whilst worn it will also \
			veil you, allowing you to take 5 hits without suffering damage, this veil will recharge very slowly \
			outside of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"

