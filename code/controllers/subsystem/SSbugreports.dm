SUBSYSTEM_DEF(bugreports)
	name = "Bug Reports"
	init_order = INIT_ORDER_DEFAULT
	wait = 10 MINUTES
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "Bug reports won't be recorded at the end of the round or loaded from the DB on roundstart"
	cpu_display = SS_CPUDISPLAY_DEFAULT

/datum/controller/subsystem/bugreports/Initialize()
	// We just want to load all bug reports into the
	var/datum/db_query/query_bug_reports = SSdbcore.NewQuery("SELECT * FROM bug_reports")
	if(!query_bug_reports.warn_execute())
		log_debug("Failed to load stored bug reports from DB")
		qdel(query_bug_reports)
		return
	while(query_bug_reports.NextRow())
		// Create a new bug report form an load the details from the current row into it
		var/datum/tgui_bug_report_form/bug_report = new()
		GLOB.bug_reports += bug_report
		bug_report.db_uid = query_bug_reports.item[1]
		bug_report.initial_key = query_bug_reports.item[2]
		bug_report.bug_report_data = json_decode(query_bug_reports.item[5])
		bug_report.awaiting_approval = TRUE

/datum/controller/subsystem/bugreports/fire()
	return

/datum/controller/subsystem/bugreports/Shutdown()
	record_bug_reports()

/proc/record_bug_reports()
	for(var/datum/tgui_bug_report_form/bug_report in GLOB.bug_reports)
		var/datum/db_query/bug_query = SSdbcore.NewQuery({"
			INSERT IGNORE INTO bug_reports (db_uid, author_ckey, title, round_id, contents_json) VALUES (:db_uid, :author_ckey, :title, :round_id, :contents_json)
			"},
			list(
				"db_uid" = bug_report.db_uid,
				"author_ckey" = bug_report.initial_key,
				"title" = bug_report.bug_report_data["title"],
				"round_id" = bug_report.bug_report_data["round_id"],
				"contents_json" = json_encode(bug_report.bug_report_data),
			)
		)
		bug_query.warn_execute()
		qdel(bug_query)
		GLOB.bug_reports -= bug_report
		qdel(bug_report)
	return
