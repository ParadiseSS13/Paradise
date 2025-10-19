/datum/buildmode_mode/area_edit
	key = "areaedit"
	var/area/stored_area
	var/image/area_image

/datum/buildmode_mode/area_edit/New()
	area_image = image('icons/turf/areas.dmi', null, "yellow")
	..()

/datum/buildmode_mode/area_edit/enter_mode(datum/click_intercept/buildmode/BM)
	BM.holder.images += area_image

/datum/buildmode_mode/area_edit/exit_mode(datum/click_intercept/buildmode/BM)
	area_image.loc = null // de-color the area
	BM.holder.images -= area_image
	return ..()

/datum/buildmode_mode/area_edit/Destroy()
	QDEL_NULL(area_image)
	return ..()

/datum/buildmode_mode/area_edit/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob  = Paint area</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/turf/mob = Select area to paint</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Create new area</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/area_edit/change_settings(mob/user)
	var/target_path = tgui_input_text(user, "Enter typepath:", "Typepath", "/area")
	var/area_type = text2path(target_path)
	if(ispath(area_type,/area))
		var/area_name = tgui_input_text(user,"Enter area name:", "Area name", "Area")
		if(!area_name || !length(area_name))
			return
		stored_area = new area_type
		stored_area.admin_spawned = TRUE
		stored_area.powernet.equipment_powered = FALSE
		stored_area.powernet.lighting_powered = FALSE
		stored_area.powernet.environment_powered = FALSE
		stored_area.always_unpowered = FALSE
		stored_area.name = area_name
		area_image.loc = stored_area // color our area

/datum/buildmode_mode/area_edit/handle_click(user, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(!stored_area)
			to_chat(user, "<span class='warning'>Configure or select the area you want to paint first!</span>")
			return
		var/turf/T = get_turf(object)
		if(get_area(T) != stored_area)
			stored_area.contents.Add(T)
	else if(right_click)
		var/turf/T = get_turf(object)
		stored_area = get_area(T)
		area_image.loc = stored_area // color our area
