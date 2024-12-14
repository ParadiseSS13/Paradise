/// Makes sure objects actually have icons that exist!
/datum/game_test/missing_icons
	var/static/list/possible_icon_states = list()

/datum/game_test/missing_icons/proc/generate_possible_icon_states_list(directory_path = "icons/obj/")
	for(var/file_path in flist(directory_path))
		if(findtext(file_path, ".dmi"))
			for(var/sprite_icon in icon_states("[directory_path][file_path]", 1)) //2nd arg = 1 enables 64x64+ icon support, otherwise you'll end up with "sword0_1" instead of "sword"
				possible_icon_states[sprite_icon] += list("[directory_path][file_path]")
		else
			possible_icon_states += generate_possible_icon_states_list("[directory_path][file_path]")

/datum/game_test/missing_icons/Run()
	generate_possible_icon_states_list()
	generate_possible_icon_states_list("icons/effects/")

	//Add EVEN MORE paths if needed here!
	//generate_possible_icon_states_list("your/folder/path/")
	var/list/bad_list = list()
	for(var/obj/obj_path as anything in subtypesof(/obj)) // maybe someday a subtype of this test can cover mobs too (hell maybe atom/movable)
		if(initial(obj_path.flags) & ABSTRACT)
			continue

		var/icon = initial(obj_path.icon)
		if(isnull(icon))
			continue
		var/icon_state = initial(obj_path.icon_state)
		if(isnull(icon_state))
			continue

		if(length(bad_list) && (icon_state in bad_list[icon]))
			continue

		if(icon_exists(icon, icon_state))
			continue

		bad_list[icon] += list(icon_state)

		var/match_message
		if(icon_state in possible_icon_states)
			for(var/file_place in possible_icon_states[icon_state])
				match_message += (match_message ? " & '[file_place]'" : " - Matching sprite found in: '[file_place]'")

		TEST_FAIL("Missing icon_state for [obj_path] in '[icon]'.\n\ticon_state = \"[icon_state]\"[match_message]")

