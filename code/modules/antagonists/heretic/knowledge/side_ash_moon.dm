/datum/heretic_knowledge_tree_column/ash_to_moon
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/ash
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/moon

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/medallion
	tier2 = /datum/heretic_knowledge/dummy_ash_to_moon
	tier3 = /datum/heretic_knowledge/summon/ashy

// Sidepaths for knowledge between Ash and Flesh.

/datum/heretic_knowledge/dummy_ash_to_moon
	name = "Ash and Moon ways"
	desc = "Research this to gain access to the other path"
	gain_text = "Madness leads to decay, and the fire is as great show for the soul."
	cost = 1


/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Allows you to transmute a pair of eyes, a candle, and a glass shard into an Eldritch Medallion. \
		The Eldritch Medallion grants you thermal vision while worn, and also functions as a focus."
	gain_text = "Piercing eyes guided them through the mundane. Neither darkness nor terror could stop them."

	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Allows you to transmute a head, a pile of ash, and a book to create an Ash Spirit. \
		Ash Spirits have a short range jaunt and the ability to cause bleeding in foes at range. \
		They also have the ability to create a ring of fire around themselves for a length of time."
	gain_text = "I combined my principle of hunger with my desire for destruction. The Marshal knew my name, and the Nightwatcher gazed on."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/external/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/basic/heretic_summon/ash_spirit
	cost = 1


