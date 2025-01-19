/datum/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Lets you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 9 tiles."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 25 SECONDS

	invocation = "RE'L'TY PH'S'E."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/spell/pointed/void_phase/cast(list/targets, mob/user)
	. = ..()
	var/turf/source_turf = get_turf(user)
	var/cast_on = targets[1]
	var/turf/targeted_turf = get_turf(cast_on)

	cause_aoe(source_turf, /obj/effect/temp_visual/voidin, user)
	cause_aoe(targeted_turf, /obj/effect/temp_visual/voidout, user)

	user.forceMove(cast_on)

/// Does the AOE effect of the blinka t the passed turf
/datum/spell/pointed/void_phase/proc/cause_aoe(turf/target_turf, effect_type = /obj/effect/temp_visual/voidin, mob/user)
	new effect_type(target_turf)
	playsound(target_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	for(var/mob/living/living_mob in range(damage_radius, target_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == user)
			continue
		if(living_mob.can_block_magic(antimagic_flags))
			continue
		living_mob.apply_damage(40, BRUTE)
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
