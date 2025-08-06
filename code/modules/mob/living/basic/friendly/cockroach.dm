/mob/living/basic/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 270
	maximum_survivable_temperature = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BUG
	mob_size = MOB_SIZE_TINY
	ai_controller = /datum/ai_controller/basic_controller/cockroach
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	loot = list(/obj/effect/decal/cleanable/insectguts)
	basic_mob_flags = DEL_ON_DEATH
	/// Chance to get squished
	var/squish_chance = 50

/mob/living/basic/cockroach/can_die()
	return ..() && !SSticker.cinematic // If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.

/mob/living/basic/cockroach/Initialize(mapload) // Lizards are a great way to deal with cockroaches
	. = ..()
	ADD_TRAIT(src, TRAIT_EDIBLE_BUG, "edible_bug")
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/cockroach/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(isliving(entered))
		var/mob/living/A = entered
		if(A.mob_size > MOB_SIZE_SMALL)
			if(prob(squish_chance))
				A.visible_message("<span class='notice'>\The [A] squashed \the [name].</span>", "<span class='notice'>You squashed \the [name].</span>")
				death()
			else
				visible_message("<span class='notice'>\The [name] avoids getting crushed.</span>")
	else if(isstructure(entered))
		visible_message("<span class='notice'>As \the [entered] moved over \the [name], it was crushed.</span>")
		death()

/mob/living/basic/cockroach/ex_act() // Explosions are a terrible way to handle a cockroach.
	return

// mining pet
/mob/living/basic/cockroach/brad
	name = "Brad"
	desc = "Lavaland's most resilient cockroach. Seeing this little guy walk through the wastes almost makes you wish for nuclear winter."
	response_help_continuous = "carefully pets"
	response_help_simple = "carefully pet"
	weather_immunities = list("ash")
	gold_core_spawnable = NO_SPAWN

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/roach,
	)

/datum/ai_planning_subtree/find_and_hunt_target/roach
	hunt_targets = list(/obj/effect/decal/cleanable/ants)
