GLOBAL_LIST_EMPTY(all_quirks)

/datum/quirk
	var/name = "basetype"
	var/desc = "You shouldn't see this"
	var/mob/living/carbon/human/owner
	/// If only organic characters can have it
	var/organic_only = FALSE
	/// If having this bars you from rolling sec/command
	var/blacklisted

/datum/quirk/randomize_allergy()
	var/list/possible_allergens = list("charcoal", "teporone", "salbutamol", "potass_iodide", "spaceacillin", "salglu_solution",
									"sal_acid", "cryoxadone", "hydrocodone", "mitocholide",
									"sanguine_reagent", "ephedrine", "bicaridine", "kelotane")

