datum/directive
	var/datum/game_mode/mutiny/mode
	var/list/special_orders

	New(var/datum/game_mode/mutiny/M)
		mode = M

	proc/get_description()
		return {"
			<p>
				NanoTrasen's reasons for the following directives are classified.
			</p>
		"}

	proc/meets_prerequisites()
		return 0

	proc/directives_complete()
		return 1

	proc/initialize()
		return 1

	proc/get_remaining_orders()
		return ""

/proc/get_directive(type)
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if(!mode || !mode.current_directive || !istype(mode.current_directive, text2path("/datum/directive/[type]")))
		return null

	return mode.current_directive
