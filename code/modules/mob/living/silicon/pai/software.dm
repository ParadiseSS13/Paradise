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

/obj/effect/proc_holder/spell/access_software_pai
	name = "Software interface"
	desc = "Allows you to access your downloaded software."
	clothes_req = FALSE
	base_cooldown = 1 SECONDS
	action_icon_state = "choose_module"
	action_background_icon_state = "bg_tech_blue"

/obj/effect/proc_holder/spell/access_software_pai/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/access_software_pai/cast(list/targets, mob/living/user = usr)
	var/mob/living/silicon/pai/pai_user = user

	pai_user.ui_interact(pai_user)

/mob/living/silicon/pai/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.self_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PAI", name, 600, 650, master_ui, state)
		ui.open()

/mob/living/silicon/pai/ui_data(mob/user)
	var/list/data = list()
	data["app_template"] = active_software.template_file
	data["app_icon"] = active_software.ui_icon
	data["app_title"] = active_software.name
	data["app_data"] = active_software.get_app_data(src)

	return data

// Yes the stupid amount of args here is important, so we can proxy stuff to child UIs
/mob/living/silicon/pai/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
			active_software.ui_act(action, params, ui, state)
