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
	var/list/rval = new
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed)
			rval += C
	return rval

/mob/living/silicon/robot/proc/get_armour()
	if(!LAZYLEN(components))
		return 0
	var/datum/robot_component/C = components["armour"]
	if(C && C.installed)
		return C
	return 0

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
