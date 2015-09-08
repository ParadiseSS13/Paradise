/datum/chemical_reaction/

	hydrocodone
		name = "Hydrocodone"
		id = "hydrocodone"
		result = "hydrocodone"
		required_reagents = list("morphine" = 1, "sacid" = 1, "water" = 1, "oil" = 1)
		result_amount = 2

	mitocholide
		name = "mitocholide"
		id = "mitocholide"
		result = "mitocholide"
		required_reagents = list("synthflesh" = 1, "cryoxadone" = 1, "plasma" = 1)
		result_amount = 3

	cryoxadone
		name = "Cryoxadone"
		id = "cryoxadone"
		result = "cryoxadone"
		required_reagents = list("cryostylane" = 1, "plasma" = 1, "acetone" = 1, "mutagen" = 1)
		result_amount = 4
		mix_message = "The solution bubbles softly."

	spaceacillin
		name = "Spaceacillin"
		id = "spaceacillin"
		result = "spaceacillin"
		required_reagents = list("fungus" = 1, "ethanol" = 1)
		result_amount = 2
		mix_message = "The solvent extracts an antibiotic compound from the fungus."

	audioline
		name = "Audioline"
		id = "audioline"
		result = "audioline"
		required_reagents = list("spaceacillin" = 1, "salglu_solution" = 1, "epinephrine" = 1)
		result_amount = 3

	rezadone
		name = "Rezadone"
		id = "rezadone"
		result = "rezadone"
		required_reagents = list("carpotoxin" = 1, "spaceacillin" = 1, "copper" = 1)
		result_amount = 3

	virus_food
		name = "Virus Food"
		id = "virusfood"
		result = "virusfood"
		required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
		result_amount = 3
/*
	mix_virus
		name = "Mix Virus"
		id = "mixvirus"
		result = "blood"
		required_reagents = list("virusfood" = 5)
		required_catalysts = list("blood")
		var/level = 2

		on_reaction(var/datum/reagents/holder, var/created_volume)

			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
			if(B && B.data)
				var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
				if(D)
					D.Evolve(level - rand(0, 1))


		mix_virus_2

			name = "Mix Virus 2"
			id = "mixvirus2"
			required_reagents = list("mutagen" = 5)
			level = 4

		rem_virus

			name = "Devolve Virus"
			id = "remvirus"
			required_reagents = list("synaptizine" = 5)

			on_reaction(var/datum/reagents/holder, var/created_volume)

				var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
				if(B && B.data)
					var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
					if(D)
						D.Devolve()
*/

	sterilizine
		name = "Sterilizine"
		id = "sterilizine"
		result = "sterilizine"
		required_reagents = list("ethanol" = 1, "charcoal" = 1, "chlorine" = 1)
		result_amount = 3