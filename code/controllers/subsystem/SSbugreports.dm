SUBSYSTEM_DEF(bugreports)
	name = "Bug Reports"
	init_order = INIT_ORDER_DEFAULT
	wait = 10 MINUTES
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT
	offline_implications = "Bug reports won't be recorded at the end of the round or loaded from the DB on roundstart"
	cpu_display = SS_CPUDISPLAY_DEFAULT

/datum/controller/subsystem/bugreports/Initialize()
	return

/datum/controller/subsystem/bugreports/fire()
	return

/datum/controller/subsystem/bugreports/Shutdown()
	record_bug_reports()

/proc/record_bug_reports()
	for(var/datum/tgui_bug_report_form/bug_report in GLOB.bug_reports)
		var/datum/db_query/bug_query = SSdbcore.NewQuery({"
			INSERT INTO bug_reports (author_ckey, title, round_id, contents_json)
			VALUES (:author_ckey, :title, :round_id, :contents_json)"},
			list(
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
