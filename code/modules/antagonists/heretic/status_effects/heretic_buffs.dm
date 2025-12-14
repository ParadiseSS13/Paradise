// POTIONS

// DUSK AND DAWN
/datum/status_effect/duskndawn
	id = "Blessing of Dusk and Dawn"
	status_type = STATUS_EFFECT_REFRESH
	duration = 90 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/duskndawn

/datum/status_effect/duskndawn/on_apply()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, id)
	owner.update_sight()
	return TRUE

/datum/status_effect/duskndawn/on_remove()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, id)
	owner.update_sight()

// WOUNDED SOLDIER
/datum/status_effect/marshal
	id = "Blessing of Wounded Soldier"
	status_type = STATUS_EFFECT_REFRESH
	duration = 60 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/marshal

/datum/status_effect/marshal/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	return TRUE

/datum/status_effect/marshal/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/human/drinker = owner
	for(var/obj/item/organ/external/E in drinker.bodyparts)
		E.fix_internal_bleeding()
		E.fix_burn_wound()
		E.mend_fracture()
	playsound(drinker, 'sound/effects/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)

/datum/status_effect/marshal/tick()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/human/carbie = owner

	carbie.adjustBruteLoss(-0.5,updating_health = FALSE, robotic = TRUE)
	carbie.adjustFireLoss(-0.5, updating_health = FALSE, robotic = TRUE)
	for(var/obj/item/organ/external/E in carbie.bodyparts)
		if(E.status & ORGAN_BROKEN | ORGAN_BURNT | ORGAN_INT_BLEEDING)
			carbie.adjustBruteLoss(-0.5,updating_health = FALSE, robotic = TRUE)
			carbie.adjustFireLoss(-0.5, updating_health = FALSE, robotic = TRUE)
	carbie.updatehealth("marshal status effect")


/atom/movable/screen/alert/status_effect/duskndawn
	name = "Blessing of Dusk and Dawn"
	desc = "Many things hide beyond the horizon. With Owl's help I managed to slip past Sun's guard and Moon's watch."
	icon_state = "duskndawn"

/atom/movable/screen/alert/status_effect/marshal
	name = "Blessing of Wounded Soldier"
	desc = "Some people seek power through redemption. One thing many people don't know is that battle \
		is the ultimate redemption, and wounds let you bask in eternal glory."
	icon_state = "wounded_soldier"

// BLADES

/// Summons multiple foating knives around the owner.
/// Each knife will block an attack straight up.
/datum/status_effect/protective_blades
	id = "Silver Knives"
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = 0
	/// The number of blades we summon up to.
	var/max_num_blades = 4
	/// The radius of the blade's orbit.
	var/blade_orbit_radius = 20
	/// The time between spawning blades.
	var/time_between_initial_blades = 0.25 SECONDS
	/// If TRUE, we self-delete our status effect after all the blades are deleted.
	var/delete_on_blades_gone = TRUE
	/// What blade type to create
	var/obj/effect/floating_blade/blade_type
	/// A list of blade effects orbiting / protecting our owner
	var/list/obj/effect/floating_blade/blades = list()

/datum/status_effect/protective_blades/on_creation(
	mob/living/new_owner,
	new_duration = -1,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/effect/floating_blade,
)

	src.duration = new_duration
	src.max_num_blades = max_num_blades
	src.blade_orbit_radius = blade_orbit_radius
	src.time_between_initial_blades = time_between_initial_blades
	src.blade_type = blade_type
	return ..()

/datum/status_effect/protective_blades/on_apply()
	RegisterSignal(owner, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_shield_reaction))
	for(var/blade_num in 1 to max_num_blades)
		var/time_until_created = (blade_num - 1) * time_between_initial_blades
		if(time_until_created <= 0)
			create_blade()
		else
			addtimer(CALLBACK(src, PROC_REF(create_blade)), time_until_created)

	return TRUE

/datum/status_effect/protective_blades/on_remove()
	UnregisterSignal(owner, COMSIG_HUMAN_CHECK_SHIELDS)
	QDEL_LIST_CONTENTS(blades)

	return ..()

/// Creates a floating blade, adds it to our blade list, and makes it orbit our owner.
/datum/status_effect/protective_blades/proc/create_blade()
	if(QDELETED(src) || QDELETED(owner))
		return

	var/obj/effect/floating_blade/blade = new blade_type(get_turf(owner))
	blades += blade
	blade.orbit(owner, blade_orbit_radius)
	RegisterSignal(blade, COMSIG_PARENT_QDELETING, PROC_REF(remove_blade))
	playsound(get_turf(owner), 'sound/items/unsheath.ogg', 33, TRUE)

/// Signal proc for [COMSIG_LIVING_CHECK_BLOCK].
/// If we have a blade in our list, consume it and block the incoming attack (shield it)
/datum/status_effect/protective_blades/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	attack_text = "the attack",
	final_block_chance = 0,
	damage = 0,
	attack_type = MELEE_ATTACK,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(!length(blades))
		return

	if(HAS_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED))
		return SHIELD_BLOCK

	ADD_TRAIT(source, TRAIT_BEING_BLADE_SHIELDED, type)

	var/obj/effect/floating_blade/to_remove = blades[1]

	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.visible_message(
		SPAN_WARNING("[to_remove] orbiting [source] snaps in front of [attack_text], blocking it before vanishing!"),
		SPAN_WARNING("[to_remove] orbiting you snaps in front of [attack_text], blocking it before vanishing!"),
		SPAN_HEAR("You hear a clink."),
	)

	qdel(to_remove)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(callback_remove_trait), source, TRAIT_BEING_BLADE_SHIELDED, type), 0.1 SECONDS)

	return SHIELD_BLOCK

/// Remove deleted blades from our blades list properly.
/datum/status_effect/protective_blades/proc/remove_blade(obj/effect/floating_blade/to_remove)
	SIGNAL_HANDLER

	if(!(to_remove in blades))
		CRASH("[type] called remove_blade() with a blade that was not in its blades list.")

	to_remove.stop_orbit(owner.get_orbiters())
	blades -= to_remove

	if(!length(blades) && !QDELETED(src) && delete_on_blades_gone)
		qdel(src)

	return SHIELD_BLOCK

/// A subtype that doesn't self-delete / disappear when all blades are gone
/// It instead regenerates over time back to the max after blades are consumed
/datum/status_effect/protective_blades/recharging
	delete_on_blades_gone = FALSE
	/// The amount of time it takes for a blade to recharge
	var/blade_recharge_time = 1 MINUTES

/datum/status_effect/protective_blades/recharging/on_creation(
	mob/living/new_owner,
	new_duration = -1,
	max_num_blades = 4,
	blade_orbit_radius = 20,
	time_between_initial_blades = 0.25 SECONDS,
	blade_type = /obj/projectile/magic/floating_blade,
	blade_recharge_time = 1 MINUTES,
)

	src.blade_recharge_time = blade_recharge_time
	return ..()

/datum/status_effect/protective_blades/recharging/remove_blade(obj/effect/floating_blade/to_remove)
	. = ..()
	if(!.)
		return

	addtimer(CALLBACK(src, PROC_REF(create_blade)), blade_recharge_time)


/datum/status_effect/caretaker_refuge
	id = "Caretaker’s Last Refuge"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/caretaker_refuge/on_apply()
	animate(owner, alpha = 45,time = 0.5 SECONDS)
	owner.set_density(FALSE)
	owner.status_flags |= GODMODE
	owner.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))
	RegisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST, PROC_REF(prevent_spell_usage))
	RegisterSignal(owner, COMSIG_ATOM_HOLY_ATTACK, PROC_REF(nullrod_handler))

	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, id)
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	return TRUE

/datum/status_effect/caretaker_refuge/on_remove()
	owner.alpha = initial(owner.alpha)
	owner.density = initial(owner.density)
	owner.mouse_opacity = initial(owner.mouse_opacity)
	owner.status_flags &= ~GODMODE
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	UnregisterSignal(owner, COMSIG_MOB_BEFORE_SPELL_CAST)
	UnregisterSignal(owner, COMSIG_ATOM_HOLY_ATTACK)
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, id)
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	owner.visible_message(
		SPAN_WARNING("The haze around [owner] disappears, leaving them materialized!"),
		SPAN_NOTICE("You exit the refuge."),
	)

/datum/status_effect/caretaker_refuge/proc/nullrod_handler(datum/source, obj/item/weapon)
	SIGNAL_HANDLER
	playsound(get_turf(owner), 'sound/effects/curse/curse1.ogg', 80, TRUE)
	owner.visible_message(SPAN_WARNING("[weapon] repels the haze around [owner]!"))
	owner.remove_status_effect(type)

/datum/status_effect/caretaker_refuge/proc/on_focus_lost()
	SIGNAL_HANDLER
	to_chat(owner, SPAN_DANGER("Without a focus, your refuge weakens and dissipates!"))
	qdel(src)

/datum/status_effect/caretaker_refuge/proc/prevent_spell_usage(datum/source, datum/spell)
	SIGNAL_HANDLER
	if(!istype(spell, /datum/spell/caretaker))
		to_chat(owner, SPAN_DANGER("You can not cast a spell in refuge!"))
		return SPELL_CANCEL_CAST


// Path Of Moon status effect which hides the identity of the heretic
/datum/status_effect/moon_grasp_hide
	id = "Moon Grasp Hide Identity"
	status_type = STATUS_EFFECT_REFRESH
	duration = 15 SECONDS
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/moon_grasp_hide

/datum/status_effect/moon_grasp_hide/on_apply()
	ADD_TRAIT(owner, TRAIT_UNKNOWN, id)
	ADD_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)
	return ..()

/datum/status_effect/moon_grasp_hide/on_remove()
	REMOVE_TRAIT(owner, TRAIT_UNKNOWN, id)
	REMOVE_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)

/atom/movable/screen/alert/status_effect/moon_grasp_hide
	name = "Blessing of The Moon"
	desc = "The Moon clouds their vision, as the sun always has yours."
	icon_state = "moon_hide"

