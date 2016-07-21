/datum/reagent/hydrocodone
	name = "Hydrocodone"
	id = "hydrocodone"
	description = "An extremely effective painkiller; may have long term abuse consequences."
	reagent_state = LIQUID
	color = "#C805DC"
	metabolization_rate = 0.3 // Lasts 1.5 minutes for 15 units
	shock_reduction = 200

/datum/reagent/hydrocodone/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

	//makes you squeaky clean
/datum/reagent/sterilizine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/sterilizine/reaction_turf(turf/T, volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
	reagent_state = LIQUID
	color = "#FA46FA"
	overdose_threshold = 40

/datum/reagent/synaptizine/on_mob_life(mob/living/M)
	M.drowsyness = max(0, M.drowsyness-5)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.SetSleeping(0)
	if(prob(50))
		M.adjustBrainLoss(-1.0)
	..()

/datum/reagent/synaptizine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.adjustToxLoss(1)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] staggers and drools, their eyes bloodshot!</span>")
			M.Dizzy(8)
			M.Weaken(4)
		if(effect <= 15)
			M.adjustToxLoss(1)

/datum/reagent/mitocholide
	name = "Mitocholide"
	id = "mitocholide"
	description = "A specialized drug that stimulates the mitochondria of cells to encourage healing of internal organs."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/mitocholide/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
		for(var/name in H.internal_organs)
			var/obj/item/organ/internal/I = H.get_int_organ(name)
			if(I.damage > 0)
				I.damage = max(I.damage-0.4, 0)
	..()

/datum/reagent/mitocholide/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/Org = O
		Org.rejuvenate()

/datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#0000C8" // rgb: 200, 165, 220
	heart_rate_decrease = 1

/datum/reagent/cryoxadone/on_mob_life(mob/living/M)
	if(M.bodytemperature < 265)
		M.adjustCloneLoss(-4)
		M.adjustOxyLoss(-10)
		M.adjustToxLoss(-3)
		M.adjustBruteLoss(-12)
		M.adjustFireLoss(-12)
		M.status_flags &= ~DISFIGURED
	..()

/datum/reagent/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30

/datum/reagent/rezadone/on_mob_life(mob/living/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.adjustCloneLoss(-1) //What? We just set cloneloss to 0. Why? Simple; this is so external organs properly unmutate.
	M.adjustBruteLoss(-1)
	M.adjustFireLoss(-1)
	M.status_flags &= ~DISFIGURED
	..()

/datum/reagent/rezadone/overdose_process(mob/living/M, severity)
	M.adjustToxLoss(1)
	M.Dizzy(5)
	M.Jitter(5)

/datum/reagent/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antibiotic agent extracted from space fungus."
	reagent_state = LIQUID
	color = "#0AB478"
	metabolization_rate = 0.2