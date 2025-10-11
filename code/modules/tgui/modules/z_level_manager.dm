RESTRICT_TYPE(/datum/ui_module/admin/z_level_manager)

/datum/ui_module/admin/z_level_manager
	name = "Z-Level Manager"

/datum/ui_module/admin/z_level_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/admin/z_level_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ZLevelManager", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/admin/z_level_manager/ui_data(mob/user)
	. = list()

	.["levels"] = list()

	for(var/zlvl in GLOB.space_manager.z_list)
		var/datum/space_level/level = GLOB.space_manager.z_list[zlvl]
		.["levels"]["[level.zpos]"] = level.ui_data()

/datum/ui_module/admin/z_level_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("jump_to_coords")
			var/x = params["x"]
			var/y = params["y"]
			var/z = params["z"]

			usr.client.jumptocoord(x, y, z)

	return TRUE
