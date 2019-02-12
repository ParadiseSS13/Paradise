/datum/reagent/consumable/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	color = "#E78108" // rgb: 231, 129, 8
	taste_message = "something which should not exist"
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp_hot = 0
	var/adj_temp_cool = 0

/datum/reagent/consumable/drink/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(adj_dizzy)
		M.AdjustDizzy(adj_dizzy)
	if(adj_drowsy)
		M.AdjustDrowsy(adj_drowsy)
	if(adj_sleepy)
		update_flags |= M.AdjustSleeping(adj_sleepy, FALSE)
	if(adj_temp_hot)
		if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = min(310, M.bodytemperature + (adj_temp_hot * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(adj_temp_cool)
		if(M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = max(310, M.bodytemperature - (adj_temp_cool * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..() | update_flags
