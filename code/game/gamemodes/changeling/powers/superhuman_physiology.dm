/datum/action/changeling/superhuman
	name = "Superhuman Physiology"
	desc = "We utilize the pooled knowledge of the hivemind and our enhanced physiology to further weaponize our unique abilities into a dynamic fighting style."
	dna_cost = 3
	req_human = FALSE
	needs_button = FALSE
	var/datum/martial_art/superhuman/style = new

/datum/action/changeling/superhuman/on_purchase(mob/user)
	style.teach(user, TRUE)
	return TRUE

/datum/action/changeling/superhuman/Remove(mob/user)
	style.remove(user)
	return TRUE
