/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 5 stored DNA."
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 1
	req_dna = 5
	power_type = CHANGELING_PURCHASABLE_POWER


/datum/action/changeling/spiders/sting_action(mob/user)
	for(var/i in 1 to 2)
		var/obj/structure/spider/spiderling/spider = new(user.loc)
		spider.grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

