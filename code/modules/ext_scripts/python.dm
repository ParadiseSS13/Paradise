/proc/ext_python(var/script, var/args, var/scriptsprefix = 1)
	if(scriptsprefix) script = "scripts/" + script

	if(world.system_type == MS_WINDOWS)
		script = replacetext(script, "/", "\\")

	var/command = python_path + " " + script + " " + args
	// These allow you to actually call shell commands with <> in so it doesnt get overwrote to files
	script = replacetext(script, "<", "&lt;")
	script = replacetext(script, ">", "&gt;")
	shell("[command]")
	return
