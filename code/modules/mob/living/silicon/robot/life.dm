/mob/living/silicon/robot/Life(seconds, times_fired)
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(src.notransform)
		return

	//Status updates, death etc.
	clamp_values()

	if(..())
		handle_robot_cell()
		process_locks()
		process_queued_alarms()

/mob/living/silicon/robot/proc/clamp_values()
	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
	SetWeakened(min(weakened, 20))
	SetSleeping(0)

/mob/living/silicon/robot/proc/handle_robot_cell()
	if(stat != DEAD)
		if(!is_component_functioning("power cell"))
			uneq_all()
			low_power_mode = 1
			update_headlamp()
			diag_hud_set_borgcell()
			return
		if(low_power_mode)
			if(is_component_functioning("power cell") && cell.charge)
				low_power_mode = 0
				update_headlamp()
		else if(stat == CONSCIOUS)
			use_power()

/mob/living/silicon/robot/proc/use_power()
	// this check is safe because `cell` is guaranteed to be set when the power cell is functioning
	if(is_component_functioning("power cell") && cell.charge)
		if(cell.charge <= 100)
			uneq_all()
		var/amt = Clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
		cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick
	else
		uneq_all()
		low_power_mode = 1
		update_headlamp()
	diag_hud_set_borgcell()

/mob/living/silicon/robot/handle_regular_status_updates()

	. = ..()

	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	if(sleeping)
		AdjustSleeping(-1)

	if(.) //alive
		if(!istype(src, /mob/living/silicon/robot/drone))
			if(health < 50) //Gradual break down of modules as more damage is sustained
				if(uneq_module(module_state_3))
					to_chat(src, "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>")

				if(health < 0)
					if(uneq_module(module_state_2))
						to_chat(src, "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>")

					if(health < -50)
						if(uneq_module(module_state_1))
							to_chat(src, "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>")

		diag_hud_set_health()
		diag_hud_set_status()

	//update the state of modules and components here
	if(stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio") || stat == UNCONSCIOUS)
		radio.on = 0
	else
		radio.on = 1

	return 1

/mob/living/silicon/robot/handle_hud_icons()
	update_items()
	update_cell()
	if(emagged)
		throw_alert("hacked", /obj/screen/alert/hacked)
	else
		clear_alert("hacked")
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

	switch(bodytemperature) //310.055 optimal body temp
		if(335 to INFINITY)
			throw_alert("temp", /obj/screen/alert/hot/robot, 2)
		if(320 to 335)
			throw_alert("temp", /obj/screen/alert/hot/robot, 1)
		if(300 to 320)
			clear_alert("temp")
		if(260 to 300)
			throw_alert("temp", /obj/screen/alert/cold/robot, 1)
		else
			throw_alert("temp", /obj/screen/alert/cold/robot, 2)

/mob/living/silicon/robot/proc/update_cell()
	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				clear_alert("charge")
			if(0.5 to 0.75)
				throw_alert("charge", /obj/screen/alert/lowcell, 1)
			if(0.25 to 0.5)
				throw_alert("charge", /obj/screen/alert/lowcell, 2)
			if(0.01 to 0.25)
				throw_alert("charge", /obj/screen/alert/lowcell, 3)
			else
				throw_alert("charge", /obj/screen/alert/emptycell)
	else
		throw_alert("charge", /obj/screen/alert/nocell)



/mob/living/silicon/robot/proc/update_items()
	if(client)
		for(var/obj/I in get_all_slots())
			client.screen |= I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3
	update_icons()

/mob/living/silicon/robot/proc/process_locks()
	if(weapon_lock)
		uneq_all()
		weaponlock_time --
		if(weaponlock_time <= 0)
			if(src.client)
				to_chat(src, "<span class='warning'><B>Weapon Lock Timed Out!</span>")
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove(delay_action_updates = 0)
	if(paralysis || stunned || IsWeakened() || buckled || lockcharge || stat)
		canmove = 0
	else
		canmove = 1
	update_transform()
	if(!delay_action_updates)
		update_action_buttons_icon()
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

/mob/living/silicon/robot/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire
