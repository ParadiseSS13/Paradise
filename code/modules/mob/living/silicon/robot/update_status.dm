// No args for restraints because robots don't have those
/mob/living/silicon/robot/incapacitated()
	if(stat || lockcharge || weakened || stunned || paralysis || !is_component_functioning("actuator"))
		return 1
