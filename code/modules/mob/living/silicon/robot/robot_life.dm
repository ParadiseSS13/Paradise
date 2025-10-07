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


/mob/living/silicon/robot/proc/handle_robot_cell()
	if(stat == DEAD)
		return
	if(externally_powered)
		return
	if(low_power_mode)
		handle_no_power()
	else if(!is_component_functioning("power cell")) //This makes it so you'll only get the warnings once per running out of charge
		enter_low_power_mode()
	else if(stat == CONSCIOUS)
		use_power()

/mob/living/silicon/robot/proc/use_power()
	var/amt = clamp((lamp_intensity - 2) * 2, 1, cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
	cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick
	diag_hud_set_borgcell()

/mob/living/silicon/robot/proc/handle_no_power()
	diag_hud_set_borgcell()
	if(is_component_functioning("power cell"))
		low_power_mode = FALSE
		return
	adjustStaminaLoss(3)

/mob/living/silicon/robot/proc/enter_low_power_mode()
	low_power_mode = TRUE
	playsound(src, "sound/mecha/lowpower.ogg", 50, FALSE, SOUND_RANGE_SET(10))
	to_chat(src, "<span class='warning'>Alert: Power cell requires immediate charging.</span>")
	handle_no_power()

/mob/living/silicon/robot/proc/handle_equipment()
	if(camera && camera.status && !scrambledcodes) //Don't turn off cameras already off
		if(stat == DEAD || wires.is_cut(WIRE_BORG_CAMERA))
			camera.turn_off(src, FALSE)

	//update the state of modules and components here
	if(stat != CONSCIOUS)
		uneq_all()

	if(!is_component_functioning("radio") || stat == UNCONSCIOUS)
		radio.on = FALSE
	else
		radio.on = TRUE

/mob/living/silicon/robot/proc/SetEmagged(new_state)
	emagged = new_state
	update_icons()
	if(emagged)
		throw_alert("hacked", /atom/movable/screen/alert/hacked)
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
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 1)
			if(0.25 to 0.5)
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 2)
			if(0.01 to 0.25)
				throw_alert("charge", /atom/movable/screen/alert/lowcell, 3)
			else
				throw_alert("charge", /atom/movable/screen/alert/emptycell)
	else
		throw_alert("charge", /atom/movable/screen/alert/nocell)



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
