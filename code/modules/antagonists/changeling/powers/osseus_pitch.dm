/datum/action/changeling/osseus
	name = "Osseus Pitch"
	desc = "We evolve the ability to break off shards of our bone, and shape them into throwing weapons to embed into our foes. Costs 20 chemicals."
	helptext = "The shards of bone will dull upon hitting a target, rendering them unusable as weapons."
	button_icon_state = "digital_camo"
	chemical_cost = 20
	dna_cost = 3
	req_human = TRUE
	power_type = CHANGELING_PURCHASABLE_POWER
	menu_location = CLING_MENU_ATTACK

/datum/action/changeling/osseus/sting_action(mob/living/user)
