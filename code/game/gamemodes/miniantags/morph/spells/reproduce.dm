/datum/spell/morph_spell/reproduce
	name = "Reproduce"
	desc = "Split yourself in half making a new morph. Can only be used while on a floor. Makes you temporarily unable to vent crawl."
	hunger_cost = 150 // 5 humans
	base_cooldown = 30 SECONDS
	action_icon_state = "morph_reproduce"
	create_attack_logs = FALSE

/datum/spell/morph_spell/reproduce/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/morph_spell/reproduce/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!isturf(user.loc))
		if(show_message)
			to_chat(user, "<span class='warning'>You can only split while on flooring!</span>")
		return FALSE

/datum/spell/morph_spell/reproduce/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, "<span class='sinister'>You prepare to split in two, making you unable to vent crawl!</span>")
	user.ventcrawler = VENTCRAWLER_NONE // Temporarily disable it
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)
	if(!length(candidates))
		to_chat(user, "<span class='warning'>Your body refuses to split at the moment. Try again later.</span>")
		revert_cast(user)
		user.ventcrawler = initial(user.ventcrawler) // re enable the crawling
		return
	var/mob/C = pick(candidates)

	var/mob/living/simple_animal/hostile/morph/new_morph = new /mob/living/simple_animal/hostile/morph(get_turf(user))
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_morph)
	new_morph.make_morph_antag()
	dust_if_respawnable(C)
	user.create_log(MISC_LOG, "Made a new morph using [src]", new_morph)
	user.ventcrawler = initial(user.ventcrawler) // re enable the crawling
