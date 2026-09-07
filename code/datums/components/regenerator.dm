#define REGENERATION_FILTER "healing_glow"

/**
 * # Regenerator component
 *
 * A mob with this component will regenerate its health over time, as long as it has not received damage
 * in the last X seconds. Taking any damage will reset this cooldown.
 */
/datum/component/regenerator
	/// You will only regain health if you haven't been hurt for this many seconds
	var/regeneration_delay
	/// Brute reagined every second
	var/brute_per_second
	/// Burn reagined every second
	var/burn_per_second
	/// Toxin reagined every second
	var/tox_per_second
	/// Oxygen reagined every second
	var/oxy_per_second
	/// List of damage types we don't care about, in case you want to only remove this with fire damage or something
	var/list/ignore_damage_types
	/// Colour of regeneration animation, or none if you don't want one
	var/outline_colour
	/// When this timer completes we start restoring health, it is a timer rather than a cooldown so we can do something on its completion
	var/regeneration_start_timer
	/// Callback for adding special checks for whether or not we can start regenning
	var/datum/callback/regen_check = null

/datum/component/regenerator/Initialize(
	regeneration_delay = 3 SECONDS,
	brute_per_second = 2,
	burn_per_second = 0,
	tox_per_second = 0,
	oxy_per_second = 0,
	ignore_damage_types = list(STAMINA),
	outline_colour = COLOR_GREEN,
	regen_check = null,
)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.regeneration_delay = regeneration_delay
	src.brute_per_second = brute_per_second
	src.burn_per_second = burn_per_second
	src.tox_per_second = tox_per_second
	src.oxy_per_second = oxy_per_second
	src.ignore_damage_types = ignore_damage_types
	src.outline_colour = outline_colour
	src.regen_check = regen_check

/datum/component/regenerator/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))

/datum/component/regenerator/UnregisterFromParent()
	. = ..()
	if(regeneration_start_timer)
		deltimer(regeneration_start_timer)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	stop_regenerating()

/datum/component/regenerator/Destroy(force)
	stop_regenerating()
	. = ..()
	if(regeneration_start_timer)
		deltimer(regeneration_start_timer)

/// When you take damage, reset the cooldown and start processing
/datum/component/regenerator/proc/on_take_damage(datum/source, damage, damagetype, ...)
	SIGNAL_HANDLER

	if(damagetype in ignore_damage_types)
		return

	reset_regeneration_timer()

/datum/component/regenerator/proc/reset_regeneration_timer()
	stop_regenerating()
	regeneration_start_timer = addtimer(CALLBACK(src, PROC_REF(start_regenerating)), regeneration_delay, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/// Start processing health regeneration, and show animation if provided
/datum/component/regenerator/proc/start_regenerating()
	if(!should_be_regenning(parent))
		return
	var/mob/living/living_parent = parent
	living_parent.visible_message(SPAN_NOTICE("[living_parent]'s wounds begin to knit closed!"))
	START_PROCESSING(SSobj, src)
	regeneration_start_timer = null
	if(!outline_colour)
		return
	living_parent.add_filter(REGENERATION_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 150, "size" = 1))
	var/filter = living_parent.get_filter(REGENERATION_FILTER)
	animate(filter, easing = TRUE, alpha = 125, time = 2 SECONDS, loop = -1)

/datum/component/regenerator/proc/stop_regenerating()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/living_parent = parent
	var/filter = living_parent.get_filter(REGENERATION_FILTER)
	animate(filter)
	living_parent.remove_filter(REGENERATION_FILTER)

/datum/component/regenerator/process()
	if(!should_be_regenning(parent))
		stop_regenerating()
		return

	var/mob/living/living_parent = parent
	var/heal_mod = 1
	// Heal bonus for being in crit. Only applies to carbons
	if(iscarbon(living_parent))
		var/mob/living/carbon/carbon_parent
		if(/datum/disease/critical/heart_failure in carbon_parent.viruses)
			heal_mod = 2

	var/need_mob_update = FALSE
	if(brute_per_second)
		need_mob_update += living_parent.adjustBruteLoss(-1 * heal_mod * brute_per_second, updating_health = FALSE)
	if(burn_per_second)
		need_mob_update += living_parent.adjustFireLoss(-1 * heal_mod * burn_per_second, updating_health = FALSE)
	if(tox_per_second)
		need_mob_update += living_parent.adjustToxLoss(-1 * heal_mod * tox_per_second, updating_health = FALSE)
	if(oxy_per_second)
		need_mob_update += living_parent.adjustOxyLoss(-1 * heal_mod * oxy_per_second, updating_health = FALSE)

	if(need_mob_update)
		living_parent.updatehealth()

/// Checks if the passed mob is in a valid state to be regenerating
/datum/component/regenerator/proc/should_be_regenning(mob/living/who)
	if(who.stat == DEAD)
		return FALSE

	if(regen_check && !regen_check.Invoke(who))
		reset_regeneration_timer()
		return FALSE

	if(who.health < who.maxHealth)
		return TRUE

	return FALSE

#undef REGENERATION_FILTER
