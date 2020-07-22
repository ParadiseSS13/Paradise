/datum/buildmode_mode
	var/key = "oops"

	var/datum/click_intercept/buildmode/BM

	var/use_corner_selection = FALSE
	var/processing_selection = FALSE
	var/list/preview
	var/turf/cornerA
	var/turf/cornerB

/datum/buildmode_mode/New(datum/click_intercept/buildmode/newBM)
	BM = newBM
	preview = list()
	return ..()

/datum/buildmode_mode/Destroy()
	Reset()
	return ..()

/datum/buildmode_mode/proc/enter_mode(datum/click_intercept/buildmode/BM)
	return

/datum/buildmode_mode/proc/exit_mode(datum/click_intercept/buildmode/BM)
	return

/datum/buildmode_mode/proc/get_button_iconstate()
	return "buildmode_[key]"

/datum/buildmode_mode/proc/show_help(mob/user)
	CRASH("No help defined, yell at a coder")
	to_chat(user, "<span class='warning'>There is no help defined for this mode, this is a bug.</span>")

/datum/buildmode_mode/proc/change_settings(mob/user)
	to_chat(user, "<span class='warning'>There is no configuration available for this mode</span>")

/datum/buildmode_mode/proc/Reset()
	deselect_region()

/datum/buildmode_mode/proc/select_tile(turf/T, corner_to_select)
	var/overlaystate
	BM.holder.images -= preview
	switch(corner_to_select)
		if(AREASELECT_CORNERA)
			overlaystate = "greenOverlay"
		if(AREASELECT_CORNERB)
			overlaystate = "blueOverlay"
	preview += image('icons/turf/overlays.dmi', T, overlaystate)
	BM.holder.images += preview
	return T 

/datum/buildmode_mode/proc/highlight_region(region)
	BM.holder.images -= preview
	for(var/t in region)
		preview += image('icons/turf/overlays.dmi', T, "redOverlay")
	BM.holder.images += preview

/datum/buildmode_mode/proc/deselect_region()
	BM.holder.images -= preview
	QDEL_LIST(preview)
	cornerA = null
	cornerB = null

/datum/buildmode_mode/proc/handle_click(user, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	if(use_corner_selection)
		if(left_click)
			if(!cornerA)
				cornerA = select_tile(get_turf(object), AREASELECT_CORNERA)
				return
			else if(!cornerB)
				cornerB = select_tile(get_turf(object), AREASELECT_CORNERB)
				to_chat(user, "<span class='boldwarning'>Region selected, if you're happy with your selection left click again, otherwise right click.</span>")
				return
			if(processing_selection)
				return
			processing_selection = TRUE
			handle_selected_region(user, params)
			processing_selection = FALSE
			deselect_region()
		else if(cornerA || cornerB)
			to_chat(user, "<span class='notice'>Region selection canceled!</span>")
			deselect_region()

/datum/buildmode_mode/proc/handle_selected_region(mob/user, params)
	return