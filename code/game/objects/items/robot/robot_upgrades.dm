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
	var/instant_use = FALSE
	var/multiple_use = FALSE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		to_chat(usr, "<span class='notice'>[src] will not function on a deceased cyborg.</span>")
		return FALSE
	if(src in R.upgrades && !multiple_use)
		to_chat(R, "<span class='notice'>There is already [src] inside!</span>")
		return FALSE
	if(module_type && !istype(R.module, module_type))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return FALSE
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/R, user = usr)
	if (!(src in R.upgrades))
		return FALSE
	return TRUE

/obj/item/borg/upgrade/reset
	name = "cyborg module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the cyborg."
	icon_state = "cyborg_upgrade1"
	require_module = TRUE
	instant_use = TRUE

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	if(..())
		if(!isclocker(R))
			R.reset_module()

	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"
	instant_use = TRUE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..())
		if(!R.allow_rename)
			to_chat(R, "<span class='warning'>Internal diagnostic error: incompatible upgrade module detected.</span>")
			return 0
		R.notify_ai(ROBOT_NOTIFY_AI_NAME, R.name, heldname)
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
	instant_use = TRUE

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
	if(R.health < 0)
		to_chat(usr, "<span class='warning'>You have to repair the cyborg before using this module!</span>")
		return FALSE
	if(!R.key)
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key
	R.stat = CONSCIOUS
	GLOB.dead_mob_list -= R //please never forget this ever kthx
	GLOB.alive_mob_list += R
	R.notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
	return TRUE

/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = TRUE
	origin_tech = "engineering=4;materials=5;programming=4"

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..())
		R.speed = -1 // Gotta go fast.

		return TRUE

/obj/item/borg/upgrade/vtec/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		R.speed = 0

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4;combat=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/security

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R)
	if(..())
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			to_chat(usr, "<span class='notice'>There's no disabler in this unit!</span>")
			return
		T.charge_delay = max(2 , T.charge_delay - 4)

		return TRUE

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			return FALSE
		T.charge_delay = initial(T.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "A energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;powerstorage=4"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R)
	if(..())
		R.ionpulse = TRUE
		return TRUE

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		R.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=5"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R)
	if(..())
		for(var/obj/item/pickaxe/drill/cyborg/D in R.module.modules)
			qdel(D)
		for(var/obj/item/shovel/S in R.module.modules)
			qdel(S)

		R.module.modules += new /obj/item/pickaxe/drill/cyborg/diamond(R.module)
		R.module.rebuild()

		return TRUE

/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in R.module)
			qdel(DD)

		R.module.modules += new /obj/item/pickaxe/drill/cyborg(R.module)
		R.module.modules += new /obj/item/shovel(R.module)
		R.module.rebuild()

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	origin_tech = "engineering=4;materials=4;bluespace=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R)
	if(..())
		for(var/obj/item/storage/bag/ore/cyborg/S in R.module.modules)
			qdel(S)

		R.module.modules += new /obj/item/storage/bag/ore/holding/cyborg(R.module)
		R.module.rebuild()

		return TRUE

/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		for(var/obj/item/storage/bag/ore/holding/cyborg/H in R.module)
			qdel(H)

		R.module.modules += new /obj/item/storage/bag/ore/cyborg(R.module)
		R.module.rebuild()

/obj/item/borg/upgrade/abductor_engi
	name = "engineering cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces an engineering cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "engineering=6;materials=6;abductor=3"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering

/obj/item/borg/upgrade/abductor_engi/action(mob/living/silicon/robot/R)
	if(..())
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

/obj/item/borg/upgrade/abductor_engi/deactivate(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/weldingtool/abductor/W in R.module.modules)
		qdel(W)
	for(var/obj/item/screwdriver/abductor/S in R.module.modules)
		qdel(S)
	for(var/obj/item/wrench/abductor/E in R.module.modules)
		qdel(E)
	for(var/obj/item/crowbar/abductor/C in R.module.modules)
		qdel(C)
	for(var/obj/item/wirecutters/abductor/I in R.module.modules)
		qdel(I)
	for(var/obj/item/multitool/abductor/M in R.module.modules)
		qdel(M)

	R.module.modules += new /obj/item/weldingtool/abductor(R.module)
	R.module.modules += new /obj/item/wrench/cyborg(R.module)
	R.module.modules += new /obj/item/screwdriver/cyborg(R.module)
	R.module.modules += new /obj/item/crowbar/cyborg(R.module)
	R.module.modules += new /obj/item/wirecutters/cyborg(R.module)
	R.module.modules += new /obj/item/multitool/cyborg(R.module)
	R.module.rebuild()

	return TRUE

/obj/item/borg/upgrade/abductor_medi
	name = "medical cyborg abductor upgrade"
	desc = "An experimental upgrade that replaces a medical cyborgs tools with the abductor version."
	icon_state = "abductor_mod"
	origin_tech = "biotech=6;materials=6;abductor=2"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical

/obj/item/borg/upgrade/abductor_medi/action(mob/living/silicon/robot/R)
	if(..())
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

/obj/item/borg/upgrade/abductor_medi/deactivate(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/scalpel/laser/laser3/L in R.module.modules)
		qdel(L)
	for(var/obj/item/hemostat/alien/H in R.module.modules)
		qdel(H)
	for(var/obj/item/retractor/alien/E in R.module.modules)
		qdel(E)
	for(var/obj/item/bonegel/alien/B in R.module.modules)
		qdel(B)
	for(var/obj/item/FixOVein/alien/F in R.module.modules)
		qdel(F)
	for(var/obj/item/bonesetter/alien/S in R.module.modules)
		qdel(S)
	for(var/obj/item/circular_saw/alien/C in R.module.modules)
		qdel(C)
	for(var/obj/item/surgicaldrill/alien/D in R.module.modules)
		qdel(D)

	R.module.modules += new /obj/item/scalpel/laser/laser1(R.module)
	R.module.modules += new /obj/item/hemostat(R.module)
	R.module.modules += new /obj/item/retractor(R.module)
	R.module.modules += new /obj/item/bonegel(R.module)
	R.module.modules += new /obj/item/FixOVein(R.module)
	R.module.modules += new /obj/item/bonesetter(R.module)
	R.module.modules += new /obj/item/circular_saw(R.module)
	R.module.modules += new /obj/item/surgicaldrill(R.module)
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
		to_chat(R, "<span class='warning'>Warning: Safety Overide Protocols have been disabled.</span>")
		R.weapons_unlock = TRUE
		return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		to_chat(R, "<span class='notice'>Notice: Safety Overide Protocols have been restored.</span>")
		R.weapons_unlock = FALSE

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = TRUE
	module_type = /obj/item/robot_module/miner

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R)
	if(..())
		R.weather_immunities += "lava"
		return TRUE

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..() && ("lava" in R.weather_immunities))
		R.weather_immunities -= "lava"

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
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R)
	if(..())
		icon_state = "selfrepair_off"
		cyborg = R
		toggle_action = new /datum/action/item_action/toggle(src)
		toggle_action.Grant(R)
		return TRUE

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		cyborg = null
		toggle_action.Remove(R)
		QDEL_NULL(toggle_action)
		STOP_PROCESSING(SSobj, src)
		if(!QDELETED(src))
			qdel(src)

/obj/item/borg/upgrade/selfrepair/Destroy()
	on = 0
	return ..()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		to_chat(cyborg, "<span class='notice'>You activate the self-repair module.</span>")
		activate_sr()
	else
		to_chat(cyborg, "<span class='notice'>You deactivate the self-repair module.</span>")
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
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please, insert the power cell.</span>")
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, "<span class='warning'>Self-repair module deactivated. Please recharge.</span>")
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

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, "<span class='notice'>Self-repair is active in <span class='boldnotice'>[msgmode]</span> mode.</span>")
			msg_cooldown = world.time
	else
		deactivate_sr()

/obj/item/borg/upgrade/storageincreaser
	name = "storage increaser"
	desc = "Improves cyborg storage with bluespace technology to store more medicines"
	icon_state = "cyborg_upgrade2"
	origin_tech = "bluespace=4;materials=5;engineering=3"
	require_module = TRUE

/obj/item/borg/upgrade/storageincreaser/action(mob/living/silicon/robot/R)
	if(..())
		for(var/datum/robot_energy_storage/ES in R.module.storages)
			ES.max_energy *= 3
			ES.recharge_rate *= 2
			ES.energy = ES.max_energy
		return TRUE

/obj/item/borg/upgrade/storageincreaser/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		for(var/datum/robot_energy_storage/ES in R.module.storages)
			ES.max_energy = initial(ES.max_energy)
			ES.recharge_rate = initial(ES.recharge_rate)
			ES.energy = initial(ES.max_energy)

/obj/item/borg/upgrade/hypospray
	name = "cyborg hypospray upgrade"
	desc = "Adds and replaces some reagents with better ones"
	icon_state = "cyborg_upgrade2"
	origin_tech = "biotech=6;materials=5"
	require_module = TRUE

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/R)
	if(..())
		var/obj/item/reagent_containers/borghypo/basic/H2 = locate() in R.module.modules
		if(H2)
			qdel(H2)
			R.module.modules += new /obj/item/reagent_containers/borghypo/basic/upgraded(R.module)
			R.module.rebuild()
			return TRUE

		var/obj/item/reagent_containers/borghypo/H = locate() in R.module.modules
		if(H)
			qdel(H)
			R.module.modules += new /obj/item/reagent_containers/borghypo/upgraded(R.module)
			R.module.rebuild()
			return TRUE

		to_chat(usr, "<span class='notice'>There's no hypospray in this unit!</span>")
		return 0

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/R, user = usr)
	if(..())
		var/obj/item/reagent_containers/borghypo/basic/upgraded/H2 = locate() in R.module.modules
		if(H2)
			qdel(H2)
			R.module.modules += new /obj/item/reagent_containers/borghypo/basic(R.module)
			R.module.rebuild()
		var/obj/item/reagent_containers/borghypo/upgraded/H = locate() in R.module.modules
		if(H)
			qdel(H)
			R.module.modules += new /obj/item/reagent_containers/borghypo(R.module)
			R.module.rebuild()

/obj/item/borg/upgrade/syndie_rcd
	name = "Syndicate cyborg RCD upgrade"
	desc = "An experimental upgrade that replaces cyborgs RCDs with the syndicate version."
	icon_state = "syndicate_cyborg_upgrade"
	origin_tech = "engineering=6;materials=6;syndicate=5"

/obj/item/borg/upgrade/syndie_rcd/action(mob/living/silicon/robot/R)
	if(..())
		var/obj/item/rcd/borg/borg_rcd = locate() in R.module.modules
		if(!borg_rcd)
			to_chat(usr, "<span class='notice'>There's no RCD in this unit!</span>")
			return 0
		for(borg_rcd in R.module.modules)
			qdel(borg_rcd)
		R.module.modules += new /obj/item/rcd/syndicate/borg(R.module)
		R.module.rebuild()
		return TRUE

/obj/item/borg/upgrade/syndie_rcd/deactivate(mob/living/silicon/robot/R)
	if(..())
		var/obj/item/rcd/syndicate/borg/borg_rcd = locate() in R.module.modules
		if(!borg_rcd)
			return
		for(borg_rcd in R.module.modules)
			qdel(borg_rcd)
		R.module.modules += new /obj/item/rcd/borg(R.module)
		R.module.rebuild()
