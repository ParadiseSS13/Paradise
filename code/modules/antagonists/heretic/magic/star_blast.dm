/datum/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "This spell fires a disk with cosmic energies at a target, spreading the star mark."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "star_blast"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	is_a_heretic_spell = TRUE
	base_cooldown = 20 SECONDS

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	clothes_req = FALSE
	//active_msg = "You prepare to cast your star blast!"
//	deactive_msg = "You stop swirling cosmic energies from the palm of your hand... for now."
	cast_range = 12
	//projectile_type = /obj/item/projectile/magic/star_ball

/obj/item/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	speed = 0.2
	range = 100
	knockdown = 4 SECONDS
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3

/obj/item/projectile/magic/star_ball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

/obj/item/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob || cast_on.buckled == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)

/obj/item/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	for(var/turf/cast_turf as anything in get_turfs())
		new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/obj/item/projectile/magic/star_ball/proc/get_turfs()
	return list(get_turf(src), pick(get_step(src, NORTH), get_step(src, SOUTH)), pick(get_step(src, EAST), get_step(src, WEST)))
