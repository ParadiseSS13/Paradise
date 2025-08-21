/// Core topics are VV topics which should work even if the code responsible
/// for processing vv topics for that datum is runtiming. They're kept separately
/// from [/datum/proc/vv_do_topic] for that reason.
/client/proc/vv_core_topics(datum/target, href_list)
	if(href_list[VV_HK_JUMP_TO])
		if(!check_rights(R_ADMIN))
			return

		var/turf/T = get_turf(target)
		if(T)
			jumptoturf(T)
		href_list["datumrefresh"] = target.UID()
	if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_ADMIN | R_VAREDIT))	return

		var/D = locateUID(href_list["datumedit"])
		if(!istype(D,/datum) && !isclient(D))
			to_chat(usr, "<span class='notice'>This can only be used on instances of types /client or /datum.</span>")
			return

		modify_variables(D, href_list["varnameedit"], 1)
	if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_ADMIN | R_VAREDIT))
			return

		var/D = locateUID(href_list["datumchange"])
		if(!istype(D,/datum) && !isclient(D))
			to_chat(usr, "<span class='notice'>This can only be used on instances of types /client or /datum.</span>")
			return

		modify_variables(D, href_list["varnamechange"], 0)
	if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_ADMIN | R_VAREDIT))
			return

		var/atom/A = locateUID(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "<span class='notice'>This can only be used on instances of type /atom.</span>")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])
	if(href_list[VV_HK_DELETE])
		if(!check_rights(R_DEBUG, 0))
			return

		admin_delete(target)
		return
	if(href_list[VV_HK_MARK_OBJECT])
		if(!check_rights(0))	return

		if(!istype(target))
			to_chat(usr, "<span class='notice'>This can only be done to instances of type /datum.</span>")
			return

		holder.marked_datum = target
		href_list["datumrefresh"] = target.UID()
	if(href_list[VV_HK_PROC_CALL])
		if(!check_rights(R_PROCCALL))
			return

		if(target)
			callproc_datum(target)
	if(href_list[VV_HK_ADDCOMPONENT])
		if(!check_rights(NONE))
			return

		var/list/names = list()
		var/list/componentsubtypes = sortList(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sortList(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))

		var/result = tgui_input_list(usr, "Choose a component/element to add", "Add Component", names)
		if(isnull(result))
			return
		if(!usr || result == "---Components---" || result == "---Elements---")
			return

		if(QDELETED(target))
			to_chat(usr, "<span class='notice'>That thing doesn't exist anymore!</span>", confidential = TRUE)
			return

		var/list/lst = get_callproc_args()
		if(!lst)
			return

		var/datumname = "error"
		lst.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(lst)
		else
			datumname = "element"
			target._AddElement(lst)
		log_admin("[key_name(usr)] has added [result] [datumname] to [key_name(target)].")
		message_admins("<span class='notice'>[key_name_admin(usr)] has added [result] [datumname] to [key_name_admin(target)].</span>")
	if(href_list[VV_HK_REMOVECOMPONENT] || href_list[VV_HK_MASSREMOVECOMPONENT])
		if(!check_rights(NONE))
			return
		var/mass_remove = href_list[VV_HK_MASSREMOVECOMPONENT]
		var/list/components = target.datum_components.Copy()
		var/list/names = list()
		names += "---Components---"
		if(length(components))
			names += sortList(components, GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Elements---"
		// We have to list every element here because there is no way to know what element is on this object without doing some sort of hack.
		names += sortList(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/path = tgui_input_list(usr, "Choose a component/element to remove. All elements listed here may not be on the datum.", "Remove element", names)
		if(isnull(path))
			return
		if(!usr || path == "---Components---" || path == "---Elements---")
			return
		if(QDELETED(target))
			to_chat(usr, "<span class='notice'>That thing doesn't exist anymore!</span>")
			return
		var/list/targets_to_remove_from = list(target)
		if(mass_remove)
			var/method = vv_subtype_prompt(target.type)
			targets_to_remove_from = get_all_of_type(target.type, method)

			if(tgui_alert(usr, "Are you sure you want to mass-delete [path] on [target.type]?", "Mass Remove Confirmation", list("Yes", "No")) != "Yes")
				return

		var/list/ele_list = list()
		if(ispath(path, /datum/element))
			ele_list = get_callproc_args()
			ele_list.Insert(1, path)
		for(var/datum/target_to_remove_from as anything in targets_to_remove_from)
			if(ispath(path, /datum/element))
				target._RemoveElement(ele_list)
			else
				var/list/components_actual = target_to_remove_from.GetComponents(path)
				for(var/to_delete in components_actual)
					qdel(to_delete)

		message_admins("<span class='notice'>[key_name_admin(usr)] has [mass_remove ? "mass" : ""] removed [path] component from [mass_remove ? target.type : key_name_admin(target)].</span>")
