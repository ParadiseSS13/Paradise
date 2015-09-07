/datum/reagent/hydrocodone
	name = "Hydrocodone"
	id = "hydrocodone"
	description = "An extremely effective painkiller; may have long term abuse consequences."
	reagent_state = LIQUID
	color = "#C805DC"
	metabolization_rate = 0.3 // Lasts 1.5 minutes for 15 units
	shock_reduction = 200

/datum/reagent/hydrocodone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	..()
	return

/datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

/datum/reagent/virus_food/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor*REM
	..()
	return

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

	//makes you squeaky clean
/datum/reagent/sterilizine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if (method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/sterilizine/reaction_obj(var/obj/O, var/volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/sterilizine/reaction_turf(var/turf/T, var/volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
	reagent_state = LIQUID
	color = "#FA46FA"

/datum/reagent/synaptizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(prob(50))
		M.adjustBrainLoss(-1.0)
	..()
	return

/datum/reagent/audioline
	name = "Audioline"
	id = "audioline"
	description = "Heals ear damage."
	reagent_state = LIQUID
	color = "#6600FF" // rgb: 100, 165, 255

/datum/reagent/audioline/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.ear_damage = 0
	M.ear_deaf = 0
	..()
	return

/datum/reagent/mitocholide
	name = "Mitocholide"
	id = "mitocholide"
	description = "A specialized drug that stimulates the mitochondria of cells to encourage healing of internal organs."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/mitocholide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
		for(var/name in H.internal_organs_by_name)
			var/obj/item/organ/I = H.internal_organs_by_name[name]
			if(I.damage > 0)
				I.damage -= 0.20
	..()
	return

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#0000C8" // rgb: 200, 165, 220

/datum/reagent/cryoxadone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.bodytemperature < 265)
		M.adjustCloneLoss(-4)
		M.adjustOxyLoss(-10)
		M.heal_organ_damage(12,12)
		M.adjustToxLoss(-3)
		M.status_flags &= ~DISFIGURED
	..()
	return

/datum/reagent/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat genetic damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0

/datum/reagent/rezadone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1,1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2,1)
			M.status_flags &= ~DISFIGURED
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)

	..()
	return

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antibiotic agent extracted from space fungus."
	reagent_state = LIQUID
	color = "#0AB478"

/datum/reagent/spaceacillin/on_mob_life(var/mob/living/M as mob)
	..()
	return