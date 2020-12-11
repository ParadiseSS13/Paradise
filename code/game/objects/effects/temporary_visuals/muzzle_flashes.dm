/obj/effect/temp_visual/target_angled/muzzle_flash
	icon = 'icons/effects/projectile.dmi'
	icon_state = "firing_effect"
	duration = 0.2

/obj/effect/temp_visual/target_angled/muzzle_flash/Initialize(mapload, atom/target, duration_override = null)
	if(duration_override)
		duration = duration_override
	. = ..()
	if(get_dir(src, target) & NORTH)
		layer = BELOW_MOB_LAYER


/obj/effect/temp_visual/target_angled/muzzle_flash/energy
	icon_state = "firing_effect_energy"

/obj/effect/temp_visual/target_angled/muzzle_flash/magic
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
