/datum/quirk/negative

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
	var/datum/reagent/allergen

/datum/quirk/negative/allergy/low
	name = "Low-Risk Allergy"
	desc = "You have an allergy to a random rare medicine."
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
	desc = "You get internal injuries much easier."
	cost = -3

/datum/quirk/negative/asthma
	name = "Asthma"
	desc = "You have trouble breathing sometimes."
	cost = -4
