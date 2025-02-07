/mob/living/simple_animal/hostile/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm."
	icon = 'icons/mob/eldritch_mobs.dmi'
	gender = NEUTER
	mob_biotypes = NONE
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help = "thinks better of touching"
	response_disarm = "flails at"
	response_harm = "reaps"
	speak_emote = list("screams")
	speak_chance = 1
	speed = 0
	stop_automated_movement = TRUE
	a_intent = INTENT_HARM
	AIStatus = AI_OFF
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	del_on_death = TRUE
	universal_speak = TRUE
	universal_understand = TRUE
	deathmessage = "implodes into itself."
	loot = list(/obj/effect/gibspawner/human)
	faction = list("heretic")

	/// Innate spells that are added when a beast is created.
	var/list/actions_to_add

/mob/living/simple_animal/hostile/heretic_summon/Initialize(mapload)
	. = ..()
	for(var/spell in actions_to_add)
		var/datum/spell/new_spell = new spell(src)
		AddSpell(new_spell)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit
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

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/leeching_walk)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_appearance(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
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

/mob/living/simple_animal/hostile/heretic_summon/stalker
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
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash,
		/datum/spell/emplosion/heretic,
	)

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet
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
	loot = list(/obj/effect/gibspawner/human, /obj/item/organ/external/arm, /obj/item/organ/internal/eyes)
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash/long,
		/datum/spell/remotetalk/eldritch,
		/datum/spell/blind/eldritch,
	)
	/// The UID to the last target we smacked. Hitting targets consecutively does more damage.
	var/last_target

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user == src) // Easy to hit yourself + very fragile = accidental suicide, prevent that
		return

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/AttackingTarget()
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

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/rotation_degree = (360 / 3)
	if(movement_dir & WEST || movement_dir & SOUTH)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(transform)
	to_turn = turn(transform, rotation_degree)
	animate(src, transform = to_turn, time = 0.1 SECONDS)

// A summon which floats around the station incorporeally, and can appear in any mirror
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
	name = "Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "A floating and flowing wisp of chilled air. Glancing at it causes it to shimmer slightly."
	icon = 'icons/mob/mob.dmi'
	icon_state = "stand"
	icon_living = "stand"
	speak_emote = list("whispers")
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
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/examine(mob/user)
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
				"<span class='warning'>[src] seems to fade in and out slightly.</span>",
				"<span class='userdanger'>[user]'s gaze pierces your every being!</span>",
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.1) // We take 10% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(CALLBACK(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown)

	// If we're examined on low enough health we die straight up
	else
		visible_message(
				"<span class='danger'>[src] vanishes from existence!</span>",
				"<span class='userdanger'>[user]'s gaze shatters your form, destroying you!</span>",
		)

		death()

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(!(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)


// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
/mob/living/simple_animal/hostile/heretic_summon/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "An abomination made from dozens and dozens of severed and malformed limbs piled onto each other."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	obj_damage = 200
	ranged_cooldown_time = 5
	ranged = TRUE
	rapid = 1
	actions_to_add = list(/datum/spell/worm_contract)
	///Previous segment in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/backsy
	///Next segment in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/front
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
/mob/living/simple_animal/hostile/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
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
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = src
	// The current link in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/current

	for(var/i in 1 to worm_length)
		current = new type(drop_location(), FALSE)
		current.icon_state = "armsy_mid"
		current.icon_living = "armsy_mid"
		current.AIStatus = AI_OFF
		current.front = prev
		prev.backsy = current
		prev = current

	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustBruteLoss(amount, updating_health, forced, required_bodytype)
	if(backsy)
		return backsy.adjustBruteLoss(amount, updating_health, forced)

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustFireLoss(amount, updating_health, forced, required_bodytype)
	if(backsy)
		return backsy.adjustFireLoss(amount, updating_health, forced)

	return ..()

// We are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/simple_animal/hostile/heretic_summon/armsy/Process_Spacemove(movement_dir, continuous_move)
	return TRUE


/mob/living/simple_animal/hostile/heretic_summon/armsy/can_be_pulled()
	return FALSE

/// Updates every body in the chain to force move onto a single tile.
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/contract_next_chain_into_single_tile()
	if(!backsy)
		return

	backsy.forceMove(loc)
	backsy.contract_next_chain_into_single_tile()

/*
 * Recursively get the length of our chain.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/get_length()
	. = 1
	if(backsy)
		. += backsy.get_length()

/// Updates the next mob in the chain to move to our last location. Fixes the chain if somehow broken.
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/update_chain_links()
	SIGNAL_HANDLER

	if(!follow)
		return

	if(backsy && backsy.loc != oldloc)
		backsy.Move(oldloc)

	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)

	oldloc = loc

/mob/living/simple_animal/hostile/heretic_summon/armsy/Destroy()
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
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/heal()
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

	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = new type(drop_location(), FALSE)
	icon_state = "armsy_mid"
	icon_living = "armsy_mid"
	backsy = prev
	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"
	prev.front = src
	prev.AIStatus = AI_OFF
	current_stacks = 0

/mob/living/simple_animal/hostile/heretic_summon/armsy/Shoot(atom/targeted_atom)
	GiveTarget(targeted_atom)
	AttackingTarget()

/mob/living/simple_animal/hostile/heretic_summon/armsy/AttackingTarget()
	if(istype(target, /obj/item/organ/external/arm))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(target)
		heal()
		return
	if(target == backsy || target == front)
		return
	if(backsy)
		backsy.GiveTarget(target)
		backsy.AttackingTarget()
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

/mob/living/simple_animal/hostile/heretic_summon/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/heretic_summon/armsy/prime/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 9)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4, 1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/heretic_summon/star_gazer
	name = "\improper Star Gazer"
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
	speed = 0
	maxHealth = 6000
	health = 6000
	initial_traits = list(TRAIT_FLYING)
	obj_damage = 400
	armour_penetration_flat = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	attacktext = "ravages"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("says as spacetime ripples out the words") //shut up its a big cosmic entity it gets a flavourful say verb
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)
	death_sound = 'sound/magic/cosmic_expansion.ogg'
	loot = list(/obj/effect/temp_visual/cosmic_domain)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/death(gibbed)
	. = ..()
	explosion(loc, 3, 6, 12)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
	RegisterSignal(src, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	set_light(4, l_color = "#dcaa5b")

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(250)

		if(2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/AttackingTarget()
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
		to_chat(nearby_mob, "<span class='userdanger'>\The [src] [attacktext] you!</span>")
		do_attack_animation(nearby_mob, ATTACK_EFFECT_CLAW)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/on_teleport() // Nope, can't bait it off station
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_TELEPORT
