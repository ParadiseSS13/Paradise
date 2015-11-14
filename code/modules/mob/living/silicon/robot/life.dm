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
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	if (is_component_functioning("power cell") && cell)
		if(src.cell.charge <= 0)
			uneq_all()
			update_headlamp(1)
			src.stat = UNCONSCIOUS
			has_power = 0
			for(var/V in components)
				var/datum/robot_component/C = components[V]
				if(C.name == "actuator") // Let drained robots move, disable the rest
					continue
				C.consume_power()
		else if (src.cell.charge <= 100)
			uneq_all()
			src.cell.use(1)
		else
			if(src.module_state_1)
				src.cell.use(4)
			if(src.module_state_2)
				src.cell.use(4)
			if(src.module_state_3)
				src.cell.use(4)

			for(var/V in components)
				var/datum/robot_component/C = components[V]
				C.consume_power()

			var/amt = Clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
			cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick

			if(!is_component_functioning("actuator"))
				Paralyse(3)
			src.eye_blind = 0
			src.stat = 0
			has_power = 1
	else
		uneq_all()
		src.stat = UNCONSCIOUS
		update_headlamp(1)
		Paralyse(3)

/mob/living/silicon/robot/handle_regular_status_updates()

	if(src.camera && !scrambledcodes)
		if(src.stat == 2 || wires.IsCameraCut())
			src.camera.status = 0
		else
			src.camera.status = 1

	health = maxHealth - (getOxyLoss() + getFireLoss() + getBruteLoss())

	if(getOxyLoss() > 50) Paralyse(3)

	if(src.sleeping)
		Paralyse(3)
		src.sleeping--

	if(src.resting)
		Weaken(5)

	if(health <= config.health_threshold_dead && src.stat != 2) //die only once
		death()

	if (src.stat != 2) //Alive.
		if(!istype(src,/mob/living/silicon/robot/drone))
			if(health < 50) //Gradual break down of modules as more damage is sustained
				if(uneq_module(module_state_3))
					src << "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>"
				if(health < 0)
					if(uneq_module(module_state_2))
						src << "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>"
					if(health < -50)
						if(uneq_module(module_state_1))
							src << "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>"

		if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
			src.stat = 1
			if (src.stunned > 0)
				AdjustStunned(-1)
			if (src.weakened > 0)
				AdjustWeakened(-1)
			if (src.paralysis > 0)
				AdjustParalysis(-1)
				src.eye_blind = max(eye_blind, 1)
			else
				src.eye_blind = 0

		else	//Not stunned.
			src.stat = 0

	else //Dead.
		src.eye_blind = 1

	if (src.stuttering) src.stuttering--

	if (src.eye_blind)
		src.eye_blind--

	src.density = !( src.lying )

	if (src.disabilities & BLIND)
		src.eye_blind = max(1, eye_blind)

	if (src.eye_blurry > 0)
		src.eye_blurry--
		src.eye_blurry = max(0, src.eye_blurry)

	if (src.druggy > 0)
		src.druggy--
		src.druggy = max(0, src.druggy)

	//update the state of modules and components here
	if (src.stat != 0)
		uneq_all()

	if(!is_component_functioning("radio") || src.stat == 1)
		radio.on = 0
	else
		radio.on = 1

	if(is_component_functioning("camera") && src.stat == 0)
		src.blinded = 0
	else
		src.blinded = 1

	if(!is_component_functioning("actuator"))
		src.Paralyse(3)


	return 1

/mob/living/silicon/robot/update_sight()

	if (src.stat == 2 || src.sight_mode & BORGXRAY)
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		src.see_in_dark = 8
		if (src.sight_mode & BORGMESON && src.sight_mode & BORGTHERM)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.see_invisible = SEE_INVISIBLE_MINIMUM
		else if (src.sight_mode & BORGMESON)
			src.sight |= SEE_TURFS
			src.see_invisible = SEE_INVISIBLE_MINIMUM
			src.see_in_dark = 1
		else if (src.sight_mode & BORGTHERM)
			src.sight |= SEE_MOBS
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else if (src.stat != 2)
			src.sight &= ~SEE_MOBS
			src.sight &= ~SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
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
			else if(health > maxHealth*0.5)
				healths.icon_state = "health2"
			else if(health > 0)
				healths.icon_state = "health3"
			else if(health > -maxHealth*0.5)
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


/mob/living/silicon/robot/handle_regular_hud_updates()
	if(!client)
		return

	switch(sensor_mode)
		if(SEC_HUD)
			process_sec_hud(src,1)
		if(MED_HUD)
			process_med_hud(src,1)

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



/mob/living/silicon/robot/proc/update_items()
	if (src.client)
		src.client.screen -= src.contents
		for(var/obj/I in src.contents)
			if(I && !(istype(I,/obj/item/weapon/stock_parts/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				src.client.screen += I
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
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire