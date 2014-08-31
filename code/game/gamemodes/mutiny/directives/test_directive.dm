// For testing
datum/directive/terminations/test
	special_orders = list(
		"Suspend financial accounts of all ugly personnel.",
		"Transfer their payrolls to the station account.",
		"Terminate their employment.")

datum/directive/terminations/test/get_crew_to_terminate()
	var/list/uglies[0]
	for(var/mob/M in player_list)
		uglies+=(M)
	return uglies

datum/directive/terminations/test/get_description()
	return {"
		<p>
			Wow. Much ugly. So painful.
			Many terminations. Very classified.
		</p>
	"}

datum/directive/terminations/test/meets_prerequisites()
	return 1
