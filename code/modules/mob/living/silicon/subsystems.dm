/mob/living/silicon
	var/register_alarms = TRUE
	var/datum/tgui_module/atmos_control/atmos_control
	var/datum/tgui_module/crew_monitor/crew_monitor
	var/datum/tgui_module/law_manager/law_manager
	var/datum/tgui_module/power_monitor/digital/power_monitor

/mob/living/silicon
	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager
	)

/mob/living/silicon/ai
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_atmos_control,
		/mob/living/silicon/proc/subsystem_crew_monitor,
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot/drone
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager,
		/mob/living/silicon/proc/subsystem_power_monitor
	)

/mob/living/silicon/robot/syndicate
	register_alarms = 0

/mob/living/silicon/proc/init_subsystems()
	atmos_control 	= new(src)
	crew_monitor 	= new(src)
	law_manager		= new(src)
	power_monitor	= new(src)

/********************
*	Atmos Control	*
********************/
/mob/living/silicon/proc/subsystem_atmos_control()
	set category = "Subsystems"
	set name = "Atmospherics Control"

	atmos_control.tgui_interact(usr, state = GLOB.tgui_self_state)

/********************
*	Crew Monitor	*
********************/
/mob/living/silicon/proc/subsystem_crew_monitor()
	set category = "Subsystems"
	set name = "Crew Monitor"
	crew_monitor.tgui_interact(usr, state = GLOB.tgui_self_state)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Law Manager"
	set category = "Subsystems"

	law_manager.tgui_interact(usr, state = GLOB.tgui_conscious_state)

/********************
*	Power Monitor	*
********************/
/mob/living/silicon/proc/subsystem_power_monitor()
	set category = "Subsystems"
	set name = "Power Monitor"

	power_monitor.tgui_interact(usr, state = GLOB.tgui_self_state)

