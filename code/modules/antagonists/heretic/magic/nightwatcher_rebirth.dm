/datum/spell/aoe/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you and drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition \
		will have the last of their vitality drained, killing them."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "smoke"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES

	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER

/datum/spell/aoe/fiery_rebirth/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new()
	A.include_user = FALSE
	A.range = 7
	A.allowed_type = /mob/living/carbon
	return A

/datum/spell/aoe/fiery_rebirth/cast(list/targets, mob/living/carbon/user)
	user.ExtinguishMob()
	for(var/mob/living/carbon/nearby_mob in targets)
		if(nearby_mob == user)
			continue
		if(!nearby_mob.mind || !nearby_mob.client)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.stat == DEAD || !nearby_mob.on_fire)
			continue


		new /obj/effect/temp_visual/eldritch_smoke(get_turf(nearby_mob))
		nearby_mob.Beam(user, icon_state = "r_beam", time = 2 SECONDS)

		//This is essentially a death mark, use this to finish your opponent quicker.
		if(nearby_mob.health <= 0)
			nearby_mob.death()
		nearby_mob.apply_damage(20, BURN)

		// Heal the caster for every victim damaged
		var/need_mob_update = FALSE
		need_mob_update += user.adjustBruteLoss(-10, updating_health = FALSE)
		need_mob_update += user.adjustFireLoss(-10, updating_health = FALSE)
		need_mob_update += user.adjustToxLoss(-10, updating_health = FALSE)
		need_mob_update += user.adjustOxyLoss(-10, updating_health = FALSE)
		need_mob_update += user.adjustStaminaLoss(-10)
		if(need_mob_update)
			user.updatehealth()

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
