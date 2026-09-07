/datum/data/pda/utility/robot_headlamp
	name = "Adjust Headlamp"
	icon = "lightbulb-o"

/datum/data/pda/utility/robot_headlamp/start()
	var/mob/living/silicon/robot/robot = pda.loc
	robot.control_headlamp()
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)

/datum/data/pda/utility/robot_self_diagnosis
	name = "Run Self-Diagnostics"

/datum/data/pda/utility/robot_self_diagnosis/start()
	var/mob/living/silicon/robot/robot = pda.loc
	robot.self_diagnosis()
	if(!pda.silent)
		playsound(pda, 'sound/machines/terminal_select.ogg', 15, TRUE)
