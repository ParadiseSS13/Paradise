/datum/spell/fireball/star_blast
	name = "Star Blast"
	desc = "This spell fires a disk with cosmic energies at a target, spreading the star mark."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "star_blast"
	what_icon_state = "star_blast"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	is_a_heretic_spell = TRUE
	base_cooldown = 20 SECONDS

	invocation = "R'T'T' ST'R!"
	selection_activated_message = "You prepare to cast your star blast!"
	selection_deactivated_message = "You stop swirling cosmic energies from the palm of your hand... for now."
	fireball_type = /obj/projectile/magic/star_ball
	cares_about_turf = FALSE

/obj/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	speed = 5
	range = 100
	knockdown = 4 SECONDS
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3

/obj/projectile/magic/star_ball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	var/pins_hit = 0
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)
		pins_hit++
	if(pins_hit >= 10)
		playsound(get_turf(src), 'sound/effects/bowling_strike.ogg', 100, FALSE)
		for(var/mob/nearby_mob in range(9, target))
			to_chat(nearby_mob, SPAN_HIEROPHANT_WARNING("STRIKE!"))

/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	for(var/turf/cast_turf in RANGE_TURFS(1, src))
		new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

