GLOBAL_LIST_INIT(pai_emotions, list(
		"Happy" = 1,
		"Cat" = 2,
		"Extremely Happy" = 3,
		"Face" = 4,
		"Laugh" = 5,
		"Off" = 6,
		"Sad" = 7,
		"Angry" = 8,
		"What" = 9
))

GLOBAL_LIST_EMPTY(pai_software_by_key)

/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"

	tgui_interact(src)

/mob/living/silicon/pai/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_self_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PAI", name, 600, 650, master_ui, state)
		ui.open()

/mob/living/silicon/pai/tgui_data(mob/user)
	var/list/data = list()
	data["app_template"] = active_software.template_file
	data["app_icon"] = active_software.ui_icon
	data["app_title"] = active_software.name
	data["app_data"] = active_software.get_app_data(user)

	return data

// Yes the stupid amount of args here is important, so we can proxy stuff to child UIs
/mob/living/silicon/pai/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		// This call is global to all templates, hence the prefix
		if("MASTER_back")
			active_software = installed_software["mainmenu"]
			// Bail early
			return
		else
			active_software.tgui_act(action, params, ui, state)
