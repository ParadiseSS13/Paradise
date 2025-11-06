/client/proc/load_sdql2_query()
	set category = "Debug"
	set name = "Load SDQL2 Query"

	if(!check_rights(R_PROCCALL))
		return

	var/list/choices = flist("data/sdql/")
	var/choice = input(src, "Choose an SDQL script to run:", "Load SDQL Query", null) as null|anything in choices
	if(isnull(choice))
		return

	var/script_text = return_file_text("data/sdql/[choice]")
	script_text = input(usr, "SDQL2 query", "", script_text) as message

	if(!script_text || length(script_text) < 1)
		return

	run_sdql2_query(script_text)
