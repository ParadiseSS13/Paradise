#define IDLE_AGGRESSIVE "0"
#define FOLLOW_AGGRESSIVE "1"
#define FOLLOW_RETALIATE "2"
#define IDLE_RETALIATE "3"

/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating an aggressive arachnid which will regard us as a friend."
	helptext = "The spiders are thoughtless creatures, but will not attack their creators. Requires at least 5 stored DNA. Their orders can be changed via remote hivemind (Alt+Shift click)"
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 2
	req_dna = 7
	var/spider_counter = 0 // This var keeps track of the changeling's spider count
	var/is_operating = FALSE // Checks if changeling is already spawning a spider
	power_type = CHANGELING_PURCHASABLE_POWER

//Makes a spider. Good for setting traps and combat.
/datum/action/changeling/spiders/sting_action(mob/user)
	if(is_operating == TRUE) // To stop spawning multiple at once
		return FALSE
	is_operating = TRUE
	if(spider_counter >= 3)
		to_chat(user, "<span class='warning'>We cannot sustain more than three spiders!</span>")
		is_operating = FALSE
		return FALSE
	user.visible_message("<span class='danger'>[user] begins vomiting an arachnid!</span>")
	if(do_after(user, 4 SECONDS, FALSE, target = user)) // Takes 4 seconds to spawn a spider
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
	var/current_order = IDLE_AGGRESSIVE // Handles the spider's behavior
	var/list/enemies = list()
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
		switch(current_order)
			if(IDLE_AGGRESSIVE)
				. += "<span class='notice'>The giant spider will remain idle but will attack anyone on sight.</span>"
			if(FOLLOW_AGGRESSIVE)
				. += "<span class='notice'>The giant spider is following us, but will attack anyone on sight.</span>"
			if(FOLLOW_RETALIATE)
				. += "<span class='notice'>The giant spider is following us and staying calm, only attacking it is attacked.</span>"
			if(IDLE_RETALIATE)
				. += "<span class='notice'>The giant spider will remain idle and calm, only attacking if it is attacked.</span>"

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/AltShiftClick(mob/user)
	. = ..()
	if(user.UID() == owner_UID)
		spider_order(user)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/spider_order(mob/user)
	enemies = list()
	switch(current_order)
		if(IDLE_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us but attack anyone on sight.</span>")
			current_order = FOLLOW_AGGRESSIVE
		if(FOLLOW_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us and stay calm, only attacking if it is attacked.</span>")
			current_order = FOLLOW_RETALIATE
		if(FOLLOW_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle and calm, only attacking if it is attacked.</span>")
			current_order = IDLE_RETALIATE
		if(IDLE_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle but attack anyone on sight.</span>")
			current_order = IDLE_AGGRESSIVE
	handle_automated_movement()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	var/list/around = view(src, vision_range)
	switch(current_order)
		if(IDLE_AGGRESSIVE)
			Find_Enemies(around)
			walk(src,0)
			return TRUE
		if(FOLLOW_AGGRESSIVE)
			Find_Enemies(around)
			if(!busy)
				for(var/mob/living/carbon/C in around)
					if(faction_check_mob(C))
						if(Adjacent(C))
							return TRUE
						Goto(C, 0.5 SECONDS, 1)
				return TRUE
		if(FOLLOW_RETALIATE)
			if(!busy)
				for(var/mob/living/carbon/C in around)
					if(faction_check_mob(C))
						if(Adjacent(C))
							return TRUE
						Goto(C, 0.5 SECONDS, 1)
				return TRUE
		if(IDLE_RETALIATE)
			walk(src,0)
			return TRUE

	for(var/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/H in around)
		if(faction_check_mob(H) && !attack_same && !H.attack_same)
			H.enemies |= enemies

// Bellow is the way the spiders react and retaliate when in an idle mode.

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/ListTargets()
	if(!length(enemies))
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/Find_Enemies(around)
	enemies = list() // Reset enemies list, only focus on the ones around you, spiders don't have grudges
	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/M = A
			if(!faction_check_mob(M))
				enemies |= M

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attackby(obj/item/W, mob/user, params)
	..()
	if(W.force == 0)
		return
	if(!faction_check_mob(user))
		enemies |= user

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/bullet_act(obj/item/projectile/P)
	..()
	if(!faction_check_mob(P.firer))
		enemies |= P.firer

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_alien(mob/living/carbon/alien/user)
	..()
	if(user.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(user))
		enemies |= user

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_animal(mob/living/simple_animal/M)
	..()
	if(M.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(M))
		enemies |= M

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_hand(mob/living/carbon/human/H)
	..()
	if(H.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(H))
		enemies |= H
