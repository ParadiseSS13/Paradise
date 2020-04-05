/datum/buildmode_mode/mapgen
	key = "mapgen"

	use_corner_selection = TRUE
	var/generator_path

/datum/buildmode_mode/mapgen/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select corner</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on buildmode button = Select generator</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/mapgen/change_settings(mob/user)
	var/list/gen_paths = subtypesof(/datum/mapGenerator)

	var/type = input(user,"Select Generator Type","Type") as null|anything in gen_paths
	if(!type) return

	generator_path = type
	deselect_region()

/datum/buildmode_mode/mapgen/handle_click(mob/user, params, obj/object)
	if(isnull(generator_path))
		to_chat(user, "<span class='warning'>Select generator type first.</span>")
		deselect_region()
		return
	..()

/datum/buildmode_mode/mapgen/handle_selected_region(mob/user, params)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click) //rectangular
		if(cornerA && cornerB)
			var/datum/mapGenerator/G = new generator_path
			G.defineRegion(cornerA, cornerB, 1)
			highlight_region(G.map)
			var/confirm = alert("Are you sure you want run the map generator?", "Run generator", "Yes", "No")
			if(confirm == "Yes")
				G.generate()
