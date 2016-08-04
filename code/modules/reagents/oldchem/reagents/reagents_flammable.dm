/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "A highly flammable blend of basic hydrocarbons, mostly Acetylene. Useful for both welding and organic chemistry, and can be fortified into a heavier oil."
	reagent_state = LIQUID
	color = "#060606"

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 10)
		return
	..()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existance."
	process_flags = ORGANIC | SYNTHETIC //ethereal means everything processes it.
	metabolization_rate = 1

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	M.adjustBrainLoss(3)
	if(iscultist(M))
		M.status_flags |= GOTTAGOFAST
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustParalysis(-2)
		M.AdjustStunned(-2)
		M.AdjustWeakened(-2)
	else
		M.adjustToxLoss(2)
		M.adjustFireLoss(2)
		M.adjustOxyLoss(2)
		M.adjustBruteLoss(2)
	..()

/datum/reagent/fuel/unholywater/reagent_deleted(mob/living/M)
	M.status_flags &= ~GOTTAGOFAST
	..()

/datum/reagent/plasma
	name = "Plasma"
	id = "plasma"
	description = "The liquid phase of an unusual extraterrestrial compound."
	reagent_state = LIQUID
	color = "#7A2B94"

/datum/reagent/plasma/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	if(holder.has_reagent("epinephrine"))
		holder.remove_reagent("epinephrine", 2)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(10)
	..()

/datum/reagent/plasma/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with plasma is stronger than fuel!
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)
		..()


/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/thermite/reaction_turf(turf/simulated/wall/W, volume)
	if(volume >= 5 && istype(W))
		W.thermite = 1
		W.overlays.Cut()
		W.overlays = image('icons/effects/effects.dmi',icon_state = "thermite")

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128