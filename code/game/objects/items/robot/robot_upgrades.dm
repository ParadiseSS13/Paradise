// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "programming=2"
	var/locked = 0
	var/installed = 0
	var/require_module = FALSE
	var/module_type = null

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='notice'>[src] will not function on a deceased cyborg.</span>")
		return TRUE
	if(module_type && !istype(R.module, module_type))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return TRUE

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = TRUE

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	if(..())
		return

	R.reset_module()

	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..())
		return
	if(!R.allow_rename)
		to_chat(R, "<span class='warning'>Internal diagnostic error: incompatible upgrade module detected.</span>")
		return 0
	R.notify_ai(3, R.name, heldname)
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

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
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
	R.notify_ai(1)

	return TRUE


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = TRUE
	origin_tech = "engineering=4;materials=5;programming=4"

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..())
		return
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

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R)
	if(..())
		return

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

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R)
	if(..())
		return

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

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/pickaxe/drill/cyborg/D in R.module.modules)
		qdel(D)
	for(var/obj/item/shovel/S in R.module.modules)
		qdel(S)

	R.module.modules += new /obj/item/pickaxe/drill/cyborg/diamond(R.module)
	R.module.rebuild()

	return TRUE

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=4;bluespace=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/storage/bag/ore/cyborg/S in R.module.modules)
		qdel(S)

	R.module.modules += new /obj/item/storage/bag/ore/holding(R.module)
	R.module.rebuild()

	return TRUE

/obj/item/borg/upgrade/abductor_engi
	name = "engineering cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces an engineering cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "engineering=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering

/obj/item/borg/upgrade/abductor_engi/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weldingtool/largetank/cyborg/W in R.module.modules)
		qdel(W)
	for(var/obj/item/screwdriver/cyborg/S in R.module.modules)
		qdel(S)
	for(var/obj/item/wrench/cyborg/E in R.module.modules)
		qdel(E)
	for(var/obj/item/crowbar/cyborg/C in R.module.modules)
		qdel(C)
	for(var/obj/item/wirecutters/cyborg/I in R.module.modules)
		qdel(I)
	for(var/obj/item/multitool/cyborg/M in R.module.modules)
		qdel(M)

	R.module.modules += new /obj/item/weldingtool/abductor(R.module)
	R.module.modules += new /obj/item/wrench/abductor(R.module)
	R.module.modules += new /obj/item/screwdriver/abductor(R.module)
	R.module.modules += new /obj/item/crowbar/abductor(R.module)
	R.module.modules += new /obj/item/wirecutters/abductor(R.module)
	R.module.modules += new /obj/item/multitool/abductor(R.module)
	R.module.rebuild()

	return TRUE

/obj/item/borg/upgrade/abductor_medi
	name = "medical cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces a medical cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "biotech=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical

/obj/item/borg/upgrade/abductor_medi/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/scalpel/laser/laser1/L in R.module.modules)
		qdel(L)
	for(var/obj/item/hemostat/H in R.module.modules)
		qdel(H)
	for(var/obj/item/retractor/E in R.module.modules)
		qdel(E)
	for(var/obj/item/bonegel/B in R.module.modules)
		qdel(B)
	for(var/obj/item/FixOVein/F in R.module.modules)
		qdel(F)
	for(var/obj/item/bonesetter/S in R.module.modules)
		qdel(S)
	for(var/obj/item/circular_saw/C in R.module.modules)
		qdel(C)
	for(var/obj/item/surgicaldrill/D in R.module.modules)
		qdel(D)

	R.module.modules += new /obj/item/scalpel/laser/laser3(R.module) //no abductor laser scalpel, so next best thing.
	R.module.modules += new /obj/item/hemostat/alien(R.module)
	R.module.modules += new /obj/item/retractor/alien(R.module)
	R.module.modules += new /obj/item/bonegel/alien(R.module)
	R.module.modules += new /obj/item/FixOVein/alien(R.module)
	R.module.modules += new /obj/item/bonesetter/alien(R.module)
	R.module.modules += new /obj/item/circular_saw/alien(R.module)
	R.module.modules += new /obj/item/surgicaldrill/alien(R.module)
	R.module.rebuild()

	return TRUE

/obj/item/borg/upgrade/syndicate
	name = "safety override module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	origin_tech = "combat=6;materials=6"
	require_module = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R)
	if(..())
		return
	if(R.weapons_unlock)
		to_chat(R, "<span class='warning'>Warning: Safety Overide Protocols have be disabled.</span>")
		return
	R.weapons_unlock = 1
	return TRUE

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R)
	if(..())
		return
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

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R)
	if(..())
		return

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
