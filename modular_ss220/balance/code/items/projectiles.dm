/obj/item/projectile
	///If TRUE, hit mobs even if they're on the floor and not our target
	var/hit_prone_targets = FALSE

/obj/item/projectile/set_angle(new_angle)
	. = ..()
	hit_prone_targets = TRUE

/obj/item/ammo_casing/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/firer_source_atom)
	. = ..()
	if(!BB)
		return
	if(user.a_intent != INTENT_HELP)
		BB.hit_prone_targets = TRUE

/mob/living/carbon/human/projectile_hit_check(obj/item/projectile/P)
	if(stat == CONSCIOUS)
		return !P.hit_prone_targets && !density
	return !density
