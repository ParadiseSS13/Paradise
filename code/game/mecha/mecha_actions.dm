/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	if(locate(/obj/item/mecha_parts/mecha_equipment/thrusters) in equipment)
		add_thrusters()
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.give_targeted_action()

/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)
	thrusters_action.Remove(user)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.remove_targeted_action()

/datum/action/innate/mecha
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/mecha/chassis

/datum/action/innate/mecha/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
	. = ..()

/datum/action/innate/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/innate/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/mech_eject/Activate()
	if(!owner)
		return
	if(!chassis || chassis.occupant != owner)
		return
	chassis.go_out()

/datum/action/innate/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/innate/mecha/mech_toggle_internals/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.occupant_message("Now taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"].")
	chassis.log_message("Now taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"].")
	build_all_button_icons()

/datum/action/innate/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.lights = !chassis.lights
	if(chassis.lights)
		chassis.set_light(chassis.lights_range, chassis.lights_power)
		button_icon_state = "mech_lights_on"
	else
		chassis.set_light(chassis.lights_range_ambient, chassis.lights_power_ambient)
		button_icon_state = "mech_lights_off"
	chassis.occupant_message("Toggled lights [chassis.lights ? "on" : "off"].")
	chassis.log_message("Toggled lights [chassis.lights ? "on" : "off"].")
	build_all_button_icons()

/datum/action/innate/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/innate/mecha/mech_view_stats/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.occupant << browse(chassis.get_stats_html(), "window=exosuit")

/datum/action/innate/mecha/mech_defence_mode
	name = "Toggle Defence Mode"
	button_icon_state = "mech_defense_mode_off"

/datum/action/innate/mecha/mech_defence_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.defence_mode = forced_state
	else
		chassis.defence_mode = !chassis.defence_mode
	button_icon_state = "mech_defense_mode_[chassis.defence_mode ? "on" : "off"]"
	if(chassis.defence_mode)
		chassis.deflect_chance = chassis.defence_mode_deflect_chance
		chassis.occupant_message("<span class='notice'>You enable [chassis] defence mode.</span>")
	else
		chassis.deflect_chance = initial(chassis.deflect_chance)
		chassis.occupant_message("<span class='danger'>You disable [chassis] defence mode.</span>")
	chassis.log_message("Toggled defence mode.")
	build_all_button_icons()

/datum/action/innate/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/mech_overload_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.obj_integrity < chassis.max_integrity - chassis.max_integrity / 3)
		chassis.occupant_message("<span class='danger'>The leg actuators are too damaged to overload!</span>")
		return // Can't activate them if the mech is too damaged
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.")
	if(chassis.leg_overload_mode)
		chassis.leg_overload_mode = 1
		// chassis.bumpsmash = 1
		chassis.step_in = min(1, round(chassis.step_in / 2))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min, chassis.step_energy_drain * chassis.leg_overload_coeff)
		chassis.occupant_message("<span class='danger'>You enable leg actuators overload.</span>")
		if(istype(chassis.selected, /obj/item/mecha_parts/mecha_equipment/pulse_shield))
			chassis.occupant_message("<span class='danger'>Your shields turn off as your actuators overload.</span>")
	else
		chassis.leg_overload_mode = 0
		// chassis.bumpsmash = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message("<span class='notice'>You disable leg actuators overload.</span>")
	build_all_button_icons()
	chassis.update_icon(UPDATE_OVERLAYS)

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.get_charge() > 0)
		chassis.thrusters_active = !chassis.thrusters_active
		if(!chassis.thrusters_active)
			chassis.step_in = initial(chassis.step_in)
		button_icon_state = "mech_thrusters_[chassis.thrusters_active ? "on" : "off"]"
		chassis.log_message("Toggled thrusters.")
		chassis.occupant_message("<font color='[chassis.thrusters_active ? "blue" : "red"]'>Thrusters [chassis.thrusters_active ? "en" : "dis"]abled.")

/datum/action/innate/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/mech_smoke/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.smoke_ready && chassis.smoke > 0)
		chassis.smoke_system.start()
		chassis.smoke--
		chassis.smoke_ready = 0
		spawn(chassis.smoke_cooldown)
			chassis.smoke_ready = 1
	else
		chassis.occupant_message("<span class='warning'>You are either out of smoke, or the smoke isn't ready yet.</span>")

/datum/action/innate/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/mech_zoom/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.")
		chassis.occupant_message("<font color='[chassis.zoom_mode ? "blue" : "red"]'>Zoom mode [chassis.zoom_mode ? "en" : "dis"]abled.</font>")
		if(chassis.zoom_mode)
			owner.client.AddViewMod("mecha", 12)
			SEND_SOUND(owner, sound(chassis.zoomsound, volume = 50))
		else
			owner.client.RemoveViewMod("mecha")
		build_all_button_icons()

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[chassis.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	build_all_button_icons()


/datum/action/innate/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/new_damtype
	switch(chassis.damtype)
		if("tox")
			new_damtype = "brute"
			chassis.occupant_message("Your exosuit's hands form into fists.")
		if("brute")
			new_damtype = "fire"
			chassis.occupant_message("A torch tip extends from your exosuit's hand, glowing red.")
		if("fire")
			new_damtype = "tox"
			chassis.occupant_message("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	build_all_button_icons()

// Floor Buffer Action
/datum/action/innate/mecha/mech_toggle_floorbuffer
	name = "Toggle Floor Buffer"
	desc = "Movement speed is decreased while active."
	button_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "upgrade"

/datum/action/innate/mecha/mech_toggle_floorbuffer/Activate()
	if(!chassis.floor_buffer)
		chassis.floor_buffer = TRUE
		chassis.step_in += chassis.buffer_delay
	else
		chassis.floor_buffer = FALSE
		chassis.step_in -= chassis.buffer_delay
	to_chat(usr, "<span class='notice'>The floor buffer is now [chassis.floor_buffer ? "active" : "deactivated"].</span>")

/datum/action/innate/mecha/select_module
	name = "Hey, you shouldn't see this please make a bug report"
	var/obj/item/mecha_parts/mecha_equipment/equipment

/datum/action/innate/mecha/select_module/Grant(mob/living/L, obj/mecha/M, obj/item/mecha_parts/mecha_equipment/_equipment)
	if(!_equipment)
		return FALSE
	equipment = _equipment
	button_icon = equipment.icon
	button_icon_state = equipment.icon_state
	name = "Switch module to [equipment.name]"
	return ..()

/datum/action/innate/mecha/select_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.selected)
		chassis.selected.on_unequip()
	chassis.selected = equipment
	chassis.selected.on_equip()
	chassis.occupant_message("<span class='notice'>You switch to [equipment.name].</span>")
	chassis.visible_message("[chassis] raises [equipment.name]")
	send_byjax(chassis.occupant, "exosuit.browser", "eq_list", chassis.get_equipment_list())
