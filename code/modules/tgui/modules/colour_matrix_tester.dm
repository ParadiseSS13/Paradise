/datum/ui_module/colour_matrix_tester
	name = "Colour Matrix Tester"
	/// The datum we are modifying. This will almost always be an atom, but clients have colours too
	var/datum/target_datum
	// Target colour matrix to make applying easier
	var/list/target_matrix = list(
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
	if(islist(target:color))
		target_matrix = target:color
		target_matrix.Cut(17, 0) // get down to a 4x4 matrix
	else if(istext(target:color))
		target_matrix[1] = GETREDPART(target:color) / 255
		target_matrix[6] = GETGREENPART(target:color) / 255
		target_matrix[11] = GETBLUEPART(target:color) / 255

/datum/ui_module/colour_matrix_tester/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/colour_matrix_tester/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ColourMatrixTester", name)
		ui.autoupdate = FALSE
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
			target_matrix[params["idx"]] = params["value"]
			target_datum:color = target_matrix // Force apply

	return TRUE
