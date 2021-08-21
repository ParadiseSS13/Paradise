/obj/mecha
	//Action datums
	var/datum/action/innate/mecha/mech_eject/eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/internals_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/stats_action = new
	var/datum/action/innate/mecha/mech_defence_mode/defense_action = new
	var/datum/action/innate/mecha/mech_overload_mode/overload_action = new
	var/datum/action/innate/mecha/mech_toggle_thrusters/thrusters_action = new
	var/datum/effect_system/smoke_spread/smoke_system = new //not an action, but trigged by one
	var/datum/action/innate/mecha/mech_smoke/smoke_action = new
	var/datum/action/innate/mecha/mech_zoom/zoom_action = new
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new

/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)

/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)

/datum/action/innate/mecha
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
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
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.lights = !chassis.lights
	if(chassis.lights)
		chassis.set_light(chassis.lights_power)
		button_icon_state = "mech_lights_on"
	else
		chassis.set_light(-chassis.lights_power)
		button_icon_state = "mech_lights_off"
	chassis.occupant_message("Toggled lights [chassis.lights ? "on" : "off"].")
	chassis.log_message("Toggled lights [chassis.lights ? "on" : "off"].")
	UpdateButtonIcon()

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
	UpdateButtonIcon()

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
	else
		chassis.leg_overload_mode = 0
		// chassis.bumpsmash = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message("<span class='notice'>You disable leg actuators overload.</span>")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.get_charge() > 0)
		chassis.thrusters_active = !chassis.thrusters_active
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
		UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[chassis.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	UpdateButtonIcon()


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
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)
	UpdateButtonIcon()
