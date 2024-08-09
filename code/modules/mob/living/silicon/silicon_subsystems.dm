/mob/living/silicon/proc/init_subsystems()
	atmos_control 	= new(src)
	crew_monitor 	= new(src)
	law_manager		= new(src)
	power_monitor	= new(src)

/mob/living/silicon/robot/init_subsystems()
	. = ..()
	self_diagnosis  = new(src)
	mail_setter	= new(src)

/********************
*	Atmos Control	*
********************/
/mob/living/silicon/proc/subsystem_atmos_control()
	set category = "Subsystems"
	set name = "Atmospherics Control"

	atmos_control.ui_interact(usr)

/********************
*	Crew Monitor	*
********************/
/mob/living/silicon/proc/subsystem_crew_monitor()
	set category = "Subsystems"
	set name = "Crew Monitor"
	crew_monitor.ui_interact(usr)

/****************
*	Law Manager	*
****************/
/mob/living/silicon/proc/subsystem_law_manager()
	set name = "Law Manager"
	set category = "Subsystems"

	law_manager.ui_interact(usr)

/********************
*	Power Monitor	*
********************/
/mob/living/silicon/proc/subsystem_power_monitor()
	set category = "Subsystems"
	set name = "Power Monitor"

	power_monitor.ui_interact(usr)

/mob/living/silicon/robot/proc/self_diagnosis()
	set category = "Robot Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, "<span class='warning'>Your self-diagnosis component isn't functioning.</span>")
		return

	self_diagnosis.ui_interact(src)

/********************
*	Set Mail Tag	*
********************/
/mob/living/silicon/robot/proc/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
	set category = "Robot Commands"

	mail_setter.ui_interact(src)
