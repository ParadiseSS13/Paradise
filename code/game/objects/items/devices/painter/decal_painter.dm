/datum/painter/decal
	module_name = "decal painter"
	module_state = "floor_painter"

	var/decal_icon = 'icons/turf/decals.dmi'
	var/decal_state = "/obj/effect/turf_decal/stripes/box"
	var/decal_dir = SOUTH
	var/removal_mode = FALSE
	//TODO: Make blacklist
	var/static/list/decal_blacklist = typecacheof(list(/obj/effect/turf_decal/raven, /obj/effect/turf_decal/weather, /obj/effect/turf_decal/stripes/asteroid, /obj/effect/turf_decal/tile))
	var/static/list/allowed_decals = list()
	// This is a double-list. First entry is the type key, second is the direction, with the final value being the b64 of the icon
	var/static/list/lookup_cache_decals = list()

/datum/painter/decal/New(obj/item/painter/parent_painter)
	. = ..()
	if(!length(lookup_cache_decals))
		for(var/D in subtypesof(/obj/effect/turf_decal))
			var/obj/effect/turf_decal/decal = D
			if(decal in decal_blacklist)
				continue
			allowed_decals += decal
			if(!(decal in lookup_cache_decals))
				lookup_cache_decals[decal::icon_state] = decal

/datum/painter/decal/paint_atom(atom/target, mob/user)
	if(!istype(target, /turf/simulated/floor))
		to_chat(user, "<span class='warning'>[holder] can only be used on flooring.</span>")
		return FALSE
	var/decals = target.GetComponents(/datum/component/decal)
	if(length(decals) > 4)
		to_chat(user, "<span class='warning'>You can't fit more decals on the [target].</span>")
		return FALSE
	if(removal_mode)
		remove_decals(target)
		return TRUE
	var/typepath = lookup_cache_decals["[decal_state]"]
	new typepath(get_turf(target), decal_dir)
	return TRUE

/datum/painter/decal/pick_color(mob/user)
	if(!user)
		return
	ui_interact(user)

/datum/painter/decal/ui_state(mob/user)
	return GLOB.inventory_state

/datum/painter/decal/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalPainter", module_name)
		// Disable automatic updates, because:
		// 1) we are the only user of the item, and don't expect to observe external changes
		// 2) generating and sending the icon each tick is a bit expensive, and creates small but noticeable lag
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/painter/decal/ui_data(mob/user)
	var/list/data = list()
	data["selectedStyle"] = decal_state
	data["selectedDir"] = decal_dir
	data["removalMode"] = removal_mode

	return data


/datum/painter/decal/ui_static_data(mob/user)
	var/list/data = list()
	data["icon"] = decal_icon
	var/list/decal_names = list()
	for(var/decal in lookup_cache_decals)
		decal_names += decal
	data["availableStyles"] = decal_names

	return data

/datum/painter/decal/ui_act(action, params)
	if(..())
		return

	if(action == "select_style")
		var/new_style = params["style"]
		if(lookup_cache_decals.Find(new_style) != 0)
			decal_state = new_style
			removal_mode = FALSE

	if(action == "cycle_style")
		var/index = allowed_decals.Find(decal_state)
		index += text2num(params["offset"])
		while(index < 1)
			index += length(allowed_decals)
		while(index > length(allowed_decals))
			index -= length(allowed_decals)
		decal_state = allowed_decals[index]

	if(action == "select_direction")
		var/dir = params["direction"]
		removal_mode = FALSE
		if(dir != 0)
			decal_dir = dir

	if(action == "removal_mode")
		removal_mode = !removal_mode
	return TRUE

/datum/painter/decal/proc/remove_decals(atom/target)
	var/turf/target_turf = get_turf(target)
	target_turf.DeleteComponentsType(/datum/component/decal)
