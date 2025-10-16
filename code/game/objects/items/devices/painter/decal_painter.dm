/datum/asset/spritesheet/decal_painter
	name = "decal_painter"
	var/obj/effect/turf_decal/current_typepath

/datum/asset/spritesheet/decal_painter/create_spritesheets()
	// The first sprite we insert is a blank 32x32 icon. This means that when we
	// generate class names for icon state/direction combinations that don't
	// exist, the ones with non-existent class names will instead just point to the
	// first image on the sheet.
	Insert("blank", 'icons/turf/decals.dmi', "blank")
	for(var/obj/effect/turf_decal/decal_type as anything in subtypesof(/obj/effect/turf_decal))
		current_typepath = decal_type
		var/decal_classname = replace_characters("[decal_type]", list("/" = "_"))
		if(decal_type::icon_state == "")
			continue
		for(var/direction in GLOB.alldirs)
			Insert(
				"[decal_classname]_[direction]",
				decal_type::icon,
				decal_type::icon_state,
				direction,
			)

/datum/asset/spritesheet/decal_painter/ModifyInserted(icon/pre_asset)
	var/icon/parent = ..()
	if(current_typepath && current_typepath::color)
		parent.Blend(current_typepath::color, ICON_MULTIPLY)
	return parent

/datum/painter/decal
	module_name = "decal painter"
	module_state = "decal_painter"
	/// icon that contains the decal sprites
	var/decal_icon = 'icons/turf/decals.dmi'
	var/selected_type = /obj/effect/turf_decal/stripes/box
	var/selected_dir = SOUTH
	var/selected_category = DECAL_PAINTER_CATEGORY_STANDARD
	/// When removal_mode is TRUE the decal painter will remove decals instead
	var/removal_mode = FALSE
	var/max_decals = 4
	var/static/list/decal_blacklist = typecacheof(
		list(
			/obj/effect/turf_decal/raven,
			/obj/effect/turf_decal/weather,
			/obj/effect/turf_decal/stripes/asteroid,
			/obj/effect/turf_decal/sand,
			/obj/effect/turf_decal/plaque,
		)
	)
	/// List of typepaths of turf decals exposed by the painter.
	var/static/list/lookup_cache_decals = list()

/datum/painter/decal/New(obj/item/painter/parent_painter)
	. = ..()
	if(!length(lookup_cache_decals))
		for(var/D in subtypesof(/obj/effect/turf_decal))
			var/obj/effect/turf_decal/decal = D
			if(decal in decal_blacklist)
				continue
			if(decal::icon_state == "blank")
				continue
			lookup_cache_decals += decal

/datum/painter/decal/paint_atom(atom/target, mob/user)
	if(!istype(target, /turf/simulated/floor))
		to_chat(user, "<span class='warning'>[holder] can only be used on flooring.</span>")
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/list/datum/element/decal/decals = target_turf.get_decals()
	if(removal_mode)
		remove_decals(target)
		return TRUE
	if(length(decals) >= max_decals)
		to_chat(user, "<span class='warning'>You can't fit more decals on [target].</span>")
		return FALSE

	if(ispath(selected_type, /obj/effect/turf_decal))
		new selected_type(target_turf, selected_dir)
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
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/painter/decal/ui_data(mob/user)
	var/list/data = list()
	data["selectedDecalType"] = selected_type
	data["selectedDir"] = selected_dir
	data["selectedCategory"] = selected_category
	data["removalMode"] = removal_mode

	return data

/datum/painter/decal/ui_static_data(mob/user)
	var/static/list/data
	if(!data)
		data = list()
		data["categories"] = list(
			DECAL_PAINTER_CATEGORY_STANDARD,
			DECAL_PAINTER_CATEGORY_THIN,
			DECAL_PAINTER_CATEGORY_THICK,
			DECAL_PAINTER_CATEGORY_SQUARE,
			DECAL_PAINTER_CATEGORY_ALPHANUM,
			DECAL_PAINTER_CATEGORY_TILES,
		)
		data["icon"] = decal_icon
		var/list/availableStyles = list()

		for(var/decal in lookup_cache_decals)
			var/obj/effect/turf_decal/decal_type = decal
			if(!(decal_type::painter_category in availableStyles))
				availableStyles[decal_type::painter_category] = list()
			availableStyles[decal_type::painter_category] += list(list(
				"icon" = decal_type::icon,
				"icon_state" = decal_type::icon_state,
				"color" = decal_type::color,
				"typepath" = decal_type,
			))

		data["availableStyles"] = availableStyles

	return data

/datum/painter/decal/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("set_category")
			selected_category = params["category"]
		if("set_direction")
			var/new_dir = params["direction"]
			removal_mode = FALSE
			if(new_dir != 0)
				selected_dir = new_dir
		if("set_decal_type")
			var/new_decal_type = text2path(params["decal_type"])
			if(ispath(new_decal_type))
				selected_type = new_decal_type
				removal_mode = FALSE
		if("toggle_removal_mode")
			removal_mode = !removal_mode

	return TRUE

/datum/painter/decal/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/decal_painter)
	)

/datum/painter/decal/proc/remove_decals(atom/target)
	var/turf/target_turf = get_turf(target)
	var/list/datum/element/decal/decals = target_turf.get_decals()
	for(var/datum/element/decal/dcl in decals)
		dcl.Detach(target)
	target_turf.RemoveElement(/datum/element/decal)
