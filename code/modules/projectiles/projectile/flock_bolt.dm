/obj/projectile/energy/flock_bolt
	name = "incapacitor bolt"
	icon = 'icons/goonstation/mob/featherzone.dmi'
	icon_state = "stunbolt"

	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	hitsound = 'sound/effects/sparks3.ogg'

	pass_flags = PASSGLASS
	speed = 0.7
	damage = 4

	stamina = 25

	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

	light_color = "#55b598"

	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/energy/flock_bolt/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/victim = target
	victim.SetConfused(2.5 SECONDS)
