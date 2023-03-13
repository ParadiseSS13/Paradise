#define KW *1000
#define PULSEDEMON_REMOTE_DRAIN_MULTIPLIER 5

/obj/effect/proc_holder/spell/pulse_demon
	panel = "Pulse Demon"
	school = "pulse demon"
	clothes_req = FALSE
	action_background_icon_state = "bg_pulsedemon"
	has_altclick = TRUE
	var/locked = TRUE
	var/unlock_cost = 1 KW
	var/cast_cost = 1 KW
	var/upgrade_cost = 1 KW
	var/requires_area = FALSE
	base_cooldown = 20 SECONDS
	level_max = 4

/obj/effect/proc_holder/spell/pulse_demon/New()
	. = ..()
	update_info()

/obj/effect/proc_holder/spell/pulse_demon/proc/update_info()
	if(locked)
		name = "[initial(name)] (Locked) ([format_si_suffix(unlock_cost)]W)"
		desc = "[initial(desc)] It costs [format_si_suffix(unlock_cost)]W to unlock."
	else
		name = "[initial(name)][cast_cost == 0 ? "" : " ([format_si_suffix(cast_cost)]W)"]"
		desc = "[initial(desc)][spell_level == level_max ? "" : " It costs [format_si_suffix(upgrade_cost)]W to upgrade."]"
	action.button.name = name
	action.desc = desc
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pulse_demon/can_cast(mob/living/simple_animal/pulse_demon/user, charge_check, show_message)
	if(!..())
		return FALSE
	if(!istype(user))
		return FALSE
	if(locked)
		if(show_message)
			to_chat(user, "<span class='warning'>This ability is locked! Alt-click the button to purchase this ability.</span>")
			to_chat(user, "<span class='notice'>It costs [format_si_suffix(unlock_cost)]W to unlock.</span>")
		return FALSE
	if(user.charge < cast_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>You do not have enough charge to use this ability!</span>")
			to_chat(user, "<span class='notice'>It costs [format_si_suffix(cast_cost)]W to use.</span>")
		return FALSE
	if(requires_area && !user.controlling_area)
		if(show_message)
			to_chat(user, "<span class='warning'>You need to be controlling an area to use this ability!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/cast(list/targets, mob/living/simple_animal/pulse_demon/user)
	if(!istype(user) || locked || user.charge < cast_cost || !targets)
		return FALSE
	if(requires_area && !user.controlling_area)
		return FALSE
	if(requires_area && user.controlling_area != get_area(targets[1]))
		to_chat(user, "<span class='warning'>You can only use this ability in your controlled area!</span>")
		return FALSE
	if(try_cast_action(user, targets[1]))
		user.adjustCharge(-cast_cost)
		return TRUE
	else
		revert_cast(user)
	return FALSE

/obj/effect/proc_holder/spell/pulse_demon/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/pulse_demon/proc/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	return FALSE

// handles purchasing and upgrading abilities
/obj/effect/proc_holder/spell/pulse_demon/AltClick()
	var/mob/living/simple_animal/pulse_demon/user = usr
	if(!istype(user))
		return

	if(locked)
		if(user.charge >= unlock_cost)
			user.adjustCharge(-unlock_cost)
			locked = FALSE
			to_chat(user, "<span class='notice'>You have unlocked [initial(name)]!</span>")

			if(cast_cost > 0)
				to_chat(user, "<span class='notice'>It costs [format_si_suffix(cast_cost)]W to use once.</span>")
			if(level_max > 0 && spell_level < level_max)
				to_chat(user, "<span class='notice'>It will cost [format_si_suffix(upgrade_cost)]W to upgrade.</span>")

			update_info()
		else
			to_chat(user, "<span class='warning'>You cannot afford this ability! It costs [format_si_suffix(unlock_cost)]W to unlock.</span>")
	else
		if(spell_level >= level_max)
			to_chat(user, "<span class='warning'>You have already fully upgraded this ability!</span>")
		else if(user.charge >= upgrade_cost)
			user.adjustCharge(-upgrade_cost)
			spell_level = min(spell_level + 1, level_max)
			upgrade_cost = round(initial(upgrade_cost) * (1.5 ** spell_level))
			do_upgrade(user)

			if(spell_level == level_max)
				to_chat(user, "<span class='notice'>You have fully upgraded [initial(name)]!</span>")
			else
				to_chat(user, "<span class='notice'>The next upgrade will cost [format_si_suffix(upgrade_cost)]W to unlock.</span>")

			update_info()
		else
			to_chat(user, "<span class='warning'>You cannot afford to upgrade this ability! It costs [format_si_suffix(upgrade_cost)]W to upgrade.</span>")

/obj/effect/proc_holder/spell/pulse_demon/proc/do_upgrade(mob/living/simple_animal/pulse_demon/user)
	cooldown_handler.recharge_duration = round(base_cooldown / (1.5 ** spell_level))
	to_chat(user, "<span class='notice'>You have upgraded [initial(name)] to level [spell_level + 1], it now takes [cooldown_handler.recharge_duration / 10] seconds to recharge.</span>")

/obj/effect/proc_holder/spell/pulse_demon/cablehop
	name = "Cable Hop"
	desc = "Jump to another cable in view."
	action_icon_state = "pd_cablehop"
	unlock_cost = 15 KW
	cast_cost = 5 KW
	upgrade_cost = 75 KW

/obj/effect/proc_holder/spell/pulse_demon/cablehop/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/turf/O = get_turf(user)
	var/turf/T = get_turf(target)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!istype(C))
		to_chat(user, "<span class='warning'>No cable found!</span>")
		return FALSE
	playsound(T, 'sound/magic/lightningshock.ogg', 50, 1)
	O.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)
	for(var/turf/working in getline(O, T))
		for(var/mob/M in working)
			electrocute_mob(M, C.powernet, user)
	user.forceMove(T)
	user.Move(T)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/emagtamper
	name = "Electromagnetic Tamper"
	desc = "Unlocks hidden programming in machines. Must be inside a hijacked APC to use."
	action_icon_state = "pd_emag"
	unlock_cost = 50 KW
	cast_cost = 20 KW
	upgrade_cost = 200 KW
	requires_area = TRUE

/obj/effect/proc_holder/spell/pulse_demon/emagtamper/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	target.emag_act(user)
	to_chat(user, "<span class='warning'>You attempt to tamper with [target]!</span>")
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/emp
	name = "Electromagnetic Pulse"
	desc = "Creates an EMP where you click. Be careful not to use it on yourself!"
	action_icon_state = "pd_emp"
	unlock_cost = 50 KW
	cast_cost = 10 KW
	upgrade_cost = 200 KW
	requires_area = TRUE

/obj/effect/proc_holder/spell/pulse_demon/emp/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	empulse(get_turf(target), 1, 1)
	to_chat(user, "<span class='warning'>You EMP [target]!</span>")
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/overload
	name = "Overload Machine"
	desc = "Overloads a machine, causing it to explode."
	action_icon_state = "pd_overload"
	unlock_cost = 300 KW
	cast_cost = 50 KW
	upgrade_cost = 500 KW
	requires_area = TRUE

/obj/effect/proc_holder/spell/pulse_demon/overload/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/obj/machinery/M = target
	if(!istype(M))
		to_chat(user, "<span class='warning'>That is not a machine.</span>")
		return FALSE
	if(target.flags_2 & NO_MALF_EFFECT_2)
		to_chat(user, "<span class='warning'>That machine cannot be overloaded.</span>")
		return FALSE
	target.audible_message("<span class='italics'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	addtimer(CALLBACK(null, TYPE_PROC_REF(/datum/action/innate/ai/ranged/overload_machine, detonate_machine), target), 5 SECONDS)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/remotehijack
	name = "Remote Hijack"
	desc = "Remotely hijacks an APC."
	action_icon_state = "pd_remotehack"
	unlock_cost = 15 KW
	cast_cost = 10 KW
	level_max = 0
	base_cooldown = 3 SECONDS // you have to wait for the regular hijack time anyway

/obj/effect/proc_holder/spell/pulse_demon/remotehijack/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/obj/machinery/power/apc/A = target
	if(!istype(A))
		to_chat(user, "<span class='warning'>That is not an APC.</span>")
		return FALSE
	if(!user.try_hijack_apc(A, TRUE))
		to_chat(user, "<span class='warning'>You cannot hijack that APC right now!</span>")
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/remotedrain
	name = "Remote Drain"
	desc = "Remotely drains a power source."
	action_icon_state = "pd_remotedrain"
	unlock_cost = 5 KW
	cast_cost = 100
	upgrade_cost = 100 KW

/obj/effect/proc_holder/spell/pulse_demon/remotedrain/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(istype(target, /obj/machinery/power/apc))
		var/drained = user.drainAPC(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		if(drained == -1)
			to_chat(user, "<span class='warning'>This APC is being hijacked, you cannot drain from it right now.</span>")
		else
			to_chat(user, "<span class='notice'>You drain [format_si_suffix(drained)]W from [target].</span>")
	else if(istype(target, /obj/machinery/power/smes))
		var/drained = user.drainSMES(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		to_chat(user, "<span class='notice'>You drain [format_si_suffix(drained)]W from [target].</span>")
	else
		to_chat(user, "<span class='warning'>That is not a valid source.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/toggle
	base_cooldown = 0
	cast_cost = 0
	create_attack_logs = FALSE
	var/base_message = "see messages you shouldn't!"

/obj/effect/proc_holder/spell/pulse_demon/toggle/New(initstate = FALSE)
	. = ..()
	do_toggle(initstate, null)

/obj/effect/proc_holder/spell/pulse_demon/toggle/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/pulse_demon/toggle/proc/do_toggle(varstate, mob/user)
	if(action)
		action.background_icon_state = varstate ? action_background_icon_state : "[action_background_icon_state]_disabled"
		action.UpdateButtonIcon()
	if(user)
		to_chat(user, "<span class='notice'>You will [varstate ? "now" : "no longer"] [base_message]</span>")
	return varstate

/obj/effect/proc_holder/spell/pulse_demon/toggle/do_drain
	name = "Toggle Draining"
	desc = "Toggle whether you drain charge from power sources."
	base_message = "drain charge from power sources."
	action_icon_state = "pd_toggle_steal"
	locked = FALSE
	level_max = 0

/obj/effect/proc_holder/spell/pulse_demon/toggle/do_drain/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	user.do_drain = do_toggle(!user.do_drain, user)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable
	name = "Toggle Self-Sustaining"
	desc = "Toggle whether you can move outside of cables or power sources."
	base_message = "move outside of cables."
	action_icon_state = "pd_toggle_exit"
	unlock_cost = 100 KW
	upgrade_cost = 300 KW
	level_max = 3

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(user.can_exit_cable && !(user.current_cable || user.current_power))
		to_chat(user, "<span class='warning'>Enter a cable or power source first!</span>")
		return FALSE
	user.can_exit_cable = do_toggle(!user.can_exit_cable, user)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/do_upgrade(mob/living/simple_animal/pulse_demon/user)
	user.outside_cable_speed = max(initial(user.outside_cable_speed) - spell_level, 1)
	to_chat(user, "<span class='notice'>You have upgraded [initial(name)] to level [spell_level + 1], you will now move faster outside of cables.</span>")

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera
	name = "Cycle Camera View"
	desc = "Jump between the cameras in your APC's area. Alt-click to return to the APC."
	action_icon_state = "pd_camera_view"
	create_attack_logs = FALSE
	locked = FALSE
	cast_cost = 0
	level_max = 0
	base_cooldown = 0
	requires_area = TRUE
	var/current_camera = 0

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera/AltClick()
	var/mob/living/simple_animal/pulse_demon/user = usr
	if(!istype(user))
		return
	current_camera = 0

	if(!istype(user.current_power, /obj/machinery/power/apc))
		return
	if(get_area(user.loc) != user.controlling_area)
		return
	user.forceMove(user.current_power)

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(length(user.controlling_area.cameras) < 1)
		return

	if(istype(user.loc, /obj/machinery/power/apc))
		current_camera = 0
	else if(istype(user.loc, /obj/machinery/camera))
		current_camera = (current_camera + 1) % length(user.controlling_area.cameras)
		if(current_camera == 0)
			user.forceMove(user.current_power)
			return

	if(length(user.controlling_area.cameras) < current_camera)
		current_camera = 0
	user.forceMove(locateUID(user.controlling_area.cameras[current_camera + 1]))

#undef KW
