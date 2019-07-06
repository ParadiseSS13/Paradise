/*
//////////////////////////////////////
Sensory-Restoration
	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal.
Bonus
	The body generates Sensory restorational chemicals.
	oculine for ears
	antihol for removal of alcohol
	synaptizine to purge sensory hallucigens
	mannitol to kickstart the mind

//////////////////////////////////////
*/
/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	desc = "The virus stimulates the production and replacement of sensory tissues, causing the host to regenerate eyes and ears when damaged."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmittable = 2
	level = 4
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/sensory_restoration/Start(datum/disease/advance/A)
	..()
	if(A.properties["resistance"] >= 6) //heal brain damage
		brain_heal = TRUE
	if(A.properties["transmittable"] >= 8) //purge alcohol
		purge_alcohol = TRUE

/datum/symptom/sensory_restoration/Activate(var/datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/obj/item/organ/internal/eyes/E = M.get_int_organ(/obj/item/organ/internal/eyes)
	if(A.stage >= 2)
		M.AdjustEarDamage(-2)
		E.heal_internal_damage(2)
	if(A.stage >= 3)
		M.AdjustDizzy(-2)
		M.AdjustDrowsy(-2)
		M.AdjustSlur(-2)
		M.AdjustConfused(-2)
		if(purge_alcohol)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.AdjustDrunk(-5)

	if(A.stage >= 4)
		M.AdjustDrowsy(-2)
		if(M.reagents.has_reagent("lsd"))
			M.reagents.remove_reagent("lsd", 5)
		if(M.reagents.has_reagent("histamine"))
			M.reagents.remove_reagent("histamine", 5)
		M.hallucination = max(0, M.hallucination - 10)

	if(brain_heal && A.stage >= 5)
		M.adjustBrainLoss(-3)