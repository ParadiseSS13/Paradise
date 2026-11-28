GLOBAL_VAR(create_object_html)

/datum/admins/proc/create_object(mob/user)
	if(!GLOB.create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		GLOB.create_object_html = file2text('html/create_object.html')
		GLOB.create_object_html = replacetext(GLOB.create_object_html, "$ATOM$", "Object")
		GLOB.create_object_html = replacetext(GLOB.create_object_html, "null /* object types */", "\"[objectjs]\"")

	var/datum/browser/popup = new(user, "create_obj", "<div align='center'>Create Object</div>", 500, 550)
	var/unique_content = GLOB.create_object_html
	unique_content = replacetext(unique_content, "/* ref src */", UID())
	popup.set_content(unique_content)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.open()
	onclose(user, "create_obj")
