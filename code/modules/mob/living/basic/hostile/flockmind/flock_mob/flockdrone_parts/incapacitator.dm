/datum/flockdrone_part/incapacitator
	/// Maximum shots that can be stored
	var/max_shots = 5

	/// How many shots we have left
	var/shot_count = 5

	/// Time between shots cooldown
	COOLDOWN_DECLARE(shoot_cd)
	/// Time between shots
	var/time_between_shots = 1.2 SECONDS

	/// Time to gain 1 charge.
	var/recharge_time = 4 SECONDS

	var/recharge_timer_id

/datum/flockdrone_part/incapacitator/left_click_on(atom/target, in_reach)
	if(!COOLDOWN_FINISHED(src, shoot_cd))
		return FALSE

	if(!shot_count)
		return FALSE

	shot_count -= 1
	screen_obj?.update_appearance()

	var/obj/projectile/energy/flock_bolt/bolt = new(get_turf(drone))
	bolt.preparePixelProjectile(target, drone)
	bolt.fire()
	playsound(drone, 'sound/weapons/resonator_fire.ogg', 50, TRUE)

	if(!recharge_timer_id)
		recharge_timer_id = addtimer(CALLBACK(src, PROC_REF(recharge)), recharge_time)

	COOLDOWN_START(src, shoot_cd, time_between_shots)
	return TRUE

/// Increments shot count by 1 and starts the recharge timer if necessary.
/datum/flockdrone_part/incapacitator/proc/recharge()
	shot_count = min(shot_count + 1, max_shots)
	screen_obj?.update_appearance()

	if(shot_count == max_shots)
		recharge_timer_id = null
	else
		recharge_timer_id = addtimer(CALLBACK(src, PROC_REF(recharge)), recharge_time)

