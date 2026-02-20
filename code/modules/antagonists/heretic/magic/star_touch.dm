/datum/spell/touch/star_touch
	name = "Star Touch"
	desc = "Manifests cosmic fields on tiles next to you while marking the victim with a star mark \
		or consuming an already present star mark to put them to sleep for 4 seconds. \
		They will then be linked to you with a cosmic ray, burning them for up to a minute, or \
		until they can escape your sight. Star Touch can also remove Cosmic Runes, or teleport you \
		to your Star Gazer when used on yourself."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "star_touch"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/items/welder.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS
	invocation = "ST'R 'N'RG'!"
	invocation_type = INVOCATION_SHOUT

	hand_path = /obj/item/melee/touch_attack/star_touch
	/// Stores the UID for the Star Gazer after ascending
	var/star_gazer

/obj/item/melee/touch_attack/star_touch/after_attack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()

	if(!proximity_flag || target == user || blocked_by_antimagic || !isliving(target) || !iscarbon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //There are better ways to get a good nights sleep in a bed.
		return
	var/mob/living/living_target = target
	if(living_target.has_status_effect(/datum/status_effect/star_mark))
		living_target.Paralyse(4 SECONDS)
		living_target.remove_status_effect(/datum/status_effect/star_mark)
	else
		living_target.apply_status_effect(/datum/status_effect/star_mark, user)
	for(var/turf/cast_turf as anything in get_turfs(living_target))
		new /obj/effect/forcefield/cosmic_field(cast_turf)
	user.apply_status_effect(/datum/status_effect/cosmic_beam, living_target)
	handle_delete(user)

/obj/item/melee/touch_attack/star_touch/proc/get_turfs(mob/living/victim)
	var/list/target_turfs = list(get_turf(loc))
	var/range = attached_spell.ascended ? 2 : 1
	var/list/directions = list(turn(loc.dir, 90), turn(loc.dir, 270))
	for(var/direction as anything in directions)
		for(var/i in 1 to range)
			target_turfs += get_ranged_target_turf(loc, direction, i)
	return target_turfs


/datum/spell/touch/star_touch/proc/set_star_gazer(mob/living/basic/heretic_summon/star_gazer/star_gazer_mob)
	star_gazer = star_gazer_mob.UID()

// To obtain the star gazer if there is one
/datum/spell/touch/star_touch/proc/get_star_gazer()
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_resolved = locateUID(star_gazer)
	if(star_gazer_resolved)
		return star_gazer_resolved
	return FALSE

/obj/item/melee/touch_attack/star_touch
	name = "Star Touch"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes people with a star mark to sleep for 4 seconds, and causes people without a star mark to get one."
	icon_state = "star"
	inhand_icon_state = "star"
	catchphrase = null

/obj/item/melee/touch_attack/star_touch/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/cosmic_rune), \
	)

/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/star_touch/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(target))
	qdel(src)

/obj/item/melee/touch_attack/star_touch/activate_self(mob/user)
	if(..())
		return
	var/datum/spell/touch/star_touch/star_touch_spell = attached_spell
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = star_touch_spell?.get_star_gazer()
	if(!star_gazer_mob)
		to_chat(user, SPAN_HIEROPHANT_WARNING("You have no stargazer linked to this spell"))
		return ..()
	new /obj/effect/temp_visual/cosmic_explosion(get_turf(user))
	playsound(user, 'sound/magic/cosmic_energy.ogg', 100, TRUE)
	playsound(star_gazer_mob, 'sound/magic/cosmic_energy.ogg', 100, TRUE)
	user.forceMove(get_turf(star_gazer_mob))
	qdel(src)

/obj/effect/ebeam/cosmic
	name = "cosmic beam"

/datum/status_effect/cosmic_beam
	id = "cosmic_beam"
	tick_interval = 0.2 SECONDS
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Stores the current beam target
	var/mob/living/current_target
	/// Checks the time of the last check
	var/last_check = 0
	/// The delay of when the beam gets checked
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null

/datum/status_effect/cosmic_beam/on_creation(mob/living/new_owner, mob/living/current_target)
	src.current_target = current_target
	start_beam(current_target, new_owner)
	return ..()

/datum/status_effect/cosmic_beam/be_replaced()
	if(active)
		qdel(current_beam)
		active = FALSE
	return ..()

/datum/status_effect/cosmic_beam/tick(seconds_between_ticks)
	if(!current_target)
		lose_target()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(!can_see(owner, current_target))
		qdel(current_beam)//this will give the target lost message
		return

	if(current_target)
		on_beam_tick(current_target)

/**
 * Proc that always is called when we want to end the beam and makes sure things are cleaned up, see beam_died()
 */
/datum/status_effect/cosmic_beam/proc/lose_target()
	if(active)
		qdel(current_beam)
		active = FALSE
	if(current_target)
		on_beam_release(current_target)
	current_target = null

/**
 * Proc that is only called when the beam fails due to something, so not when manually ended.
 * manual disconnection = lose_target, so it can silently end
 * automatic disconnection = beam_died, so we can give a warning message first
 */
/datum/status_effect/cosmic_beam/proc/beam_died()
	SIGNAL_HANDLER
	to_chat(owner, SPAN_WARNING("You lose control of the beam!"))
	lose_target()
	duration = 0

/// Used for starting the beam when a target has been acquired
/datum/status_effect/cosmic_beam/proc/start_beam(atom/target, mob/living/user)

	if(current_target)
		lose_target()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = user.Beam(current_target, icon_state="cosmic_beam", time = 1 MINUTES, maxdistance = max_range, beam_type = /obj/effect/ebeam/cosmic)
	RegisterSignal(current_beam, COMSIG_PARENT_QDELETING, PROC_REF(beam_died))

	if(current_target)
		on_beam_hit(current_target)

/// What to add when the beam connects to a target
/datum/status_effect/cosmic_beam/proc/on_beam_hit(mob/living/target)
	if(!istype(target, /mob/living/basic/heretic_summon/star_gazer))
		target.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

/// What to process when the beam is connected to a target
/datum/status_effect/cosmic_beam/proc/on_beam_tick(mob/living/target)
	if(target.adjustFireLoss(3, updating_health = FALSE))
		target.updatehealth()

/// What to remove when the beam disconnects from a target
/datum/status_effect/cosmic_beam/proc/on_beam_release(mob/living/target)
	if(!istype(target, /mob/living/basic/heretic_summon/star_gazer))
		target.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
