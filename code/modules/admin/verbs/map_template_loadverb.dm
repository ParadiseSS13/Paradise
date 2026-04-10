USER_VERB(map_template_place, R_DEBUG, "Map template - Place", "Map template - Place", VERB_CATEGORY_DEBUG)
	var/datum/map_template/template

	var/map = input(client, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in GLOB.map_templates
	if(!map)
		return
	template = GLOB.map_templates[map]

	var/turf/T = get_turf(client.mob)
	if(!T)
		return

	if(!template.fits_in_map_bounds(T, centered = TRUE))
		to_chat(client, "Map is too large to fit in bounds. Map's dimensions: ([template.width], [template.height])")
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		preview += image('icons/turf/overlays.dmi',S,"greenOverlay")
	client.images += preview
	if(alert(client, "Confirm location.","Template Confirm","Yes","No") == "Yes")
		var/timer = start_watch()
		message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] has started to place the map template ([template.name]) at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>"))
		if(template.load(T, centered = TRUE))
			message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] has placed a map template ([template.name]) at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>. Took [stop_watch(timer)]s."))
		else
			to_chat(client, "Failed to place map")
	client.images -= preview

USER_VERB(map_template_upload, R_DEBUG, "Map Template - Upload", "Map Template - Upload", VERB_CATEGORY_DEBUG)
	var/map = input(client, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]",-4) != ".dmm")
		to_chat(client, "Bad map file: [map]")
		return

	var/timer = start_watch()
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] has begun uploading a map template ([map])"))
	var/datum/map_template/M = new(map=map, rename="[map]")
	if(M.preload_size(map))
		to_chat(client, "Map template '[map]' ready to place ([M.width]x[M.height])")
		GLOB.map_templates[M.name] = M
		message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] has uploaded a map template ([map]). Took [stop_watch(timer)]s."))
	else
		to_chat(client, "Map template '[map]' failed to load properly")

USER_VERB(map_template_load_lazy, R_DEBUG, "Map template - Lazy Load", "Map template - Lazy Load", VERB_CATEGORY_DEBUG)
	var/map = input(client, "Choose a Map Template to place on the lazy load map level.","Place Map Template") as null|anything in GLOB.map_templates
	if(!map)
		return
	var/datum/map_template/template = GLOB.map_templates[map]

	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] is lazyloading the map template ([template.name])."))
	var/datum/turf_reservation/reserve = SSmapping.lazy_load_template(template)
	if(!istype(reserve))
		message_admins(SPAN_DANGER("Lazyloading [template.name] failed! You should report this as a bug."))
		return
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] has lazyloaded the map template ([template.name]) at [ADMIN_JMP(reserve.bottom_left_turf)]"))
