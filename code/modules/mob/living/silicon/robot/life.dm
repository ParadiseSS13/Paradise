/mob/living/silicon/robot/Life()
	set invisibility = 0
	//set background = 1

	if (src.notransform)
		return

	src.blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	handle_actions()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if (src.stat != DEAD) //still using power
		use_power()
		process_locks()

	update_canmove()

	update_gravity(mob_has_gravity())

	handle_fire()

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
			src.stat = 1
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

			if(!is_component_functioning("actuator"))
				Paralyse(3)
			src.eye_blind = 0
			src.stat = 0
			has_power = 1
	else
		uneq_all()
		src.stat = 1
		Paralyse(3)

/mob/living/silicon/robot/proc/handle_regular_status_updates()

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

/mob/living/silicon/robot/proc/handle_regular_hud_updates()

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

	regular_hud_updates()

	switch(src.sensor_mode)
		if (SEC_HUD)
			process_sec_hud(src,1)
		if (MED_HUD)
			process_med_hud(src,1)

	if (src.healths)
		if (src.stat != 2)
			if(istype(src,/mob/living/silicon/robot/drone))
				switch(health)
					if(35 to INFINITY)
						src.healths.icon_state = "health0"
					if(25 to 34)
						src.healths.icon_state = "health1"
					if(15 to 24)
						src.healths.icon_state = "health2"
					if(5 to 14)
						src.healths.icon_state = "health3"
					if(0 to 4)
						src.healths.icon_state = "health4"
					if(-35 to 0)
						src.healths.icon_state = "health5"
					else
						src.healths.icon_state = "health6"
			else
				switch(health)
					if(100 to INFINITY)
						src.healths.icon_state = "health0"
					if(50 to 100)
						src.healths.icon_state = "health2"
					if(0 to 50)
						src.healths.icon_state = "health3"
					if(-50 to 0)
						src.healths.icon_state = "health4"
					if(config.health_threshold_dead to -50)
						src.healths.icon_state = "health5"
					else
						src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"

	if (src.syndicate && src.client)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor")
					src.client.images += I
		if(src.connected_ai)
			src.connected_ai.connected_robots -= src
			src.connected_ai = null
		if(src.mind)
			if(!src.mind.special_role)
				src.mind.special_role = "traitor"
				ticker.mode.traitors += src.mind

	if (src.cells)
		if (src.cell)
			var/cellcharge = src.cell.charge/src.cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					src.cells.icon_state = "charge4"
				if(0.5 to 0.75)
					src.cells.icon_state = "charge3"
				if(0.25 to 0.5)
					src.cells.icon_state = "charge2"
				if(0 to 0.25)
					src.cells.icon_state = "charge1"
				else
					src.cells.icon_state = "charge0"
		else
			src.cells.icon_state = "charge-empty"

	if(bodytemp)
		switch(src.bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				src.bodytemp.icon_state = "temp2"
			if(320 to 335)
				src.bodytemp.icon_state = "temp1"
			if(300 to 320)
				src.bodytemp.icon_state = "temp0"
			if(260 to 300)
				src.bodytemp.icon_state = "temp-1"
			else
				src.bodytemp.icon_state = "temp-2"


	if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"
//Oxygen and fire does nothing yet!!
//	if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
//	if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"

	client.screen.Remove(global_hud.blurry,global_hud.druggy,global_hud.vimpaired)

	if ((src.blind && src.stat != 2))
		if(src.blinded)
			src.blind.layer = 18
		else
			src.blind.layer = 0
			if (src.disabilities & NEARSIGHTED)
				src.client.screen += global_hud.vimpaired

			if (src.eye_blurry)
				src.client.screen += global_hud.blurry

			if (src.druggy)
				src.client.screen += global_hud.druggy

	if (src.stat != 2)
		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

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
	updateicon()

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
	if(paralysis || stunned || weakened || buckled || lockcharge) canmove = 0
	else canmove = 1
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
	update_icons()
	return

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire