/obj/item/disk/tech_disk
	name = "\improper Technology Disk"
	desc = "A disk for storing research data for further research, it is only capable of holding one type of research at a time."
	icon_state = "tech_"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/list/stored_research = list() // e.g (RESEARCH_POINT_STANDARD = 200)
	/// How many types of research point can we store on this disk?
	var/type_limit = 1

/// Input: List of points. Returns: points deposited or nothing if failed.
/obj/item/disk/tech_disk/proc/load_research(list/points_list)
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if(stored_research.len <= type_limit && !(i in stored_research) || i <= 0)
			continue
		stored_research[i] += points_list[i]
	change_name()
	return points_list // Return the points so the caller knows it transfered.

/// Input: List of points. Returns: points taken from the disk or nothing if failed.
/obj/item/disk/tech_disk/proc/unload_research(list/points_list)
	if(stored_research.len == 0)
		return
	points_list &= SSresearch.point_types // If a point type isnt recognised, remove it.
	for(var/i in points_list)
		if(!(i in stored_research) || i <= 0)
			continue
		if(points_list[i] > stored_research[i])
			points_list[i] = stored_research[i] // Can't overdraw.
		stored_research[i] -= points_list[i]
		if(stored_research[i] <= 0)
			stored_research.Remove(i)
	change_name()
	return points_list // Return the points so the caller knows how much as been transfered.

/obj/item/disk/tech_disk/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	make_radial(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/disk/tech_disk/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/disk/tech_disk/proc/make_radial(mob/user)
	if(!check_menu(user))
		return
	var/possible_skins = list(
		"Normal" = image(icon = 'icons/obj/module.dmi', icon_state = "tech_"),
		"Research" = image(icon = 'icons/obj/module.dmi', icon_state = "tech_Research"),
		"Illegal" = image(icon = 'icons/obj/module.dmi', icon_state = "tech_Illegal"),
		"Alien" = image(icon = 'icons/obj/module.dmi', icon_state = "tech_Alien"),
	)
	if(!possible_skins)
		return
	var/choice = show_radial_menu(user, src, possible_skins, null, 30, CALLBACK(src, PROC_REF(check_menu), user), TRUE)
	if(!choice)
		return
	update_icon(UPDATE_ICON_STATE, choice)

/obj/item/disk/tech_disk/update_icon(updates, type)
	. = ..()
	if(!type || type == "Normal")
		icon_state = initial(icon_state)
		return
	icon_state = "[initial(icon_state)][type]"

/obj/item/disk/tech_disk/proc/wipe_research()
	stored_research = list()
	change_name()

/// Updates the name to display the stored point amount or reset to normal.
/obj/item/disk/tech_disk/proc/change_name()
	if(stored_research.len > 0)
		name = "[initial(name)] \[[stored_research[1]]\]"
		return
	name = initial(name)

/obj/item/disk/tech_disk/examine(mob/user)
	. = ..()
	. += "It can store [type_limit] unique types of research."
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
	var/list/possible_types = list("Research", "Illegal", "Alien")

/obj/item/multitool/disk_loader/activate_self(mob/user)
	. = ..()
	to_load.len = 0
	load_points = tgui_input_number(usr, "Select Points", "Points", 0, 10000, 0)
	point_type = tgui_alert(usr, "Select Type", "Type", possible_types)
	p_mode = tgui_alert(usr, "Select Mode", "Mode", list("load", "unload"))
	to_load[p_mode] = load_points

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
