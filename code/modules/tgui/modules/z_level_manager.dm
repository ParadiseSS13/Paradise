RESTRICT_TYPE(/datum/ui_module/admin/z_level_manager)

/datum/ui_module/admin/z_level_manager
	name = "Z-Level Manager"
	var/datum/zlev_manager/manager

/datum/ui_module/admin/z_level_manager/New(datum/zlev_manager/manager_)
	if(!istype(manager_))
		stack_trace("attempted to create a z-Level manager UI with invalid manager_=`[manager_]`")
		qdel(src)
		return
	manager = manager_

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

	for(var/zlvl in manager.z_list)
		var/datum/space_level/level = manager.z_list[zlvl]
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

/datum/ui_module/admin/z_level_manager/global_space_manager

/datum/ui_module/admin/z_level_manager/global_space_manager/New()
	..(GLOB.space_manager)
