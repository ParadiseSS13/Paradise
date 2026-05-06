/obj/structure/flock/interceptor
	name = "weird fountain"
	desc = "Some kind of fountain. The fluid inside ripples with energy."
	icon_state = "interceptor-off"

	flock_desc = "A defense turret that fires high speed gnesis bolts at nearby projectiles, annihilating them."
	flock_id = "Interceptor"

	max_integrity = 50
	resource_cost = 100

	var/tmp/datum/proximity_monitor/advanced/interceptor/proxmon

	/// How long it takes to recharge
	var/recharge_time = 10 SECONDS
	/// Is it charged?
	var/tmp/is_charged = FALSE
	/// world.time the interceptor will be charged (might be off by 1 sometimes? idk timers wierd)
	var/tmp/ready_time
	/// timer id for recharging
	var/tmp/recharge_timer_id

/obj/structure/flock/interceptor/Initialize(mapload, datum/flock/join_flock)
	. = ..()
	proxmon = new(src, 2, TRUE)
	process()

/obj/structure/flock/interceptor/Destroy()
	QDEL_NULL(proxmon)
	deltimer(recharge_timer_id)
	return ..()

/obj/structure/flock/interceptor/update_icon_state()
	if(!active)
		icon_state = "interceptor-off"
	else if(is_charged)
		icon_state = "interceptor-ready"
	else
		icon_state = "interceptor-generating"
	. = ..()

/obj/structure/flock/interceptor/update_info_tag()
	info_tag.set_text(get_status())

/obj/structure/flock/interceptor/flock_structure_examine(mob/user)
	. = ..()
	. += "[get_status()]."

/obj/structure/flock/interceptor/process(delta_time)
	if(active)
		if(flock.available_bandwidth() < 0)
			set_active(FALSE)
	else
		if(flock.can_afford(active_bandwidth_cost))
			set_active(TRUE)

/obj/structure/flock/interceptor/set_active(new_state)
	. = ..()
	if(isnull(.))
		return

	if(. == TRUE)
		begin_charging()
	else
		is_charged = FALSE
		deltimer(recharge_timer_id)

/obj/structure/flock/interceptor/proc/begin_charging()
	is_charged = FALSE
	recharge_timer_id = addtimer(CALLBACK(src, PROC_REF(ready_to_fire)), recharge_time, TIMER_DELETE_ME | TIMER_STOPPABLE)
	update_appearance()

/// Called when recharge_cd is ready to fire
/obj/structure/flock/interceptor/proc/ready_to_fire()
	is_charged = TRUE
	update_appearance()

/obj/structure/flock/interceptor/proc/get_status()
	if(!active)
		return "Idle"

	if(is_charged)
		return "Ready"

	return "Recharging: [(timeleft(recharge_timer_id)) / 10] seconds"

/// Called when a projectile enters the view of the interceptor.
/obj/structure/flock/interceptor/proc/try_intercept_projectile(obj/projectile/P)
	if(!is_charged)
		return FALSE

	if(!istype(P, /obj/projectile/bullet))
		return FALSE

	playsound(src, 'goon/sounds/flockmind/flockdrone_fart.ogg', 50, TRUE) // It honestly kind of fits??
	Beam(get_turf(P), "rped_upgrade", time = 0.8 SECONDS, override_origin_pixel_y = 24, override_target_pixel_x = P.pixel_x, override_target_pixel_y = P.pixel_y)
	qdel(P)

	begin_charging()
	return TRUE
