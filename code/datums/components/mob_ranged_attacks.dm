/**
 * Configurable ranged attack for basic mobs.
 */
/datum/component/ranged_attacks
	/// What kind of projectile to we fire?
	var/projectile_type
	/// Sound to play when we fire our projectile
	var/projectile_sound
	/// how many shots we will fire
	var/burst_shots
	/// intervals between shots
	var/burst_intervals
	/// Time to wait between shots
	var/cooldown_time
	/// Tracks time between shots
	COOLDOWN_DECLARE(fire_cooldown)

/datum/component/ranged_attacks/Initialize(
	projectile_type,
	projectile_sound = 'sound/weapons/gunshots/gunshot.ogg',
	burst_shots,
	burst_intervals = 0.2 SECONDS,
	cooldown_time = 3 SECONDS,
)
	. = ..()
	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.projectile_sound = projectile_sound
	src.projectile_type = projectile_type
	src.cooldown_time = cooldown_time

	if(!projectile_type)
		CRASH("Set no projectile type in [parent]'s ranged attacks component! What are they supposed to be attacking with, air?")
	if(burst_shots <= 1)
		return
	src.burst_shots = burst_shots
	src.burst_intervals = burst_intervals

/datum/component/ranged_attacks/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_ATTACK_RANGED, PROC_REF(fire_ranged_attack))
	ADD_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/ranged_attacks/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_RANGED)
	REMOVE_TRAIT(parent, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, type)

/datum/component/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		return
	if(SEND_SIGNAL(firer, COMSIG_BASICMOB_PRE_ATTACK_RANGED, target, modifiers) & COMPONENT_CANCEL_RANGED_ATTACK)
		return
	COOLDOWN_START(src, fire_cooldown, cooldown_time)
	INVOKE_ASYNC(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers)
	if(isnull(burst_shots))
		return
	for(var/i in 1 to (burst_shots - 1))
		addtimer(CALLBACK(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers), i * burst_intervals)

/// Actually fire the damn thing
/datum/component/ranged_attacks/proc/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	firer.face_atom(target)
	var/turf/current_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)

	var/obj/item/projectile/mob_projectile = new projectile_type(firer.loc)
	mob_projectile.firer = firer
	mob_projectile.firer_source_atom = firer
	mob_projectile.def_zone = pick("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg")
	mob_projectile.original = target
	mob_projectile.current = current_turf
	mob_projectile.yo = target_turf.y - current_turf.y
	mob_projectile.xo = target_turf.x - current_turf.x
	mob_projectile.fire()
	playsound(firer, projectile_sound, 100, TRUE)
	SEND_SIGNAL(parent, COMSIG_BASICMOB_POST_ATTACK_RANGED, target, modifiers)
	return

