/datum/action/changeling/superhuman
	name = "Superhuman Physiology"
	desc = "We combine the fighting knowledge of the hivemind and our enhanced biological strength to form a potent martial art that makes use of our unique abilty to create weapons."
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
