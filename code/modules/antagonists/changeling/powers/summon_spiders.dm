/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating an aggressive arachnid which will regard us as a friend. Costs 30 chemicals."
	helptext = "The spiders are thoughtless creatures, but will not attack their creators. Their orders can be changed via remote hivemind (Alt+Shift click)."
	button_icon_state = "spread_infestation"
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
	if(do_after(user, 4 SECONDS, FALSE, target = user, hidden = TRUE)) // Takes 4 seconds to spawn a spider
		spider_counter++
		user.visible_message("<span class='danger'>[user] vomits up an arachnid!</span>")
		var/mob/living/basic/giant_spider/hunter/infestation_spider/S = new(user.loc)
		S.owner_UID = user.UID()
		S.ai_controller.set_blackboard_key(BB_CURRENT_PET_TARGET, user)
		S.ai_controller.set_blackboard_key(BB_CHANGELING_SPIDER_ORDER, IDLE_AGGRESSIVE)
		S.befriend(user)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
		is_operating = FALSE
		return TRUE
	is_operating = FALSE
	return FALSE

/// Child of giant_spider because this should do everything the spider does and more
/mob/living/basic/giant_spider/hunter/infestation_spider
	/// References to the owner changeling
	var/mob/owner_UID
	/// Handles the spider's behavior
	var/current_order = IDLE_AGGRESSIVE
	sentience_type = SENTIENCE_OTHER
	venom_per_bite = 3
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/giant_spider/changeling
	/// To check and gib the spider when dead, then remove only one of the counter for the changeling owner
	var/gibbed = FALSE

/mob/living/basic/giant_spider/hunter/infestation_spider/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

//These two below are needed to both gib the spider always, and even if it was gibbed only remove 1 from the counter of spider_counter instead of death's gib calling death again and removing 2
/mob/living/basic/giant_spider/hunter/infestation_spider/gib()
	gibbed = TRUE
	return ..()

/mob/living/basic/giant_spider/hunter/infestation_spider/death(gibbed)
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

/mob/living/basic/giant_spider/hunter/infestation_spider/examine(mob/user)
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

/mob/living/basic/giant_spider/hunter/infestation_spider/AltShiftClick(mob/user)
	. = ..()
	if(user.UID() != owner_UID)
		return
	var/list/possible_orders = list("Escort", "Escort Aggressively", "Idle", "Idle Aggressively")
	var/new_order = tgui_input_list(user, "How do you want your spiders to behave?", "Spider Orders", possible_orders)
	switch(new_order)
		if("Escort")
			current_order = FOLLOW_RETALIATE
		if("Escort Aggressively")
			current_order = FOLLOW_AGGRESSIVE
		if("Idle")
			current_order = IDLE_RETALIATE
		if("Idle Aggressively")
			current_order = IDLE_AGGRESSIVE
	spider_order(user)

/mob/living/basic/giant_spider/hunter/infestation_spider/proc/spider_order(mob/user)
	switch(current_order)
		if(FOLLOW_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us but attack anyone on sight.</span>")
			ai_controller.set_blackboard_key(BB_CHANGELING_SPIDER_ORDER, FOLLOW_AGGRESSIVE)
		if(FOLLOW_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to follow us and to remain calm, only attacking if it is attacked.</span>")
			ai_controller.set_blackboard_key(BB_CHANGELING_SPIDER_ORDER, FOLLOW_RETALIATE)
		if(IDLE_RETALIATE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle and calm, only attacking if it is attacked.</span>")
			ai_controller.set_blackboard_key(BB_CHANGELING_SPIDER_ORDER, IDLE_RETALIATE)
		if(IDLE_AGGRESSIVE)
			to_chat(user, "<span class='notice'>We order the giant spider to remain idle, but ready to attack anyone on sight.</span>")
			ai_controller.set_blackboard_key(BB_CHANGELING_SPIDER_ORDER, IDLE_AGGRESSIVE)
