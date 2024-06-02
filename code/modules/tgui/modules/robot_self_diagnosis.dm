/datum/ui_module/robot_self_diagnosis
	/// The robot who can use this UI to diagnose themselves.
	var/mob/living/silicon/robot/owner

/datum/ui_module/robot_self_diagnosis/New(mob/living/silicon/S)
	if(!istype(S))
		CRASH("A [S.type] was passed to /datum/ui_module/robot_self_diagnosis/New().")
	owner = S

/datum/ui_module/robot_self_diagnosis/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/robot_self_diagnosis/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RobotSelfDiagnosis", "Component Self Diagnosis")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/robot_self_diagnosis/ui_data(mob/user)
	var/list/data = list()
	for(var/c in owner.components)
		var/datum/robot_component/C = owner.components[c]
		data["component_data"] += list(list(
			"name" = C.name,
			"installed" = C.is_destroyed() ? -1 : C.installed,
			"brute_damage" = C.brute_damage,
			"electronic_damage" = C.electronics_damage,
			"max_damage" = C.max_damage,
			"powered" = C.is_powered(),
			"status" = C.toggled
		))
	return data
