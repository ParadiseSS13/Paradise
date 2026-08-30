/obj/item/disk/tech_disk
	name = "\improper Technology Disk"
	desc = "A disk for storing research data for further research, it is only capable of holding one type of research at a time."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/list/stored_research = list() // "Research", "Illegal", "Alien"
	var/possible_skins = list("Normal", "Research", "Illegal", "Alien")

/obj/item/disk/tech_disk/proc/load_research(list/points_list)
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if(points_list.len > 1)
			log_debug("Tech disk at [AREACOORD(src)] attempted load with over 1 research type.")
			return FALSE // no more then one, FALSE can be used to inform user.
		if(stored_research.len == 0 && points_list[i] > 0)
			stored_research += points_list
			change_name(i)
			return points_list[i]
		if((i in stored_research) && points_list[i] > 0)
			stored_research[i] = FLOOR(stored_research[i] + points_list[i], 0.1)
			change_name(i)
			return points_list[i] // return the points that were successfully transfered.
		return

/obj/item/disk/tech_disk/proc/unload_research(list/points_list, autobalance = TRUE)
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if(stored_research[i] < points_list[i] && autobalance == TRUE)
			points_list[i] = stored_research[i]
		if(stored_research[i] < points_list[i] && autobalance == FALSE)
			return
		var/ti = points_list[i]
		if((i in stored_research) && points_list[i] > 0)
			stored_research[i] = FLOOR(stored_research[i] - points_list[i], 0.1)
			if(stored_research[i] <= 0)
				stored_research.len = 0 //if we have no points, remove list contents so a new type can be added
			change_name(i)
			return ti // return how many points so we dont accidentally take more then we have.
		return

/obj/item/disk/tech_disk/proc/wipe_research()
	stored_research = list()
	change_name()

/obj/item/disk/tech_disk/proc/change_name(type)
	if(stored_research.len > 0 && type)
		name = "[initial(name)] \[[stored_research[type]]\]"
		return
	name = initial(name)

/obj/item/disk/tech_disk/examine(mob/user)
	. = ..()
	for(var/i in stored_research)
		. += "It contains [stored_research[i]] [i] points."

/obj/item/disk/tech_disk/multitool_act(mob/living/user, obj/item/I) // MIXTODO - Remove
	var/obj/item/multitool/disk_loader/M = I
	if(M.p_mode == "unload")
		unload_research(M.to_load)
		return
	if(M.p_mode == "load")
		load_research(M.to_load)
		return


/obj/item/multitool/disk_loader
	name = "disk loader"
	var/p_mode = "load"
	var/load_points = 0
	var/point_type = null
	var/list/to_load = list()

/obj/item/multitool/disk_loader/activate_self(mob/user)
	. = ..()
	load_points = tgui_input_number(usr, "Select Points", "Points", 0, 10000, 0)
	point_type = tgui_alert(usr, "Select Type", "Type", list("Research", "Illegal", "Alien"))
	p_mode = tgui_alert(usr, "Select Mode", "Mode", list("load", "unload"))
	var/tmp_strg = "[point_type]=[load_points]"
	to_load = ConvertReqString2List(tmp_strg)

/obj/item/multitool/disk_loader/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/item/disk/design_disk
	name = "\improper Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk2"
	var/datum/design/blueprint
	// I'm doing this so that disk paths with pre-loaded designs don't get weird names
	// Otherwise, I'd use "initial()"
	var/default_name = "\improper Component Design Disk"
	var/default_desc = "A disk for storing device design data for construction in lathes."

/obj/item/disk/design_disk/proc/load_blueprint(datum/design/D)
	name = "[default_name] \[[D]\]"
	desc = D.desc
	// NOTE: This is just a reference to the design on the system it grabbed it from
	// This seems highly fragile
	blueprint = D

/obj/item/disk/design_disk/proc/wipe_blueprint()
	name = default_name
	desc = default_desc
	blueprint = null

/datum/research/autolathe/syndicate/New()
	// Used by syndi autolathe in syndie space base ruin. Removes methods of contacting main station.
	. = ..()
	known_designs -= "intercom_electronics"
	known_designs -= "radio_headset"
	known_designs -= "bounced_radio"
	known_designs -= "newscaster_frame"
