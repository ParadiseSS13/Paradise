/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (src.notransform)
		return

	//Status updates, death etc.
	clamp_values()

	if(..())
		use_power()
		process_locks()
		process_queued_alarms()

/mob/living/silicon/robot/proc/clamp_values()
	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
	SetWeakened(min(weakened, 20))
	sleeping = 0
	ear_deaf = 0


/mob/living/silicon/robot/proc/use_power()
	if (stat == DEAD)
		return
	else if (is_component_functioning("power cell") && cell)
		if(module)
			for(var/obj/item/borg/B in get_all_slots())
				if(B.powerneeded)
					if((cell.charge * 100 / cell.maxcharge) < B.powerneeded)
						src << "Deactivating [B.name] due to lack of power!"
						uneq_module(B)
		if(cell.charge <= 0)
			uneq_all()
			update_headlamp(1)
			stat = UNCONSCIOUS
			has_power = 0
			for(var/V in components)
				var/datum/robot_component/C = components[V]
				if(C.name == "actuator") // Let drained robots move, disable the rest
					continue
				C.consume_power()
		else if(cell.charge <= 100)
			uneq_all()
			cell.use(1)
		else
			if(module_state_1)
				cell.use(4)
			if(module_state_2)
				cell.use(4)
			if(module_state_3)
				cell.use(4)

			for(var/V in components)
				var/datum/robot_component/C = components[V]
				C.consume_power()

			var/amt = Clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
			cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick

			if(!is_component_functioning("actuator"))
				Paralyse(3)
			eye_blind = 0
			// Please, PLEASE be careful with statements like this - make sure they're not
			// dead beforehand, for example -- Crazylemon
			stat = CONSCIOUS
			has_power = 1
	else
		uneq_all()
		stat = UNCONSCIOUS
		update_headlamp(1)
		Paralyse(3)
	diag_hud_set_borgcell()

/mob/living/silicon/robot/handle_regular_status_updates()

	. = ..()

	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	if(getOxyLoss() > 50)
		Paralyse(3)

	if(sleeping)
		Paralyse(3)
		sleeping--

	if(resting)
		Weaken(5)

	if(.) //alive
		if(health <= config.health_threshold_dead)
			death()
			diag_hud_set_status()
			return

		if(!istype(src, /mob/living/silicon/robot/drone))
			if(health < 50) //Gradual break down of modules as more damage is sustained
				if(uneq_module(module_state_3))
					src << "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>"

				if(health < 0)
					if(uneq_module(module_state_2))
						src << "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>"

					if(health < -50)
						if(uneq_module(module_state_1))
							src << "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>"

		if(paralysis || stunned || weakened)
			stat = UNCONSCIOUS

			if(!paralysis > 0)
				eye_blind = 0

		else
			stat = CONSCIOUS

		diag_hud_set_health()
		diag_hud_set_status()
	else //dead
		eye_blind = 1

	//update the state of modules and components here
	if(stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio") || stat == UNCONSCIOUS)
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera") && stat == CONSCIOUS)
		blinded = 0
	else
		blinded = 1

	if(!is_component_functioning("actuator"))
		Paralyse(3)

	return 1

/mob/living/silicon/robot/update_sight()
	if(stat == DEAD || sight_mode & BORGXRAY)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		see_in_dark = 8
		if(sight_mode & BORGMESON && sight_mode & BORGTHERM)
			sight |= SEE_TURFS
			sight |= SEE_MOBS
			see_invisible = SEE_INVISIBLE_MINIMUM
		else if(sight_mode & BORGMESON)
			sight |= SEE_TURFS
			see_invisible = SEE_INVISIBLE_MINIMUM
			see_in_dark = 1
		else if(sight_mode & BORGTHERM)
			sight |= SEE_MOBS
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else if(stat != DEAD)
			sight &= ~SEE_MOBS
			sight &= ~SEE_TURFS
			sight &= ~SEE_OBJS
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(see_override)
			see_invisible = see_override

/mob/living/silicon/robot/handle_hud_icons()
	update_items()
	update_cell()
	..()

/mob/living/silicon/robot/handle_hud_icons_health()
	if(healths)
		if(stat != DEAD)
			if(health >= maxHealth)
				healths.icon_state = "health0"
			else if(health > maxHealth * 0.5)
				healths.icon_state = "health2"
			else if(health > 0)
				healths.icon_state = "health3"
			else if(health > -maxHealth * 0.5)
				healths.icon_state = "health4"
			else if(health > -maxHealth)
				healths.icon_state = "health5"
			else
				healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(bodytemp)
		switch(bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				bodytemp.icon_state = "temp2"
			if(320 to 335)
				bodytemp.icon_state = "temp1"
			if(300 to 320)
				bodytemp.icon_state = "temp0"
			if(260 to 300)
				bodytemp.icon_state = "temp-1"
			else
				bodytemp.icon_state = "temp-2"

/mob/living/silicon/robot/proc/update_cell()
	if(cells)
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					cells.icon_state = "charge4"
				if(0.5 to 0.75)
					cells.icon_state = "charge3"
				if(0.25 to 0.5)
					cells.icon_state = "charge2"
				if(0 to 0.25)
					cells.icon_state = "charge1"
				else
					cells.icon_state = "charge0"
		else
			cells.icon_state = "charge-empty"


/*/mob/living/silicon/robot/handle_regular_hud_updates()
//	if(!client)
//		return
//
//	switch(sensor_mode)
//		if(SEC_HUD)
//			process_sec_hud(src,1)
//		if(MED_HUD)
//			process_med_hud(src,1)

	if(syndicate)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor")
					src.client.images += I
		if(connected_ai)
			connected_ai.connected_robots -= src
			connected_ai = null
		if(mind)
			if(!mind.special_role)
				mind.special_role = "traitor"
				ticker.mode.traitors += src.mind


	..()
	return 1
	*/



/mob/living/silicon/robot/proc/update_items()
	if (src.client)
		for(var/obj/I in get_all_slots())
			client.screen |= I
	if(src.module_state_1)
		src.module_state_1:screen_loc = ui_inv1
	if(src.module_state_2)
		src.module_state_2:screen_loc = ui_inv2
	if(src.module_state_3)
		src.module_state_3:screen_loc = ui_inv3
	update_icons()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
				src << "\red <B>Weapon Lock Timed Out!"
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || weakened || buckled || lockcharge)
		canmove = 0
	else
		canmove = 1
	update_transform()
	return canmove

//Robots on fire
/mob/living/silicon/robot/handle_fire()
	if(..())
		return
	if(fire_stacks > 0)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()

	//adjustFireLoss(3)
	return

/mob/living/silicon/robot/update_fire()
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire
