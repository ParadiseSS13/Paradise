/datum/action/vehicle/sealed/pod
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/tgvehicle/sealed/vectorcraft/spacepod/chassis

/datum/action/vehicle/sealed/pod/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/pod/proc/set_chassis(passed_chassis)
	chassis = passed_chassis

/datum/action/vehicle/sealed/pod/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/pod/mech_toggle_lights/Trigger(trigger_flags)
	if(!owner || !chassis)
		return
	chassis.toggle_lights(user = owner)

/datum/action/vehicle/sealed/pod/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/pod/mech_view_stats/Trigger(trigger_flags)
	if(!owner || !chassis)
		return

	chassis.ui_interact(owner)
