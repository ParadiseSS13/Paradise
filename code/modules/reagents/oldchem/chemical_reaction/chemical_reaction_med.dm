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
		mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

	spaceacillin
		name = "Spaceacillin"
		id = "spaceacillin"
		result = "spaceacillin"
		required_reagents = list("fungus" = 1, "ethanol" = 1)
		result_amount = 2
		mix_message = "The solvent extracts an antibiotic compound from the fungus."

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

	sterilizine
		name = "Sterilizine"
		id = "sterilizine"
		result = "sterilizine"
		required_reagents = list("antihol" = 2, "chlorine" = 1)
		result_amount = 3


//Viruses
/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	result = "blood"
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2

	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3

	name = "Mix Virus 3"
	id = "mixvirus3"
	required_reagents = list("plasma" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4

	name = "Mix Virus 4"
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5

	name = "Mix Virus 5"
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6

	name = "Mix Virus 6"
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7

	name = "Mix Virus 7"
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8

	name = "Mix Virus 8"
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9

	name = "Mix Virus 9"
	id = "mixvirus9"
	required_reagents = list("synaptizinevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus

	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("synaptizine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)

	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()