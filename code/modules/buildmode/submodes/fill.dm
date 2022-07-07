/datum/buildmode_mode/fill
	key = "fill"

	use_corner_selection = TRUE
	var/objholder = null

/datum/buildmode_mode/fill/show_help(mob/user)
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("Left Mouse Button on turf/obj/mob      = Select corner"))
	to_chat(user, span_notice("Left Mouse Button + Alt on turf/obj/mob = Delete region"))
	to_chat(user, span_notice("Right Mouse Button on buildmode button = Select object type"))
	to_chat(user, span_notice("***********************************************************"))

/datum/buildmode_mode/fill/change_settings(mob/user)
	var/target_path = input(user,"Enter typepath:" ,"Typepath","/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			alert("No path has been selected.")
			return
		else if(ispath(objholder, /area))
			objholder = null
			alert("Area paths are not supported for this mode, use the area edit mode instead.")
			return
	deselect_region()

/datum/buildmode_mode/fill/handle_click(mob/user, params, obj/object)
	if(isnull(objholder))
		to_chat(user, "<span class='warning'>Select an object type first.</span>")
		deselect_region()
		return
	..()

/datum/buildmode_mode/fill/handle_selected_region(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/alt_click = pa.Find("alt")

	if(left_click) //rectangular
		if(alt_click)
			empty_region(block(cornerA,cornerB))
		else
			for(var/turf/T in block(cornerA,cornerB))
				if(ispath(objholder,/turf))
					T.ChangeTurf(objholder)
				else
					var/obj/A = new objholder(T)
					A.setDir(BM.build_dir)
