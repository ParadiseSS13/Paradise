// malfunctioning combat drones
/mob/living/basic/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "drone3"
	icon_living = "drone3"
	icon_dead = "drone_dead"
	mob_biotypes = MOB_ROBOTIC
	response_disarm_continuous = "gently pushes aside the"
	response_disarm_simple = "gently pushes aside the"
	a_intent = INTENT_HARM
	health = 200
	maxHealth = 200
	speed = 8
	is_ranged = TRUE
	ranged_burst_count = 3
	ranged_burst_interval = 0.4
	projectile_type = /obj/item/projectile/beam/immolator/weak/hitscan
	projectile_sound = 'sound/weapons/laser3.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	faction = list("malf_drone")
	death_message = "suddenly breaks apart."
	basic_mob_flags = DEL_ON_DEATH
	advanced_bullet_dodge_chance = 25 // This will be adjusted when active, vs deactivated. Randomises on hit if it is zero.
	ai_controller = /datum/ai_controller/basic_controller/simple/malf_drone
	/// Is the drone passive?
	var/passive = FALSE

/mob/living/basic/malf_drone/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(create_trail))
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	AddElement(/datum/element/ai_retaliate)
	update_icons()

/mob/living/basic/malf_drone/proc/create_trail(datum/source, atom/oldloc, _dir, forced)
	var/turf/T = get_turf(oldloc)
	if(!has_gravity(T))
		new /obj/effect/particle_effect/ion_trails(T, _dir)

/mob/living/basic/malf_drone/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1

/mob/living/basic/malf_drone/update_icons()
	if(passive)
		icon_state = "drone_dead"
	else if(health / maxHealth > 0.9)
		icon_state = "drone3"
	else if(health / maxHealth > 0.7)
		icon_state = "drone2"
	else if(health / maxHealth > 0.5)
		icon_state = "drone1"
	else
		icon_state = "drone0"

/mob/living/basic/malf_drone/adjustHealth(damage, updating_health)
	do_sparks(3, 1, src)
	if(!QDELETED(src))
		ai_controller.set_blackboard_key(BB_MALF_DRONE_PASSIVE, FALSE)
	passive = FALSE
	update_icons()
	if(!advanced_bullet_dodge_chance)
		advanced_bullet_dodge_chance = 25
	. = ..() // this will handle finding a target if there is a valid one nearby

/mob/living/basic/malf_drone/Life(seconds, times_fired)
	. = ..()
	if(.) // mob is alive. We check this just in case Life() can fire for qdel'ed mobs.
		if(times_fired % 15 == 0) // every 15 cycles, aka 30 seconds, 50% chance to switch between modes
			scramble_settings()

/mob/living/basic/malf_drone/proc/scramble_settings()
	if(prob(50))
		do_sparks(3, 1, src)
		passive = !passive
		ai_controller.set_blackboard_key(BB_MALF_DRONE_PASSIVE, passive)
		if(passive)
			visible_message("<span class='notice'>[src] retracts several targetting vanes.</span>")
			advanced_bullet_dodge_chance = 0
			ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, null)
		else
			visible_message("<span class='warning'>[src] suddenly lights up, and additional targetting vanes slide into place.</span>")
			advanced_bullet_dodge_chance = 25
		ai_controller.cancel_actions()
		update_icons()

/// We overide the basic effect, as malfunctioning drones are in space, and use jets to dodge. Also lets us do cool effects.
/mob/living/basic/malf_drone/advanced_bullet_dodge(mob/living/source, obj/item/projectile/hitting_projectile)
	if(HAS_TRAIT(source, TRAIT_IMMOBILIZED))
		return NONE
	if(source.stat != CONSCIOUS)
		return NONE
	if(!prob(advanced_bullet_dodge_chance))
		return NONE

	source.visible_message(
		"<span class='danger'>[source]'s jets [pick("boosts", "propels", "pulses", "flares up and moves", "shudders and pushes")] it out of '[hitting_projectile]'s way!</span>",
		"<span class='userdanger'>You evade [hitting_projectile]!</span>",
	)
	playsound(source, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/effects/refill.ogg'), 75, TRUE)
	if(prob(50))
		addtimer(VARSET_CALLBACK(source, advanced_bullet_dodge_chance, advanced_bullet_dodge_chance), 0.25 SECONDS)
		advanced_bullet_dodge_chance = 0
	return ATOM_PREHIT_FAILURE

/mob/living/basic/malf_drone/emp_act(severity)
	adjustHealth(100 / severity) // takes the same damage as a mining drone from emp

/mob/living/basic/malf_drone/drop_loot()
	do_sparks(3, 1, src)

	var/turf/T = get_turf(src)

	// shards
	var/obj/O = new /obj/item/shard(T)
	step_to(O, get_turf(pick(view(7, src))))
	if(prob(75))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(50))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(25))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))

	// rods
	var/obj/item/stack/K = new /obj/item/stack/rods(T)
	step_to(K, get_turf(pick(view(7, src))))
	K.amount = pick(1, 2, 3, 4)
	K.update_icon()

	// plasteel
	K = new /obj/item/stack/sheet/plasteel(T)
	step_to(K, get_turf(pick(view(7, src))))
	K.amount = pick(1, 2, 3, 4)
	K.update_icon()

	// Spawn 1-4 boards of a random type
	var/num_boards = rand(1, 4)
	var/list/options = subtypesof(/obj/item/circuitboard/random_tech_level)
	for(var/i in 1 to num_boards)
		var/obj/item/circuitboard/random_tech_level/board = pick_n_take(options)
		new board(T)

// Becomes a board with a random level in the specified tech
// It's done like this so we can have a random level because we can't do this in the type declaration
/obj/item/circuitboard/random_tech_level
	/// Lower bound of random tech level
	var/lower_bound = 3
	/// Upper bound of random tech level
	var/upper_bound = 6

/obj/item/circuitboard/random_tech_level/Initialize(mapload)
	. = ..()
	origin_tech += "[rand(lower_bound, upper_bound)]"

/obj/item/circuitboard/random_tech_level/motherboard
	name = "Drone CPU motherboard"
	origin_tech = "programming="

/obj/item/circuitboard/random_tech_level/interface
	name = "Drone neural interface"
	origin_tech = "biotech="

/obj/item/circuitboard/random_tech_level/processor
	name = "Drone suspension processor"
	origin_tech = "magnets="

/obj/item/circuitboard/random_tech_level/controller
	name = "Drone shielding controller"
	origin_tech = "bluespace="

/obj/item/circuitboard/random_tech_level/capacitor
	name = "Drone power capacitor"
	origin_tech = "powerstorage="

/obj/item/circuitboard/random_tech_level/reinforcer
	name = "Drone hull reinforcer"
	origin_tech = "materials="

/obj/item/circuitboard/random_tech_level/autorepair
	name = "Drone auto-repair system"
	origin_tech = "engineering="

/obj/item/circuitboard/random_tech_level/counter
	name = "Drone plasma overcharge counter"
	origin_tech = "plasmatech="

/obj/item/circuitboard/random_tech_level/targeting
	name = "Drone targeting circuitboard"
	origin_tech = "combat="

/obj/item/circuitboard/random_tech_level/morality
	name = "Corrupted drone morality core"
	origin_tech = "syndicate="

/datum/ai_controller/basic_controller/simple/malf_drone
	movement_delay = 2 SECONDS
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/malf_drone,
		BB_AGGRO_RANGE = 7,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
		BB_MALF_DRONE_PASSIVE = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/malf_drone,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target/malf_drone,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/no_minimum,
	)

/datum/ai_planning_subtree/simple_find_target/malf_drone

/datum/ai_planning_subtree/simple_find_target/malf_drone/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_MALF_DRONE_PASSIVE])
		return // Only target if we're not in passive mode
	return ..()

/datum/ai_planning_subtree/random_speech/malf_drone
	speech_chance = 4
	speak = list("ALERT.", "Hostile-ile-ile entities dee-twhoooo-wected.", "Threat parameterszzzz- szzet.", "Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly.", "whirrs threateningly.", "scans for targets.")

/datum/targeting_strategy/basic/malf_drone

/// Returns false if we're on passive mode. If we get attacked, we swap out of passive mode.
/datum/targeting_strategy/basic/malf_drone/can_attack(mob/living/living_mob, atom/target, vision_range)
	if(living_mob?.ai_controller?.blackboard[BB_MALF_DRONE_PASSIVE])
		return FALSE
	return ..()
