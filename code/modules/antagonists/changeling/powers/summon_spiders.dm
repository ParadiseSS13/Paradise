#define IDLE_AGGRESSIVE 0
#define FOLLOW_AGGRESSIVE 1
#define FOLLOW_RETALIATE 2
#define IDLE_RETALIATE 3

/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating an aggressive arachnid which will regard us as a friend. Costs 30 chemicals."
	helptext = "The spiders are thoughtless creatures, but will not attack their creators. Their orders can be changed via remote hivemind (Alt+Shift click)."
	button_overlay_icon_state = "spread_infestation"
	chemical_cost = 30
	dna_cost = 4
	/// This var keeps track of the changeling's spider count
	var/spider_counter = 0
	/// Checks if changeling is already spawning a spider
	var/is_operating = FALSE
	power_type = CHANGELING_PURCHASABLE_POWER
	category = /datum/changeling_power_category/offence

/// Makes a spider. Good for setting traps and combat.
/datum/action/changeling/spiders/sting_action(mob/user)
	if(is_operating) // To stop spawning multiple at once
		return FALSE
	is_operating = TRUE
	if(spider_counter >= 3)
		to_chat(user, "<span class='warning'>We cannot sustain more than three spiders!</span>")
		is_operating = FALSE
		return FALSE
	user.visible_message("<span class='danger'>[user] begins vomiting an arachnid!</span>")
	if(do_after(user, 4 SECONDS, FALSE, target = user)) // Takes 4 seconds to spawn a spider
		spider_counter++
		user.visible_message("<span class='danger'>[user] vomits up an arachnid!</span>")
		var/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/S = new(user.loc)
		S.owner_UID = user.UID()
		S.faction |= list("spiders", "\ref[owner]") // Makes them friendly only to the owner & other spiders
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
		is_operating = FALSE
		return TRUE
	is_operating = FALSE
	return FALSE

/// Child of giant_spider because this should do everything the spider does and more
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider
	/// References to the owner changeling
	var/mob/owner_UID
	/// Handles the spider's behavior
	var/current_order = IDLE_AGGRESSIVE
	var/list/enemies = list()
	sentience_type = SENTIENCE_OTHER
	venom_per_bite = 3
	speak_chance = 0
	wander = 0
	gold_core_spawnable = NO_SPAWN
	/// To check and gib the spider when dead, then remove only one of the counter for the changeling owner
	var/gibbed = FALSE

//These two below are needed to both gib the spider always, and even if it was gibbed only remove 1 from the counter of spider_counter instead of death's gib calling death again and removing 2
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/gib()
	gibbed = TRUE
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/death(gibbed)
	var/mob/owner_mob = locateUID(owner_UID)
	if(!ismob(owner_mob))
		return ..(TRUE)
	var/datum/action/changeling/spiders/S = locate() in owner_mob.actions
	if(!isnull(S))
		if(gibbed)
			S.spider_counter--
	if(!gibbed)
		gib()
	return ..(TRUE)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/examine(mob/user)
	. = ..()
	if(user.UID() != owner_UID)
		return
	switch(current_order)
		if(IDLE_AGGRESSIVE)
			. += "<span class='notice'>The giant spider will remain idle but will attack anyone on sight.</span>"
		if(FOLLOW_AGGRESSIVE)
			. += "<span class='notice'>The giant spider is following us, but will attack anyone on sight.</span>"
		if(FOLLOW_RETALIATE)
			. += "<span class='notice'>The giant spider is following us and staying calm, only attacking if it is attacked.</span>"
		if(IDLE_RETALIATE)
			. += "<span class='notice'>The giant spider will remain idle and calm, only attacking if it is attacked.</span>"

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/AltShiftClick(mob/user)
	. = ..()
	if(user.UID() != owner_UID)
		return
	spider_order(user)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/spider_order(mob/user)
	enemies = list()
	switch(current_order)
		if(IDLE_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us but attack anyone on sight.</span>")
			current_order = FOLLOW_AGGRESSIVE
		if(FOLLOW_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us and to remain calm, only attacking if it is attacked.</span>")
			current_order = FOLLOW_RETALIATE
		if(FOLLOW_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle and calm, only attacking if it is attacked.</span>")
			current_order = IDLE_RETALIATE
		if(IDLE_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle, but ready to attack anyone on sight.</span>")
			current_order = IDLE_AGGRESSIVE
	handle_automated_movement()

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	var/list/around = view(src, vision_range)
	switch(current_order)
		if(IDLE_AGGRESSIVE)
			Find_Enemies(around)
			walk(src, 0)
		if(FOLLOW_AGGRESSIVE)
			Find_Enemies(around)
			for(var/mob/living/carbon/C in around)
				if(!faction_check_mob(C))
					continue
				if(Adjacent(C))
					return TRUE
				Goto(C, 0.5 SECONDS, 1)
		if(FOLLOW_RETALIATE)
			for(var/mob/living/carbon/C in around)
				if(!faction_check_mob(C))
					continue
				if(Adjacent(C))
					return TRUE
				Goto(C, 0.5 SECONDS, 1)
		if(IDLE_RETALIATE)
			walk(src, 0)

	for(var/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/H in around)
		if(faction_check_mob(H) && !attack_same && !H.attack_same)
			H.enemies |= enemies

	return TRUE

// Bellow is the way the spiders react and retaliate when in an idle/aggresive mode.

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/ListTargets()
	if(!length(enemies))
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/proc/Find_Enemies(around)
	enemies = list() // Reset enemies list, only focus on the ones around you, spiders don't have grudges
	for(var/mob/living/A in around)
		if(A == src)
			continue
		if(!isliving(A))
			continue
		var/mob/living/M = A
		if(!faction_check_mob(M))
			enemies |= M

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(W.force == 0)
		return
	if(!faction_check_mob(user))
		enemies |= user

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/bullet_act(obj/item/projectile/P)
	. = ..()
	if(!faction_check_mob(P.firer))
		enemies |= P.firer

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_alien(mob/living/carbon/alien/user)
	. = ..()
	if(user.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(user))
		enemies |= user

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(M.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(M))
		enemies |= M

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/infestation_spider/attack_hand(mob/living/carbon/human/H)
	. = ..()
	if(H.a_intent == INTENT_HELP)
		return
	if(!faction_check_mob(H))
		enemies |= H

#undef IDLE_AGGRESSIVE
#undef FOLLOW_AGGRESSIVE
#undef FOLLOW_RETALIATE
#undef IDLE_RETALIATE
