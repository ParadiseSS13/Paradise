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

	var/basic_mob_flags

	// State changes and data for alive/dead/gibbed.
	// TODO: Refactor into an element

	/// Icon to use when the animal is alive.
	var/icon_living
	/// Icon when the animal is dead.
	var/icon_dead
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
	var/attacked_sound = 'sound/weapons/punch1.ogg'
	/// The amount of damage done to the mob when hand-attacked on harm intent.
	var/harm_intent_damage = 3
	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// Minimum force required to deal any damage
	var/force_threshold = 0

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	apply_atmos_requirements()
	apply_temperature_requirements()

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

/mob/living/basic/death(gibbed)
	. = ..()
	if(!.)
		return FALSE
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
		apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE
