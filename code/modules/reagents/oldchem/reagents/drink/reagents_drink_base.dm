/datum/reagent/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#E78108" // rgb: 231, 129, 8
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp_hot = 0
	var/adj_temp_cool = 0

/datum/reagent/drink/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if(adj_dizzy)
		M.dizziness = max(0, M.dizziness + adj_dizzy)
	if(adj_drowsy)
		M.drowsyness = max(0, M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.AdjustSleeping(adj_sleepy)
	if(adj_temp_hot)
		if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = min(310, M.bodytemperature + (adj_temp_hot * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp_cool)
		if(M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = max(310, M.bodytemperature - (adj_temp_cool * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()