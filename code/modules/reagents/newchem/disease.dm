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

/datum/reagent/nanomachines/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	if(volume > 1.5)
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))
	..()


/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	if(volume > 1.5)
		M.ContractDisease(new /datum/disease/transformation/xeno(0))
	..()

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	id = "fungalspores"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125

/datum/reagent/fungalspores/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/tuberculosis(0))
	..()

/datum/reagent/jagged_crystals
	name = "Jagged Crystals"
	id = "jagged_crystals"
	description = "Rapid chemical decomposition has warped these crystals into twisted spikes."
	reagent_state = SOLID
	color = "#FA0000" // rgb: 250, 0, 0

/datum/reagent/jagged_crystals/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	M.ForceContractDisease(new /datum/disease/berserker(0))
	..()

/datum/reagent/salmonella
	name = "Salmonella "
	id = "salmonella "
	description = "A nasty bacteria found in spoiled food."
	reagent_state = LIQUID
	color = "#1E4600"

/datum/reagent/salmonella/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	M.ForceContractDisease(new /datum/disease/food_poisoning(0))
	..()

/datum/reagent/spore
	name = "Blob Spores"
	id = "spore"
	description = "Spores of some blob creature thingy."
	reagent_state = LIQUID
	color = "#CE760A" // rgb: 206, 118, 10
	var/client/blob_client = null
	var/blob_point_rate = 3

/datum/reagent/spore/on_mob_life(var/mob/living/M)
	if(!M) M = holder.my_atom
	if(holder.has_reagent("atrazine",45))
		holder.del_reagent("spore") //apparently this never metabolizes and stays in forever unless you have 45 units of atrazine in you or some stupid thing like that.
	if(prob(1))
		to_chat(M, "<span class='danger'>Your mouth tastes funny.</span>")
	if(prob(1) && prob(25))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(directory[ckey(C.key)])
				blob_client = directory[ckey(C.key)]
				C.gib()
				if(blob_client)
					var/obj/effect/blob/core/core = new(get_turf(C), 200, blob_client, blob_point_rate)
					if(core.overmind && core.overmind.mind)
						core.overmind.mind.name = C.name

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