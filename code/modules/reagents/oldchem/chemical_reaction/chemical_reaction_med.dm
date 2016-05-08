/datum/chemical_reaction/hydrocodone
		name = "Hydrocodone"
		id = "hydrocodone"
		result = "hydrocodone"
		required_reagents = list("morphine" = 1, "sacid" = 1, "water" = 1, "oil" = 1)
		result_amount = 2

/datum/chemical_reaction/mitocholide
		name = "mitocholide"
		id = "mitocholide"
		result = "mitocholide"
		required_reagents = list("synthflesh" = 1, "cryoxadone" = 1, "plasma" = 1)
		result_amount = 3

/datum/chemical_reaction/cryoxadone
		name = "Cryoxadone"
		id = "cryoxadone"
		result = "cryoxadone"
		required_reagents = list("cryostylane" = 1, "plasma" = 1, "acetone" = 1, "mutagen" = 1)
		result_amount = 4
		mix_message = "The solution bubbles softly."
		mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/spaceacillin
		name = "Spaceacillin"
		id = "spaceacillin"
		result = "spaceacillin"
		required_reagents = list("fungus" = 1, "ethanol" = 1)
		result_amount = 2
		mix_message = "The solvent extracts an antibiotic compound from the fungus."

/datum/chemical_reaction/rezadone
		name = "Rezadone"
		id = "rezadone"
		result = "rezadone"
		required_reagents = list("carpotoxin" = 1, "spaceacillin" = 1, "copper" = 1)
		result_amount = 3

/datum/chemical_reaction/sterilizine
		name = "Sterilizine"
		id = "sterilizine"
		result = "sterilizine"
		required_reagents = list("antihol" = 2, "chlorine" = 1)
		result_amount = 3
