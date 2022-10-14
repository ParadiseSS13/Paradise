/obj/effect/proc_holder/spell/targeted/morph_spell/reproduce
	name = "Reproduce"
	desc = "Split yourself in half making a new morph. Can only be used while on a floor. Makes you temporarily unable to vent crawl."
	hunger_cost = 150 // 5 humans
	charge_max = 30 SECONDS
	action_icon_state = "morph_reproduce"
	self_only = TRUE

/obj/effect/proc_holder/spell/targeted/morph_spell/reproduce/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!user.can_reproduce)
		if(show_message)
			to_chat(user, "<span class='warning'>You dont know how to do reproduce!</span>")
		return FALSE
	if(!isturf(user.loc))
		if(show_message)
			to_chat(user, "<span class='warning'>You can only split while on flooring!</span>")
		return FALSE

/obj/effect/proc_holder/spell/targeted/morph_spell/reproduce/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, "<span class='sinister'>You prepare to split in two, making you unable to vent crawl!</span>")
	user.ventcrawler = FALSE // Temporarily disable it
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)
	if(!length(candidates))
		to_chat(user, "<span class='warning'>Your body refuses to split at the moment. Try again later.</span>")
		revert_cast(user)
		user.ventcrawler = initial(user.ventcrawler) // re enable the crawling
		return
	var/mob/C = pick(candidates)
	user.use_food(hunger_cost)
	hunger_cost += 30
	update_name()
	user.update_action_buttons_icon()

	playsound(user, "bonebreak", 75, TRUE)
	var/mob/living/simple_animal/hostile/morph/new_morph = new /mob/living/simple_animal/hostile/morph(get_turf(user))
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_morph)
	new_morph.make_morph_antag()
	add_misc_logs(user, "Made a [new_morph] using [src]")
	user.ventcrawler = initial(user.ventcrawler) // re enable the crawling
