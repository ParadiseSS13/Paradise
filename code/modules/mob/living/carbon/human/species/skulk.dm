/datum/species/skulk

	name = "Skkulakin"
	name_plural = "Skkulakin"
	language = "Skkula-Runespeak"

	blurb = "The Skkulakin are a species of psionically-attuned furred arthropods hailing from the Western Orion Spur. \
	Originating from the world Votum-Accorium, an artic world ruled by the brutal theocratic government known as the Silver Collective.<br/><br/> \
	Despite owning a large amount of territory in the western arm of the sector, the lack of plasma of which their empire relies on is being stretched thin. \
	This has forced the once-proud species to branch out and desperate seek out a solution to their critical shortage."
	unarmed_type = /datum/unarmed_attack/claws

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	brain_mod = 0.5

	species_traits = list()
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	dietflags = DIET_HERB
	reagent_tag = PROCESS_ORG

	suicide_messages = list(
		"is attempting to blow up their mind with their mind!",
		"is jamming their claws into their eye sockets!",
		"is tearing open their arm with their fangs!",
		"is twisting their own neck!",
		"is holding their breath!")

	flesh_color = "#a540a0"
