GLOBAL_LIST_EMPTY(error_last_seen)
// error_cooldown items will either be positive (cooldown time) or negative (silenced error)
//  If negative, starts at -1, and goes down by 1 each time that error gets skipped
GLOBAL_LIST_EMPTY(error_cooldown)
GLOBAL_VAR_INIT(total_runtimes, 0)
GLOBAL_VAR_INIT(total_runtimes_skipped, 0)
// The ifdef needs to be down here, since the error viewer references total_runtimes
#ifdef DEBUG
/world/Error(exception/e, datum/e_src)
	if(!istype(e)) // Something threw an unusual exception
		log_world("\[[time_stamp()]] Uncaught exception: [e]")
		return ..()
	if(!GLOB.error_last_seen) // A runtime is occurring too early in start-up initialization
		return ..()
	GLOB.total_runtimes++

	// STEP 1 - WE SANITIZE
	// Proc args are included in runtimes. This has a habit of leaking secrets. We dont want this.
	var/list/sanitize_splitlines = splittext(e.desc, "\n")
	var/callstack_hit = FALSE
	for(var/i in 1 to length(sanitize_splitlines))
		var/original_line = sanitize_splitlines[i]
		// Blank line, skip it
		if(length(original_line) < 3)
			continue

		// We only care about lines after callstack
		if(original_line == "  call stack:")
			callstack_hit = TRUE
			continue

		// If we aint hit it, next
		if(!callstack_hit)
			continue

		// First split on the colon
		var/list/inner_split = splittext(original_line, ": ")
		if(length(inner_split) >= 2)
			var/source_half = "[inner_split[1]]: "
			var/proc_half = inner_split[2]
			var/proc_name = splittext(proc_half, "(")[1] // Put a ) here to stop the bracket colouriser whining

			proc_name = replacetext(proc_name, " ", "_") // Put the underscores back because BYOND removes them for some reason

			sanitize_splitlines[i] = "[source_half][proc_name]"

	e.desc = sanitize_splitlines.Join("\n")

	// Ok now we can do everything else
	var/erroruid = "[e.file][e.line]"
	var/last_seen = GLOB.error_last_seen[erroruid]
	var/cooldown = GLOB.error_cooldown[erroruid] || 0
	if(last_seen == null) // A new error!
		GLOB.error_last_seen[erroruid] = world.time
		last_seen = world.time
	if(cooldown < 0)
		GLOB.error_cooldown[erroruid]-- // Used to keep track of skip count for this error
		GLOB.total_runtimes_skipped++
		return // Error is currently silenced, skip handling it

	// Handle cooldowns and silencing spammy errors
	var/silencing = 0
	// Each occurrence of a unique error adds to its "cooldown" time...
	cooldown = max(0, cooldown - (world.time - last_seen)) + ERROR_COOLDOWN
	// ... which is used to silence an error if it occurs too often, too fast
	if(cooldown > ERROR_MAX_COOLDOWN)
		cooldown = -1
		silencing = 1
		spawn(0)
			usr = null
			sleep(ERROR_SILENCE_TIME)
			var/skipcount = abs(GLOB.error_cooldown[erroruid]) - 1
			GLOB.error_cooldown[erroruid] = 0
			if(skipcount > 0)
				log_world("\[[time_stamp()]] Skipped [skipcount] runtimes in [e.file]:[e.line].")
				GLOB.error_cache.logError(e, skipCount = skipcount)
	GLOB.error_last_seen[erroruid] = world.time
	GLOB.error_cooldown[erroruid] = cooldown

	// This line will log a runtime summary to a file which can be publicly distributed without sending player data
	log_runtime_summary("Runtime in [e.file]:[e.line]: [e]")

	// The detailed error info needs some tweaking to make it look nice
	var/list/srcinfo = null
	var/list/usrinfo = null
	var/locinfo
	// First, try to make better src/usr info lines
	if(istype(e_src))
		srcinfo = list("  src: [datum_info_line(e_src)]")
		locinfo = atom_loc_line(e_src)
		if(locinfo)
			srcinfo += "  src.loc: [locinfo]"
	if(istype(usr))
		usrinfo = list("  usr: [datum_info_line(usr)]")
		locinfo = atom_loc_line(usr)
		if(locinfo)
			usrinfo += "  usr.loc: [locinfo]"
	// The proceeding mess will almost definitely break if error messages are ever changed
	// I apologize in advance
	var/list/splitlines = splittext(e.desc, "\n")
	var/list/desclines = list()
	if(length(splitlines) > 2) // If there aren't at least three lines, there's no info
		for(var/line in splitlines)
			if(length(line) < 3)
				continue // Blank line, skip it
			if(findtext(line, "source file:"))
				continue // Redundant, skip it
			if(findtext(line, "usr.loc:"))
				continue // Our usr.loc is better, skip it
			if(findtext(line, "usr:"))
				if(usrinfo)
					desclines.Add(usrinfo)
					usrinfo = null
				continue // Our usr info is better, replace it
			if(srcinfo)
				if(findtext(line, "src.loc:"))
					continue
				if(findtext(line, "src:"))
					desclines.Add(srcinfo)
					srcinfo = null
					continue
			if(copytext(line, 1, 3) != "  ")
				desclines += ("  " + line) // Pad any unpadded lines, so they look pretty
			else
				desclines += line
	if(srcinfo) // If these aren't null, they haven't been added yet
		desclines.Add(srcinfo)
	if(usrinfo)
		desclines.Add(usrinfo)
	if(silencing)
		desclines += "  (This error will now be silenced for [ERROR_SILENCE_TIME / 600] minutes)"

	// Now to actually output the error info...
	log_world("\[[time_stamp()]] Runtime in [e.file]:[e.line]: [e]")
	log_runtime_txt("Runtime in [e.file],[e.line]: [e]") // All other runtimes show as [e.file]:[e.line] except this one to prevent fuckery with analyzing both old and new runtimes. runtime.log should stay in the [e.file],[e.line] format.
	for(var/line in desclines)
		log_world(line)
		log_runtime_txt(line)
#ifdef CIBUILDING
	log_world("::error file=[e.file],line=[e.line],title=Runtime::[e]")
#endif
	if(GLOB.error_cache)
		GLOB.error_cache.logError(e, desclines, e_src = e_src)
#endif

/client/proc/throw_runtime()
	set name = "Throw Runtime"
	set desc = "Throws a runtime, what did you expect?"
	set category = "Debug"

	if(!check_rights(R_MAINTAINER))
		return

	throw_runtime_inner(1337, 0)

/client/proc/throw_runtime_inner(x, y)
	to_chat(usr, "[x]/[y]=[x/y]")
