/datum/ui_module/robot_self_diagnosis
	/// The robot who can use this UI to diagnose themselves.
	var/mob/living/silicon/robot/owner

/datum/ui_module/robot_self_diagnosis/New(mob/living/silicon/S)
	if(!istype(S))
		CRASH("A [S.type] was passed to /datum/ui_module/robot_self_diagnosis/New().")
	owner = S

/datum/ui_module/robot_self_diagnosis/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RobotSelfDiagnosis", "Component Self Diagnosis", 280, 480, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/robot_self_diagnosis/ui_data(mob/user)
	var/list/data = list()
	for(var/c in owner.components)
		var/datum/robot_component/C = owner.components[c]
		data["component_data"] += list(list(
			"name" = C.name,
			"installed" = C.installed,
			"brute_damage" = C.brute_damage,
			"electronic_damage" = C.electronics_damage,
			"max_damage" = C.max_damage,
			"powered" = C.is_powered(),
			"status" = C.toggled
		))
	return data
