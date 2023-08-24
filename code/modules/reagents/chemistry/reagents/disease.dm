/datum/reagent/spider_eggs
	name = "Spider eggs"
	id = "spidereggs"
	description = "A fine dust containing spider eggs. Oh gosh."
	reagent_state = SOLID
	color = "#FFFFFF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/spider_eggs/on_mob_life(mob/living/M)
	if(volume > 2.5)
		if(iscarbon(M))
			if(!M.get_int_organ(/obj/item/organ/internal/body_egg))
				new/obj/item/organ/internal/body_egg/spider_eggs(M) //Yes, even Xenos can fall victim to the plague that is spider infestation.
	return ..()

/datum/reagent/nanomachines
	name = "Nanomachines"
	id = "nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/nanomachines/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))
	return ..()

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/xenomicrobes/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ContractDisease(new /datum/disease/transformation/xeno(0))
	return ..()

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	id = "fungalspores"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/fungalspores/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/tuberculosis(0))
	return ..()

/datum/reagent/jagged_crystals
	name = "Jagged Crystals"
	id = "jagged_crystals"
	description = "Rapid chemical decomposition has warped these crystals into twisted spikes."
	reagent_state = SOLID
	color = "#FA0000" // rgb: 250, 0, 0
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/jagged_crystals/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/berserker(0))
	return ..()

/datum/reagent/salmonella
	name = "Salmonella"
	id = "salmonella"
	description = "A nasty bacteria found in spoiled food."
	reagent_state = LIQUID
	color = "#1E4600"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/salmonella/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/food_poisoning(0))
	return ..()

/datum/reagent/gibbis
	name = "Gibbis"
	id = "gibbis"
	description = "Liquid gibbis."
	reagent_state = LIQUID
	color = "#FF0000"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/gibbis/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/gbs/curable(0))
	return ..()

/datum/reagent/prions
	name = "Prions"
	id = "prions"
	description = "A disease-causing agent that is neither bacterial nor fungal nor viral and contains no genetic material."
	reagent_state = LIQUID
	color = "#FFFFFF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/prions/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/kuru(0))
	return ..()

/datum/reagent/bacon_grease
	name = "Pure bacon grease"
	id = "bacon_grease"
	description = "Hook me up to an IV of that sweet, sweet stuff!"
	reagent_state = LIQUID
	color = "#F7E6B1"
	can_synth = FALSE
	taste_description = "bacon"

/datum/reagent/bacon_grease/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
	return ..()

/datum/reagent/heartworms
	name = "Space heartworms"
	id = "heartworms"
	description = "Aww, gross! These things can't be good for your heart. They're gunna eat it!"
	reagent_state = SOLID
	color = "#925D6C"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/heartworms/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/heart/ate_heart = H.get_int_organ(/obj/item/organ/internal/heart)
			if(ate_heart)
				ate_heart.remove(H)
				qdel(ate_heart)
	return ..()

/datum/reagent/concentrated_initro
	name = "Concentrated Initropidril"
	id = "concentrated_initro"
	description = "A guaranteed heart-stopper!"
	reagent_state = LIQUID
	color = "#AB1CCF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/concentrated_initro/on_mob_life(mob/living/M)
	if(volume >= 5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest())
				H.set_heartattack(TRUE) // rip in pepperoni
	return ..()

//virus foods

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

/datum/reagent/mutagen/mutagenvirusfood
	name = "Mutagenic agar"
	id = "mutagenvirusfood"
	description = "mutates blood"
	color = "#A3C00F" // rgb: 163,192,15

/datum/reagent/mutagen/mutagenvirusfood/sugar
	name = "Sucrose agar"
	id = "sugarvirusfood"
	color = "#41B0C0" // rgb: 65,176,192
	taste_mult = 1.5

/datum/reagent/medicine/diphenhydramine/diphenhydraminevirusfood
	name = "Virus rations"
	id = "diphenhydraminevirusfood"
	description = "mutates blood"
	color = "#D18AA5" // rgb: 209,138,165

/datum/reagent/plasma_dust/plasmavirusfood
	name = "Virus plasma"
	id = "plasmavirusfood"
	description = "mutates blood"
	color = "#A69DA9" // rgb: 166,157,169

/datum/reagent/plasma_dust/plasmavirusfood/weak
	name = "Weakened virus plasma"
	id = "weakplasmavirusfood"
	color = "#CEC3C6" // rgb: 206,195,198
