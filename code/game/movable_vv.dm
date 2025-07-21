#define VV_HK_GIVE_DEADCHAT_CONTROL "grantdeadchatcontrol"
#define VV_HK_REMOVE_DEADCHAT_CONTROL "removedeadchatcontrol"

/atom/movable/vv_get_dropdown()
	. = ..()
	if(!GetComponent(/datum/component/deadchat_control))
		VV_DROPDOWN_OPTION(VV_HK_GIVE_DEADCHAT_CONTROL, "Give deadchat control")
	else
		VV_DROPDOWN_OPTION(VV_HK_REMOVE_DEADCHAT_CONTROL, "Remove deadchat control")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_GIVE_DEADCHAT_CONTROL])
		if(!check_rights(R_EVENT))
			return

		if(!GLOB.dsay_enabled)
			// TODO verify what happens when deadchat is muted
			to_chat(usr, "<span class='warning'>Deadchat is globally muted, un-mute deadchat before enabling this.</span>")
			return

		if(GetComponent(/datum/component/deadchat_control))
			to_chat(usr, "<span class='warning'>[src] is already under deadchat control!</span>")
			return

		var/control_mode = tgui_input_list(usr, "Please select the control mode", "Deadchat Control", list("Democracy", "Anarchy"))

		var/selected_mode
		switch(control_mode)
			if("Democracy")
				selected_mode = DEADCHAT_DEMOCRACY_MODE
			if("Anarchy")
				selected_mode = DEADCHAT_ANARCHY_MODE
			else
				return

		var/cooldown = tgui_input_number(usr, "Please enter a cooldown time in seconds. For Democracy, it's the time between actions (must be greater than zero). For Anarchy, it's the time between each user's actions, or -1 for no cooldown.", "Cooldown")
		if(isnull(cooldown) || (cooldown == -1 && selected_mode == DEADCHAT_DEMOCRACY_MODE))
			return
		if(cooldown < 0 && selected_mode == DEADCHAT_DEMOCRACY_MODE)
			to_chat(usr, "<span class='warning'>The cooldown for Democracy mode must be greater than zero.</span>")
			return
		if(cooldown == -1)
			cooldown = 0
		else
			cooldown = cooldown SECONDS

		deadchat_plays(selected_mode, cooldown)
		message_admins("[key_name_admin(usr)] provided deadchat control to [src].")

	if(href_list[VV_HK_REMOVE_DEADCHAT_CONTROL])
		if(!check_rights(R_EVENT))
			return

		if(!GetComponent(/datum/component/deadchat_control))
			to_chat(usr, "<span class='warning'>[src] is not currently under deadchat control!</span>")
			return

		stop_deadchat_plays()
		message_admins("[key_name_admin(usr)] removed deadchat control from [src].")

#undef VV_HK_GIVE_DEADCHAT_CONTROL
#undef VV_HK_REMOVE_DEADCHAT_CONTROL
