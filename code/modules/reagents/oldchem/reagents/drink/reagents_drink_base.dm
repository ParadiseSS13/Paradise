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
	var/adj_temp = 0

/datum/reagent/drink/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	if (adj_dizzy) M.dizziness = max(0,M.dizziness + adj_dizzy)
	if (adj_drowsy)	M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if (adj_sleepy) M.sleeping = max(0,M.sleeping + adj_sleepy)
	if (adj_temp)
		if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
			M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
	// Drinks should be used up faster than other reagents.
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	..()
	return
