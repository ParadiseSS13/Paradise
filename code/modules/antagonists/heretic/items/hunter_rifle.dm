/// The max range we can zoom in on people from.
#define MAX_LIONHUNTER_RANGE 30

// The Lionhunter, a gun for heretics
// The ammo it uses takes time to "charge" before firing,
// releasing a homing, very damaging projectile
/obj/item/gun/projectile/shotgun/boltaction/lionhunter
	name = "\improper Lionhunter's Rifle"
	desc = "An antique looking rifle that looks immaculate despite being clearly very old."
	icon = 'icons/obj/weapons/wide_guns.dmi'
	icon_state = "lionhunter"
	inhand_icon_state = "lionhunter"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	fire_sound = 'sound/weapons/gunshots/gunshot_sniper.ogg'
	pixel_x = -8

/obj/item/gun/projectile/shotgun/boltaction/lionhunter/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIONHUNTER_FIRE)

/obj/item/gun/projectile/shotgun/boltaction/lionhunter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 3.2, flags = SCOPE_TURF_ONLY | SCOPE_NEED_ACTIVE_HAND, trait_to_add = TRAIT_THERMAL_VISION)

/obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	name = "lionhunter rifle internal magazine"
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/lionhunter
	caliber = "a762-H"
	max_ammo = 3
	multi_sprite_step = 1

/obj/item/ammo_casing/lionhunter
	icon = 'icons/obj/ammo.dmi'
	icon_state = "310-casing"
	caliber = "a762-H"
	projectile_type = /obj/projectile/homing/lionhunter
	/// Whether we're currently aiming this casing at something
	var/currently_aiming = FALSE
	/// How many seconds it takes to aim per tile of distance between the target
	var/seconds_per_distance = 0.2 SECONDS
	/// The minimum distance required to gain a damage bonus from aiming
	var/min_distance = 4

/obj/item/ammo_casing/lionhunter/fire(atom/target, mob/living/user, params, distro, quiet, zone_override = "", spread, atom/firer_source_atom)
	if(!BB)
		return
	if(!check_fire(target, user))
		return
	return ..()

/// Checks if we can successfully fire our projectile.
/obj/item/ammo_casing/lionhunter/proc/check_fire(atom/target, mob/living/user)
	// In case someone puts this in turrets or something wacky, just fire like normal
	if(!iscarbon(user) || !istype(loc, /obj/item/ammo_box/magazine/internal/boltaction/lionhunter))
		return TRUE

	if(currently_aiming)
		to_chat(user, SPAN_HIEROPHANT_WARNING("You are already aiming!"))
		return FALSE

	var/distance = get_dist(user, target)
	if(target.z != user.z || distance > MAX_LIONHUNTER_RANGE)
		return FALSE

	var/fire_time = min(distance * seconds_per_distance, 10 SECONDS)

	if(distance <= min_distance || !isliving(target))
		return TRUE

	to_chat(user, SPAN_HIEROPHANT("Taking aim..."))
	user.playsound_local(get_turf(user), 'sound/weapons/gun_interactions/rifle_load.ogg', 100, TRUE)

	var/image/reticle = image(
		icon = 'icons/mob/actions/actions.dmi',
		icon_state = "sniper_zoom",
		layer = ABOVE_MOB_LAYER,
		loc = target,
	)
	reticle.alpha = 0

	var/list/mob/viewers = viewers(target)
	// The shooter might be out of view, but they should be included
	viewers |= user

	for(var/mob/viewer as anything in viewers)
		viewer.client?.images |= reticle

	// Animate the fade in
	animate(reticle, fire_time * 0.5, alpha = 255, transform = turn(reticle.transform, 180))
	animate(reticle, fire_time * 0.5, transform = turn(reticle.transform, 180))

	currently_aiming = TRUE
	var/output = do_after(user, fire_time, target = target, extra_checks = list(CALLBACK(src, PROC_REF(check_fire_callback), target, user)), allow_moving_target = TRUE)
	animate(reticle, 0.5 SECONDS, alpha = 0)
	for(var/mob/viewer as anything in viewers)
		viewer.client?.images -= reticle
	if(!output)
		currently_aiming = FALSE
		to_chat(user, SPAN_HIEROPHANT_WARNING("You were interrupted!"))
		return FALSE

	return TRUE

/// Callback for the do_after within the check_fire proc to see if something will prevent us from firing while aiming
/obj/item/ammo_casing/lionhunter/proc/check_fire_callback(mob/living/target, mob/living/user)
	if(!isturf(target.loc))
		return TRUE

	return FALSE

/obj/item/ammo_casing/lionhunter/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(!BB)
		return

	var/distance = get_dist(user, target)
	// If we're close range, or the target's not a living, OR for some reason a non-carbon is firing the gun
	// The projectile is dry-fired, and gains no buffs
	// BUT, if we're at a decent range and the target's a living mob,
	// the projectile's been channel fired. It has full effects and homes in.
	if(distance > min_distance && isliving(target) && iscarbon(user))
		BB.stamina *= 2
		BB.knockdown = 0.5 SECONDS
		BB.stutter = 6 SECONDS
		BB.forcedodge = -1
		BB.armor_penetration_flat = 100 //No parrying this bad boy
		if(istype(BB, /obj/projectile/homing/lionhunter))
			var/obj/projectile/homing/lionhunter/if_an_admin_var_edits_another_projectile_inside_an_ammo_casing_ill_be_very_mad = BB
			if_an_admin_var_edits_another_projectile_inside_an_ammo_casing_ill_be_very_mad.homing_active = TRUE

	return ..()

/obj/projectile/homing/lionhunter
	name = "hunter's .310 bullet"
	// These stats are only applied if the weapon is fired unscoped
	// If fired without aiming or at someone too close, it will do this much
	damage = 30
	stamina = 30
	homing_active = FALSE
	///The mob that is currently inside the bullet
	var/mob/stored_mob

/obj/projectile/homing/lionhunter/fire(angle, atom/direct_target)
	. = ..()
	if(QDELETED(src) || !isliving(firer) || !isliving(original))
		return
	var/mob/living/living_firer = firer
	if(IS_HERETIC(living_firer))
		living_firer.forceMove(src)
		stored_mob = living_firer


/obj/projectile/homing/lionhunter/Exited(atom/movable/gone)
	if(gone == stored_mob)
		stored_mob = null
	return ..()

/obj/projectile/homing/lionhunter/on_range()
	stored_mob?.forceMove(loc)
	return ..()

/obj/projectile/homing/lionhunter/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(target != original)
		return
	stored_mob?.forceMove(loc) //Pretty important to get our mob out of the bullet once we hit our target
	var/mob/living/victim = target
	var/mob/firing_mob = firer
	if(IS_HERETIC_OR_MONSTER(victim) || !IS_HERETIC(firing_mob))
		qdel(src)
		return

	SEND_SIGNAL(firer, COMSIG_LIONHUNTER_ON_HIT, victim)
	qdel(src)
	return

/obj/projectile/homing/lionhunter/Destroy()
	if(stored_mob)
		stack_trace("Lionhunter bullet qdel'd with its firer still inside!")
		stored_mob.forceMove(loc)
	return ..()

// Extra ammunition can be made with a heretic ritual.
/obj/item/ammo_box/lionhunter
	name = "stripper clip (.310 hunter)"
	desc = "A stripper clip of mysterious, atypical ammo. It doesn't fit into normal ballistic rifles."
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/lionhunter
	max_ammo = 3
	multi_sprite_step = 1

/obj/effect/temp_visual/bullet_target
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2

#undef MAX_LIONHUNTER_RANGE
