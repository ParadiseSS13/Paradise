/datum/quirk/negative
	quirk_type = QUIRK_NEGATIVE

/datum/quirk/negative/lightweight
	name = "Lightweight"
	desc = "You can't handle liquor very well, and get drunk much easier."
	cost = -1

/datum/quirk/negative/foreigner
	name = "Foreigner"
	desc = "You just recently joined the greater galactic community, and don't understand the common tongue yet."
	cost = -1

/datum/quirk/negative/allergy
	organic_only = TRUE
	/// Common allergens, reagents that are very easily avoidable
	var/list/low_risk_allergens = list("banana", "apple", "peanuts", "toxin", "fungus", "egg", "tofu", "chocolate", "ants")
	/// More uncommon medicines that could be a problem to be allergic to but can be worked around.
	var/list/medium_risk_allergens = list("teporone", "sal_acid", "mitocholide", "hydrocodone", "morphine", "ephedrine", "perfluorodecalin", "synthflesh", "atropine")
	/// The most commonly used medicines. Medbay is always going to be a pain for people with these.
	var/list/high_risk_allergens = list("salglu_solution", "silver_sulfadizine", "styptic_powder", "salbutamol", "cryoxadone")
	var/datum/reagent/allergen

/datum/quirk/negative/allergy/low
	name = "Low-Risk Allergy"
	desc = "You have an allergy to a random, non-essential reagent."
	cost = -1

/datum/quirk/negative/allergy/moderate
	name = "Moderate-Risk Allergy"
	desc = "You have an allergy to a random uncommon medicine."
	cost = -2

/datum/quirk/negative/allgery/high
	name = "High-Risk Allergy"
	desc = "You have an allergy to a random common medicine. You've been provided an extra epinephrine autoinjector to compensate."
	cost = -3

/datum/quirk/negative/deaf
	name = "Deafness"
	desc = "You are incurably deaf, and cannot take a command or security position."
	cost = -4
	blacklisted = TRUE

/datum/quirk/negative/blind
	name = "Blind"
	desc = "You are incurably blind, and cannot take a command or security position."
	cost = -4
	blacklisted = TRUE

/datum/quirk/negative/frail
	name = "Frail"
	desc = "You get major injuries much easier."
	cost = -3

/datum/quirk/negative/asthma
	name = "Asthma"
	desc = "You have trouble breathing sometimes."
	cost = -4
	organic_only = TRUE
