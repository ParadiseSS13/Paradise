/datum/buildmode_mode/advanced
	key = "advanced"
	var/objholder = null

// FIXME: add logic which adds a button displaying the icon
// of the currently selected path

/datum/buildmode_mode/advanced/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Set object type</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button + alt on turf/obj    = Copy object type")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj          = Place objects</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button                     = Delete objects</span>")
	to_chat(user, "")
	to_chat(user, "<span class='notice'>Use the button in the upper left corner to</span>")
	to_chat(user, "<span class='notice'>change the direction of built objects.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/advanced/change_settings(mob/user)
	var/target_path = input(user,"Enter typepath:" ,"Typepath","/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			alert("No path was selected")
			return
		else if(ispath(objholder, /area))
			objholder = null
			alert("That path is not allowed.")
			return

/datum/buildmode_mode/advanced/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/alt_click = pa.Find("alt")

	if(left_click && alt_click)
		if(isturf(object) || isobj(object) || ismob(object))
			objholder = object.type
			to_chat(user, "<span class='notice'>[initial(object.name)] ([object.type]) selected.</span>")
		else
			to_chat(user, "<span class='notice'>[initial(object.name)] is not a turf, object, or mob! Please select again.</span>")
	else if(left_click)
		if(ispath(objholder,/turf))
			var/turf/T = get_turf(object)
			log_admin("Build Mode: [key_name(user)] modified [T] ([T.x],[T.y],[T.z]) to [objholder]")
			T.ChangeTurf(objholder)
		else if(!isnull(objholder))
			//we only want to set the direction of mobs or objects, not turfs or areas.
			var/atom/movable/A = new objholder(get_turf(object))
			if(istype(A))
				A.setDir(BM.build_dir)
				log_admin("Build Mode: [key_name(user)] modified [A]'s ([A.x],[A.y],[A.z]) dir to [BM.build_dir]")
		else
			to_chat(user, "<span class='warning'>Select object type first.</span>")
	else if(right_click)
		if(isobj(object))
			log_admin("Build Mode: [key_name(user)] deleted [object] at ([object.x],[object.y],[object.z])")
			qdel(object)

