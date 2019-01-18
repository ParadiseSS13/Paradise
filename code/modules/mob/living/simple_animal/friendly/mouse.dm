/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	icon_resting = "mouse_gray_sleep"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeaks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	var/squeak_sound = 'sound/effects/mousesqueek.ogg'
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = 0
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	var/mouse_color //brown, gray and white, leave blank for random
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	can_hide = 1
	holder_type = /obj/item/holder/mouse
	can_collar = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

/mob/living/simple_animal/mouse/Initialize()
	. = ..()

/mob/living/simple_animal/mouse/handle_automated_speech()
	..()
	if(prob(speak_chance))
		for(var/mob/M in view())
			M << squeak_sound

/mob/living/simple_animal/mouse/Life(seconds, times_fired)
	. = ..()
	if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = "mouse_[mouse_color]"
			wander = 1
		else if(prob(5))
			emote("snuffles")

/mob/living/simple_animal/mouse/process_ai()
	..()

	if(prob(0.5))
		stat = UNCONSCIOUS
		icon_state = "mouse_[mouse_color]_sleep"
		wander = 0
		speak_chance = 0

/mob/living/simple_animal/mouse/New()
	..()
	if(!mouse_color)
		mouse_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"
	desc = "It's a small [mouse_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

/mob/living/simple_animal/mouse/proc/splat()
	playsound(src, squeak_sound, 40, 1)
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[mouse_color]_splat"
	src.icon_state = "mouse_[mouse_color]_splat"
	layer = MOB_LAYER
	if(client)
		client.time_died_as_mouse = world.time

/mob/living/simple_animal/mouse/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/simple_animal/mouse/start_pulling(var/atom/movable/AM)//Prevents mouse from pulling things
	to_chat(src, "<span class='warning'>You are too small to pull anything.</span>")
	return

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if(ishuman(AM))
		if(stat == CONSCIOUS)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")
			SEND_SOUND(M, squeak_sound)
	..()

/mob/living/simple_animal/mouse/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	layer = MOB_LAYER
	if(client)
		client.time_died_as_mouse = world.time

/mob/living/simple_animal/mouse/emote(act, m_type=1, message = null)
	if(stat != CONSCIOUS)
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("squeak")		//Mouse time
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(on_CD == 1)
		return

	switch(act)
		if("squeak")
			message = "<B>\The [src]</B> squeaks!"
			m_type = 2 //audible
			playsound(src, squeak_sound, 40, 1)
		if("help")
			to_chat(src, "scream, squeak")

	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	mouse_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	mouse_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	mouse_color = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID


/mob/living/simple_animal/mouse/blobinfected
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	var/cycles_alive = 0
	var/cycles_limit = 30
	var/has_burst = FALSE

/mob/living/simple_animal/mouse/blobinfected/Life()
	cycles_alive++
	var/timeleft = (cycles_limit - cycles_alive) * 2
	if(ismob(loc)) // if someone ate it, burst immediately
		burst(FALSE)
	else if(timeleft < 1) // if timer expired, burst.
		burst(FALSE)
	else if(cycles_alive % 2 == 0) // give the mouse/player a countdown reminder every 2 cycles
		to_chat(src, "<span class='warning'>[timeleft] seconds until you burst, and become a blob...</span>")
	return ..()

/mob/living/simple_animal/mouse/blobinfected/death(gibbed)
	burst(gibbed)
	return ..(gibbed)

/mob/living/simple_animal/mouse/blobinfected/proc/burst(gibbed)
	if(has_burst)
		return FALSE
	var/turf/T = get_turf(src)
	if(!is_station_level(T.z) || isspaceturf(T))
		to_chat(src, "<span class='userdanger'>You feel ready to burst, but this isn't an appropriate place!  You must return to the station!</span>")
		return FALSE
	has_burst = TRUE
	var/datum/mind/blobmind = mind
	var/client/C = client
	if(istype(blobmind) && istype(C))
		blobmind.special_role = SPECIAL_ROLE_BLOB
		var/obj/structure/blob/core/core = new(T, 200, C, 3)
		core.lateblobtimer()
	else
		new /obj/structure/blob/core(T) // Ghosts will be prompted to control it.
	if(ismob(loc)) // in case some taj/etc ate the mouse.
		var/mob/M = loc
		M.gib()
	if(!gibbed)
		gib()

/mob/living/simple_animal/mouse/blobinfected/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>You try to pick up [src], but they slip out of your grasp!</span>")
	to_chat(src, "<span class='warning'>[src] tries to pick you up, but you wriggle free of their grasp!</span>")

/mob/living/simple_animal/mouse/fluff/clockwork
	name = "Chip"
	real_name = "Chip"
	mouse_color = "clockwork"
	icon_state = "mouse_clockwork"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	can_collar = 0
	butcher_results = list(/obj/item/stack/sheet/metal = 1)