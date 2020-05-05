/datum/reagent/plazmite_venom
	name = "Plazmite venom"
	id = "plazmitevenom"
	description = "A toxic venom injected by lavaland creatures"
	reagent_state = LIQUID
	color = "#0A770A" // rgb: 10, 119, 10
	taste_description = "bitterness"

/datum/reagent/plazmite_venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags
