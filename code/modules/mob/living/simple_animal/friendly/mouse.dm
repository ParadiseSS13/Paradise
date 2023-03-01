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
	var/squeak_sound = 'sound/creatures/mouse_squeak.ogg'
	talk_sound = list('sound/creatures/rat_talk.ogg')
	damaged_sound = list('sound/creatures/rat_wound.ogg')
	death_sound = 'sound/creatures/rat_death.ogg'
	tts_seed = "Gyro"
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = 0
	ventcrawler = 2
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	var/mouse_color //brown, gray and white, leave blank for random
	var/non_standard = FALSE //for no "mouse_" with mouse_color
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	can_hide = 1
	holder_type = /obj/item/holder/mouse
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list("[squeak_sound]" = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability) && isturf(loc))
		var/turf/simulated/floor/F = get_turf(src)
		if(istype(F) && !F.intact)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message("<span class='warning'>[src] chews through [C]. It's toast!</span>")
					playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
					toast() // mmmm toasty.
				else
					visible_message("<span class='warning'>[src] chews through [C].</span>")
				investigate_log("was chewed through by a mouse at [COORD(F)]", INVESTIGATE_WIRES)
				C.deconstruct()

/mob/living/simple_animal/mouse/handle_automated_speech()
	..()
	if(prob(speak_chance) && !incapacitated())
		playsound(src, squeak_sound, 100, 1)

/mob/living/simple_animal/mouse/handle_automated_movement()
	. = ..()
	if(resting)
		if(prob(1))
			StopResting()
		else if(prob(5))
			custom_emote(2, "snuffles")
	else if(prob(0.5))
		StartResting()

/mob/living/simple_animal/mouse/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

	color_pick()

/mob/living/simple_animal/mouse/proc/color_pick()
	if(!mouse_color)
		mouse_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"
	desc = "It's a small [mouse_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

/mob/living/simple_animal/mouse/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()

/mob/living/simple_animal/mouse/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/pet/cat))
		var/mob/living/simple_animal/pet/cat/C = M
		if(C.friendly && C.eats_mice && C.a_intent == INTENT_HARM)
			apply_damage(15, BRUTE) //3x от ХП обычной мыши или полное хп крысы
			visible_message("<span class='danger'>[M.declent_ru(NOMINATIVE)] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!</span>", \
							"<span class='userdanger'>[M.declent_ru(NOMINATIVE)] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!</span>")
			return
	. = ..()

/mob/living/simple_animal/mouse/pull_constraint(atom/movable/AM, show_message = FALSE) //Prevents mouse from pulling things
	if(istype(AM, /obj/item/reagent_containers/food/snacks/cheesewedge))
		return TRUE // Get dem
	if(show_message)
		to_chat(src, "<span class='warning'>You are too small to pull anything except cheese.</span>")
	return FALSE

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")
	..()

/mob/living/simple_animal/mouse/ratvar_act()
	new/mob/living/simple_animal/mouse/clockwork(loc)
	gib()

/mob/living/simple_animal/mouse/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()

/mob/living/simple_animal/mouse/proc/splat(var/obj/item/item = null, var/mob/living/user = null)
	if(non_standard)
		var/temp_state = initial(icon_state)
		icon_dead = "[temp_state]_splat"
		icon_state = "[temp_state]_splat"
	else
		icon_dead = "mouse_[mouse_color]_splat"
		icon_state = "mouse_[mouse_color]_splat"

	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(item)
			item.add_mob_blood(src)
		if(user)
			user.add_mob_blood(src)

/mob/living/simple_animal/mouse/death(gibbed)
	if(gibbed)
		make_remains()

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	layer = MOB_LAYER

/mob/living/simple_animal/mouse/proc/make_remains()
	var/obj/effect/decal/remains = new /obj/effect/decal/remains/mouse(src.loc)
	remains.pixel_x = pixel_x
	remains.pixel_y = pixel_y

/mob/living/simple_animal/mouse/emote(act, m_type = 1, message = null, force)
	if(stat != CONSCIOUS)
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("squeak")		//Mouse time
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(!force && on_CD == 1)
		return

	switch(act)
		if("squeak")
			message = "[pick(emote_hear)]!"
			m_type = 2 //audible
			playsound(src, squeak_sound, 40, 1)
		if("help")
			to_chat(src, "scream, squeak")
			playsound(src, damaged_sound, 40, 1)

	..()

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	mouse_color = "white"
	icon_state = "mouse_white"
	tts_seed = "Meepo"

/mob/living/simple_animal/mouse/gray
	mouse_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	mouse_color = "brown"
	icon_state = "mouse_brown"
	tts_seed = "Clockwerk"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	tts_seed = "Arthas"
	maxHealth = 10
	health = 10


/mob/living/simple_animal/mouse/blobinfected
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	gold_core_spawnable = NO_SPAWN
	var/cycles_alive = 0
	var/cycles_limit = 60
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
	gold_core_spawnable = NO_SPAWN
	can_collar = 0
	butcher_results = list(/obj/item/stack/sheet/metal = 1)
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["wood"] += 2
		C.stored_comms["glass"] += 2
		qdel(src)
		return TRUE
	return ..()

/mob/living/simple_animal/mouse/rat
	name = "rat"
	real_name = "rat"
	desc = "Крыса. Рожа у неё хитрая и знакомая..."
	squeak_sound = 'sound/creatures/rat_squeak.ogg'
	icon_state 		= "rat_gray"
	icon_living 	= "rat_gray"
	icon_dead 		= "rat_gray_dead"
	icon_resting 	= "rat_gray_sleep"
	non_standard = TRUE
	mouse_color = null
	maxHealth = 15
	health = 15

/mob/living/simple_animal/mouse/rat/color_pick()
	if(!mouse_color)
		mouse_color = pick(list("gray","white","irish"))
		icon_state 		= "rat_[mouse_color]"
		icon_living 	= "rat_[mouse_color]"
		icon_dead 		= "rat_[mouse_color]_dead"
		icon_resting 	= "rat_[mouse_color]_sleep"

/mob/living/simple_animal/mouse/rat/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE

/mob/living/simple_animal/mouse/rat/gray
	name = "gray rat"
	real_name = "gray rat"
	desc = "Серая крыса. Не яркий представитель своего вида."
	mouse_color = "gray"

/mob/living/simple_animal/mouse/rat/white
	name = "white rat"
	real_name = "white rat"
	desc = "Типичный представитель лабораторных крыс."
	icon_state 		= "rat_white"
	icon_living 	= "rat_white"
	icon_dead 		= "rat_white_dead"
	icon_resting 	= "rat_white_sleep"
	mouse_color = "white"

/mob/living/simple_animal/mouse/rat/irish
	name = "irish rat"		//Да, я знаю что это вид. Это каламбурчик.
	real_name = "irish rat"
	desc = "Ирландская крыса. На космической станции?! На этот раз им точно некуда бежать!"
	icon_state 		= "rat_irish"
	icon_living 	= "rat_irish"
	icon_dead 		= "rat_irish_dead"
	icon_resting 	= "rat_irish_sleep"
	mouse_color = "irish"

#define MAX_HAMSTER 50
GLOBAL_VAR_INIT(hamster_count, 0)

/mob/living/simple_animal/mouse/hamster
	name = "хомяк"
	real_name = "хомяк"
	desc = "С надутыми щечками."
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	icon_resting = "hamster_rest"
	gender = MALE
	non_standard = TRUE
	speak_chance = 0
	childtype = list(/mob/living/simple_animal/mouse/hamster/baby)
	animal_species = /mob/living/simple_animal/mouse/hamster
	holder_type = /obj/item/holder/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	tts_seed = "Gyro"
	maxHealth = 10
	health = 10

/mob/living/simple_animal/mouse/hamster/color_pick()
	return

/mob/living/simple_animal/mouse/hamster/New()
	gender = prob(80) ? MALE : FEMALE
	desc += MALE ? " Самец!" : " Самочка! Ох... Нет... "
	GLOB.hamster_count++
	. = ..()

/mob/living/simple_animal/mouse/hamster/Destroy()
	GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/death(gibbed)
	if(!gibbed)
		GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/pull_constraint(atom/movable/AM, show_message = FALSE)
	return TRUE

/mob/living/simple_animal/mouse/hamster/Life(seconds, times_fired)
	..()
	if(GLOB.hamster_count < MAX_HAMSTER)
		make_babies()

/mob/living/simple_animal/mouse/hamster/baby
	name = "хомячок"
	real_name = "хомячок"
	desc = "Очень миленький! Какие у него пушистые щечки!"
	tts_seed = "Meepo"
	turns_per_move = 2
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	response_help  = "полапал"
	response_disarm = "аккуратно отодвинул"
	response_harm   = "наступил на"
	attacktext = "толкается"
	transform = matrix(0.7, 0, 0, 0, 0.7, 0)
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	can_hide = 1
	can_collar = 0
	holder_type = /obj/item/holder/hamster

/mob/living/simple_animal/mouse/hamster/baby/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(show_message)
		to_chat(src, "<span class='warning'>Вы слишком малы чтобы что-то тащить.</span>")
	return

/mob/living/simple_animal/mouse/hamster/baby/Life(seconds, times_fired)
	. =..()
	if(.)
		amount_grown++
		if(amount_grown >= 100)
			var/mob/living/simple_animal/A = new /mob/living/simple_animal/mouse/hamster(loc)
			if(mind)
				mind.transfer_to(A)
			qdel(src)

/mob/living/simple_animal/mouse/hamster/baby/Crossed(AM as mob|obj, oldloc)
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, "<span class='notice'>[bicon(src)] раздавлен!</span>")
			death()
			splat(user = AM)
	..()
