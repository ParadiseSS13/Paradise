/mob/living/silicon/robot/Life()
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
		if(!is_component_functioning("power cell") || !cell)
			Paralyse(2)
			uneq_all()
			low_power_mode = 1
			update_headlamp()
			diag_hud_set_borgcell()
			return
		if(low_power_mode)
			if(is_component_functioning("power cell") && cell && cell.charge)
				low_power_mode = 0
				update_headlamp()
		else if(stat == CONSCIOUS)
			use_power()

/mob/living/silicon/robot/proc/use_power()
	if(is_component_functioning("power cell") && cell && cell.charge)
		if(cell.charge <= 100)
			uneq_all()
		var/amt = Clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
		cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick
	else
		uneq_all()
		low_power_mode = 1
		update_headlamp()
	update_cell_hud()
	diag_hud_set_borgcell()


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
				to_chat(src, "\red <B>Weapon Lock Timed Out!")
			weapon_lock = 0
			weaponlock_time = 120

/mob/living/silicon/robot/update_canmove(delay_action_updates = 0)
	if(incapacitated())
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

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

//Robots on fire
