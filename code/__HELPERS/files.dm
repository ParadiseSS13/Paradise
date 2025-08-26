// Security helpers to ensure you cant arbitrarily load stuff from disk
/proc/wrap_file(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, "<span class='boldannounceooc'>File load blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to load files via advanced proc-call")
		log_admin("[key_name(usr)] attempted to load files via advanced proc-call")
		return

	return file(filepath)

/proc/wrap_file2text(filepath)
	if(IsAdminAdvancedProcCall())
		// Admins shouldnt fuck with this
		to_chat(usr, "<span class='boldannounceooc'>File load blocked: Advanced ProcCall detected.</span>")
		message_admins("[key_name(usr)] attempted to load files via advanced proc-call")
		log_admin("[key_name(usr)] attempted to load files via advanced proc-call")
		return

	return file2text(filepath)

//checks if a file exists and contains text
//returns text as a string if these conditions are met
/proc/return_file_text(filename)
	if(fexists(filename) == 0)
		error("File not found ([filename])")
		return

	var/text = wrap_file2text(filename)
	if(!text)
		error("File empty ([filename])")
		return

	return text

/client/proc/browse_files(root="data/logs/", max_iterations=10, list/valid_extensions=list("txt", "log", "htm", "json"))
	if(!dd_hasprefix(root, "data/logs/") || findtext(root, "../"))
		message_admins("/client/browse_files was called with a non-log or relative root `[root]`, please inform a headcoder!")
		log_admin("/client/browse_files was called with a non-log or relative root `[root]`!")

		return
	var/path = root

	for(var/i=0, i<max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1,"/")

		var/choice = input(src,"Choose a file to access:","Download",null) as null|anything in choices
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path,-1,0) != "/")		//didn't choose a directory, no need to iterate again
			break

	var/list/exploded = splittext(path, ".")
	var/extension = exploded[length(exploded)]
	if(!fexists(path) || !(extension in valid_extensions))
		to_chat(src, "<font color='red'>Error: browse_files(): File not found/Invalid file([path]).</font>")
		return

	return path

#define FTPDELAY 200	//200 tick delay to discourage spam
/*	This proc is a failsafe to prevent spamming of file requests.
	It is just a timer that only permits a download every [FTPDELAY] ticks.
	This can be changed by modifying FTPDELAY's value above.

	PLEASE USE RESPONSIBLY, Some log files canr each sizes of 4MB!	*/
/client/proc/file_spam_check()
	var/time_to_wait = GLOB.fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: file_spam_check(): Spam. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 1
	GLOB.fileaccess_timer = world.time + FTPDELAY
	return 0
#undef FTPDELAY

/// Returns the md5 of a file at a given path.
/proc/md5filepath(path)
	. = md5(file(path))

/// Save file as an external file then md5 it.
/// Used because md5ing files stored in the rsc sometimes gives incorrect md5 results.
/proc/md5asfile(file)
	var/static/notch = 0
	// Its importaint this code can handle md5filepath sleeping instead of hard blocking, if it's converted to use rust_g.
	var/filename = "tmp/md5asfile.[world.realtime].[world.timeofday].[world.time].[world.tick_usage].[notch]"
	notch = WRAP(notch+1, 0, 2**15)
	fcopy(file, filename)
	. = md5filepath(filename)
	fdel(filename)
