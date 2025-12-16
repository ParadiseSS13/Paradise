GLOBAL_LIST_EMPTY(bug_reports)
GLOBAL_LIST_EMPTY(bug_report_time)

// Datum for handling bug reports
#define STATUS_SUCCESS 201

/datum/tgui_bug_report_form
	/// contains all the body text for the bug report.
	var/list/bug_report_data = list()

	/// client of the bug report author, needed to create the ticket
	var/initial_user_uid = null

	/// ckey of the author
	var/initial_key = null // just incase they leave after creating the bug report

	/// client of the admin/dev who is accessing the report, we don't want multiple people unknowingly making changes at the same time.
	var/approving_user = null

	/// value to determine if the bug report is submitted and awaiting admin/dev approval, used for state purposes in tgui.
	var/awaiting_approval = FALSE

	/// for garbage collection purposes.
	var/selected_confirm = FALSE

	/// time the report was filed
	var/file_time

	/// Index of the report in the db
	var/row_index

	/// Whether the report has been handled
	var/handled = FALSE

/datum/tgui_bug_report_form/New(mob/user)
	if(user)
		initial_user_uid = user.client.UID()
		initial_key = user.client.key

/datum/tgui_bug_report_form/proc/add_metadata(mob/user)
	bug_report_data["server_byond_version"] = "[world.byond_version].[world.byond_build]"
	bug_report_data["user_byond_version"] = "[user.client.byond_version].[user.client.byond_build]"

	bug_report_data["local_commit"] = "No Commit Data"
	if(GLOB.revision_info.commit_hash)
		bug_report_data["local_commit"] = GLOB.revision_info.commit_hash
	if(GLOB.revision_info?.origin_commit && length(GLOB.revision_info.origin_commit))
		bug_report_data["local_commit"] = GLOB.revision_info.origin_commit

	for(var/datum/tgs_revision_information/test_merge/tm in GLOB.revision_info.testmerges)
		bug_report_data["test_merges"] += "#[tm.number] at [tm.head_commit]\n"
	bug_report_data["round_id"] = GLOB.round_id


/datum/tgui_bug_report_form/proc/external_link_prompt(client/user)
	tgui_alert(user, "Unable to create a bug report at this time, please create the issue directly through our GitHub repository instead")
	var/url = "https://github.com/ParadiseSS13/Paradise"

	if(tgui_alert(user, "This will open the GitHub in your browser. Are you sure?", "Confirm", list("Yes", "No")) == "Yes")
		user << link(url)

/datum/tgui_bug_report_form/ui_state()
	return GLOB.always_state

/datum/tgui_bug_report_form/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BugReportForm")
		ui.open()

/datum/tgui_bug_report_form/ui_close(mob/user)
	. = ..()
	// handled reports can no longer be modified.
	if(!handled)
		var/datum/db_query/query_set_closed = SSdbcore.NewQuery("UPDATE bug_reports SET approver_ckey=\"\" WHERE id=:index", list("index" = row_index))
		if(!query_set_closed.warn_execute())
			to_chat(usr,chat_box_red("The bug report's state in row [row_index] could not be set to unopened"))
	// The reports shouldn't persist unless being made or reviewed.
	qdel(src)

/datum/tgui_bug_report_form/proc/sanitize_payload(list/params)
	for(var/param in params)
		params[param] = html_decode(sanitize(params[param], list("\t"=" ","�"=" ","<"=" ",">"=" ","&"=" ")))

	return params

// whether or not an admin/dev can access the record at a given time.
/datum/tgui_bug_report_form/proc/assign_approver(mob/user)
	if(!check_rights(R_VIEWRUNTIMES|R_ADMIN|R_DEBUG, user = user))
		message_admins("[user.ckey] has attempted to review [initial_key]'s bug report titled [bug_report_data["title"]] without proper authorization at [SQLtime()].")
		return FALSE

	if(!initial_key)
		to_chat(user, SPAN_WARNING("Unable to identify the author of the bug report."))
		return FALSE

	if(approving_user)
		if(user.ckey == approving_user)
			to_chat(user, SPAN_WARNING("This bug report review is already opened and accessed by you."))
			return FALSE
		else
			to_chat(user, SPAN_WARNING("[approving_user] is currently accessing this report, it will open in read only mode."))
			return TRUE

	approving_user = user.ckey
	var/datum/db_query/query_update_approver = SSdbcore.NewQuery("UPDATE bug_reports SET approver_ckey=:approver WHERE id=:index", list("approver" = user.ckey, "index" = row_index))
	if(!query_update_approver.warn_execute())
		to_chat(user, "<span class='warning'> Failed to set bug report approver in row [row_index] in the database")
	return TRUE

// returns the body payload
/datum/tgui_bug_report_form/proc/create_form()
	var/desc = {"
## What did you expect to happen?
[bug_report_data["expected_behavior"]]

## What happened instead?
[bug_report_data["description"]]

## Why is this bad/What are the consequences?
[bug_report_data["consequences"]]

## Steps to reproduce the issue:
[bug_report_data["steps"]]

## Attached logs
```
[bug_report_data["log"] ? bug_report_data["log"] : "N/A"]
```

## Additional details
- Author: [initial_key]
- Approved By: [approving_user]
- Round ID: [bug_report_data["round_id"] ? bug_report_data["round_id"] : "N/A"]
- Client BYOND Version: [bug_report_data["user_byond_version"]]
- Server BYOND Version: [bug_report_data["server_byond_version"]]
- Server commit: [bug_report_data["local_commit"]]
- Active Test Merges: [bug_report_data["test_merges"] ? bug_report_data["test_merges"] : "None"]
- Note: [bug_report_data["approver_note"] ? bug_report_data["approver_note"] : "None"]
	"}

	return desc

// the real deal, we are sending the request through the api.
/datum/tgui_bug_report_form/proc/send_request(payload_body, client/user)
	// for any future changes see https://docs.github.com/en/rest/issues/issues
	var/repo_name = "Paradise"
	var/org = "ParadiseSS13"
	var/token = GLOB.configuration.system.github_api_token

	if(token == null)
		tgui_alert(user, "The configuration is not set for the external API.", "Issue not reported!")
		external_link_prompt(user)
		return

	var/url = "https://api.github.com/repos/[org]/[repo_name]/issues"
	var/list/headers = list()
	headers["Authorization"] = "Bearer [token]"
	headers["Content-Type"] = "text/markdown; charset=utf-8"
	headers["Accept"] = "application/vnd.github+json"

	var/datum/http_request/request = new()
	var/list/payload = list(
		"title" = bug_report_data["title"],
		"body" = payload_body,
		"labels" = list("Bug")
	)

	request.prepare(RUSTLIBS_HTTP_METHOD_POST, url, json_encode(payload), headers)
	request.begin_async()

	var/start_time = world.time
	UNTIL(request.is_complete() || (world.time > start_time + 5 SECONDS))
	if(!request.is_complete() && world.time > start_time + 5 SECONDS)
		CRASH("bug report HTML request hit timeout limit of 5 seconds");

	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != STATUS_SUCCESS)
		message_admins(SPAN_ADMINNOTICE("The GitHub API has failed to create the bug report titled [bug_report_data["title"]] approved by [approving_user], status code:[response.status_code]. Please paste this error code into the development channel on discord."))
		external_link_prompt(user)
	else
		var/client/initial_user = locateUID(initial_user_uid)
		message_admins("[user.ckey] has approved a bug report from [initial_key] titled [bug_report_data["title"]] at [SQLtime()].")
		if(initial_user)
			to_chat(initial_user, SPAN_NOTICE("An admin has successfully submitted your report and it should now be visible on GitHub. Thanks again!"))
		// Update bug report status on the DB
		var/datum/db_query/query_update_submission = SSdbcore.NewQuery("UPDATE bug_reports SET submitted=1 WHERE id=:index", list("index" = row_index))
		if(!query_update_submission.warn_execute())
			message_admins("Failed to update status of bug report from [initial_key] titled [bug_report_data["title"]] to submitted at [SQLtime()]. DB request failed")
		handled = TRUE

// proc that creates a ticket for an admin to approve or deny a bug report request
/datum/tgui_bug_report_form/proc/bug_report_request()
	var/client/initial_user = locateUID(initial_user_uid)
	file_time = SQLtime()
	if(!save_to_db())
		external_link_prompt(initial_user)
		return
	if(initial_user)
		to_chat(initial_user, SPAN_NOTICE("Your bug report has been submitted, thank you!"))
	message_roles(chat_box_green("[initial_key] has created a bug report which is now pending approval. The report can be viewed using \"View Bug Reports\" in the debug tab"), R_DEBUG|R_VIEWRUNTIMES|R_ADMIN)

/datum/tgui_bug_report_form/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(handled)
		to_chat(ui.user, "<span class='warning'>The report has already been handled. Changes cannot be made.")
		return
	if(approving_user && approving_user != ui.user.ckey)
		to_chat(ui.user, "<span class='warning'>The report is in use by someone else and has been opened in read only mode. Changes cannot be made.")
		return
	var/mob/user = ui.user
	switch(action)
		if("confirm")
			if(selected_confirm) // prevent someone from spamming the approve button
				to_chat(user, SPAN_WARNING("You have already approved this submission, please wait a moment for the API to process your submission."))
				return
			bug_report_data = sanitize_payload(params)
			add_metadata(user)
			selected_confirm = TRUE
			// Bug report request is being submitted for approval
			if(!awaiting_approval)
				bug_report_request()
				GLOB.bug_report_time[user.ckey] = world.time
				awaiting_approval = TRUE
			// Otherwise it's being approved
			else
				var/payload_body = create_form()
				send_request(payload_body, user.client)
		if("cancel")
			if(awaiting_approval) // admin has chosen to reject the bug report
				reject(user.client)
	ui.close()
	. = TRUE

/datum/tgui_bug_report_form/ui_data(mob/user)
	. = list()
	.["read_only"] = approving_user ? approving_user != user.ckey : FALSE
	.["report_details"] = bug_report_data // only filled out once the user as submitted the form
	.["awaiting_approval"] = awaiting_approval

/datum/tgui_bug_report_form/proc/reject(client/user)
	var/datum/db_query/query_update_submission = SSdbcore.NewQuery("UPDATE bug_reports SET submitted=2 WHERE id=:index", list("index" = row_index))
	if(!query_update_submission.warn_execute())
		message_admins("Failed to reject bug report from [initial_key] titled [bug_report_data["title"]] at [SQLtime()]. DB request failed")
	else
		handled = TRUE
		message_admins("[user.ckey] has rejected a bug report from [initial_key] titled [bug_report_data["title"]] at [SQLtime()].")
		var/client/initial_user = locateUID(initial_user_uid)
		if(initial_user)
			to_chat(initial_user, SPAN_WARNING("A staff member has rejected your bug report, this can happen for several reasons. They will most likely get back to you shortly regarding your issue."))
	qdel(query_update_submission)

/// Populates a list using the bug reports db table and returns it
/proc/read_bug_report_table()
	var/list/bug_reports = list()
	var/datum/db_query/query_bug_reports = SSdbcore.NewQuery("SELECT id, filetime, author_ckey, contents_json, approver_ckey, submitted FROM bug_reports WHERE submitted=0")
	if(!query_bug_reports.warn_execute())
		log_debug("Failed to load stored bug reports from DB")
		qdel(query_bug_reports)
		return list()
	while(query_bug_reports.NextRow())
		var/datum/tgui_bug_report_form/bug_report = new()
		bug_reports += bug_report
		bug_report.row_index = query_bug_reports.item[1]
		bug_report.file_time = query_bug_reports.item[2]
		bug_report.initial_key = query_bug_reports.item[3]
		bug_report.bug_report_data = json_decode(query_bug_reports.item[4])
		bug_report.approving_user = query_bug_reports.item[5] == "" ? null : query_bug_reports.item[5]
		bug_report.awaiting_approval = TRUE
		bug_report.handled = !!query_bug_reports.item[6]
	qdel(query_bug_reports)

	return bug_reports

/// Create a list of ids, authors and titles of bug reports awaiting approval
/proc/read_bug_report_titles()
	var/list/bug_reports = list()
	var/datum/db_query/query_bug_reports = SSdbcore.NewQuery("SELECT id, author_ckey, contents_json FROM bug_reports WHERE submitted=0")
	if(!query_bug_reports.warn_execute())
		log_debug("Failed to load stored bug reports from DB")
		qdel(query_bug_reports)
		return list()
	while(query_bug_reports.NextRow())
		var/list/report_data = json_decode(query_bug_reports.item[3])
		bug_reports["[query_bug_reports.item[2]] - [report_data["title"]]"] = query_bug_reports.item[1]
	qdel(query_bug_reports)

	return bug_reports

/proc/read_bug_report(index)
	var/datum/db_query/query_bug_reports = SSdbcore.NewQuery("SELECT id, filetime, author_ckey, contents_json, approver_ckey, submitted FROM bug_reports WHERE id=:index", list("index" = index))
	if(!query_bug_reports.warn_execute())
		log_debug("Failed to load bug report from DB")
		qdel(query_bug_reports)
		return
	if(!query_bug_reports.NextRow())
		log_debug("Attempted to load bug report from DB with invalid index")
		qdel(query_bug_reports)
		return
	var/datum/tgui_bug_report_form/bug_report = new()
	bug_report.row_index = query_bug_reports.item[1]
	bug_report.file_time = query_bug_reports.item[2]
	bug_report.initial_key = query_bug_reports.item[3]
	bug_report.bug_report_data = json_decode(query_bug_reports.item[4])
	bug_report.approving_user = query_bug_reports.item[5] == "" ? null : query_bug_reports.item[5]
	bug_report.awaiting_approval = TRUE
	bug_report.handled = !!query_bug_reports.item[6]
	qdel(query_bug_reports)
	return bug_report

/datum/tgui_bug_report_form/proc/save_to_db()
	. = TRUE
	var/datum/db_query/bug_query = SSdbcore.NewQuery({"
				INSERT INTO bug_reports (filetime, author_ckey, title, round_id, contents_json, approver_ckey) VALUES (:filetime, :author_ckey, :title, :round_id, :contents_json, :approver_ckey)
				"},
				list(
					"filetime" = file_time,
					"author_ckey" = initial_key,
					"title" = bug_report_data["title"],
					"round_id" = bug_report_data["round_id"],
					"contents_json" = json_encode(bug_report_data),
					"approver_ckey" = approving_user ? approving_user : ""
				)
			)
	if(!bug_query.warn_execute())
		. = FALSE
	qdel(bug_query)

#undef STATUS_SUCCESS
