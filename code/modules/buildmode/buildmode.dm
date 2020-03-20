#define BM_SWITCHSTATE_NONE	0
#define BM_SWITCHSTATE_MODE	1
#define BM_SWITCHSTATE_DIR	2

/datum/click_intercept/buildmode
	var/build_dir = SOUTH
	var/datum/buildmode_mode/mode

	// SECTION UI

	// Switching management
	var/switch_state = BM_SWITCHSTATE_NONE
	var/switch_width = 5
	// modeswitch UI
	var/obj/screen/buildmode/mode/modebutton
	var/list/modeswitch_buttons = list()
	// dirswitch UI
	var/obj/screen/buildmode/bdir/dirbutton
	var/list/dirswitch_buttons = list()

/datum/click_intercept/buildmode/New()
	mode = new /datum/buildmode_mode/basic(src)
	. = ..()
	mode.enter_mode(src)

/datum/click_intercept/buildmode/Destroy()
	close_switchstates()
	QDEL_NULL(mode)
	QDEL_LIST(modeswitch_buttons)
	QDEL_LIST(dirswitch_buttons)
	return ..()

/datum/click_intercept/buildmode/create_buttons()
	// keep a reference so we can update it upon mode switch
	modebutton = new /obj/screen/buildmode/mode(src)
	buttons += modebutton
	buttons += new /obj/screen/buildmode/help(src)
	// keep a reference so we can update it upon dir switch
	dirbutton = new /obj/screen/buildmode/bdir(src)
	buttons += dirbutton
	buttons += new /obj/screen/buildmode/quit(src)
	// build the list of modeswitching buttons
	build_options_grid(subtypesof(/datum/buildmode_mode), modeswitch_buttons, /obj/screen/buildmode/modeswitch)
	build_options_grid(list(SOUTH,EAST,WEST,NORTH,NORTHWEST), dirswitch_buttons, /obj/screen/buildmode/dirswitch)

/datum/click_intercept/buildmode/proc/build_options_grid(list/elements, list/buttonslist, buttontype)
	var/pos_idx = 0
	for(var/thing in elements)
		var/x = pos_idx % switch_width
		var/y = FLOOR(pos_idx / switch_width, 1)
		var/obj/screen/buildmode/B = new buttontype(src, thing)
		// this stuff is equivalent to the commented out line for 511 compat
		// B.screen_loc = "NORTH-[(1 + 0.5 + y*1.5)],WEST+[0.5 + x*1.5]"
		B.screen_loc = "NORTH-[1 + FLOOR(0.5 + 1.5*y, 1) + ((y + 1) % 2)]:[16*((y + 1) % 2)],WEST+[FLOOR(0.5 + 1.5*x, 1)]:[16*((x + 1) % 2)]"
		buttonslist += B
		pos_idx++

/datum/click_intercept/buildmode/proc/close_switchstates()
	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			close_modeswitch()
		if(BM_SWITCHSTATE_DIR)
			close_dirswitch()

/datum/click_intercept/buildmode/proc/toggle_modeswitch()
	if(switch_state == BM_SWITCHSTATE_MODE)
		close_modeswitch()
	else
		close_switchstates()
		open_modeswitch()
	
/datum/click_intercept/buildmode/proc/open_modeswitch()
	switch_state = BM_SWITCHSTATE_MODE
	holder.screen += modeswitch_buttons

/datum/click_intercept/buildmode/proc/close_modeswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= modeswitch_buttons

/datum/click_intercept/buildmode/proc/toggle_dirswitch()
	if(switch_state == BM_SWITCHSTATE_DIR)
		close_dirswitch()
	else
		close_switchstates()
		open_dirswitch()
	
/datum/click_intercept/buildmode/proc/open_dirswitch()
	switch_state = BM_SWITCHSTATE_DIR
	holder.screen += dirswitch_buttons

/datum/click_intercept/buildmode/proc/close_dirswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= dirswitch_buttons

/datum/click_intercept/buildmode/proc/change_mode(newmode)
	mode.exit_mode(src)
	QDEL_NULL(mode)
	close_switchstates()
	mode = new newmode(src)
	mode.enter_mode(src)
	modebutton.update_icon()

/datum/click_intercept/buildmode/proc/change_dir(newdir)
	build_dir = newdir
	close_dirswitch()
	dirbutton.update_icon()
	return TRUE

/datum/click_intercept/buildmode/InterceptClickOn(user, params, atom/object)
	mode.handle_click(user, params, object)

/proc/togglebuildmode(mob/M in GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = "Event"

	if(M.client)
		if(istype(M.client.click_intercept, /datum/click_intercept/buildmode))
			var/datum/click_intercept/buildmode/B = M.client.click_intercept
			B.quit()
			log_admin("[key_name(usr)] has left build mode.")
		else
			new/datum/click_intercept/buildmode(M.client)
			message_admins("[key_name_admin(usr)] has entered build mode.")
			log_admin("[key_name(usr)] has entered build mode.")
	
#undef BM_SWITCHSTATE_NONE
#undef BM_SWITCHSTATE_MODE
#undef BM_SWITCHSTATE_DIR
