/datum/reagent/spider_eggs
	name = "spider eggs"
	id = "spidereggs"
	description = "A fine dust containing spider eggs. Oh gosh."
	reagent_state = SOLID
	color = "#FFFFFF"

/datum/reagent/spider_eggs/on_mob_life(mob/living/M)
	if(volume > 2.5)
		if(iscarbon(M))
			if(!M.get_int_organ(/obj/item/organ/internal/body_egg))
				new/obj/item/organ/internal/body_egg/spider_eggs(M) //Yes, even Xenos can fall victim to the plague that is spider infestation.
	..()


/datum/reagent/nanomachines
	name = "Nanomachines"
	id = "nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/nanomachines/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))
	..()


/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ContractDisease(new /datum/disease/transformation/xeno(0))
	..()

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	id = "fungalspores"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125

/datum/reagent/fungalspores/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/tuberculosis(0))
	..()

/datum/reagent/jagged_crystals
	name = "Jagged Crystals"
	id = "jagged_crystals"
	description = "Rapid chemical decomposition has warped these crystals into twisted spikes."
	reagent_state = SOLID
	color = "#FA0000" // rgb: 250, 0, 0

/datum/reagent/jagged_crystals/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/berserker(0))
	..()

/datum/reagent/salmonella
	name = "Salmonella"
	id = "salmonella"
	description = "A nasty bacteria found in spoiled food."
	reagent_state = LIQUID
	color = "#1E4600"

/datum/reagent/salmonella/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/food_poisoning(0))
	..()

/datum/reagent/gibbis
	name = "Gibbis"
	id = "gibbis"
	description = "Liquid gibbis."
	reagent_state = LIQUID
	color = "#FF0000"

/datum/reagent/gibbis/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/gbs/curable(0))
	..()

/datum/reagent/prions
	name = "Prions"
	id = "prions"
	description = "A disease-causing agent that is neither bacterial nor fungal nor viral and contains no genetic material."
	reagent_state = LIQUID
	color = "#FFFFFF"

/datum/reagent/prions/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/kuru(0))
	..()

/datum/reagent/grave_dust
	name = "Grave Dust"
	id = "grave_dust"
	description = "Moldy old dust taken from a grave site."
	reagent_state = LIQUID
	color = "#465046"

/datum/reagent/grave_dust/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/vampire(0))
	..()

/datum/reagent/heartworms
	name = "Space heartworms"
	id = "heartworms"
	description = "Aww, gross! These things can't be good for your heart. They're gunna eat it!"
	reagent_state = SOLID
	color = "#925D6C"

/datum/reagent/heartworms/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/heart/ate_heart = H.get_int_organ(/obj/item/organ/internal/heart)
			if(ate_heart)
				ate_heart.remove(H)
				qdel(ate_heart)
	..()

//virus-specific symptom reagents

/datum/reagent/synaphydramine
	name = "Diphen-Synaptizine"
	id = "synaphydramine"
	description = "Reduces drowsiness and hallucinations while also purging histamine from the body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/synaphydramine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("lsd"))
		holder.remove_reagent("lsd", 5)
	if(holder.has_reagent("histamine"))
		holder.remove_reagent("histamine", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1)
	..()

//virus food
/datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

/datum/reagent/virus_food/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor * REAGENTS_EFFECT_MULTIPLIER
	..()

/datum/reagent/mutagen/mutagenvirusfood
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	description = "mutates blood"
	color = "#A3C00F" // rgb: 163,192,15

/datum/reagent/mutagen/mutagenvirusfood/sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	color = "#41B0C0" // rgb: 65,176,192

/datum/reagent/diphenhydramine/diphenhydraminevirusfood
	name = "virus rations"
	id = "diphenhydraminevirusfood"
	description = "mutates blood"
	color = "#D18AA5" // rgb: 209,138,165

/datum/reagent/plasma_dust/plasmavirusfood
	name = "virus plasma"
	id = "plasmavirusfood"
	description = "mutates blood"
	color = "#A69DA9" // rgb: 166,157,169

/datum/reagent/plasma_dust/plasmavirusfood/weak
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	color = "#CEC3C6" // rgb: 206,195,198

//reactions
/datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food_mutagen
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	result = "mutagenvirusfood"
	required_reagents = list("mutagen" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_diphenhydramine
	name = "virus rations"
	id = "diphenhydraminevirusfood"
	result = "diphenhydraminevirusfood"
	required_reagents = list("diphenhydramine" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma
	name = "virus plasma"
	id = "plasmavirusfood"
	result = "plasmavirusfood"
	required_reagents = list("plasma_dust" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma_diphenhydramine
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	result = "weakplasmavirusfood"
	required_reagents = list("diphenhydramine" = 1, "plasmavirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	result = "sugarvirusfood"
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "sucrose agar"
	id = "salineglucosevirusfood"
	result = "sugarvirusfood"
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)
	result_amount = 2


//mix virus
/datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
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
	required_reagents = list("plasma_dust" = 1)
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
	required_reagents = list("diphenhydraminevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("diphenhydramine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()