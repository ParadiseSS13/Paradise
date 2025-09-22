RESTRICT_TYPE(/datum/ui_module/obj_access_modifier)

/datum/ui_module/obj_access_modifier
	name = "Access Modifier"
	var/obj/target_obj

/datum/ui_module/obj_access_modifier/New(datum/_host, obj/target)
	..()
	if(!(isobj(target)))
		stack_trace("Attempted to create an access modifier on a non-/obj")
		qdel(src)
		return

	target_obj = target

/datum/ui_module/obj_access_modifier/ui_state(mob/user)
	return GLOB.admin_state

/datum/ui_module/obj_access_modifier/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ObjAccessModifier", name)
		ui.autoupdate = FALSE
		ui.open()

/datum/ui_module/obj_access_modifier/ui_data(mob/user)
	var/list/data = list(
		"one_access" = length(target_obj.req_one_access),
		"selected_accesses" = length(target_obj.req_one_access) ? target_obj.req_one_access : target_obj.req_access
	)

	return data

/datum/ui_module/obj_access_modifier/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(REGION_GENERAL, REGION_MISC)
	return data

/datum/ui_module/obj_access_modifier/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/one_access = length(target_obj.req_one_access)

	switch(action)
		if("set_one_access")
			if((params["access"] == "one") && (length(target_obj.req_access)))
				target_obj.req_one_access = target_obj.req_access.Copy()
				target_obj.req_access.Cut()
			else
				target_obj.req_access = target_obj.req_one_access.Copy()
				target_obj.req_one_access.Cut()
		if("set")
			var/access = text2num(params["access"])
			if(isnull(access))
				return FALSE
			if(one_access)
				if(access in target_obj.req_one_access)
					target_obj.req_one_access -= access
				else
					target_obj.req_one_access |= access
			else
				if(access in target_obj.req_access)
					target_obj.req_access -= access
				else
					target_obj.req_access |= access
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > REGION_MISC)
				return FALSE
			if(one_access)
				target_obj.req_one_access |= get_region_accesses(region)
			else
				target_obj.req_access |= get_region_accesses(region)
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > REGION_MISC)
				return FALSE
			if(one_access)
				target_obj.req_one_access -= get_region_accesses(region)
			else
				target_obj.req_access -= get_region_accesses(region)
		if("grant_all")
			if(one_access)
				target_obj.req_one_access = get_absolutely_all_accesses()
			else
				target_obj.req_access = get_absolutely_all_accesses()
		if("clear_all")
			target_obj.req_one_access.Cut()
			target_obj.req_access.Cut()

	return TRUE
