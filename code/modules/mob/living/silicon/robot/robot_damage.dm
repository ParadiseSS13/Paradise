/mob/living/silicon/robot/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - (getOxyLoss() + getFireLoss() + getBruteLoss())
	update_stat("updatehealth([reason])")
	handle_hud_icons_health()
	diag_hud_set_health()

/mob/living/silicon/robot/getBruteLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0 && (!repairable_only || C.installed != -1)) // Installed ones only and if repair only remove the borked ones
			amount += C.brute_damage
	return amount

/mob/living/silicon/robot/getFireLoss(repairable_only = FALSE)
	var/amount = 0
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed != 0 && (!repairable_only || C.installed != -1)) // Installed ones only and if repair only remove the borked ones
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
		if((C.installed == 1 || (get_borked && C.installed == -1) || (get_missing && C.installed == 0)) && ((get_brute && C.brute_damage) || (get_burn && C.electronics_damage)))
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_missing_components()
	var/list/datum/robot_component/parts = list()
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 0)
			parts += C
	return parts

/mob/living/silicon/robot/proc/get_damageable_components()
	var/list/rval = new
	for(var/V in components)
		var/datum/robot_component/C = components[V]
		if(C.installed == 1)
			rval += C
	return rval

/mob/living/silicon/robot/proc/get_armour()
	if(!LAZYLEN(components))
		return 0
	var/datum/robot_component/C = components["armour"]
	if(C && C.installed == 1)
		return C
	return 0

/mob/living/silicon/robot/heal_organ_damage(brute, burn, updating_health = TRUE)
	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)
	if(!LAZYLEN(parts))	
		return
	var/datum/robot_component/picked = pick(parts)
	picked.heal_damage(brute, burn, updating_health)

/mob/living/silicon/robot/take_organ_damage(brute = 0, burn = 0, updating_health = TRUE, sharp = 0, edge = 0)
	var/list/components = get_damageable_components()
	if(!LAZYLEN(components))
		return

	 //Combat shielding absorbs a percentage of damage directly into the cell.
	var/obj/item/borg/combat/shield/shield
	if(module_state_1 && istype(module_state_1, /obj/item/borg/combat/shield))
		shield = module_state_1
	else if(module_state_2 && istype(module_state_2, /obj/item/borg/combat/shield))
		shield = module_state_2
	else if(module_state_3 && istype(module_state_3, /obj/item/borg/combat/shield))
		shield = module_state_3
	if(shield)
		//Shields absorb a certain percentage of damage based on their power setting.
		var/absorb_brute = brute * shield.shield_level
		var/absorb_burn = burn * shield.shield_level
		var/cost = (absorb_brute+absorb_burn) * 100

		cell.charge -= cost
		if(cell.charge <= 0)
			cell.charge = 0
			to_chat(src, "<span class='warning'>Your shield has overloaded!</span>")
		else
			brute -= absorb_brute
			burn -= absorb_burn
			to_chat(src, "<span class='warning'>Your shield absorbs some of the impact!</span>")

	var/datum/robot_component/armour/A = get_armour()
	if(A)
		A.take_damage(brute, burn, sharp, updating_health)
		return

	var/datum/robot_component/C = pick(components)
	C.take_damage(brute, burn, sharp, updating_health)

/mob/living/silicon/robot/heal_overall_damage(var/brute, var/burn, updating_health = TRUE)
	var/list/datum/robot_component/parts = get_damaged_components(brute, burn)

	while(LAZYLEN(parts) && (brute > 0 || burn > 0) )
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.heal_damage(brute,burn, updating_health)

		brute -= (brute_was - picked.brute_damage)
		burn -= (burn_was - picked.electronics_damage)

		parts -= picked

	if(updating_health)
		updatehealth("heal overall damage")

/mob/living/silicon/robot/take_overall_damage(brute = 0, burn = 0, updating_health = TRUE, used_weapon = null, sharp = 0)
	if(status_flags & GODMODE)	return	//godmode
	var/list/datum/robot_component/parts = get_damageable_components()

	 //Combat shielding absorbs a percentage of damage directly into the cell.
	var/obj/item/borg/combat/shield/shield
	if(module_state_1 && istype(module_state_1, /obj/item/borg/combat/shield))
		shield = module_state_1
	else if(module_state_2 && istype(module_state_2, /obj/item/borg/combat/shield))
		shield = module_state_2
	else if(module_state_3 && istype(module_state_3, /obj/item/borg/combat/shield))
		shield = module_state_3
	if(shield)
		//Shields absorb a certain percentage of damage based on their power setting.
		var/absorb_brute = brute * shield.shield_level
		var/absorb_burn = burn * shield.shield_level
		var/cost = (absorb_brute+absorb_burn) * 100

		cell.charge -= cost
		if(cell.charge <= 0)
			cell.charge = 0
			to_chat(src, "<span class='warning'>Your shield has overloaded!</span>")
		else
			brute -= absorb_brute
			burn -= absorb_burn
			to_chat(src, "<span class='warning'>Your shield absorbs some of the impact!</span>")

	var/datum/robot_component/armour/A = get_armour()
	if(A)
		A.take_damage(brute, burn, sharp)
		return

	while(LAZYLEN(parts) && (brute > 0 || burn > 0) )
		var/datum/robot_component/picked = pick(parts)

		var/brute_was = picked.brute_damage
		var/burn_was = picked.electronics_damage

		picked.take_damage(brute, burn, sharp, FALSE)

		brute	-= (picked.brute_damage - brute_was)
		burn	-= (picked.electronics_damage - burn_was)

		parts -= picked
	updatehealth()
