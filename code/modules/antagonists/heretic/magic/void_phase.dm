/datum/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Lets you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 9 tiles."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 40 SECONDS

	invocation = "RE'L'TY PH'S'E."
	invocation_type = INVOCATION_WHISPER

	cast_range = 9
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/spell/pointed/void_phase/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.allowed_type = /turf/simulated
	return T

/datum/spell/pointed/void_phase/valid_target(target, user)
	if(get_dist(target, user) < 3)
		var/mob/living/living_owner = user
		to_chat(living_owner, SPAN_WARNING("That is too close to teleport to!"))
		return FALSE
	return TRUE

/datum/spell/pointed/void_phase/cast(list/targets, mob/user)
	. = ..()
	var/turf/source_turf = get_turf(user)
	var/cast_on = targets[1]
	var/turf/targeted_turf = get_turf(cast_on)
	if(SEND_SIGNAL(user, COMSIG_MOVABLE_TELEPORTING, targeted_turf) & COMPONENT_BLOCK_TELEPORT)
		return FALSE

	cause_aoe(source_turf, /obj/effect/temp_visual/voidin, user)
	cause_aoe(targeted_turf, /obj/effect/temp_visual/voidout, user)

	user.forceMove(targeted_turf)

/// Does the AOE effect of the blinka t the passed turf
/datum/spell/pointed/void_phase/proc/cause_aoe(turf/target_turf, effect_type = /obj/effect/temp_visual/voidin, mob/user)
	new effect_type(target_turf)
	playsound(target_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	for(var/mob/living/living_mob in range(damage_radius, target_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == user)
			continue
		if(living_mob.can_block_magic(antimagic_flags))
			continue
		living_mob.apply_damage(20, BRUTE)
		living_mob.apply_status_effect(/datum/status_effect/void_chill, 1)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
