USER_VERB(load_sdql2_query, R_PROCCALL, "Load SDQL2 Query", "Load SDQL2 Query from data directory.", VERB_CATEGORY_DEBUG)
	var/list/choices = flist("data/sdql/")
	var/choice = wrapped_selection_input(client, "Choose an SDQL script to run:", "Load SDQL Query", choices)
	if(isnull(choice))
		return

	var/script_text = return_file_text("data/sdql/[choice]")
	script_text = stripped_multiline_input(client, "SDQL2 query", "", script_text)

	if(!script_text || length(script_text) < 1)
		return

	client.run_sdql2_query(script_text)
