// Custom human behavior for deadchat control


/mob/living/carbon/human/proc/dchat_emote()
	var/list/possible_emotes = list("scream", "clap", "snap", "crack", "dap", "burp")
	emote(pick(possible_emotes), intentional = TRUE)

/mob/living/carbon/human/proc/dchat_attack(intent)
	var/turf/ahead = get_turf(get_step(src, dir))
	var/atom/victim = locate(/mob/living) in ahead
	var/obj/item/in_hand = get_active_hand()
	var/implement = "[isnull(in_hand) ? "[p_their()] fists" : in_hand]"
	if(!victim)
		victim = locate(/obj/structure) in ahead
	if(!victim)
		switch(intent)
			if(INTENT_HARM)
				visible_message("<span class='warning'>[src] swings [implement] wildly!</span>")
			if(INTENT_HELP)
				visible_message("<span class='notice'>[src] seems to take a deep breath.</span>")
		return
	if(isLivingSSD(victim))
		visible_message("<span class='notice'>[src] [intent == INTENT_HARM ? "reluctantly " : ""]lowers [p_their()] [implement].</span>")
		return

	var/original_intent = a_intent
	a_intent = intent
	if(in_hand)
		in_hand.melee_attack_chain(src, victim)
	else
		UnarmedAttack(victim, TRUE)
	a_intent = original_intent

/mob/living/carbon/human/proc/dchat_resist()
	if(!can_resist())
		visible_message("<span class='warning'>[src] seems to be unable to do anything!</span>")
		return
	if(!restrained())
		visible_message("<span class='notice'>[src] seems to be doing nothing in particular.</span>")
		return

	visible_message("<span class='warning'>[src] is trying to break free!</span>")
	resist()

/mob/living/carbon/human/proc/dchat_pickup()
	var/turf/ahead = get_step(src, dir)
	var/obj/item/thing = locate(/obj/item) in ahead
	if(!thing)
		return

	var/old_loc = thing.loc
	var/obj/item/in_hand = get_active_hand()

	if(in_hand)
		if(in_hand.flags & NODROP)
			visible_message("<span class='warning'>[src] attempts to drop [in_hand], but it seems to be stuck to [p_their()] hand!</span>")
			return
		if(in_hand.flags & ABSTRACT)
			visible_message("<span class='notice'>[src] seems to have [p_their()] hands full!</span>")
			return
		visible_message("<span class='notice'>[src] drops [in_hand] and picks up [thing] instead!</span>")
		unequip(in_hand)
		in_hand.forceMove(old_loc)
	else
		visible_message("<span class='notice'>[src] picks up [thing]!</span>")
	put_in_active_hand(thing)

/mob/living/carbon/human/proc/dchat_throw()
	var/obj/item/in_hand = get_active_hand()
	if(!in_hand || in_hand.flags & ABSTRACT)
		visible_message("<span class='notice'>[src] makes a throwing motion!</span>")
		return
	var/atom/possible_target
	var/cur_turf = get_turf(src)
	for(var/i in 1 to 5)
		cur_turf = get_step(cur_turf, dir)
		possible_target = locate(/mob/living) in cur_turf
		if(possible_target)
			break

		possible_target = locate(/obj/structure) in cur_turf
		if(possible_target)
			break

	if(!possible_target)
		possible_target = cur_turf
	if(in_hand.flags & NODROP)
		visible_message("<span class='warning'>[src] tries to throw [in_hand][isturf(possible_target) ? "" : " towards [possible_target]"], but it won't come off [p_their()] hand!</span>")
		return
	throw_item(possible_target)

/mob/living/carbon/human/proc/dchat_shove()
	var/turf/ahead = get_turf(get_step(src, dir))
	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in ahead
	if(!H)
		visible_message("<span class='notice'>[src] tries to shove something away!</span>")
		return
	dna?.species.disarm(src, H)

/mob/living/carbon/human/proc/dchat_shoot()

	var/atom/possible_target
	var/cur_turf = get_turf(src)
	for(var/i in 1 to 5)
		cur_turf = get_step(cur_turf, dir)
		possible_target = locate(/mob/living) in cur_turf
		if(possible_target)
			break

	if(!possible_target)
		possible_target = cur_turf

	var/obj/item/gun/held_gun = get_active_hand()
	if(!held_gun)
		visible_message("<span class='warning'>[src] makes fingerguns towards [possible_target]!</span>")
		return
	if(!istype(held_gun))
		visible_message("<span class='warning'>[src] points [held_gun] towards [possible_target]!</span>")
		return
	// for his neutral special, he wields a Gun
	held_gun.afterattack__legacy__attackchain(possible_target, src)
	visible_message("<span class='danger'>[src] fires [held_gun][isturf(possible_target) ? "" : " towards [possible_target]!"]</span>")

/mob/living/carbon/human/proc/dchat_step(dir)
	if(length(grabbed_by))
		resist_grab()
	step(src, dir)


/mob/living/carbon/human/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 7 SECONDS)
	var/list/inputs = list(
		"emote" = CALLBACK(src, PROC_REF(dchat_emote)),
		"attack" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HARM),
		"help" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HELP),
		"pickup" = CALLBACK(src, PROC_REF(dchat_pickup)),
		"throw" = CALLBACK(src, PROC_REF(dchat_throw)),
		"disarm" = CALLBACK(src, PROC_REF(dchat_shove)),
		"resist" = CALLBACK(src, PROC_REF(dchat_resist)),
		"shoot" = CALLBACK(src, PROC_REF(dchat_shoot)),
	)

	AddComponent(/datum/component/deadchat_control/human, mode, inputs, cooldown)

