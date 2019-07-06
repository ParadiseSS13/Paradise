/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = -1 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_desc = "<b>Stage Speed 6:</b> Doubles healing speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2

/datum/symptom/heal/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE


/datum/symptom/heal/starlight
	name = "Starlight Condensation"
	desc = "The virus reacts to direct starlight, producing regenerative chemicals. Works best against toxin-based damage."
	stealth = -1
	resistance = -2
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = "<span class='notice'>You miss the feeling of starlight on your skin.</span>"
	var/nearspace_penalty = 0.3
	threshold_desc = "<b>Stage Speed 6:</b> Increases healing speed.<br>\
					  <b>Transmission 6:</b> Removes penalty for only being close to space."

/datum/symptom/heal/starlight/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 6)
		nearspace_penalty = 1
	if(A.properties["stage_rate"] >= 6)
		power = 2

/datum/symptom/heal/starlight/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(istype(get_turf(M), /turf/space))
		return power
	else
		for(var/turf/T in view(M, 2))
			if(istype(T, /turf/space))
				return power * nearspace_penalty

/datum/symptom/heal/starlight/Heal(mob/living/carbon/human/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power
	if(M.getToxLoss() && prob(5))
		to_chat(M, "<span class='notice'>Your skin tingles as the starlight seems to heal you.</span>")

	M.adjustToxLoss(-(4 * heal_amt)) //most effective on toxins

	var/list/parts = M.get_damaged_organs(1, 1)

	if(!parts.len)
		return

	for(var/obj/item/organ/external/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, TRUE))
			M.UpdateDamageIcon()
	return 1

/datum/symptom/heal/starlight/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmittable = -2
	level = 7
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_desc = "<b>Resistance 7:</b> Increases chem removal speed.<br>\
					  <b>Stage Speed 6:</b> Consumed chemicals nourish the host."

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6)
		food_conversion = TRUE
	if(A.properties["resistance"] >= 7)
		power = 2

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.nutrition = M.nutrition + 0.3
		if(prob(2))
			to_chat(M, "<span class='notice'>You feel a mild warmth as your blood purifies itself.</span>")
	return 1

/datum/symptom/heal/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	stealth = 2
	resistance = -1
	stage_speed = -2
	transmittable = -1
	level = 6
	passive_message = "<span class='notice'>You feel tingling on your skin as light passes over it.</span>"
	threshold_desc = "<b>Stage Speed 8:</b> Doubles healing speed."

/datum/symptom/heal/darkness/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8)
		power = 2

/datum/symptom/heal/darkness/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	var/light_amount = 0
	if(isturf(M.loc)) //else, there's considered to be no light
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount < 2)
			return power

/datum/symptom/heal/darkness/Heal(mob/living/carbon/human/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_organs(1, 1)

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>The darkness soothes and mends your wounds.</span>")

	for(var/obj/item/organ/external/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len * 0.5, null, TRUE)) //more effective on brute
			M.UpdateDamageIcon()
	return 1

/datum/symptom/heal/darkness/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/water
	name = "Tissue Hydration"
	desc = "The virus uses excess water inside and outside the body to repair damaged tissue cells. More effective when using holy water and against burns."
	stealth = 0
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 6
	passive_message = "<span class='notice'>Your skin feels oddly dry...</span>"
	var/absorption_coeff = 1
	threshold_desc = "<b>Resistance 5:</b> Water is consumed at a much slower rate.<br>\
					  <b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/water/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		power = 2
	if(A.properties["resistance"] >= 5)
		absorption_coeff = 0.25

/datum/symptom/heal/water/CanHeal(datum/disease/advance/A)
	. = 0
	var/mob/living/M = A.affected_mob
	if(M.fire_stacks < 0)
		M.fire_stacks = min(M.fire_stacks + 1 * absorption_coeff, 0)
		. += power
	if(M.reagents.has_reagent("holywater"))
		M.reagents.remove_reagent("holywater", 0.5 * absorption_coeff)
		. += power * 0.75
	else if(M.reagents.has_reagent("water"))
		M.reagents.remove_reagent("water", 0.5 * absorption_coeff)
		. += power * 0.5

/datum/symptom/heal/water/Heal(mob/living/carbon/human/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 2 * actual_power

	var/list/parts = M.get_damaged_organs(1, 1) //more effective on burns

	if(!parts.len)
		return

	if(prob(5))
		to_chat(M, "<span class='notice'>You feel yourself absorbing the water around you to soothe your damaged skin.</span>")

	for(var/obj/item/organ/external/L in parts)
		if(L.heal_damage(heal_amt/parts.len * 0.5, heal_amt/parts.len, null, TRUE))
			M.UpdateDamageIcon()

	return 1

/datum/symptom/heal/water/passive_message_condition(mob/living/M)
	if(M.getBruteLoss() || M.getFireLoss())
		return TRUE
	return FALSE

/datum/symptom/heal/radiation
	name = "Radioactive Resonance"
	desc = "The virus uses radiation to fix damage through dna mutations."
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = -3
	level = 6
	symptom_delay_min = 1
	symptom_delay_max = 1
	passive_message = "<span class='notice'>Your skin glows faintly for a moment.</span>"
	var/cellular_damage = FALSE
	threshold_desc = "<b>Transmission 6:</b> Additionally heals cellular damage.<br>\
					  <b>Resistance 7:</b> Increases healing speed."

/datum/symptom/heal/radiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 7)
		power = 2
	if(A.properties["transmittable"] >= 6)
		cellular_damage = TRUE

/datum/symptom/heal/radiation/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	switch(M.radiation)
		if(0)
			return FALSE
		if(1 to 25)
			return 0.25
		if(25 to 50)
			return 0.5
		if(50 to 75)
			return 0.75
		if(75 to 100)
			return 1
		else
			return 1.5

/datum/symptom/heal/radiation/Heal(mob/living/carbon/human/M, datum/disease/advance/A, actual_power)
	var/heal_amt = actual_power

	if(cellular_damage)
		M.adjustCloneLoss(-heal_amt * 0.5)

	M.adjustToxLoss(-(2 * heal_amt))

	var/list/parts = M.get_damaged_organs(1, 1)

	if(!parts.len)
		return

	if(prob(4))
		to_chat(M, "<span class='notice'>Your skin glows faintly, and you feel your wounds mending themselves.</span>")

	for(var/obj/item/organ/external/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, 1))
			M.UpdateDamageIcon()
	return 1
