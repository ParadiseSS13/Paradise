RESTRICT_TYPE(/mob/living/basic)

/// # Basic Mob
///
/// Basic mobs are a modern replacement for the simple_animal/"simple mob"
/// system. Rather than deep type trees with overrides for AI, basic mobs rely
/// on their AI controllers for the majority of their behavior.
///
/// It is also intended that as little implementation as possible be part of the
/// basic mob definition directly; rather, as much behavior as possible should
/// be delegated to components and elements, such as
/// [/datum/element/atmos_requirements] for handling reacting to atmosphere, and
/// [/datum/element/body_temperature] for handling changes in body temperature.
///
/// Migrating simple mobs to basic mobs is an incremental effort; and refactors
/// should be considered before making large changes to existing simple mob
/// code.
/mob/living/basic
	name = "basic mob"
	desc = "If you can see this, make an issue report on GitHub."
	healable = TRUE
	icon = 'icons/mob/animal.dmi'
	hud_type = /datum/hud/simple_animal

	var/basic_mob_flags

	// State changes and data for alive/dead/gibbed.
	// TODO: Refactor into an element

	/// Icon to use when the animal is alive.
	var/icon_living
	/// Icon when the animal is dead.
	var/icon_dead
	/// Icon when the animal is resting
	var/icon_resting
	/// We only try to show a gibbing animation if this exists.
	var/icon_gib
	/// The sound played on death
	var/death_sound
	/// The message displayed on death
	var/death_message

	// Xenobiology/sentience

	/// What is heard by mobs who cannot understand this one when speaking.
	/// This doesn't feel like it belongs here but say code and language code
	/// is a mess to untangle so maybe it can move somewhere later.
	var/list/unintelligble_phrases
	var/list/unintelligble_speak_verbs
	/// If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood
	var/gold_core_spawnable = NO_SPAWN
	/// Holding var for determining who own/controls a sentient simple animal (for sentience potions).
	var/mob/living/carbon/human/master_commander = null
	/// Sentience type, for slime potions
	var/sentience_type = SENTIENCE_ORGANIC

	/// Higher speed is slower, negative speed is faster
	var/speed = 1

	/// Leaving something at 0 means it's off - has no maximum.
	var/list/atmos_requirements = list(
		"min_oxy" = 5,
		"max_oxy" = 0,
		"min_plas" = 0,
		"max_plas" = 1,
		"min_co2" = 0,
		"max_co2" = 5,
		"min_n2" = 0,
		"max_n2" = 0
	)
	/// This damage is taken when atmos doesn't fit all the requirements above.
	/// Set to 0 to avoid adding the atmos_requirements element.
	var/unsuitable_atmos_damage = 1

	/// Minimal body temperature without receiving damage
	var/minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP
	/// Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP
	/// This damage is taken when the body temp is too cold. Set both this and unsuitable_heat_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_cold_damage = 1
	/// This damage is taken when the body temp is too hot. Set both this and unsuitable_cold_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_heat_damage = 1

	// String interpolation for actions.
	//
	// Currently only the continuous tense forms are used because there's
	// typically no specific to_chat message for the instigator of the action.
	// Rather, they get the same message as everyone around them, e.g. "Foo
	// pokes the cow" instead of "You poke the cow." Properly integrating the
	// simple tense would require ensuring visible_message doesn't show to the
	// instigator via something like a list of ignored mobs.

	/// When someone interacts with the simple animal.
	/// Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	/// Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	/// Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	/// Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	/// Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	/// Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"

	/// Basic mob's own attacks verbs,
	/// Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	/// Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	/// Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	/// Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"

	// Attack related vars.
	// Unclear how much of this should either be componentized or pulled to /mob/living
	/// Sound played when the critter attacks.
	var/attack_sound = 'sound/weapons/punch1.ogg'
	/// Sound played when the critter is attacked.
	var/attacked_sound = 'sound/weapons/punch1.ogg'
	/// The amount of damage done to the mob when hand-attacked on harm intent.
	var/harm_intent_damage = 3
	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// Minimum force required to deal any damage
	var/force_threshold = 0
	/// Lower bound of damage done by unarmed melee attacks.
	var/melee_damage_lower = 0
	/// Upper bound of damage done by unarmed melee attacks.
	var/melee_damage_upper = 0
	/// How much damage this simple animal does to objects, if any
	var/obj_damage = 0
	/// What can this mob break?
	var/environment_smash = ENVIRONMENT_SMASH_NONE
	/// Flat armour reduction, occurs after percentage armour penetration.
	var/armor_penetration_flat = 0
	/// Percentage armour reduction, happens before flat armour reduction.
	var/armor_penetration_percentage = 0
	/// Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	/// Lower bound for melee attack cooldown
	var/melee_attack_cooldown_min = 2 SECONDS
	/// Upper bound for melee attack cooldown
	var/melee_attack_cooldown_max = 2 SECONDS
	/// Can this mob ignite?
	var/can_be_on_fire = FALSE
	/// How much fire damage does a mob take?
	var/fire_damage = 2

	/// Loot this mob drops on death.
	var/list/loot = list()

	/// Compatibility with mob spawners
	var/datum/component/spawner/nest

	/// Footsteps
	var/step_type

	/// Does this type do range attacks?
	var/is_ranged = FALSE
	/// How many shots in a burst?
	var/ranged_burst_count = 1
	/// How fast do we fire between shots in a burst?
	var/ranged_burst_interval = 0.2 SECONDS
	/// Time between bursts
	var/ranged_cooldown = 2 SECONDS
	/// What casing type is the projectile?
	var/casing_type
	/// What projectile do we shoot?
	var/projectile_type
	/// What sound does it make when firing?
	var/projectile_sound

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	apply_atmos_requirements()
	apply_temperature_requirements()
	if(step_type)
		AddComponent(/datum/component/footstep, step_type)
	if(can_hide)
		var/datum/action/innate/hide/hide = new()
		hide.Grant(src)
	if(is_ranged)
		AddComponent(/datum/component/ranged_attacks, casing_type = casing_type, projectile_type = projectile_type, projectile_sound = projectile_sound, burst_shots = ranged_burst_count, burst_intervals = ranged_burst_interval, cooldown_time = ranged_cooldown)

/mob/living/basic/Destroy()
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	return ..()

/mob/living/basic/movement_delay()
	. = speed
	if(forced_look)
		. += DIRECTION_LOCK_SLOWDOWN
	. += GLOB.configuration.movement.animal_delay

/mob/living/basic/proc/apply_atmos_requirements()
	if(unsuitable_atmos_damage == 0)
		return

	atmos_requirements = string_assoc_list(atmos_requirements)
	AddElement(/datum/element/atmos_requirements, atmos_requirements, unsuitable_atmos_damage)

/mob/living/basic/proc/apply_temperature_requirements()
	AddElement(/datum/element/body_temperature, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage)

/mob/living/basic/handle_fire()
	if(!can_be_on_fire)
		return FALSE
	. = ..()
	if(!.)
		return
	adjustFireLoss(fire_damage) // Slowly start dying from being on fire

/mob/living/basic/vv_edit_var(vname, vval)
	switch(vname)
		if("atmos_requirements", "unsuitable_atmos_damage")
			RemoveElement(/datum/element/atmos_requirements, atmos_requirements, unsuitable_atmos_damage)
			. = TRUE
		if("minimum_survivable_temperature", "maximum_survivable_temperature", "unsuitable_cold_damage", "unsuitable_heat_damage")
			RemoveElement(/datum/element/body_temperature, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage)
			. = TRUE

	. = ..()

	switch(vname)
		if("habitable_atmos", "unsuitable_atmos_damage")
			apply_atmos_requirements()
		if("minimum_survivable_temperature", "maximum_survivable_temperature", "unsuitable_cold_damage", "unsuitable_heat_damage")
			apply_temperature_requirements()

/// Return whether or not ghosts can take over this mob via "Respawn as NPC"
/mob/living/basic/proc/valid_respawn_target_for(mob/user)
	return FALSE

/mob/living/basic/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	melee_attack(attack_target, modifiers)

/mob/living/basic/proc/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!early_melee_attack(target, modifiers, ignore_cooldown))
		return FALSE

	var/result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/proc/early_melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if(!ignore_cooldown && !client)
		var/melee_attack_cooldown = rand(melee_attack_cooldown_min, melee_attack_cooldown_max)
		changeNext_move(melee_attack_cooldown)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE
	return TRUE

/mob/living/basic/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		return attack_threshold_check(damage, M.melee_damage_type)

/mob/living/basic/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) // if harm or disarm intent.
		if(M.a_intent == INTENT_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] [response_disarm_continuous] [name]!</span>", "<span class='userdanger'>[M] [response_disarm_continuous] you!</span>")
			add_attack_logs(M, src, "Alien disarmed")
		else
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
					"<span class='userdanger'>[M] has slashed at [src]!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			add_attack_logs(M, src, "Alien attacked")
			attack_threshold_check(damage)
		return TRUE

/mob/living/basic/handle_environment(datum/gas_mixture/readonly_environment)
	SEND_SIGNAL(src, COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT, readonly_environment)

/mob/living/basic/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
			create_debug_log("died of damage, trigger reason: [reason]")
		else
			if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
				if(stat == CONSCIOUS)
					KnockOut()
					create_debug_log("knocked out, trigger reason: [reason]")
			else if(stat == UNCONSCIOUS)
				WakeUp()
				create_debug_log("woke up, trigger reason: [reason]")
	med_hud_set_status()

/mob/living/basic/revive()
	..()
	density = initial(density)
	health = maxHealth
	icon = initial(icon)
	icon_state = icon_living
	density = initial(density)
	if(TRAIT_FLYING in initial_traits)
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)

/mob/living/basic/death(gibbed)
	. = ..()
	if(!.)
		return FALSE
	REMOVE_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	drop_loot()
	if(!gibbed)
		if(death_sound)
			playsound(get_turf(src), death_sound, 200, 1)
		if(death_message)
			visible_message("<span class='danger'>\The [src] [death_message]</span>")
		else if(!(basic_mob_flags & DEL_ON_DEATH))
			visible_message("<span class='danger'>\The [src] stops moving...</span>")
	if(HAS_TRAIT(src, TRAIT_XENOBIO_SPAWNED))
		SSmobs.xenobiology_mobs--
	if(basic_mob_flags & DEL_ON_DEATH)
		// Moves them to their turf to prevent rendering problems
		forceMove(get_turf(src))
		// From simplemob implementation; prevent infinite loops if the mob
		// Destroy() is overridden in such a manner as to cause a call to
		// death() again. One hopes this isn't still necessary but whatevs
		basic_mob_flags &= ~DEL_ON_DEATH
		ghostize()
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		if(basic_mob_flags & FLIP_ON_DEATH)
			transform = transform.Turn(180)
		density = FALSE

/mob/living/basic/attack_hand(mob/living/carbon/human/M)
	..()
	switch(M.a_intent)

		if(INTENT_HELP)
			if(health > 0)
				visible_message(
					"<span class='notice'>[M] [response_help_continuous] [src].</span>",
					"<span class='notice'>[M] [response_help_continuous] you.</span>"
				)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(INTENT_GRAB)
			grabbedby(M)

		if(INTENT_HARM, INTENT_DISARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='warning'>You don't want to hurt [src]!</span>")
				return
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message(
				"<span class='danger'>[M] [response_harm_continuous] [src]!</span>",
				"<span class='userdanger'>[M] [response_harm_continuous] you!</span>"
			)
			playsound(loc, attacked_sound, 25, TRUE, -1)
			attack_threshold_check(harm_intent_damage)
			add_attack_logs(M, src, "Melee attacked with fists")
			updatehealth()
			return TRUE

// TODO: Could probably be moved to /mob/living but would need more testing to
// ensure it doesn't interfere with carbons.
/mob/living/basic/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = MELEE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message("<span class='warning'>[src] looks unharmed.</span>")
		return FALSE
	else
		apply_damage(damage, damagetype, null, getarmor(armor_type = armorcheck))
		return TRUE


/mob/living/basic/handle_basic_attack(mob/living/basic/attacker, modifiers)
	. = ..()
	if(.)
		var/damage = rand(attacker.melee_damage_lower, attacker.melee_damage_upper)
		return attack_threshold_check(damage, attacker.melee_damage_type)

/mob/living/basic/on_lying_down(new_lying_angle)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT) //simple mobs cannot crawl (unless they can)

/mob/living/basic/on_standing_up()
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living

// Health/Damage adjustment, cribbed straight from simplemobs

/mob/living/basic/adjustHealth(amount, updating_health = TRUE)
	. = ..()
	if(!ckey && stat == CONSCIOUS)
		if(ai_controller?.ai_status == AI_STATUS_IDLE)
			ai_controller.set_ai_status(AI_STATUS_ON)

/mob/living/basic/adjustBruteLoss(amount, updating_health = TRUE)
	if(damage_coeff[BRUTE])
		return adjustHealth(amount * damage_coeff[BRUTE], updating_health)

/mob/living/basic/adjustFireLoss(amount, updating_health = TRUE)
	if(damage_coeff[BURN])
		return adjustHealth(amount * damage_coeff[BURN], updating_health)

/mob/living/basic/adjustOxyLoss(amount, updating_health = TRUE)
	if(damage_coeff[OXY])
		return adjustHealth(amount * damage_coeff[OXY], updating_health)

/mob/living/basic/adjustToxLoss(amount, updating_health = TRUE)
	if(damage_coeff[TOX])
		return adjustHealth(amount * damage_coeff[TOX], updating_health)

/mob/living/basic/adjustCloneLoss(amount, updating_health = TRUE)
	if(damage_coeff[CLONE])
		return adjustHealth(amount * damage_coeff[CLONE], updating_health)

/mob/living/basic/adjustStaminaLoss(amount, updating_health = TRUE)
	if(damage_coeff[STAMINA])
		return ..(amount * damage_coeff[STAMINA], updating_health)

/mob/living/basic/proc/drop_loot()
	if(length(loot))
		for(var/item in loot)
			new item(get_turf(src))
