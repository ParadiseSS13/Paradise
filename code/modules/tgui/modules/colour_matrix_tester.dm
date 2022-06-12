/datum/ui_module/colour_matrix_tester
	name = "Colour Matrix Tester"
	/// The datum we are modifying. This will almost always be an atom, but clients have colours too
	var/datum/target_datum
	// Target colour matrix to make applying easier
	var/target_matrix = list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)

/datum/ui_module/colour_matrix_tester/New(datum/_host, datum/target)
	..()
	if(!(isatom(target) || isclient(target)))
		stack_trace("Attempted to create a colour matrix tester on a non atom/client!")
		qdel(src)
		return

	target_datum = target

/datum/ui_module/colour_matrix_tester/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ColourMatrixTester", name, 350, 170, master_ui, state)
		ui.autoupdate = TRUE
		ui.open()

/datum/ui_module/colour_matrix_tester/ui_data(mob/user)
	var/list/data = list()
	data["colour_data"] = target_matrix
	return data

/datum/ui_module/colour_matrix_tester/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("setvalue")
			target_matrix[text2num(params["idx"])] = text2num(params["value"])
			target_datum:color = target_matrix // Force apply

	return TRUE
