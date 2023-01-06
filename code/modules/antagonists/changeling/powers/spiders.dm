/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating an aggressive arachnid which will regard us as a friend."
	helptext = "The spiders are thoughtless creatures, but will not attack their creators. Requires at least 5 stored DNA."
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 1
	req_dna = 5
	var/spider_counter = 0 // This var keeps track of the changeling's spider count
	var/is_operating = FALSE // Checks if changeling is already spawning a spider
	power_type = CHANGELING_PURCHASABLE_POWER

//Makes some spiderlings. Good for setting traps and causing general trouble.
/datum/action/changeling/spiders/sting_action(mob/user)
	if(is_operating == TRUE) // To stop spawning multiple at once
		return FALSE
	is_operating = TRUE
	if(spider_counter > 4)
		to_chat(user, "<span class='warning'>We cannot sustain more than five spiders!</span>")
		is_operating = FALSE
		return FALSE
	user.visible_message("<span class='danger'>[user] begins vomiting an arachnid!</span>")
	if(do_after(user, 5 SECONDS, FALSE, target = user)) // Takes 5 seconds to spawn a spider
		spider_counter++
		var/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/S = new(user.loc)
		S.owner_UID = user.UID()
		S.faction |= list("spiders", "\ref[owner]") // Makes them friendly only to the owner & other spiders
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
		is_operating = FALSE
		return TRUE
	is_operating = FALSE
	return FALSE

// Child of giant_spider because this should do everything the spider does and more
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider
	var/mob/owner_UID // References to the owner changeling
	venom_per_bite = 3

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/death()
	var/mob/owner_mob = locateUID(owner_UID)
	var/datum/action/changeling/spiders/S = locate() in owner_mob.actions
	S.spider_counter--
	return ..()
