/obj/item/projectile
	///If TRUE, hit mobs even if they're on the floor and not our target
	var/hit_prone_targets = FALSE

/atom/handle_ricochet(obj/item/projectile/ricocheting_projectile)
	. = ..()
	if(.)
		// here is confirmed ricochet - force projectile to hit targets
		ricocheting_projectile.hit_prone_targets = TRUE

/obj/item/ammo_casing/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/firer_source_atom)
	. = ..()
	if(!BB)
		return
	BB.hit_prone_targets = user.a_intent != INTENT_HELP

/mob/living/carbon/human/projectile_hit_check(obj/item/projectile/P)
	if(stat == CONSCIOUS)
		return !P.hit_prone_targets && !density
	return !density
