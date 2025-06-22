/atom/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if("light_power", "light_range", "light_color")
			update_light()
		if("color")
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)

/atom/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_MANIPULATE_COLOR_MATRIX, "Manipulate Colour Matrix")
	var/turf/curturf = get_turf(src)
	if(curturf)
		.["Jump to turf"] = "byond://?_src_=holder;adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	VV_DROPDOWN_OPTION(VV_HK_ADDREAGENT, "Add reagent")
	VV_DROPDOWN_OPTION(VV_HK_EDITREAGENTS, "Edit reagents")
	VV_DROPDOWN_OPTION(VV_HK_EXPLODE, "Trigger explosion")
	VV_DROPDOWN_OPTION(VV_HK_EMP, "Trigger EM pulse")

/atom/vv_get_header()
	. = ..()
	. += "<a href='byond://?_src_=vars;datumedit=[UID()];varnameedit=name'><b>[src]</b></a>"
	if(dir)
		. += "<br><font size='1'><a href='byond://?_src_=vars;rotatedatum=[UID()];rotatedir=left'><<</a> <a href='byond://?_src_=vars;datumedit=[UID()];varnameedit=dir'>[dir2text(dir)]</a> <a href='byond://?_src_=vars;rotatedatum=[UID()];rotatedir=right'>>></a></font>"

/atom/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list["rotatedatum"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		switch(href_list["rotatedir"])
			if("right")	dir = turn(dir, -45)
			if("left")	dir = turn(dir, 45)

		message_admins("[key_name_admin(usr)] has rotated \the [src]")
		log_admin("[key_name(usr)] has rotated \the [src]")
		href_list["datumrefresh"] = href_list["rotatedatum"]
	if(href_list[VV_HK_EXPLODE])
		if(!check_rights(R_DEBUG|R_EVENT))
			return

		usr.client.cmd_admin_explosion(src)
		href_list["datumrefresh"] = href_list[VV_HK_EXPLODE]
	if(href_list[VV_HK_EMP])
		if(!check_rights(R_DEBUG|R_EVENT))
			return

		usr.client.cmd_admin_emp(src)
		href_list["datumrefresh"] = href_list[VV_HK_EMP]
	if(href_list[VV_HK_ADDREAGENT]) /* Made on /TG/, credit to them. */
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/chosen_id
			var/list/reagent_options = sortAssoc(GLOB.chemical_reagents_list)
			switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
				if("Enter ID")
					var/valid_id
					while(!valid_id)
						chosen_id = stripped_input(usr, "Enter the ID of the reagent you want to add.")
						if(!chosen_id) //Get me out of here!
							break
						for(var/ID in reagent_options)
							if(ID == chosen_id)
								valid_id = 1
						if(!valid_id)
							to_chat(usr, "<span class='warning'>A reagent with that ID doesn't exist!</span>")
				if("Choose ID")
					chosen_id = input(usr, "Choose a reagent to add.", "Choose a reagent.") as null|anything in reagent_options
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to \the [src]")
					message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to \the [src]</span>")
	if(href_list[VV_HK_EDITREAGENTS])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		usr.client.try_open_reagent_editor(src)
	if(href_list[VV_HK_MANIPULATE_COLOR_MATRIX])
		if(!check_rights(R_DEBUG))
			return

		message_admins("[key_name_admin(usr)] is manipulating the colour matrix for [src]")
		var/datum/ui_module/colour_matrix_tester/CMT = new(target=src)
		CMT.ui_interact(usr)
