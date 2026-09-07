USER_VERB(load_sdql2_query, R_PROCCALL, "Load SDQL2 Query", "Load SDQL2 Query from data directory.", VERB_CATEGORY_DEBUG)
	var/list/choices = flist("data/sdql/")
	var/choice = input(client, "Choose an SDQL script to run:", "Load SDQL Query", null) as null|anything in choices
	if(isnull(choice))
		return

	var/script_text = return_file_text("data/sdql/[choice]")
	script_text = input(client, "SDQL2 query", "", script_text) as message

	if(!script_text || length(script_text) < 1)
		return

	client.run_sdql2_query(script_text)
