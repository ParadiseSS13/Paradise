var/list/error_last_seen = list()
// error_cooldown items will either be positive (cooldown time) or negative (silenced error)
//  If negative, starts at -1, and goes down by 1 each time that error gets skipped
var/list/error_cooldown = list()
var/total_runtimes = 0
var/total_runtimes_skipped = 0
// The ifdef needs to be down here, since the error viewer references total_runtimes
#ifdef DEBUG
/world/Error(var/exception/e, var/datum/e_src)
	if(!istype(e)) // Something threw an unusual exception
		log_to_dd("\[[time_stamp()]] Uncaught exception: [e]")
		return ..()
	if(!error_last_seen) // A runtime is occurring too early in start-up initialization
		return ..()
	total_runtimes++

	var/erroruid = "[e.file][e.line]"
	var/last_seen = error_last_seen[erroruid]
	var/cooldown = error_cooldown[erroruid] || 0
	if(last_seen == null) // A new error!
		error_last_seen[erroruid] = world.time
		last_seen = world.time
	if(cooldown < 0)
		error_cooldown[erroruid]-- // Used to keep track of skip count for this error
		total_runtimes_skipped++
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
			var/skipcount = abs(error_cooldown[erroruid]) - 1
			error_cooldown[erroruid] = 0
			if(skipcount > 0)
				log_to_dd("\[[time_stamp()]] Skipped [skipcount] runtimes in [e.file],[e.line].")
				error_cache.logError(e, skipCount = skipcount)
	error_last_seen[erroruid] = world.time
	error_cooldown[erroruid] = cooldown

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
	if(splitlines.len > 2) // If there aren't at least three lines, there's no info
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
	log_to_dd("\[[time_stamp()]] Runtime in [e.file],[e.line]: [e]")
	for(var/line in desclines)
		log_to_dd(line)
	if(error_cache)
		error_cache.logError(e, desclines, e_src = e_src)

#endif

/proc/log_runtime(exception/e, datum/e_src, extra_info)
	if(!istype(e))
		world.Error(e, e_src)
		return

	if(extra_info)
		// Adding extra info adds two newlines, because parsing runtimes is funky
		if(islist(extra_info))
			e.desc = "  [jointext(extra_info, "\n  ")]\n\n" + e.desc
		else
			e.desc = "  [extra_info]\n\n" + e.desc

	world.Error(e, e_src)
