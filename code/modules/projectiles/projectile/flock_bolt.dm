/obj/projectile/energy/flock_bolt
	name = "incapacitor bolt"
	icon = 'goon/icons/mob/featherzone.dmi'
	icon_state = "stunbolt"

	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	hitsound = 'goon/sounds/weapons/sparks6.ogg'

	pass_flags = PASSGLASS
	speed = 0.7
	damage = 4
	damage_type = BURN

	disorient_damage = 25
	disorient_length = 2.5 SECONDS

	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

	light_color = "#55b598"

	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/energy/flock_bolt/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(. != BULLET_ACT_HIT)
		return

	if(!isliving(target))
		return

	var/mob/living/victim = target
	victim.Disorient(2.5 SECONDS, ceil(STAMINA_MAX / 4), knockdown = 2.5 SECONDS, overstam = TRUE)

/obj/projectile/energy/flock_bolt/can_hit_target(atom/target, direct_target, ignore_loc, cross_failed)
	if(isflockmob(target))
		return FALSE
	return ..()
