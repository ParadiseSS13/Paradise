USER_VERB(map_template_place, R_DEBUG, "Map template - Place", "Map template - Place", VERB_CATEGORY_DEBUG)
	var/datum/map_template/template

	var/map = input(user, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in GLOB.map_templates
	if(!map)
		return
	template = GLOB.map_templates[map]

	var/turf/T = get_turf(user.mob)
	if(!T)
		return

	if(!template.fits_in_map_bounds(T, centered = TRUE))
		to_chat(user, "Map is too large to fit in bounds. Map's dimensions: ([template.width], [template.height])")
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		preview += image('icons/turf/overlays.dmi',S,"greenOverlay")
	user.images += preview
	if(alert(user, "Confirm location.","Template Confirm","Yes","No") == "Yes")
		var/timer = start_watch()
		message_admins("<span class='adminnotice'>[key_name_admin(user)] has started to place the map template ([template.name]) at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
		if(template.load(T, centered = TRUE))
			message_admins("<span class='adminnotice'>[key_name_admin(user)] has placed a map template ([template.name]) at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>. Took [stop_watch(timer)]s.</span>")
		else
			to_chat(user, "Failed to place map")
	user.images -= preview

USER_VERB(map_template_upload, R_DEBUG, "Map Template - Upload", "Map Template - Upload", VERB_CATEGORY_DEBUG)
	var/map = input(user, "Choose a Map Template to upload to template storage","Upload Map Template") as null|file
	if(!map)
		return
	if(copytext("[map]",-4) != ".dmm")
		to_chat(user, "Bad map file: [map]")
		return

	var/timer = start_watch()
	message_admins("<span class='adminnotice'>[key_name_admin(user)] has begun uploading a map template ([map])</span>")
	var/datum/map_template/M = new(map=map, rename="[map]")
	if(M.preload_size(map))
		to_chat(user, "Map template '[map]' ready to place ([M.width]x[M.height])")
		GLOB.map_templates[M.name] = M
		message_admins("<span class='adminnotice'>[key_name_admin(user)] has uploaded a map template ([map]). Took [stop_watch(timer)]s.</span>")
	else
		to_chat(user, "Map template '[map]' failed to load properly")

USER_VERB(map_template_load_lazy, R_DEBUG, "Map template - Lazy Load", "Map template - Lazy Load", VERB_CATEGORY_DEBUG)
	var/map = input(user, "Choose a Map Template to place on the lazy load map level.","Place Map Template") as null|anything in GLOB.map_templates
	if(!map)
		return
	var/datum/map_template/template = GLOB.map_templates[map]

	message_admins("<span class='adminnotice'>[key_name_admin(user)] is lazyloading the map template ([template.name]).</span>")
	var/datum/turf_reservation/reserve = SSmapping.lazy_load_template(template)
	if(!istype(reserve))
		message_admins("<span class='danger'>Lazyloading [template.name] failed! You should report this as a bug.</span>")
		return
	message_admins("<span class='adminnotice'>[key_name_admin(user)] has lazyloaded the map template ([template.name]) at [ADMIN_JMP(reserve.bottom_left_turf)]</span>")
