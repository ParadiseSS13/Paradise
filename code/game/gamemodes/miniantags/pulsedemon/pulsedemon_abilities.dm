#define PULSEDEMON_REMOTE_DRAIN_MULTIPLIER 5

#define PD_UPGRADE_HIJACK_SPEED "Speed"
#define PD_UPGRADE_DRAIN_SPEED  "Absorption"
#define PD_UPGRADE_HEALTH_LOSS  "Endurance"
#define PD_UPGRADE_HEALTH_REGEN "Recovery"
#define PD_UPGRADE_MAX_HEALTH   "Strength"
#define PD_UPGRADE_HEALTH_COST  "Efficiency"
#define PD_UPGRADE_MAX_CHARGE   "Capacity"

/obj/effect/proc_holder/spell/pulse_demon
	panel = "Pulse Demon"
	school = "pulse demon"
	clothes_req = FALSE
	action_background_icon_state = "bg_pulsedemon"
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

/obj/effect/proc_holder/spell/pulse_demon/can_cast(mob/living/simple_animal/demon/pulse_demon/user, charge_check, show_message)
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

/obj/effect/proc_holder/spell/pulse_demon/cast(list/targets, mob/living/simple_animal/demon/pulse_demon/user)
	if(!istype(user) || locked || user.charge < cast_cost || !length(targets))
		return FALSE
	if(requires_area && !user.controlling_area)
		return FALSE
	if(requires_area && user.controlling_area != get_area(targets[1]))
		to_chat(user, "<span class='warning'>You can only use this ability in your controlled area!</span>")
		return FALSE
	if(try_cast_action(user, targets[1]))
		user.adjust_charge(-cast_cost)
		return TRUE
	else
		revert_cast(user)
	return FALSE

/obj/effect/proc_holder/spell/pulse_demon/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/pulse_demon/proc/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	return FALSE

// handles purchasing and upgrading abilities
/obj/effect/proc_holder/spell/pulse_demon/AltClick(mob/living/simple_animal/demon/pulse_demon/user)
	if(!istype(user))
		return

	if(locked)
		if(user.charge >= unlock_cost)
			user.adjust_charge(-unlock_cost)
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
			user.adjust_charge(-upgrade_cost)
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

/obj/effect/proc_holder/spell/pulse_demon/proc/do_upgrade(mob/living/simple_animal/demon/pulse_demon/user)
	cooldown_handler.recharge_duration = round(base_cooldown / (1.5 ** spell_level))
	to_chat(user, "<span class='notice'>You have upgraded [initial(name)] to level [spell_level + 1], it now takes [cooldown_handler.recharge_duration / 10] seconds to recharge.</span>")

/obj/effect/proc_holder/spell/pulse_demon/cablehop
	name = "Cable Hop"
	desc = "Jump to another cable in view."
	action_icon_state = "pd_cablehop"
	unlock_cost = 15 KW
	cast_cost = 5 KW
	upgrade_cost = 75 KW

/obj/effect/proc_holder/spell/pulse_demon/cablehop/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/turf/O = get_turf(user)
	var/turf/T = get_turf(target)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!istype(C))
		to_chat(user, "<span class='warning'>No cable found!</span>")
		return FALSE
	playsound(T, 'sound/magic/lightningshock.ogg', 50, TRUE)
	O.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)
	for(var/turf/working in get_line(O, T))
		for(var/mob/living/L in working)
			if(!electrocute_mob(L, C.powernet, user)) // give a little bit of non-lethal counterplay against insuls
				L.Jitter(5 SECONDS)
				L.apply_status_effect(STATUS_EFFECT_DELAYED, 1 SECONDS, CALLBACK(L, TYPE_PROC_REF(/mob/living, KnockDown), 5 SECONDS), COMSIG_LIVING_CLEAR_STUNS)
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

/obj/effect/proc_holder/spell/pulse_demon/emagtamper/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	to_chat(user, "<span class='warning'>You attempt to tamper with [target]!</span>")
	target.emag_act(user)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/emp
	name = "Electromagnetic Pulse"
	desc = "Creates an EMP where you click. Be careful not to use it on yourself!"
	action_icon_state = "pd_emp"
	unlock_cost = 50 KW
	cast_cost = 10 KW
	upgrade_cost = 200 KW
	requires_area = TRUE

/obj/effect/proc_holder/spell/pulse_demon/emp/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	to_chat(user, "<span class='warning'>You attempt to EMP [target]!</span>")
	empulse(get_turf(target), 1, 1)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/overload
	name = "Overload Machine"
	desc = "Overloads a machine, causing it to explode."
	action_icon_state = "pd_overload"
	unlock_cost = 300 KW
	cast_cost = 50 KW
	upgrade_cost = 500 KW
	requires_area = TRUE

/obj/effect/proc_holder/spell/pulse_demon/overload/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/obj/machinery/M = target
	if(!istype(M))
		to_chat(user, "<span class='warning'>That is not a machine.</span>")
		return FALSE
	if(target.flags_2 & NO_MALF_EFFECT_2)
		to_chat(user, "<span class='warning'>That machine cannot be overloaded.</span>")
		return FALSE
	target.audible_message("<span class='italics'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	addtimer(CALLBACK(src, PROC_REF(detonate), M), 5 SECONDS)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/overload/proc/detonate(obj/machinery/target)
	if(!QDELETED(target))
		explosion(get_turf(target), 0, 1, 1, 0)
		if(!QDELETED(target))
			qdel(target)

/obj/effect/proc_holder/spell/pulse_demon/remotehijack
	name = "Remote Hijack"
	desc = "Remotely hijacks an APC."
	action_icon_state = "pd_remotehack"
	unlock_cost = 15 KW
	cast_cost = 10 KW
	level_max = 0
	base_cooldown = 3 SECONDS // you have to wait for the regular hijack time anyway

/obj/effect/proc_holder/spell/pulse_demon/remotehijack/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
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

/obj/effect/proc_holder/spell/pulse_demon/remotedrain/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	if(isapc(target))
		var/drained = user.drain_APC(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		if(drained == PULSEDEMON_SOURCE_DRAIN_INVALID)
			to_chat(user, "<span class='warning'>This APC is being hijacked, you cannot drain from it right now.</span>")
		else
			to_chat(user, "<span class='notice'>You drain [format_si_suffix(drained)]W from [target].</span>")
	else if(istype(target, /obj/machinery/power/smes))
		var/drained = user.drain_SMES(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
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

/obj/effect/proc_holder/spell/pulse_demon/toggle/do_drain/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	user.do_drain = do_toggle(!user.do_drain, user)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/toggle/do_drain/AltClick(mob/living/simple_animal/demon/pulse_demon/user)
	if(!istype(user))
		return

	var/amount = text2num(input(user, "Input a value between 1 and [user.max_drain_rate]. 0 will reset it to the maximum.", "Drain Speed Setting"))
	if(amount == null || amount < 0)
		to_chat(user, "<span class='warning'>Invalid input. Drain speed has not been modified.</span>")
		return

	if(amount == 0)
		amount = user.max_drain_rate
	user.power_drain_rate = amount
	to_chat(user, "<span class='notice'>Drain speed has been set to [format_si_suffix(user.power_drain_rate)]W per second.</span>")

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable
	name = "Toggle Self-Sustaining"
	desc = "Toggle whether you can move outside of cables or power sources."
	base_message = "move outside of cables."
	action_icon_state = "pd_toggle_exit"
	unlock_cost = 100 KW
	upgrade_cost = 300 KW
	level_max = 3

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	if(user.can_exit_cable && !(user.current_cable || user.current_power))
		to_chat(user, "<span class='warning'>Enter a cable or power source first!</span>")
		return FALSE
	user.can_exit_cable = do_toggle(!user.can_exit_cable, user)
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/toggle/can_exit_cable/do_upgrade(mob/living/simple_animal/demon/pulse_demon/user)
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

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera/AltClick(mob/living/simple_animal/demon/pulse_demon/user)
	if(!istype(user))
		return
	current_camera = 0

	if(!isapc(user.current_power))
		return
	if(get_area(user.loc) != user.controlling_area)
		return
	user.forceMove(user.current_power)

/obj/effect/proc_holder/spell/pulse_demon/cycle_camera/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	if(!length(user.controlling_area.cameras))
		return FALSE

	if(isapc(user.loc))
		current_camera = 0
	else if(istype(user.loc, /obj/machinery/camera))
		current_camera = (current_camera + 1) % length(user.controlling_area.cameras)
		if(current_camera == 0)
			user.forceMove(user.current_power)
			return TRUE

	if(length(user.controlling_area.cameras) < current_camera)
		current_camera = 0

	user.forceMove(locateUID(user.controlling_area.cameras[current_camera + 1]))
	return TRUE

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades
	name = "Open Upgrade Menu"
	desc = "Open the upgrades menu. Alt-click for descriptions and costs."
	action_icon_state = "pd_upgrade"
	create_attack_logs = FALSE
	locked = FALSE
	cast_cost = 0
	level_max = 0
	base_cooldown = 0
	var/static/list/upgrade_icons = list(
		PD_UPGRADE_HIJACK_SPEED = image(icon = 'icons/obj/power.dmi', icon_state = "apcemag"),
		PD_UPGRADE_DRAIN_SPEED  = image(icon = 'icons/obj/power.dmi', icon_state = "ccharger"),
		PD_UPGRADE_MAX_HEALTH   = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "bluespace_matter_bin"),
		PD_UPGRADE_HEALTH_REGEN = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "femto_mani"),
		PD_UPGRADE_HEALTH_LOSS  = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "triphasic_scan_module"),
		PD_UPGRADE_HEALTH_COST  = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "quadultra_micro_laser"),
		PD_UPGRADE_MAX_CHARGE   = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "quadratic_capacitor")
	)
	var/static/list/upgrade_descs = list(
		PD_UPGRADE_HIJACK_SPEED = "Decrease the amount of time required to hijack an APC.",
		PD_UPGRADE_DRAIN_SPEED  = "Increase the amount of charge drained from a power source per cycle.",
		PD_UPGRADE_MAX_HEALTH   = "Increase the total amount of health you can have at once.",
		PD_UPGRADE_HEALTH_REGEN = "Increase the amount of health regenerated when powered per cycle.",
		PD_UPGRADE_HEALTH_LOSS  = "Decrease the amount of health lost when unpowered per cycle.",
		PD_UPGRADE_HEALTH_COST  = "Decrease the amount of power required to regenerate per cycle.",
		PD_UPGRADE_MAX_CHARGE   = "Increase the total amount of charge you can have at once."
	)

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades/proc/calc_cost(mob/living/simple_animal/demon/pulse_demon/user, upgrade)
	var/cost
	switch(upgrade)
		if(PD_UPGRADE_HIJACK_SPEED)
			if(user.hijack_time <= 1 SECONDS)
				return -1
			cost = (100 / (user.hijack_time / (1 SECONDS))) * 20 KW
		if(PD_UPGRADE_DRAIN_SPEED)
			if(user.max_drain_rate >= 500 KW)
				return -1
			cost = user.max_drain_rate * 15
		if(PD_UPGRADE_MAX_HEALTH)
			if(user.maxHealth >= 200)
				return -1
			cost = user.maxHealth * 5 KW
		if(PD_UPGRADE_HEALTH_REGEN)
			if(user.health_regen_rate >= 100)
				return -1
			cost = user.health_regen_rate * 50 KW
		if(PD_UPGRADE_HEALTH_LOSS)
			if(user.health_loss_rate <= 1)
				return -1
			cost = (100 / user.health_loss_rate) * 20 KW
		if(PD_UPGRADE_HEALTH_COST)
			if(user.power_per_regen <= 1)
				return -1
			cost = (100 / user.power_per_regen) * 50 KW
		if(PD_UPGRADE_MAX_CHARGE)
			cost = user.maxcharge
		else
			return -1
	return round(cost)

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades/proc/get_upgrades(mob/living/simple_animal/demon/pulse_demon/user)
	var/upgrades = list()
	for(var/upgrade in upgrade_icons)
		var/cost = calc_cost(user, upgrade)
		if(cost == -1)
			continue
		upgrades["[upgrade] ([format_si_suffix(cost)]W)"] = upgrade_icons[upgrade]
	return upgrades

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades/AltClick(mob/living/simple_animal/demon/pulse_demon/user)
	if(!istype(user))
		return

	to_chat(user, "<b>Pulse Demon upgrades:</b>")
	for(var/upgrade in upgrade_descs)
		var/cost = calc_cost(user, upgrade)
		to_chat(user, "<b>[upgrade]</b> ([cost == -1 ? "Fully Upgraded" : "[format_si_suffix(cost)]W"]) - [upgrade_descs[upgrade]]")

/obj/effect/proc_holder/spell/pulse_demon/open_upgrades/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/upgrades = get_upgrades(user)
	if(!length(upgrades))
		to_chat(user, "<span class='warning'>You have already fully upgraded everything available!</span>")
		return FALSE

	var/raw_choice = show_radial_menu(user, user, upgrades, radius = 48)
	if(!raw_choice)
		return
	var/choice = splittext(raw_choice, " ")[1]

	var/cost = calc_cost(user, choice)
	if(cost == -1)
		return FALSE
	if(user.charge < cost)
		to_chat(user, "<span class='warning'>You do not have enough charge to purchase this upgrade!</span>")
		return FALSE

	user.adjust_charge(-cost)
	switch(choice)
		if(PD_UPGRADE_HIJACK_SPEED)
			user.hijack_time = max(round(user.hijack_time / 1.5), 1 SECONDS)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], it now takes [user.hijack_time / (1 SECONDS)] second\s to hijack APCs.</span>")
		if(PD_UPGRADE_DRAIN_SPEED)
			var/old = user.max_drain_rate
			user.max_drain_rate = min(round(user.max_drain_rate * 1.5), 500 KW)
			if(user.power_drain_rate == old)
				user.power_drain_rate = user.max_drain_rate
			to_chat(user, "<span class='notice'>You have upgraded your [choice], you can now drain [format_si_suffix(user.max_drain_rate)]W per cycle.</span>")
		if(PD_UPGRADE_MAX_HEALTH)
			user.maxHealth = min(round(user.maxHealth * 1.5), 200)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], your max health is now [user.maxHealth].</span>")
		if(PD_UPGRADE_HEALTH_REGEN)
			user.health_regen_rate = min(round(user.health_regen_rate * 1.5), 100)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], you will now regenerate [user.health_regen_rate] health per cycle when powered.</span>")
		if(PD_UPGRADE_HEALTH_LOSS)
			user.health_loss_rate = max(round(user.health_loss_rate / 1.5), 1)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], you will now lose [user.health_loss_rate] health per cycle when unpowered.</span>")
		if(PD_UPGRADE_HEALTH_COST)
			user.power_per_regen = max(round(user.power_per_regen / 1.5), 1)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], it now takes [format_si_suffix(user.power_per_regen)]W of power to regenerate health.</span>")
			to_chat(user, "<span class='notice'>Additionally, if you enable draining while on a cable, any excess power that would've been used regenerating will be added to your charge.</span>")
		if(PD_UPGRADE_MAX_CHARGE)
			user.maxcharge = round(user.maxcharge * 2)
			to_chat(user, "<span class='notice'>You have upgraded your [choice], you can now store [format_si_suffix(user.maxcharge)]W of charge.</span>")
		else
			return FALSE
	return TRUE


#undef PULSEDEMON_REMOTE_DRAIN_MULTIPLIER
#undef PD_UPGRADE_HIJACK_SPEED
#undef PD_UPGRADE_DRAIN_SPEED
#undef PD_UPGRADE_HEALTH_LOSS
#undef PD_UPGRADE_HEALTH_REGEN
#undef PD_UPGRADE_MAX_HEALTH
#undef PD_UPGRADE_HEALTH_COST
#undef PD_UPGRADE_MAX_CHARGE
