/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating an aggressive arachnid which will regard us as a friend."
	helptext = "The spiders are thoughtless creatures, but will not attack their creators. Requires at least 5 stored DNA."
	button_icon_state = "spread_infestation"
	chemical_cost = 5//45
	dna_cost = 1
	req_dna = 0//5
	var/spider_counter = 0 // This var keeps track of the changeling's spider count
	var/is_operating = FALSE // Checks if changeling is already spawning a spider
	power_type = CHANGELING_PURCHASABLE_POWER

//Makes some spiderlings. Good for setting traps and causing general trouble.
/datum/action/changeling/spiders/sting_action(mob/user)
	if(is_operating == TRUE) // To stop spawning multiple at once
		return FALSE
	is_operating = TRUE
	if(spider_counter >= 3)
		to_chat(user, "<span class='warning'>We cannot sustain more than three spiders!</span>")
		is_operating = FALSE
		return FALSE
	user.visible_message("<span class='danger'>[user] begins vomiting an arachnid!</span>")
	if(do_after(user, 4 SECONDS, FALSE, target = user)) // Takes 5 seconds to spawn a spider
		spider_counter++
		user.visible_message("<span class='danger'>[user] vomits an arachnid!</span>")
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
	var/gibbed = FALSE // To check if the spider died via gib or if it still needs to be gibbed, to prevent post-death revival
	var/currentOrder = 0
	var/list/enemies = list() // BIG AAAA TEST FOR RETALIATE
	venom_per_bite = 3
	speak_chance = 0
	wander = 0

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/gib()
	gibbed = TRUE
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/death()
	if(!gibbed)
		gib()
		return
	var/mob/owner_mob = locateUID(owner_UID)
	var/datum/action/changeling/spiders/S = locate() in owner_mob.actions
	S.spider_counter--
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/examine(mob/user)
	. = ..()
	if(user.UID() == owner_UID)
		. += "<span class='notice'>It is currently angy!</span>"

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/AltShiftClick(mob/user)
	. = ..()
	if(user.UID() == owner_UID)
		spider_order(user)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/spider_order(mob/user)
	switch(currentOrder)
		if(0)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us but attack anything on sight.</span>")
			currentOrder = 1
		if(1)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us and stay calm, only attacking if we or it are attacked.</span>")
			currentOrder = 2
		if(2)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle and calm, only attacking if we or it are attacked.</span>")
			currentOrder = 3
		if(3)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle but attack anything on sight.</span>")
			currentOrder = 0
	handle_automated_movement()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	var/list/around = view(src, vision_range)
	switch(currentOrder)
		if(0)
			Find_Enemies()
			walk(src,0)
			return TRUE
		if(1)
			Find_Enemies()
			if(!busy)
				for(var/mob/living/carbon/C in around)
					if(faction_check_mob(C))
						if(Adjacent(C))
							return TRUE
						//stop_automated_movement = TRUE
						Goto(C, 0.5 SECONDS, 1)
						//stop_automated_movement = FALSE
				return TRUE
		if(2)
			if(!busy)
				for(var/mob/living/carbon/C in around)
					if(faction_check_mob(C))
						if(Adjacent(C))
							return TRUE
						//stop_automated_movement = TRUE
						Goto(C, 0.5 SECONDS, 1)
						//stop_automated_movement = FALSE
				//walk(src,0)
				return TRUE
		if(3)
			walk(src,0)
			return TRUE

	for(var/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/H in around)
		if(faction_check_mob(H) && !attack_same && !H.attack_same)
			H.enemies |= enemies

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/ListTargets()
	if(!enemies.len)
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see

// Aaaaaaaaaaaaaaaaaaaaaaa

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/Find_Enemies()
	var/list/around = view(src, vision_range)
	enemies -= enemies // Reset enemies list, only focus on the ones around you, spiders don't have grudges
	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/M = A
			if(!faction_check_mob(M))
				enemies |= M

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attackby(obj/item/W, mob/user, params)
	..()
	if(!faction_check_mob(user))
		enemies |= user
