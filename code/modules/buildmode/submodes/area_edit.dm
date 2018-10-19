/datum/buildmode_mode/area_edit
	key = "areaedit"
	var/area/storedarea
	var/image/areaimage

/datum/buildmode_mode/area_edit/New()
	areaimage = image('icons/turf/areas.dmi', null, "yellow")
	..()

/datum/buildmode_mode/area_edit/enter_mode(datum/click_intercept/buildmode/BM)
	BM.holder.images += areaimage

/datum/buildmode_mode/area_edit/exit_mode(datum/click_intercept/buildmode/BM)
	areaimage.loc = null // de-color the area
	BM.holder.images -= areaimage
	return ..()

/datum/buildmode_mode/area_edit/Destroy()
	QDEL_NULL(areaimage)
	return ..()

/datum/buildmode_mode/area_edit/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj/turf/mob  = Paint area</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj/turf/mob = Select area to paint</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Create new area</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/area_edit/change_settings(mob/user)
	var/target_path = input(user,"Enter typepath:", "Typepath", "/area")
	var/areatype = text2path(target_path)
	if(ispath(areatype,/area))
		var/areaname = input(user,"Enter area name:", "Area name", "Area")
		if(!areaname || !length(areaname))
			return
		storedarea = new areatype
		storedarea.power_equip = 0
		storedarea.power_light = 0
		storedarea.power_environ = 0
		storedarea.always_unpowered = 0
		storedarea.name = areaname
		areaimage.loc = storedarea // color our area

/datum/buildmode_mode/area_edit/handle_click(user, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(left_click)
		if(!storedarea)
			to_chat(user, "<span class='warning'>Configure or select the area you want to paint first!</span>")
			return
		var/turf/T = get_turf(object)
		if(get_area(T) != storedarea)
			storedarea.contents.Add(T)
	else if(right_click)
		var/turf/T = get_turf(object)
		storedarea = get_area(T)
		areaimage.loc = storedarea // color our area
