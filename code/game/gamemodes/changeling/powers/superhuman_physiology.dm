/datum/action/changeling/superhuman
	name = "Superhuman Physiology"
	helptext = "We may toggle our superhuman biology on and off to avoid detection."
	desc = "We combine the fighting knowledge of the hivemind and our enhanced biological strength to form a potent martial art that makes use of our unique abilty to create weapons. Costs 30 chemicals to toggle"
	dna_cost = 3
	req_human = 0
	needs_button = FALSE
	var/datum/martial_art/superhuman/style = new

/datum/action/changeling/superhuman/on_purchase(mob/user)
	style.teach(user,1)
	return TRUE

/datum/action/changeling/superhuman/Remove(mob/user)
	style.remove(user)
	return TRUE
