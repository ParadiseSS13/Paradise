GLOBAL_VAR(create_object_html)
GLOBAL_LIST_INIT(create_object_forms, list(/obj, /obj/structure, /obj/machinery, /obj/effect, /obj/item, /obj/mecha, /obj/item/clothing, /obj/item/stack, /obj/item/reagent_containers, /obj/item/gun))

/datum/admins/proc/create_object(var/mob/user)
	if(!GLOB.create_object_html)
		var/objectjs = null
		objectjs = jointext(typesof(/obj), ";")
		GLOB.create_object_html = file2text('html/create_object.html')
		GLOB.create_object_html = replacetext(GLOB.create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(replacetext(GLOB.create_object_html, "/* ref src */", UID()), "window=create_object;size=425x475")

/datum/admins/proc/quick_create_object(var/mob/user)
	var/path = input("Select the path of the object you wish to create.", "Path", /obj) in GLOB.create_object_forms
	var/html_form = GLOB.create_object_forms[path]

	if(!html_form)
		var/objectjs = jointext(typesof(path), ";")
		html_form = file2text('html/create_object.html')
		html_form = replacetext(html_form, "null /* object types */", "\"[objectjs]\"")
		GLOB.create_object_forms[path] = html_form

	user << browse(replacetext(html_form, "/* ref src */", UID()), "window=qco[path];size=425x475")
