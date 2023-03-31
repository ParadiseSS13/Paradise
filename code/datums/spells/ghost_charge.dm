#define NORMAL_GHOST_CHARGE_POWER 1
#define ADMIN_GHOST_CHARGE_POWER 2
#define MAINT_GHOST_CHARGE_POWER 3

/obj/effect/proc_holder/spell/ghost_charge
	name = "Chaaaarge!"
	desc = "How about a moshpit in the afterlife?"
	ghost = TRUE

	action_icon = 'icons/mob/actions/ghost_charge.dmi'
	action_icon_state = "ghost_charge"
	school = "transmutation"
	base_cooldown = 5 SECONDS
	clothes_req = FALSE
	stat_allowed = UNCONSCIOUS
	invocation = ""
	invocation_type = "none"
	var/power_level
	create_attack_logs = FALSE

/obj/effect/proc_holder/spell/ghost_charge/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/T = new()
	return T

/obj/effect/proc_holder/spell/ghost_charge/proc/get_power_level(mob/target)
	if(check_rights(R_MAINTAINER, FALSE, target))
		return MAINT_GHOST_CHARGE_POWER
	if(is_admin(target))
		return ADMIN_GHOST_CHARGE_POWER
	return NORMAL_GHOST_CHARGE_POWER

/obj/effect/proc_holder/spell/ghost_charge/Click(mob/user = usr)
	..()
	if(active)
		stop_orbit()
		user.SpinAnimation(2, parallel = FALSE)
	else
		animate(user)

/obj/effect/proc_holder/spell/ghost_charge/cast(list/targets, mob/user)
	if(!power_level)
		power_level = get_power_level(user)
	var/atom/target = targets[1]
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	animate(user) // stop the spin
	stop_orbit()
	user.throw_at(target, 5, 2, user, FALSE, callback = CALLBACK(src, PROC_REF(at_end), user), do_hit_check = FALSE)

/obj/effect/proc_holder/spell/ghost_charge/proc/at_end(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/effect/proc_holder/spell/ghost_charge/proc/on_moved(mob/user, atom/OldLoc)
	var/charge_angle = get_angle(OldLoc, user.loc)
	var/hit_something
	for(var/mob/dead/observer/O in user.loc)
		if(O == user)
			continue

		if(get_power_level(O) > power_level)
			// Get bounced, nerd
			var/throw_dir = angle2dir(charge_angle + 180 + rand(-45, 45))
			var/atom/throw_target = get_edge_target_turf(user.loc, throw_dir)
			user.playsound_local(user, "explosion", 50)
			user.throw_at(throw_target, get_power_level(O), 2, O, do_hit_check = FALSE)
			break

		hit_something = TRUE
		var/throw_dir = angle2dir(charge_angle + rand(-45, 45))
		var/atom/throw_target = get_edge_target_turf(user.loc, throw_dir)
		O.playsound_local(user, "swing_hit", 50)
		O.throw_at(throw_target, power_level, 1, src, do_hit_check = FALSE)

	if(hit_something)
		user.playsound_local(user, "swing_hit", 50)
