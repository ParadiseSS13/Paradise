/mob/living/basic/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm."
	icon = 'icons/mob/eldritch_mobs.dmi'
	mob_biotypes = NONE
	response_help_continuous = "thinks better of touching"
	response_help_continuous = "flails at"
	response_harm_continuous = "reaps"
	speak_emote = list("screams")
	speed = 0
	a_intent = INTENT_HARM
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	universal_speak = TRUE
	universal_understand = TRUE
	deathmessage = "implodes into itself."
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile_obstacles
	loot = list(/obj/effect/gibspawner/human)
	faction = list("heretic")
	basic_mob_flags = DEL_ON_DEATH

	/// Innate spells that are added when a beast is created.
	var/list/actions_to_add

/mob/living/basic/heretic_summon/Initialize(mapload)
	. = ..()
	for(var/spell in actions_to_add)
		var/datum/spell/new_spell = new spell(src)
		AddSpell(new_spell)
	add_numbering()

/mob/living/basic/heretic_summon/proc/add_numbering()
	name += " ([rand(1,999)])"

/mob/living/basic/heretic_summon/fire_shark
	name = "\improper Fire Shark"
	real_name = "Fire Shark"
	desc = "It is a eldritch dwarf space shark, also known as a fire shark."
	icon = 'icons/mob/eldritch_mobs_64x64.dmi'
	icon_state = "fire_shark"
	icon_living = "fire_shark"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speed = -0.5
	health = 30
	maxHealth = 30
	melee_damage_lower = 15
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_heat_damage = 0
	pressure_resistance = 200
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 50
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, STAMINA = 0, OXY = 0)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	faction = list("heretic")
	mob_size = MOB_SIZE_TINY
	speak_emote = list("screams")
	initial_traits = list(TRAIT_FLYING, TRAIT_SHOCKIMMUNE)
	/// How much Phlog should we inject per bite?
	var/phlog_per_bite = 2

/mob/living/basic/heretic_summon/fire_shark/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_gases, list(SPAWN_GAS_PLASMA = 50))
	AddComponent(/datum/component/swarming, 0, 0)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_MAROON)

/mob/living/basic/heretic_summon/fire_shark/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/heretic_summon/fire_shark/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()

/mob/living/basic/heretic_summon/fire_shark/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && phlog_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, TRUE))
			C.reagents.add_reagent("phlogiston", phlog_per_bite)

/mob/living/basic/heretic_summon/fire_shark/wild
	faction = list("carp", "mining")

/mob/living/basic/heretic_summon/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "An incomprehensible abomination. Everywhere it steps, it appears to be actively seeping life out of its surroundings."
	icon_state = "rust_walker_s"
	icon_living = "rust_walker_s"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/spell/aoe/rust_conversion/construct,
		/datum/spell/fireball/rust_wave/short,
	)

/mob/living/basic/heretic_summon/rust_spirit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/leeching_walk)

/mob/living/basic/heretic_summon/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/heretic_summon/rust_spirit/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/// Converts unconverted terrain, sprays pocket sand around
/datum/ai_controller/basic_controller/rust_walker
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/rust
	planning_subtrees = list(
		/datum/ai_planning_subtree/use_mob_ability/rust_walker,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Moves a lot if healthy and on rust (to find more tiles to rust) or unhealthy and not on rust (to find healing rust)
/// Still moving in random directions though we're not really seeking it out
/datum/idle_behavior/idle_random_walk/rust

/datum/idle_behavior/idle_random_walk/rust/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/our_mob = controller.pawn
	var/turf/our_turf = get_turf(our_mob)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 10 : 50
	else
		walk_chance = (our_mob.health < our_mob.maxHealth) ? 50 : 10
	return ..()

/// Use if we're not stood on rust right now
/datum/ai_planning_subtree/use_mob_ability/rust_walker

/datum/ai_planning_subtree/use_mob_ability/rust_walker/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	var/turf/our_turf = get_turf(controller.pawn)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

/mob/living/basic/heretic_summon/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "An incomprehensible abomination. As it moves, a thin trail of ash follows, appearing from seemingly nowhere."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash,
		/datum/spell/pointed/cleave,
		/datum/spell/fire_sworn,
	)

/mob/living/basic/heretic_summon/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "An abomination made from several limbs and organs. Every moment you stare at it, it appears to shift and change unnaturally."
	icon_state = "stalker"
	icon_living = "stalker"
	status_flags = CANPUSH
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	ai_controller = /datum/ai_controller/basic_controller/stalker
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash,
		/datum/spell/emplosion/heretic,
	)

/// Changes shape and lies in wait when it has no target, uses EMP and attacks once it does
/datum/ai_controller/basic_controller/stalker
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	movement_delay = 5 SECONDS
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/heretic_summon/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "An abomination stitched together from a few severed arms and one lost eye."
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 65
	health = 65
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	ai_controller = /datum/ai_controller/basic_controller/raw_prophet
	loot = list(/obj/effect/gibspawner/human, /obj/item/organ/external/arm, /obj/item/organ/internal/eyes)
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash/long,
		/datum/spell/remotetalk/eldritch,
		/datum/spell/blind/eldritch,
	)
	/// The UID to the last target we smacked. Hitting targets consecutively does more damage.
	var/last_target

/// Walk and attack people, blind them when we can
/datum/ai_controller/basic_controller/raw_prophet
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/heretic_summon/raw_prophet/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user == src) // Easy to hit yourself + very fragile = accidental suicide, prevent that
		return

	return ..()

/mob/living/basic/heretic_summon/raw_prophet/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(target.UID() == last_target)
		melee_damage_lower = min(melee_damage_lower + 5, 30)
		melee_damage_upper = min(melee_damage_upper + 5, 35)
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)

	. = ..()
	if(!.)
		return

	SpinAnimation(5, 1)
	last_target = target.UID()

/mob/living/basic/heretic_summon/raw_prophet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/rotation_degree = (360 / 3)
	if(movement_dir & WEST || movement_dir & SOUTH)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(transform)
	to_turn = turn(transform, rotation_degree)
	animate(src, transform = to_turn, time = 0.1 SECONDS)

// A summon which floats around the station incorporeally, and can appear in any mirror
/mob/living/basic/heretic_summon/maid_in_the_mirror
	name = "Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "A floating and flowing wisp of chilled air. Glancing at it causes it to shimmer slightly."
	icon = 'icons/mob/mob.dmi'
	icon_state = "stand"
	icon_living = "stand"
	speak_emote = list("crackles")
	status_flags = CANSTUN | CANPUSH
	attack_sound = "shatter"
	maxHealth = 80
	health = 80
	melee_damage_lower = 24 //Bit buffed from tg because like, you are not making these as much as cult wraiths
	melee_damage_upper = 24
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	deathmessage = "shatters and vanishes, releasing a gust of cold air."
	initial_traits = list(TRAIT_FLYING)
	loot = list(
		/obj/item/shard,
		/obj/effect/decal/cleanable/ash,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/organ/internal/lungs,
	)
	actions_to_add = list(/datum/spell/bloodcrawl/mirror_walk)

	/// Whether we take damage when we're examined
	var/weak_on_examine = TRUE
	/// The cooldown after being examined that the same mob cannot trigger it again
	var/recent_examine_damage_cooldown = 10 SECONDS
	/// A list of uids to people who recently examined us
	var/list/recent_examiner_refs = list()

// Examining them will harm them, on a cooldown.
/mob/living/basic/heretic_summon/maid_in_the_mirror/examine(mob/user)
	. = ..()
	if(!weak_on_examine)
		return

	if(!isliving(user) || user.stat == DEAD)
		return

	if(IS_HERETIC_OR_MONSTER(user) || user == src)
		return

	var/user_ref = user.UID()
	if(user_ref in recent_examiner_refs)
		return

	// If we have health, we take some damage
	if(health > (maxHealth * 0.125))
		visible_message(
				SPAN_WARNING("[src] seems to fade in and out slightly."),
				SPAN_USERDANGER("[user]'s gaze pierces your every being!"),
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.1) // We take 10% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(CALLBACK(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown)

	// If we're examined on low enough health we die straight up
	else
		visible_message(
				SPAN_DANGER("[src] vanishes from existence!"),
				SPAN_USERDANGER("[user]'s gaze shatters your form, destroying you!"),
		)

		death()

/mob/living/basic/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(!(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)


// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
/mob/living/basic/heretic_summon/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "An abomination made from dozens and dozens of severed and malformed limbs piled onto each other."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	unsuitable_heat_damage = 0
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	obj_damage = 200
	actions_to_add = list(/datum/spell/worm_contract)
	///Previous segment in the chain
	var/mob/living/basic/heretic_summon/armsy/backsy
	///Next segment in the chain
	var/mob/living/basic/heretic_summon/armsy/front
	///Your old location
	var/oldloc
	///Allow / disallow pulling
	var/allow_pulling = FALSE
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0
	///Does this follow other pieces?
	var/follow = TRUE

/*
 * Arguments
 * * spawn_bodyparts - whether we spawn additional armsy bodies until we reach length.
 * * worm_length - the length of the worm we're creating. Below 3 doesn't work very well.
 */
/mob/living/basic/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
	. = ..()
	if(worm_length < 3)
		stack_trace("[type] created with invalid len ([worm_length]). Reverting to 3.")
		worm_length = 3 //code breaks below 3, let's just not allow it.

	oldloc = loc
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(update_chain_links))
	if(!spawn_bodyparts)
		return

	allow_pulling = TRUE
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = worm_length * maxHealth
	health = maxHealth

	// The previous link in the chain
	var/mob/living/basic/heretic_summon/armsy/prev = src
	// The current link in the chain
	var/mob/living/basic/heretic_summon/armsy/current

	for(var/i in 1 to worm_length)
		current = new type(drop_location(), FALSE)
		current.icon_state = "armsy_mid"
		current.icon_living = "armsy_mid"
		current.ai_controller = null
		current.front = prev
		prev.backsy = current
		prev = current

	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"

/mob/living/basic/heretic_summon/armsy/adjustBruteLoss(amount, updating_health, forced, required_bodytype)
	if(backsy)
		return backsy.adjustBruteLoss(amount, updating_health, forced)

	return ..()

/mob/living/basic/heretic_summon/armsy/adjustFireLoss(amount, updating_health, forced, required_bodytype)
	if(backsy)
		return backsy.adjustFireLoss(amount, updating_health, forced)

	return ..()

// We are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/basic/heretic_summon/armsy/Process_Spacemove(movement_dir, continuous_move)
	return TRUE


/mob/living/basic/heretic_summon/armsy/can_be_pulled()
	return FALSE

/// Updates every body in the chain to force move onto a single tile.
/mob/living/basic/heretic_summon/armsy/proc/contract_next_chain_into_single_tile()
	if(!backsy)
		return

	backsy.forceMove(loc)
	backsy.contract_next_chain_into_single_tile()

/*
 * Recursively get the length of our chain.
 */
/mob/living/basic/heretic_summon/armsy/proc/get_length()
	. = 1
	if(backsy)
		. += backsy.get_length()

/// Updates the next mob in the chain to move to our last location. Fixes the chain if somehow broken.
/mob/living/basic/heretic_summon/armsy/proc/update_chain_links()
	SIGNAL_HANDLER

	if(!follow)
		return

	if(backsy && backsy.loc != oldloc)
		backsy.Move(oldloc)

	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)

	oldloc = loc

/mob/living/basic/heretic_summon/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
		front.backsy = null
		front = null
	if(backsy)
		QDEL_NULL(backsy) // chain destruction baby
	return ..()

/*
 * Handle healing our chain.
 *
 * Eating arms off the ground heals us,
 * and if we eat enough arms while above
 * a certain health threshold,  we even gain back parts!
 */
/mob/living/basic/heretic_summon/armsy/proc/heal()
	if(backsy)
		backsy.heal()
		return

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5, FALSE)

	if(health < maxHealth * 0.8)
		return

	current_stacks++
	if(current_stacks < stacks_to_grow)
		return

	var/mob/living/basic/heretic_summon/armsy/prev = new type(drop_location(), FALSE)
	icon_state = "armsy_mid"
	icon_living = "armsy_mid"
	backsy = prev
	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"
	prev.front = src
	prev.ai_controller = null
	current_stacks = 0

/mob/living/basic/heretic_summon/armsy/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(istype(target, /obj/item/organ/external/arm))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(target)
		heal()
		return
	if(target == backsy || target == front)
		return
	if(!Adjacent(target))
		return
	do_attack_animation(target)

	if(ishuman(target))
		var/mob/living/carbon/human/carbon_target = target

		var/list/parts_to_remove = list()
		for(var/obj/item/organ/external/bodypart in carbon_target.bodyparts)
			if(bodypart.body_part == ARM_LEFT || bodypart.body_part == ARM_RIGHT)
				if(!(bodypart.limb_flags & CANNOT_DISMEMBER))
					parts_to_remove += bodypart

		if(parts_to_remove.len && prob(10))
			var/obj/item/organ/external/lost_arm = pick(parts_to_remove)
			lost_arm.droplimb(FALSE, DROPLIMB_SHARP)

	return ..()

/mob/living/basic/heretic_summon/armsy/add_numbering()
	return

/mob/living/basic/heretic_summon/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/basic/heretic_summon/armsy/prime/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 9)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4, 1.4)
	transform = matrix_transformation

/mob/living/basic/heretic_summon/star_gazer
	name = "\improper Star Gazer"
	real_name = "\improper Star Gazer"
	desc = "A creature that has been tasked to watch over the stars."
	icon = 'icons/mob/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	layer = LARGE_MOB_LAYER
	maxHealth = 6000
	health = 6000
	initial_traits = list(TRAIT_FLYING)
	obj_damage = 400
	unsuitable_heat_damage = 0
	armor_penetration_flat = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	attack_verb_continuous = "ravages"
	ai_controller = /datum/ai_controller/basic_controller/star_gazer
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("ripples out the words")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/magic/cosmic_expansion.ogg'
	loot = list(/obj/effect/temp_visual/cosmic_domain)
	/// The commands our summoner can give us
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/protect_owner,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/star_gazer,
	)

/mob/living/basic/heretic_summon/star_gazer/death(gibbed)
	. = ..()
	explosion(loc, 3, 6, 12)

/mob/living/basic/heretic_summon/star_gazer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	RegisterSignal(src, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	set_light(4, l_color = "#dcaa5b")

/mob/living/basic/heretic_summon/star_gazer/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(250)

		if(2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)

/mob/living/basic/heretic_summon/star_gazer/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/mob/living/basic/heretic_summon/star_gazer/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()

/mob/living/basic/heretic_summon/star_gazer/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/star_mark)
	living_target.apply_damage(damage = 5, damagetype = BURN)
	for(var/mob/living/nearby_mob in range(1, src))
		if(living_target == nearby_mob || !IS_HERETIC(living_target))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.apply_damage(10)
		to_chat(nearby_mob, SPAN_USERDANGER("\The [src] [attack_verb_continuous] you!"))
		do_attack_animation(nearby_mob, ATTACK_EFFECT_CLAW)

/mob/living/basic/heretic_summon/star_gazer/proc/on_teleport() // Nope, can't bait it off station
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_TELEPORT

/mob/living/basic/heretic_summon/star_gazer/add_numbering()
	return

/datum/ai_controller/basic_controller/star_gazer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends/attack_everything,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_planning_subtree/attack_obstacle_in_path/pet_target/star_gazer
	attack_behaviour = /datum/ai_behavior/attack_obstructions/star_gazer

/datum/ai_behavior/attack_obstructions/star_gazer
	action_cooldown = 0.4 SECONDS
	can_attack_turfs = TRUE

/datum/pet_command/attack/star_gazer
	speech_commands = list("attack", "sic", "kill", "slash them", "die", "suffer")
	command_feedback = "stares!"
	pointed_reaction = "stares intensely!"
	refuse_reaction = "..."
	requires_pointing = FALSE

/datum/pet_command/idle/star_gazer
	command_feedback = "twinkles."
	pointed_reaction = "twinkles!"

