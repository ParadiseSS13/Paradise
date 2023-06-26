// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "programming=2"
	var/locked = FALSE
	var/installed = FALSE
	var/require_module = FALSE
	var/module_type = null
	var/instant_use = FALSE
	var/multiple_use = FALSE


/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/robot, mob/user)
	if(robot.stat == DEAD)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("[src] will not function on a deceased cyborg!")]")
		return FALSE
	if((locate(src) in robot.upgrades) && !multiple_use)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there is already [src] inside!")]")
		return FALSE
	if(module_type && !istype(robot.module, module_type))
		to_chat(robot, SPAN_WARNING("Upgrade mounting error! No suitable hardpoint detected!"))
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there's no mounting point for the module!")]")
		return FALSE
	return TRUE


/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!(src in robot.upgrades))
		return FALSE
	return TRUE


/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = TRUE
	instant_use = TRUE


/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	if(isclocker(robot))
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("this unit somehow refuses to reset!")]")
		return FALSE

	robot.reset_module()
	return TRUE


/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "Default Name"
	instant_use = TRUE


/obj/item/borg/upgrade/rename/attack_self(mob/user)
	var/new_heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)
	new_heldname = reject_bad_name(new_heldname, TRUE, MAX_NAME_LEN)
	if(!new_heldname)
		to_chat(user, SPAN_WARNING("Prohibited sequence detected. Entered configuration has been cancelled."))
	else
		heldname = new_heldname
	return


/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	if(!robot.allow_rename)
		to_chat(robot, SPAN_WARNING("Internal diagnostic error: incompatible upgrade module detected."))
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("incompatible upgrade module detected!")]")
		return FALSE

	if(!robot.shouldRename(heldname))
		robot.rename_self(robot.braintype, TRUE)
	else
		if(heldname == "Default Name")
			robot.custom_name = "" //allows usage of Namepick
			robot.rename_character(robot.name, robot.get_default_name())
		else
			robot.rename_character(robot.name, heldname)
	return TRUE


/mob/living/silicon/robot/proc/shouldRename(newname)
	if(src.stat == CONSCIOUS)
		var/choice = alert(src, "Активирован протокол переименования. Предложенное имя: [newname]. Продолжить операцию?","Внимание!","Да","Нет")
		if(src.stat == CONSCIOUS) //no abuse by using window in unconscious state
			switch(choice)
				if("Да")
					return TRUE
				if("Нет")
					return FALSE
	return TRUE


/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	instant_use = TRUE


/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/robot, mob/user)
	if(robot.health < 0)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("you have to repair the cyborg before using this module!")]")
		return FALSE

	if(!robot.key)
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(ghost.mind && ghost.mind.current == robot)
				robot.key = ghost.key

	robot.stat = CONSCIOUS
	GLOB.dead_mob_list -= robot //please never forget this ever kthx
	GLOB.alive_mob_list += robot
	robot.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
	return TRUE


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = TRUE
	origin_tech = "engineering=4;materials=5;programming=4"


/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/robot)
	if(!..())
		return FALSE

	robot.speed -= 1 // Gotta go fast.
	return TRUE


/obj/item/borg/upgrade/vtec/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	robot.speed += 1
	return TRUE


/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4;combat=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/security


/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in robot.module.modules
	if(!disabler)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there's no disabler in this unit!")]")
		return FALSE

	disabler.charge_delay = max(2 , disabler.charge_delay - 4)
	return TRUE


/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in robot.module.modules
	if(!disabler)
		return FALSE

	disabler.charge_delay = initial(disabler.charge_delay)
	return TRUE


/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "A energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4"


/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	robot.ionpulse = TRUE
	return TRUE


/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	robot.ionpulse = FALSE
	return TRUE


/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=5"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner


/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/pickaxe/drill/cyborg/drill in robot.module.modules)
		qdel(drill)
	for(var/obj/item/shovel/shovel in robot.module.modules)
		qdel(shovel)

	robot.module.modules += new /obj/item/pickaxe/drill/cyborg/diamond(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/pickaxe/drill/cyborg/diamond/drill in robot.module)
		qdel(drill)

	robot.module.modules += new /obj/item/pickaxe/drill/cyborg(robot.module)
	robot.module.modules += new /obj/item/shovel(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=4;bluespace=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner


/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/storage/bag/ore/cyborg/orebag in robot.module.modules)
		qdel(orebag)

	robot.module.modules += new /obj/item/storage/bag/ore/holding/cyborg(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/storage/bag/ore/holding/cyborg/orebag in robot.module)
		qdel(orebag)

	robot.module.modules += new /obj/item/storage/bag/ore/cyborg(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/gps
	name = "cyborg gps upgrade"
	desc = "Upgraded GPS for cyborgs."
	icon_state = "cyborg_upgrade3"


/obj/item/borg/upgrade/gps/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/gps/cyborg/gps in robot.module.modules)
		qdel(gps)

	robot.module.modules += new /obj/item/gps/cyborg/upgraded(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/gps/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/gps/cyborg/upgraded/gps in robot.module)
		qdel(gps)

	robot.module.modules += new /obj/item/gps/cyborg(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/abductor_engi
	name = "engineering cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces an engineering cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "engineering=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering


/obj/item/borg/upgrade/abductor_engi/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/weldingtool/largetank/cyborg/weldingtool in robot.module.modules)
		qdel(weldingtool)
	for(var/obj/item/screwdriver/cyborg/screwdriver in robot.module.modules)
		qdel(screwdriver)
	for(var/obj/item/wrench/cyborg/wrench in robot.module.modules)
		qdel(wrench)
	for(var/obj/item/crowbar/cyborg/crowbar in robot.module.modules)
		qdel(crowbar)
	for(var/obj/item/wirecutters/cyborg/wirecutters in robot.module.modules)
		qdel(wirecutters)
	for(var/obj/item/multitool/cyborg/multitool in robot.module.modules)
		qdel(multitool)

	robot.module.modules += new /obj/item/weldingtool/abductor(robot.module)
	robot.module.modules += new /obj/item/wrench/abductor(robot.module)
	robot.module.modules += new /obj/item/screwdriver/abductor(robot.module)
	robot.module.modules += new /obj/item/crowbar/abductor(robot.module)
	robot.module.modules += new /obj/item/wirecutters/abductor(robot.module)
	robot.module.modules += new /obj/item/multitool/abductor(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/abductor_engi/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/weldingtool/abductor/weldingtool in robot.module.modules)
		qdel(weldingtool)
	for(var/obj/item/screwdriver/abductor/screwdriver in robot.module.modules)
		qdel(screwdriver)
	for(var/obj/item/wrench/abductor/wrench in robot.module.modules)
		qdel(wrench)
	for(var/obj/item/crowbar/abductor/crowbar in robot.module.modules)
		qdel(crowbar)
	for(var/obj/item/wirecutters/abductor/wirecutters in robot.module.modules)
		qdel(wirecutters)
	for(var/obj/item/multitool/abductor/multitool in robot.module.modules)
		qdel(multitool)

	robot.module.modules += new /obj/item/weldingtool/abductor(robot.module)
	robot.module.modules += new /obj/item/wrench/cyborg(robot.module)
	robot.module.modules += new /obj/item/screwdriver/cyborg(robot.module)
	robot.module.modules += new /obj/item/crowbar/cyborg(robot.module)
	robot.module.modules += new /obj/item/wirecutters/cyborg(robot.module)
	robot.module.modules += new /obj/item/multitool/cyborg(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/abductor_medi
	name = "medical cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces a medical cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "biotech=6;materials=6;abductor=2"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical


/obj/item/borg/upgrade/abductor_medi/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/scalpel/laser/laser1/scalpel in robot.module.modules)
		qdel(scalpel)
	for(var/obj/item/hemostat/hemostat in robot.module.modules)
		qdel(hemostat)
	for(var/obj/item/retractor/retractor in robot.module.modules)
		qdel(retractor)
	for(var/obj/item/bonegel/bonegel in robot.module.modules)
		qdel(bonegel)
	for(var/obj/item/FixOVein/fix_o_vein in robot.module.modules)
		qdel(fix_o_vein)
	for(var/obj/item/bonesetter/bonesetter in robot.module.modules)
		qdel(bonesetter)
	for(var/obj/item/circular_saw/circular_saw in robot.module.modules)
		qdel(circular_saw)
	for(var/obj/item/surgicaldrill/surgical_drill in robot.module.modules)
		qdel(surgical_drill)

	robot.module.modules += new /obj/item/scalpel/laser/laser3(robot.module) //no abductor laser scalpel, so next best thing.
	robot.module.modules += new /obj/item/hemostat/alien(robot.module)
	robot.module.modules += new /obj/item/retractor/alien(robot.module)
	robot.module.modules += new /obj/item/bonegel/alien(robot.module)
	robot.module.modules += new /obj/item/FixOVein/alien(robot.module)
	robot.module.modules += new /obj/item/bonesetter/alien(robot.module)
	robot.module.modules += new /obj/item/circular_saw/alien(robot.module)
	robot.module.modules += new /obj/item/surgicaldrill/alien(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/abductor_medi/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/obj/item/scalpel/laser/laser3/scalpel in robot.module.modules)
		qdel(scalpel)
	for(var/obj/item/hemostat/alien/hemostat in robot.module.modules)
		qdel(hemostat)
	for(var/obj/item/retractor/alien/retractor in robot.module.modules)
		qdel(retractor)
	for(var/obj/item/bonegel/alien/bonegel in robot.module.modules)
		qdel(bonegel)
	for(var/obj/item/FixOVein/alien/fix_o_vein in robot.module.modules)
		qdel(fix_o_vein)
	for(var/obj/item/bonesetter/alien/bonesetter in robot.module.modules)
		qdel(bonesetter)
	for(var/obj/item/circular_saw/alien/circular_saw in robot.module.modules)
		qdel(circular_saw)
	for(var/obj/item/surgicaldrill/alien/surgical_drill in robot.module.modules)
		qdel(surgical_drill)

	robot.module.modules += new /obj/item/scalpel/laser/laser1(robot.module)
	robot.module.modules += new /obj/item/hemostat(robot.module)
	robot.module.modules += new /obj/item/retractor(robot.module)
	robot.module.modules += new /obj/item/bonegel(robot.module)
	robot.module.modules += new /obj/item/FixOVein(robot.module)
	robot.module.modules += new /obj/item/bonesetter(robot.module)
	robot.module.modules += new /obj/item/circular_saw(robot.module)
	robot.module.modules += new /obj/item/surgicaldrill(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/syndicate
	name = "safety override module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	origin_tech = "combat=6;materials=6"
	require_module = TRUE


/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	to_chat(robot, SPAN_WARNING("Warning: Safety Overide Protocols have been disabled."))
	robot.weapons_unlock = TRUE
	return TRUE


/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	to_chat(robot, SPAN_NOTICE("Notice: Safety Overide Protocols have been restored."))
	robot.weapons_unlock = FALSE
	return TRUE


/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = TRUE
	module_type = /obj/item/robot_module/miner


/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	robot.weather_immunities |= "lava"
	return TRUE


/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	robot.weather_immunities -= "lava"
	return TRUE


/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_module = TRUE
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = FALSE
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg
	var/datum/action/toggle_action


/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	icon_state = "selfrepair_off"
	cyborg = robot
	toggle_action = new /datum/action/item_action/toggle(src)
	toggle_action.Grant(robot)
	return TRUE


/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	cyborg = null
	toggle_action.Remove(robot)
	QDEL_NULL(toggle_action)
	STOP_PROCESSING(SSobj, src)
	if(!QDELETED(src))
		qdel(src)
	return TRUE


/obj/item/borg/upgrade/selfrepair/Destroy()
	on = FALSE
	return ..()


/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		to_chat(cyborg, SPAN_NOTICE("You activate the self-repair module."))
		activate_sr()
	else
		to_chat(cyborg, SPAN_NOTICE("You deactivate the self-repair module."))
		deactivate_sr()
	update_icon()


/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"


/obj/item/borg/upgrade/selfrepair/proc/activate_sr()
	START_PROCESSING(SSobj, src)
	on = TRUE
	update_icon()


/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_icon()


/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, SPAN_WARNING("Self-repair module deactivated. Please, insert the power cell."))
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, SPAN_NOTICE("Self-repair module deactivated. Please recharge."))
			deactivate_sr()
			return

		if(cyborg.health < cyborg.maxHealth)
			if(cyborg.health < 0)
				repair_amount = 2.5
				powercost = 30
			else
				repair_amount = 1
				powercost = 10
			cyborg.heal_overall_damage(repair_amount, repair_amount)
			cyborg.cell.use(powercost)
		else
			cyborg.cell.use(5)
		repair_tick = 0

		if((world.time - 2000) > msg_cooldown)
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, SPAN_NOTICE("Self-repair is active in [SPAN_NOTICE_BOLD("[msgmode]")] mode."))
			msg_cooldown = world.time
	else
		deactivate_sr()


/obj/item/borg/upgrade/storageincreaser
	name = "storage increaser"
	desc = "Improves cyborg storage with bluespace technology to store more medicines."
	icon_state = "cyborg_upgrade2"
	origin_tech = "bluespace=4;materials=5;engineering=3"
	require_module = TRUE


/obj/item/borg/upgrade/storageincreaser/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/datum/robot_energy_storage/energy_storage in robot.module.storages)
		energy_storage.max_energy *= 3
		energy_storage.recharge_rate *= 2
		energy_storage.energy = energy_storage.max_energy
	return TRUE


/obj/item/borg/upgrade/storageincreaser/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	for(var/datum/robot_energy_storage/energy_storage in robot.module.storages)
		energy_storage.max_energy = initial(energy_storage.max_energy)
		energy_storage.recharge_rate = initial(energy_storage.recharge_rate)
		energy_storage.energy = initial(energy_storage.max_energy)
	return TRUE


/obj/item/borg/upgrade/hypospray
	name = "cyborg hypospray upgrade"
	desc = "Adds and replaces some reagents with better ones."
	icon_state = "cyborg_upgrade2"
	origin_tech = "biotech=6;materials=5"
	require_module = TRUE


/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/reagent_containers/borghypo/basic/borghypo_basic = locate() in robot.module.modules
	if(borghypo_basic)
		qdel(borghypo_basic)
		robot.module.modules += new /obj/item/reagent_containers/borghypo/basic/upgraded(robot.module)
		robot.module.rebuild()
		return TRUE

	var/obj/item/reagent_containers/borghypo/borghypo = locate() in robot.module.modules
	if(borghypo)
		qdel(borghypo)
		robot.module.modules += new /obj/item/reagent_containers/borghypo/upgraded(robot.module)
		robot.module.rebuild()
		return TRUE

	to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there's no hypospray in this unit!")]")
	return FALSE


/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/reagent_containers/borghypo/basic/upgraded/borghypo_basic = locate() in robot.module.modules
	if(borghypo_basic)
		qdel(borghypo_basic)
		robot.module.modules += new /obj/item/reagent_containers/borghypo/basic(robot.module)
		robot.module.rebuild()
		return TRUE

	var/obj/item/reagent_containers/borghypo/upgraded/borghypo = locate() in robot.module.modules
	if(borghypo)
		qdel(borghypo)
		robot.module.modules += new /obj/item/reagent_containers/borghypo(robot.module)
		robot.module.rebuild()
		return TRUE

	return FALSE


/obj/item/borg/upgrade/hypospray_pierce
	name = "cyborg hypospray advanced injector"
	desc = "Upgrades cyborg hypospray with advanced injector allowing it to pierce thick tissue and materials."
	icon_state = "cyborg_upgrade2"
	origin_tech = "materials=4;biotech=5;engineering=5"
	require_module = TRUE


/obj/item/borg/upgrade/hypospray_pierce/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/reagent_containers/borghypo/hypospray = locate() in robot.module.modules
	if(!hypospray)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there's no hypospray in this unit!")]")
		return FALSE

	if(hypospray.bypass_protection)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("unit's hypospray is already upgraded!")]")
		return FALSE

	hypospray.bypass_protection = TRUE
	return TRUE


/obj/item/borg/upgrade/hypospray_pierce/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/reagent_containers/borghypo/hypospray = locate() in robot.module.modules
	if(!hypospray)
		return FALSE

	hypospray.bypass_protection = FALSE
	return TRUE


/obj/item/borg/upgrade/syndie_rcd
	name = "Syndicate cyborg RCD upgrade"
	desc = "An experimental upgrade that replaces cyborgs RCDs with the syndicate version."
	icon_state = "syndicate_cyborg_upgrade"
	origin_tech = "engineering=6;materials=6;syndicate=5"


/obj/item/borg/upgrade/syndie_rcd/action(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/rcd/borg/borg_rcd = locate() in robot.module.modules
	if(!borg_rcd)
		to_chat(user, "[SPAN_DANGER("UPGRADE ERROR: ")]" + "[SPAN_NOTICE("there's no RCD in this unit!")]")
		return FALSE

	for(borg_rcd in robot.module.modules)
		qdel(borg_rcd)

	robot.module.modules += new /obj/item/rcd/syndicate/borg(robot.module)
	robot.module.rebuild()
	return TRUE


/obj/item/borg/upgrade/syndie_rcd/deactivate(mob/living/silicon/robot/robot, mob/user)
	if(!..())
		return FALSE

	var/obj/item/rcd/syndicate/borg/borg_rcd = locate() in robot.module.modules
	if(!borg_rcd)
		return FALSE

	for(borg_rcd in robot.module.modules)
		qdel(borg_rcd)

	robot.module.modules += new /obj/item/rcd/borg(robot.module)
	robot.module.rebuild()
	return TRUE
