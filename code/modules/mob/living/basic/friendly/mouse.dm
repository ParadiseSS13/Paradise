/mob/living/basic/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	icon_resting = "mouse_gray_sleep"
	speak_emote = list("squeeks","squeaks","squiks")
	var/squeak_sound = 'sound/creatures/mousesqueak.ogg'
	ai_controller = /datum/ai_controller/basic_controller/mouse
	see_in_dark = 6
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/food/meat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "stamps on"
	response_harm_simple = "stamp on"
	faction = list("mouse")
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_TINY
	var/mouse_color // brown, gray and white, leave blank for random
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 223	// Below -50 Degrees Celcius
	maximum_survivable_temperature = 323	// Above 50 Degrees Celcius
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	holder_type = /obj/item/holder/mouse
	gold_core_spawnable = FRIENDLY_SPAWN
	/// Probability that, if we successfully bite a shocked cable, that we will die to it.
	var/cable_zap_prob = 85
	/// Food types that mice eat
	var/static/list/food_types = list(/obj/item/food/sliced/cheesewedge, /obj/item/food/sliceable/cheesewheel)

/mob/living/basic/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddComponent(/datum/component/squeak, list(src.squeak_sound = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) // as quiet as a mouse or whatever
	AddComponent(/datum/component/swarming, 16, 16) // max_x, max_y
	if(!mouse_color)
		mouse_color = pick("brown", "gray", "white")
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 100)

/mob/living/basic/mouse/update_desc()
	. = ..()
	desc = "It's a small [mouse_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

/mob/living/basic/mouse/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

/mob/living/basic/mouse/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/food/sliced/cheesewedge))
		try_consume_cheese(attack_target)
		return TRUE

	if(istype(attack_target, /obj/structure/cable))
		try_bite_cable(attack_target)
		return TRUE

/// Signal proc for [COMSIG_ATOM_ENTERED]. Sends a lil' squeak to chat when someone walks over us.
/mob/living/basic/mouse/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(ishuman(entered) && stat == CONSCIOUS)
		to_chat(entered, "<span class='notice'>Squeak!</span>")

/// Called when a mouse is hand-fed some cheese, it will stop being afraid of humans
/mob/living/basic/mouse/tamed(mob/living/tamer, obj/item/food/sliced/cheesewedge/cheese)
	new /obj/effect/temp_visual/heart(loc)
	faction |= "neutral"
	try_consume_cheese(cheese)
	ai_controller.cancel_actions() // Interrupt any current fleeing

/mob/living/basic/mouse/proc/try_consume_cheese(obj/item/food/sliced/cheesewedge/cheese)
	if(prob(90) || health < maxHealth)
		visible_message(
			"<span class='notice'>[src] nibbles [cheese].</span>",
			"<span class='notice'>You nibble [cheese][health < maxHealth ? ", restoring your health" : ""].</span>"
		)
		adjustHealth(-maxHealth)
	else
		visible_message(
			"<span class='notice'>[src] nibbles through [cheese], attracting another mouse!</span>",
			"<span class='notice'>You nibble through [cheese], attracting another mouse!</span>"
		)
		new /mob/living/basic/mouse(loc)
	qdel(cheese)

/// Biting into a cable will cause a mouse to get shocked and die if applicable. Or do nothing if they're lucky.
/mob/living/basic/mouse/proc/try_bite_cable(obj/structure/cable/cable)
	if(!prob(cable_zap_prob))
		return
	var/turf/simulated/floor/F = get_turf(cable)
	if(cable.get_available_power() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		visible_message("<span class='warning'>[src] chews through [cable]. It's toast!</span>")
		playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
		toast() // mmmm toasty.
	else
		visible_message("<span class='warning'>[src] chews through [cable].</span>")
	investigate_log("was chewed through by a mouse in [get_area(F)]([F.x], [F.y], [F.z] - [ADMIN_JMP(F)])",INVESTIGATE_WIRES)
	cable.deconstruct()

/mob/living/basic/mouse/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)// Prevents mouse from pulling things
	if(istype(AM, /obj/item/food/sliced/cheesewedge))
		return ..() // Get dem
	if(show_message)
		to_chat(src, "<span class='warning'>You are too small to pull anything except cheese.</span>")
	return

/mob/living/basic/mouse/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(ishuman(entered))
		if(stat == CONSCIOUS)
			var/mob/M = entered
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")

/mob/living/basic/mouse/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()

/mob/living/basic/mouse/proc/splat()
	icon_dead = "mouse_[mouse_color]_splat"
	icon_state = "mouse_[mouse_color]_splat"

/mob/living/basic/mouse/death(gibbed)
	// Only execute the below if we successfully died
	playsound(src, squeak_sound, 40, 1)
	. = ..(gibbed)
	if(!.)
		return FALSE
	layer = MOB_LAYER
	if(client)
		client.persistent.time_died_as_mouse = world.time

/*
 * Mouse types
 */

/mob/living/basic/mouse/white
	mouse_color = "white"
	icon_state = "mouse_white"

/mob/living/basic/mouse/white/linter
	name = "Linter"

/mob/living/basic/mouse/white/linter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, ROUNDSTART_TRAIT)

/mob/living/basic/mouse/gray
	mouse_color = "gray"

/mob/living/basic/mouse/brown
	mouse_color = "brown"
	icon_state = "mouse_brown"

// TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/basic/mouse/brown/tom
	name = "Tom"
	real_name = "Tom"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/mouse/brown/tom/update_desc()
	. = ..()
	desc = "Jerry the cat is not amused."

/mob/living/basic/mouse/brown/tom/Initialize(mapload)
	. = ..()
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, SPECIES_TRAIT)

/mob/living/basic/mouse/white/brain
	name = "Brain"
	real_name = "Brain"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/mouse/white/brain/update_desc()
	. = ..()
	desc = "Gee Virology, what are we going to do tonight? The same thing we do every night, try to take over the world!"

// Boolog
/mob/living/basic/mouse/blobinfected
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	gold_core_spawnable = NO_SPAWN
	var/bursted = FALSE

/mob/living/basic/mouse/blobinfected/Initialize(mapload)
	. = ..()
	apply_status_effect(STATUS_EFFECT_BLOB_BURST, 120 SECONDS, CALLBACK(src, PROC_REF(burst), FALSE))

/mob/living/basic/mouse/blobinfected/Life()
	if(ismob(loc)) // if someone ate it, burst immediately
		burst(FALSE)
	return ..()

/mob/living/basic/mouse/blobinfected/death(gibbed)
	. = ..(gibbed)
	if(.) // Only burst if they actually died
		burst(gibbed)

/mob/living/basic/mouse/blobinfected/proc/burst(gibbed)
	if(bursted)
		return // Avoids double bursting in some situations
	bursted = TRUE
	var/turf/T = get_turf(src)
	if(!is_station_level(T.z) || isspaceturf(T))
		to_chat(src, "<span class='userdanger'>You feel ready to burst, but this isn't an appropriate place!  You must return to the station!</span>")
		apply_status_effect(STATUS_EFFECT_BLOB_BURST, 5 SECONDS, CALLBACK(src, PROC_REF(burst), FALSE))
		return FALSE
	var/datum/mind/blobmind = mind
	var/client/C = client
	var/obj/structure/blob/core/core
	if(istype(blobmind) && istype(C))
		core = new(T, C, 3)
		core.lateblobtimer()
		qdel(blobmind) // Delete the old mind. THe blob will make a new one
	else
		core = new(T) // Ghosts will be prompted to control it.
	if(ismob(loc)) // in case some taj/etc ate the mouse.
		var/mob/M = loc
		M.gib()
	if(!gibbed)
		gib()

	if(core)
		core.admin_spawned = admin_spawned

	SSticker.record_biohazard_start(BIOHAZARD_BLOB)

/mob/living/basic/mouse/blobinfected/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>You try to pick up [src], but they slip out of your grasp!</span>")
	to_chat(src, "<span class='warning'>[src] tries to pick you up, but you wriggle free of their grasp!</span>")

/mob/living/basic/mouse/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["metal"] += 2
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()

/// The mouse AI controller
/datum/ai_controller/basic_controller/mouse
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/larger, // Use this to find people to run away from
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
	)

	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Try to speak, because it's cute
		/datum/ai_planning_subtree/random_speech/mouse,
		// Look for and execute hunts for cheese even if someone is looking at us
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Next priority is see if anyone is looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/// Don't look for anything to run away from if you are distracted by being adjacent to cheese
/datum/ai_planning_subtree/flee_target/mouse

/datum/ai_planning_subtree/flee_target/mouse/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/hunted_cheese = controller.blackboard[BB_CURRENT_HUNTING_TARGET]
	if(!isnull(hunted_cheese))
		return // We see some cheese, which is more important than our life
	return ..()

/datum/ai_planning_subtree/random_speech/mouse
	speech_chance = 1
	speak = list("Squeak!", "SQUEAK!", "Squeak?")
	sound = list('sound/creatures/mousesqueak.ogg')
	emote_hear = list("squeeks.","squeaks.","squiks.")
	emote_see = list("runs in a circle.", "shakes.", "scritches at something.")
