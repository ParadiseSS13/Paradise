/mob/living/silicon/robot/updatehealth(reason = "none given")
	..(reason)
	check_module_damage()

/mob/living/silicon/robot/getBruteLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed || (!repairable_only && C.is_destroyed())) // Installed ones only and if repair only remove the borked ones
			amount += C.brute_damage
	return amount

/mob/living/silicon/robot/getFireLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed || (!repairable_only && C.is_destroyed())) // Installed ones only and if repair only remove the borked ones
			amount += C.electronics_damage
	return amount

/mob/living/silicon/robot/adjustBruteLoss(amount, updating_health = TRUE)
	if(amount > 0)
		take_overall_damage(amount, 0, updating_health)
	else
		heal_overall_damage(-amount, 0, updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/silicon/robot/adjustFireLoss(amount, updating_health = TRUE)
	if(amount > 0)
		take_overall_damage(0, amount, updating_health)
	else
		heal_overall_damage(0, -amount, updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/silicon/robot/update_stamina()
	if(rebooting)
		return
	var/current_stam_damage = getStaminaLoss()
	if(current_stam_damage > DAMAGE_PRECISION && (maxHealth - current_stam_damage) <= HEALTH_THRESHOLD_CRIT && stat == CONSCIOUS)
		start_emergency_reboot()

/mob/living/silicon/robot/handle_status_effects()
	..()
	if(stam_regen_start_time <= world.time)
		update_stamina()
		if(staminaloss && !rebooting)
			setStaminaLoss(0, FALSE)
			update_stamina_hud()

/mob/living/silicon/robot/proc/get_damaged_components(get_brute, get_burn, get_borked = FALSE, get_missing = FALSE)
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if((C.installed || (get_borked && C.is_destroyed()) || (get_missing && C.is_missing())) && ((get_brute && C.brute_damage) || (get_burn && C.electronics_damage)))
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_missing_components()
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.is_missing())
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_damageable_components()
	var/list/rval = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed)
			rval += C
	return rval
///Returns the armour component for a borg, or false if its missing or broken
/mob/living/silicon/robot/proc/get_armour()
	if(!LAZYLEN(components))
		return FALSE
	var/datum/robot_component/C = components["armour"]
	if(C && C.installed)
		return C
	return FALSE
///Returns the power cell component for a borg, or false if its missing or broken
/mob/living/silicon/robot/proc/get_cell_component()
	if(!LAZYLEN(components))
		return FALSE
	var/datum/robot_component/C = components["power cell"]
	if(C?.installed)
		return C
	return FALSE

/mob/living/silicon/robot/proc/get_total_component_slowdown()
	var/total_slowdown = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		total_slowdown += C.get_movement_delay()
	return total_slowdown

/mob/living/silicon/robot/proc/get_stamina_slowdown()
	return round((staminaloss / 40), 0.125)

/mob/living/silicon/robot/heal_organ_damage(brute, burn, updating_health = TRUE)
	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)
	if(!LAZYLEN(parts))
		return
	var/datum/robot_component/picked = pick(parts)
	picked.heal_damage(brute, burn, updating_health)

/mob/living/silicon/robot/take_organ_damage(brute = 0, burn = 0, updating_health = TRUE, sharp = FALSE, edge = 0)
	var/list/components = get_damageable_components()
	if(!LAZYLEN(components))
		return

	var/datum/robot_component/armour/A = get_armour()
	if(A)
		A.take_damage(brute, burn, sharp, updating_health)
		return

	var/datum/robot_component/C = pick(components)
	C.take_damage(brute, burn, sharp, updating_health)

/mob/living/silicon/robot/heal_overall_damage(brute, burn, updating_health = TRUE)
	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)

	while(LAZYLEN(parts) && (brute > 0 || burn > 0))
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.heal_damage(brute,burn, updating_health)

		brute -= (brute_was - picked.brute_damage)
		burn -= (burn_was - picked.electronics_damage)

		parts -= picked

	if(updating_health)
		updatehealth("heal overall damage")

/mob/living/silicon/robot/take_overall_damage(brute = 0, burn = 0, updating_health = TRUE, used_weapon = null, sharp = FALSE)
	if(status_flags & GODMODE)
		return

	brute = max((brute - damage_protection) * brute_mod, 0)
	burn = max((burn - damage_protection) * burn_mod, 0)

	var/list/datum/robot_component/parts = get_damageable_components()

	var/datum/robot_component/armour/A = get_armour()
	if(A)
		A.take_damage(brute, burn, sharp)
		updatehealth()
		return

	while(LAZYLEN(parts) && (brute > 0 || burn > 0))
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.take_damage(brute, burn, sharp, FALSE)

		brute	-= (picked.brute_damage - brute_was)
		burn	-= (picked.electronics_damage - burn_was)

		parts -= picked
	updatehealth()

/*
Begins the stamcrit reboot process for borgs. Stuns them, and warns people if the borg has no power source.
*/
/mob/living/silicon/robot/proc/start_emergency_reboot()
	rebooting = TRUE
	playsound(src, 'sound/machines/shut_down.ogg', 100, FALSE, SOUND_RANGE_SET(10))
	if(!has_power_source())
		visible_message(
			"<span class='warning'>[src]'s system sounds an alarm, \"ERROR: NO POWER SOURCE DETECTED. SYSTEM SHUTDOWN IMMINENT.\"</span>",
			"<span class='warning'>EMERGENCY: FULL SYSTEM SHUTDOWN IMMINENT.</span>")
		playsound(src, 'sound/machines/buzz-two.ogg' , 50, FALSE, SOUND_RANGE_SET(10))
	else
		visible_message(
			"<span class='notice'>[src]'s lights suddenly go dark and [p_they()] seem to shut down.</span>",
			"<span class='notice'>A critical neural connection error has occurred. Beginning emergency reboot...</span>"
		)
	var/stun_time = rand(13 SECONDS, 18 SECONDS) //Slightly longer than old flash timer
	setStaminaLoss(0) //Have you tried turning it off and on again?
	Weaken(stun_time)
	addtimer(CALLBACK(src, PROC_REF(end_emergency_reboot)), stun_time)
/*
Finishes the stamcrit process. If the borg doesn't have a power source for the reboot, they die.
*/
/mob/living/silicon/robot/proc/end_emergency_reboot()
	if(!has_power_source()) //Can't turn itself back on
		rebooting = FALSE
		death()
		return
	if(getStaminaLoss()) //If someone has been chain-flashing a borg then the ride never ends
		var/restun_time = rand(7 SECONDS, 10 SECONDS)
		to_chat(src, "<span class='warning'>Error: Continual sensor overstimulation resulted in faulty reboot. Retrying in [restun_time / 10] seconds.</span>")
		setStaminaLoss(0) //Just keep trying to turn it off and on again, surely it'll work eventually
		Weaken(restun_time)
		addtimer(CALLBACK(src, PROC_REF(end_emergency_reboot)), restun_time)
		return
	rebooting = FALSE
	if(stat != CONSCIOUS)
		return
	playsound(src, 'sound/machines/reboot_chime.ogg' , 100, FALSE, SOUND_RANGE_SET(10))
	update_stamina_hud()
	to_chat(src, "<span class='notice'>Reboot complete, neural interface operational.</span>")
