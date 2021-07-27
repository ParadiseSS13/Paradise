/mob/living/silicon/robot/Life(seconds, times_fired)
	set invisibility = 0
	if(notransform)
		return

	. = ..()

	handle_equipment()

	// if Alive
	if(.)
		handle_robot_hud_updates()
		handle_robot_cell()
		process_locks()
		update_items()


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
		var/amt = clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
		cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick
	else
		uneq_all()
		low_power_mode = 1
		update_headlamp()
	diag_hud_set_borgcell()

/mob/living/silicon/robot/proc/handle_equipment()
	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.is_cut(WIRE_BORG_CAMERA))
			camera.status = 0
		else
			camera.status = 1

	//update the state of modules and components here
	if(stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio") || stat == UNCONSCIOUS)
		radio.on = 0
	else
		radio.on = 1

/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	update_icons()
	if(emagged)
		throw_alert("hacked", /obj/screen/alert/hacked)
	else
		clear_alert("hacked")

/mob/living/silicon/robot/proc/handle_robot_hud_updates()
	if(!client)
		return

	update_cell_hud_icon()

/mob/living/silicon/robot/update_health_hud()
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

/mob/living/silicon/robot/proc/update_cell_hud_icon()
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



/mob/living/silicon/robot/proc/update_items() // What in the Sam hell is this?
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
	. = ..()
	if(!.)
		return
	if(fire_stacks > 0)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()


/mob/living/silicon/robot/update_fire()
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning")

/mob/living/silicon/robot/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire
