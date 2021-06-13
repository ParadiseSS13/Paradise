// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "programming=2"
	/// Whether or not the cyborg needs to have a chosen module before they can recieve this upgrade.
	var/require_module = FALSE
	/// The type of module this upgrade is compatible with: Engineering, Medical, etc.
	var/module_type = null
	/// A list of items, and their replacements that this upgrade should replace on installation, in the format of `item_type_to_replace = replacement_item_type`.
	var/list/items_to_replace = list()
	/// A list of replacement items will need to be placed into a cyborg module's `special_rechargable` list after this upgrade is installed.
	var/list/special_rechargables = list()

/**
 * Called when someone clicks on a borg with an upgrade in their hand.
 *
 * Arguments:
 * * R - the cyborg that was clicked on with an upgrade.
 */
/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(!pre_install_checks(R))
		return
	if(!do_install(R))
		return
	after_install(R)
	return TRUE

/**
 * Checks if the upgrade is able to be applied to the cyborg, before actually applying it.
 *
 * Arguments:
 * * R - the cyborg that was clicked on with an upgrade.
 */
/obj/item/borg/upgrade/proc/pre_install_checks(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='warning'>[src] will not function on a deceased cyborg.</span>")
		return FALSE
	if(module_type && !istype(R.module, module_type))
		to_chat(R, "<span class='warning'>Upgrade mounting error!  No suitable hardpoint detected!</span>")
		to_chat(usr, "<span class='warning'>There's no mounting point for the module!</span>")
		return FALSE
	return TRUE

/**
 * Executes code that will modify the cyborg or its module.
 *
 * Arguments:
 * * R - the cyborg we're applying the upgrade to.
 */
/obj/item/borg/upgrade/proc/do_install(mob/living/silicon/robot/R)
	return TRUE

/**
 * Executes code after the module has been installed and the cyborg has been modified in some way.
 *
 * Arguments:
 * * R - the cyborg that we've applied the upgrade to.
 */
/obj/item/borg/upgrade/proc/after_install(mob/living/silicon/robot/R)
	for(var/item in items_to_replace)
		var/replacement_type = items_to_replace[item]
		var/obj/item/replacement = new replacement_type(R.module)
		R.module.remove_item_from_lists(item)
		R.module.basic_modules += replacement

		if(replacement_type in special_rechargables)
			R.module.special_rechargables += replacement

	R.module.rebuild_modules()
	return TRUE

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = TRUE

/obj/item/borg/upgrade/reset/do_install(mob/living/silicon/robot/R)
	R.reset_module()
	return TRUE

/obj/item/borg/upgrade/reset/after_install(mob/living/silicon/robot/R)
	return // We don't need to give them replacement items, or rebuild their module list. It's going to be a blank borg.

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/do_install(mob/living/silicon/robot/R)
	if(!R.allow_rename)
		to_chat(R, "<span class='warning'>Internal diagnostic error: incompatible upgrade module detected.</span>")
		return 0
	R.notify_ai(RENAME, R.name, heldname)
	R.name = heldname
	R.custom_name = heldname
	R.real_name = heldname
	if(R.mmi && R.mmi.brainmob)
		R.mmi.brainmob.name = R.name
	return TRUE

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/restart/do_install(mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "<span class='warning'>You have to repair the cyborg before using this module!</span>")
		return 0

	if(!R.key)
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	GLOB.dead_mob_list -= R //please never forget this ever kthx
	GLOB.alive_mob_list += R
	R.notify_ai(NEW_BORG)

	return TRUE


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = TRUE
	origin_tech = "engineering=4;materials=5;programming=4"

/obj/item/borg/upgrade/vtec/do_install(mob/living/silicon/robot/R)
	if(R.speed < 0)
		to_chat(R, "<span class='notice'>A VTEC unit is already installed!</span>")
		to_chat(usr, "<span class='notice'>There's no room for another VTEC unit!</span>")
		return

	R.speed = -1 // Gotta go fast.

	return TRUE

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4;combat=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/security

/obj/item/borg/upgrade/disablercooler/do_install(mob/living/silicon/robot/R)
	var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
	if(!T)
		to_chat(usr, "<span class='notice'>There's no disabler in this unit!</span>")
		return
	if(T.charge_delay <= 2)
		to_chat(R, "<span class='notice'>A cooling unit is already installed!</span>")
		to_chat(usr, "<span class='notice'>There's no room for another cooling unit!</span>")
		return

	T.charge_delay = max(2 , T.charge_delay - 4)

	return TRUE

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "A energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4"

/obj/item/borg/upgrade/thrusters/do_install(mob/living/silicon/robot/R)
	if(R.ionpulse)
		to_chat(usr, "<span class='notice'>This unit already has ion thrusters installed!</span>")
		return

	R.ionpulse = 1
	return TRUE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=5"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner
	items_to_replace = list(
		/obj/item/pickaxe/drill/cyborg = /obj/item/pickaxe/drill/cyborg/diamond
	)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=4;bluespace=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner
	items_to_replace = list(
		/obj/item/storage/bag/ore/cyborg = /obj/item/storage/bag/ore/holding
	)

/obj/item/borg/upgrade/abductor_engi
	name = "engineering cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces an engineering cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "engineering=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering
	items_to_replace = list(
		/obj/item/weldingtool = /obj/item/weldingtool/abductor,
		/obj/item/wrench = /obj/item/wrench/abductor,
		/obj/item/screwdriver = /obj/item/screwdriver/abductor,
		/obj/item/crowbar = /obj/item/crowbar/abductor,
		/obj/item/wirecutters = /obj/item/wirecutters/abductor,
		/obj/item/multitool = /obj/item/multitool/abductor
	)
	special_rechargables = list(
		/obj/item/weldingtool/abductor
	)

/obj/item/borg/upgrade/abductor_medi
	name = "medical cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces a medical cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "biotech=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	items_to_replace = list(
		/obj/item/scalpel/laser/laser1 = /obj/item/scalpel/laser/laser3, // No abductor laser scalpel, so next best thing.
		/obj/item/hemostat = /obj/item/hemostat/alien,
		/obj/item/retractor = /obj/item/retractor/alien,
		/obj/item/bonegel = /obj/item/bonegel/alien,
		/obj/item/FixOVein = /obj/item/FixOVein/alien,
		/obj/item/bonesetter = /obj/item/bonesetter/alien,
		/obj/item/circular_saw = /obj/item/circular_saw/alien,
		/obj/item/surgicaldrill = /obj/item/surgicaldrill/alien
	)

/obj/item/borg/upgrade/syndicate
	name = "safety override module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	origin_tech = "combat=6;materials=6"
	require_module = TRUE

/obj/item/borg/upgrade/syndicate/do_install(mob/living/silicon/robot/R)
	if(R.weapons_unlock)
		return // They already had the safety override upgrade, or they're a cyborg type which has this by default.
	R.weapons_unlock = TRUE
	to_chat(R, "<span class='warning'>Warning: Safety Overide Protocols have be disabled.</span>")
	return TRUE

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/lavaproof/do_install(mob/living/silicon/robot/R)
	if(istype(R))
		R.weather_immunities += "lava"
	return TRUE

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_module = TRUE
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = 0
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg

/obj/item/borg/upgrade/selfrepair/do_install(mob/living/silicon/robot/R)
	var/obj/item/borg/upgrade/selfrepair/U = locate() in R
	if(U)
		to_chat(usr, "<span class='warning'>This unit is already equipped with a self-repair module.</span>")
		return 0

	cyborg = R
	icon_state = "selfrepair_off"
	var/datum/action/A = new /datum/action/item_action/toggle(src)
	A.Grant(R)
	return TRUE

/obj/item/borg/upgrade/selfrepair/Destroy()
	cyborg = null
	STOP_PROCESSING(SSobj, src)
	on = 0
	return ..()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		to_chat(cyborg, "<span class='notice'>You activate the self-repair module.</span>")
		START_PROCESSING(SSobj, src)
	else
		to_chat(cyborg, "<span class='notice'>You deactivate the self-repair module.</span>")
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/deactivate()
	STOP_PROCESSING(SSobj, src)
	on = 0
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>")
			deactivate()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please recharge.</span>")
			deactivate()
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

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>")
			msg_cooldown = world.time
	else
		deactivate()
