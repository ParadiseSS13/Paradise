/datum/reagent/consumable/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	color = "#E78108" // rgb: 231, 129, 8
	taste_description = "something which should not exist"
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0

/datum/reagent/consumable/drink/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(adj_dizzy)
		M.AdjustDizzy(adj_dizzy)
	if(adj_drowsy)
		M.AdjustDrowsy(adj_drowsy)
	if(adj_sleepy)
		M.AdjustSleeping(adj_sleepy)
	return ..() | update_flags
