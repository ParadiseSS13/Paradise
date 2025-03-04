/// Turf type that appears to be a world border, completely impassable and non-interactable to all physical (alive) entities.
/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	explosion_block = 50
	rad_insulation_beta = RAD_FULL_INSULATION
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	baseturf = /turf/cordon

// /turf/cordon/rust_heretic_act()
// 	return FALSE

/turf/cordon/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/cordon/singularity_act()
	return FALSE

/turf/cordon/TerraformTurf(path, list/new_baseturfs, flags)
	return

/turf/cordon/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit)
	SHOULD_CALL_PARENT(FALSE) // Fuck you
	return

/turf/cordon/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return FALSE
