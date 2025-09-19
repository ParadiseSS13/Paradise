/obj/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_DELALL, "Delete all of type")
	if(!speed_process)
		VV_DROPDOWN_OPTION(VV_HK_MAKESPEEDY, "Make speed process")
	else
		VV_DROPDOWN_OPTION(VV_HK_MAKENORMALSPEED, "Make normal process")
	VV_DROPDOWN_OPTION(VV_HK_MODIFYARMOR, "Modify armor values")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ACCESS, "Modify access")

/obj/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_DELALL])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/action_type = tgui_alert(usr, "Strict type ([type]) or type and all subtypes?", "Select", list("Strict type", "Type and Subtypes", "Cancel"))
		if(action_type == "Cancel" || !action_type)
			return

		if(tgui_alert(usr, "Are you really sure you want to delete all objects of type [type]?", "Confirm", list("Yes", "No")) != "Yes")
			return

		if(tgui_alert("Second confirmation required. Delete?", "Confirm", list("Yes", "No")) != "Yes")
			return

		var/O_type = type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "<span class='notice'>No objects of this type exist.</span>")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted)")
				message_admins("[key_name_admin(usr)] deleted all objects of type [O_type] ([i] objects deleted)")
			if("Type and Subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj, O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "<span class='notice'>No objects of this type exist.</span>")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)")
				message_admins("[key_name_admin(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted)")

	if(href_list[VV_HK_MAKESPEEDY])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var_edited = TRUE
		makeSpeedProcess()
		log_admin("[key_name(usr)] has made [src] speed process")
		message_admins("<span class='notice'>[key_name(usr)] has made [src] speed process</span>")
	if(href_list[VV_HK_MAKENORMALSPEED])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var_edited = TRUE
		makeNormalProcess()
		log_admin("[key_name(usr)] has made [src] process normally")
		message_admins("<span class='notice'>[key_name(usr)] has made [src] process normally</span>")
	if(href_list[VV_HK_MODIFYARMOR])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var_edited = TRUE
		var/list/armorlist = armor.getList()
		var/list/displaylist

		var/result
		do
			displaylist = list()
			for(var/key in armorlist)
				displaylist += "[key] = [armorlist[key]]"
			result = input(usr, "Select an armor type to modify..", "Modify armor") as null|anything in displaylist + "(ADD ALL)" + "(SET ALL)" + "(DONE)"

			if(result == "(DONE)")
				break
			else if(result == "(ADD ALL)" || result == "(SET ALL)")
				var/new_amount = tgui_input_number(usr, result == "(ADD ALL)" ? "Enter armor to add to all types:" : "Enter new armor value for all types:", "Modify all types")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				for(var/key in armorlist)
					armorlist[key] = (result == "(ADD ALL)" ? armorlist[key] : 0) + proper_amount
			else if(result)
				var/list/fields = splittext(result, " = ")
				if(length(fields) != 2)
					continue
				var/type = fields[1]
				if(isnull(armorlist[type]))
					continue
				var/new_amount = tgui_input_number(usr, "Enter new armor value for [type]:", "Modify [type]")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				armorlist[type] = proper_amount
		while(result)

		if(!result || !QDELETED(src))
			return TRUE

		armor = armor.setRating(armorlist[MELEE], armorlist[BULLET], armorlist[LASER], armorlist[ENERGY], armorlist[BOMB], armorlist[RAD], armorlist[FIRE], armorlist[ACID], armorlist[MAGIC])

		log_admin("[key_name(usr)] modified the armor on [src] to: melee = [armorlist[MELEE]], bullet = [armorlist[BULLET]], laser = [armorlist[LASER]], energy = [armorlist[ENERGY]], bomb = [armorlist[BOMB]], rad = [armorlist[RAD]], fire = [armorlist[FIRE]], acid = [armorlist[ACID]], magic = [armorlist[MAGIC]]")
		message_admins("<span class='notice'>[key_name(usr)] modified the armor on [src] to: melee = [armorlist[MELEE]], bullet = [armorlist[BULLET]], laser = [armorlist[LASER]], energy = [armorlist[ENERGY]], bomb = [armorlist[BOMB]], rad = [armorlist[RAD]], fire = [armorlist[FIRE]], acid = [armorlist[ACID]], magic = [armorlist[MAGIC]]</span>")
	if(href_list[VV_HK_MODIFY_ACCESS])
		if(!check_rights(R_ADMIN))
			return

		log_and_message_admins("[key_name_admin(usr)] is modifying the access of [src]")
		var/datum/ui_module/obj_access_modifier/ui = new(target = src)
		ui.ui_interact(usr)
