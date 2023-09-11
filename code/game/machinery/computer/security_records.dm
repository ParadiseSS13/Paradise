#define SEC_DATA_R_LIST	1	// Record list
#define SEC_DATA_RECORD	2	// Record

#define SEC_FIELD(N, V, E, LB) list(field = N, value = V, edit = E, line_break = LB)

/obj/machinery/computer/secure_data
	name = "security records"
	desc = "Used to view and edit personnel's security records."
	icon_keyboard = "security_key"
	icon_screen = "security"
	circuit = /obj/item/circuitboard/secure_data
	/// The current page being viewed.
	var/current_page = SEC_DATA_R_LIST
	/// The current general record being viewed.
	var/datum/data/record/record_general = null
	/// The current security record being viewed.
	var/datum/data/record/record_security = null
	/// Whether the computer is currently printing a paper or not.
	var/is_printing = FALSE
	/// The editable fields and their associated question to display to the user.
	var/static/list/field_edit_questions
	/// The editable fields and their associated choices to display to the user.
	var/static/list/field_edit_choices
	/// The current temporary notice.
	var/temp_notice

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/secure_data/Initialize(mapload)
	. = ..()
	req_one_access = list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS)
	if(!field_edit_questions)
		field_edit_questions = list(
			// General
			"name" = "Please input new name:",
			"id" = "Please input new ID:",
			"sex" = "Please select new sex:",
			"age" = "Please input new age:",
			"fingerprint" = "Please input new fingerprint hash:",
			// Security
			"criminal" = "Please select new criminal status:",
			"mi_crim" = "Please input new minor crimes:",
			"mi_crim_d" = "Please summarize minor crimes:",
			"ma_crim" = "Please input new major crimes:",
			"ma_crim_d" = "Please summarize major crimes:",
			"notes" = "Please input new important notes:",
		)
		field_edit_choices = list(
			// General
			"sex" = list("Male", "Female"),
			// Security
			"criminal" = list(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_INCARCERATED, SEC_RECORD_STATUS_RELEASED, SEC_RECORD_STATUS_PAROLLED, SEC_RECORD_STATUS_DEMOTE, SEC_RECORD_STATUS_SEARCH, SEC_RECORD_STATUS_MONITOR),
		)

/obj/machinery/computer/secure_data/Destroy()
	record_general = null
	record_security = null
	return ..()

/obj/machinery/computer/secure_data/attackby(obj/item/O, mob/user, params)
	if(ui_login_attackby(O, user))
		return
	return ..()

/obj/machinery/computer/secure_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/secure_data/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "SecurityRecords", name, 800, 800)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/secure_data/ui_data(mob/user)
	var/list/data = list()
	data["currentPage"] = current_page
	data["isPrinting"] = is_printing
	ui_login_data(data, user)
	data["modal"] = ui_modal_data()
	data["temp"] = temp_notice
	if(data["loginState"]["logged_in"])
		switch(current_page)
			if(SEC_DATA_R_LIST)
				// Prepare the list of security records to associate with the general ones.
				// This is not ideal but datacore code sucks and needs to be rewritten.
				var/list/sec_records_assoc = list()
				for(var/datum/data/record/S in GLOB.data_core.security)
					sec_records_assoc["[S.fields["name"]]|[S.fields["id"]]"] = S
				// List the general records
				var/list/records = list()
				data["records"] = records
				for(var/datum/data/record/G in GLOB.data_core.general)
					var/datum/data/record/S = sec_records_assoc["[G.fields["name"]]|[G.fields["id"]]"]
					var/list/record_line = list("uid_gen" = G.UID(), "id" = G.fields["id"], "name" = G.fields["name"], "rank" = G.fields["rank"], "fingerprint" = G.fields["fingerprint"])
					record_line["status"] = S?.fields["criminal"] || "No record"
					record_line["uid_sec"] = S?.UID() // So we don't have to perform the search through a for loop again later
					records[++records.len] = record_line
			if(SEC_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(record_general && GLOB.data_core.general.Find(record_general))
					var/list/gen_fields = record_general.fields
					general["fields"] = list(
						SEC_FIELD("Name", 				gen_fields["name"], 		"name",			FALSE),
						SEC_FIELD("ID", 				gen_fields["id"], 			"id",			TRUE),
						SEC_FIELD("Sex", 				gen_fields["sex"], 			"sex",			FALSE),
						SEC_FIELD("Age", 				gen_fields["age"], 			"age",			TRUE),
						SEC_FIELD("Assignment", 		gen_fields["rank"], 		null,			FALSE),
						SEC_FIELD("Fingerprint", 		gen_fields["fingerprint"], 	"fingerprint",	TRUE),
						SEC_FIELD("Physical Status", 	gen_fields["p_stat"], 		null,			FALSE),
						SEC_FIELD("Mental Status", 		gen_fields["m_stat"], 		null,			TRUE),
						SEC_FIELD("Important Notes", 	gen_fields["notes"], 		null,			FALSE),
					)
					general["photos"] = list(
						gen_fields["photo-south"],
						gen_fields["photo-west"],
					)
					general["has_photos"] = (gen_fields["photo-south"] || gen_fields["photo-west"]) ? TRUE : FALSE
					general["empty"] = FALSE
				else
					general["empty"] = TRUE

				var/list/security = list()
				data["security"] = security
				if(record_security && GLOB.data_core.security.Find(record_security))
					var/list/sec_fields = record_security.fields
					security["fields"] = list(
						SEC_FIELD("Criminal Status", 	sec_fields["criminal"], 	"criminal", 	TRUE),
						SEC_FIELD("Minor Crimes", 		sec_fields["mi_crim"], 		"mi_crim", 		FALSE),
						SEC_FIELD("Details", 			sec_fields["mi_crim_d"], 	"mi_crim_d", 	TRUE),
						SEC_FIELD("Major Crimes", 		sec_fields["ma_crim"], 		"ma_crim", 		FALSE),
						SEC_FIELD("Details", 			sec_fields["ma_crim_d"], 	"ma_crim_d", 	TRUE),
						SEC_FIELD("Important Notes", 	sec_fields["notes"], 		null, 			FALSE),
					)
					if(!islist(sec_fields["comments"]))
						sec_fields["comments"] = list()
					security["comments"] = sec_fields["comments"]
					security["empty"] = FALSE
				else
					security["empty"] = TRUE

	return data

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	if(ui_act_modal(action, params))
		return
	if(ui_login_act(action, params))
		return

	var/logged_in = ui_login_get().logged_in
	switch(action)
		if("cleartemp")
			temp_notice = null
		if("page") // Select Page
			if(!logged_in)
				return
			var/page_num = clamp(text2num(params["page"]), SEC_DATA_R_LIST, SEC_DATA_R_LIST) // SEC_DATA_RECORD cannot be accessed through this act
			current_page = page_num
			record_general = null
			record_security = null
		if("view") // View Record
			if(!logged_in)
				return
			var/datum/data/record/G = locateUID(params["uid_gen"])
			var/datum/data/record/S = locateUID(params["uid_sec"])
			if(!istype(G)) // No general record!
				set_temp("General record not found!", "danger")
				return
			if(istype(S) && !(G.fields["name"] == S.fields["name"] && G.fields["id"] == S.fields["id"])) // General and security records don't match!
				S = null
			record_general = G
			record_security = S
			current_page = SEC_DATA_RECORD
		if("new_general") // New General Record
			if(!logged_in)
				return
			if(record_general)
				return
			var/datum/data/record/G = new /datum/data/record()
			G.fields["name"] = "New Record"
			G.fields["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
			G.fields["rank"] = "Unassigned"
			G.fields["real_rank"] = "Unassigned"
			G.fields["sex"] = "Male"
			G.fields["age"] = "Unknown"
			G.fields["fingerprint"] = "Unknown"
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			G.fields["species"] = "Human"
			G.fields["notes"] = "No notes."
			GLOB.data_core.general += G
			record_general = G
			record_security = null
			current_page = SEC_DATA_RECORD
		if("new_security") // New Security Record
			if(!logged_in)
				return
			if(!record_general || record_security)
				return
			var/datum/data/record/S = new /datum/data/record()
			S.fields["name"] = record_general.fields["name"]
			S.fields["id"] = record_general.fields["id"]
			S.name = "Security Record #[S.fields["id"]]"
			S.fields["criminal"] = SEC_RECORD_STATUS_NONE
			S.fields["mi_crim"] = "None"
			S.fields["mi_crim_d"] = "No minor crime convictions."
			S.fields["ma_crim"] = "None"
			S.fields["ma_crim_d"] = "No major crime convictions."
			S.fields["notes"] = "No notes."
			GLOB.data_core.security += S
			record_security = S
			update_all_mob_security_hud()
		if("delete_general") // Delete General, Security and Medical Records
			if(!logged_in)
				return
			if(!record_general)
				return
			message_admins("[key_name_admin(usr)] has deleted [record_general.fields["name"]]'s general, security and medical records at [ADMIN_COORDJMP(usr)]")
			usr.create_log(MISC_LOG, "deleted [record_general.fields["name"]]'s general, security and medical records")
			for(var/datum/data/record/M in GLOB.data_core.medical)
				if(M.fields["name"] == record_general.fields["name"] && M.fields["id"] == record_general.fields["id"])
					qdel(M)
			QDEL_NULL(record_general)
			QDEL_NULL(record_security)
			update_all_mob_security_hud()
			current_page = SEC_DATA_R_LIST
			set_temp("General, Security and Medical records deleted.")
		if("delete_security") // Delete Security Record
			if(!logged_in)
				return
			if(!record_security)
				return
			message_admins("[key_name_admin(usr)] has deleted [record_security.fields["name"]]'s security record at [ADMIN_COORDJMP(usr)]")
			usr.create_log(MISC_LOG, "deleted [record_security.fields["name"]]'s security record")
			QDEL_NULL(record_security)
			update_all_mob_security_hud()
			set_temp("Security record deleted.")
		if("comment_delete") // Delete Comment
			if(!logged_in)
				return
			var/index = text2num(params["id"])
			if(!index || !record_security)
				return

			var/list/comments = record_security.fields["comments"]
			if(!length(comments))
				return
			index = clamp(index, 1, length(comments))
			comments.Cut(index, index + 1)
		if("print_record")
			if(!logged_in)
				return
			if(is_printing)
				return
			is_printing = TRUE
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
			addtimer(CALLBACK(src, PROC_REF(print_record_finish)), 5 SECONDS)
		else
			return FALSE

	add_fingerprint(usr)

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/computer/secure_data/proc/ui_act_modal(action, list/params)
	if(!ui_login_get().logged_in)
		return
	. = TRUE
	var/id = params["id"]
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("edit")
					var/field = arguments["field"]
					if(!length(field) || !field_edit_questions[field])
						return
					var/question = field_edit_questions[field]
					var/choices = field_edit_choices[field]
					if(length(choices))
						ui_modal_choice(src, id, question, arguments = arguments, value = arguments["value"], choices = choices)
					else
						ui_modal_input(src, id, question, arguments = arguments, value = arguments["value"])
				if("comment_add")
					ui_modal_input(src, id, "Please enter your message:")
				if("print_cell_log")
					if(is_printing)
						return
					if(!length(GLOB.cell_logs))
						set_temp("There are no cell logs available to print.")
						return
					var/list/choices = list()
					var/list/already_in = list()
					for(var/p in GLOB.cell_logs)
						var/obj/item/paper/P = p
						if(already_in[P.name])
							continue
						choices += P.name
						already_in[P.name] = TRUE
					ui_modal_choice(src, id, "Please select the cell log you would like printed:", choices = choices)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("edit")
					var/field = arguments["field"]
					if(!length(field) || !field_edit_questions[field])
						return
					var/list/choices = field_edit_choices[field]
					if(length(choices) && !(answer in choices))
						return

					if(field == "age")
						var/new_age = text2num(answer)
						if(new_age < AGE_MIN || new_age > AGE_MAX)
							set_temp("Invalid age. It must be between [AGE_MIN] and [AGE_MAX].", "danger")
							return
						answer = new_age
					else if(field == "criminal")
						var/text = "Please enter a reason for the status change to [answer]:"
						if(answer == SEC_RECORD_STATUS_EXECUTE)
							text = "Please explain why they are being executed. Include a list of their crimes, and victims."
						else if(answer == SEC_RECORD_STATUS_DEMOTE)
							text = "Please explain why they are being demoted. Include a list of their offenses."
						ui_modal_input(src, "criminal_reason", text, arguments = list("status" = answer))
						return

					if(record_security && (field in record_security.fields))
						record_security.fields[field] = answer
					else if(record_general && (field in record_general.fields))
						record_general.fields[field] = answer
				if("criminal_reason")
					var/status = arguments["status"]
					if(!record_security || !(status in field_edit_choices["criminal"]))
						return
					if((status in list(SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_DEMOTE)) && !length(answer))
						set_temp("A valid reason must be provided for this status.", "danger")
						return
					var/datum/ui_login/state = ui_login_get()
					if(!set_criminal_status(usr, record_security, status, answer, state.rank, state.access, state.name))
						set_temp("Required permissions to set this criminal status not found!", "danger")
				if("comment_add")
					var/datum/ui_login/state = ui_login_get()
					if(!length(answer) || !record_security || !length(state.name))
						return
					record_security.fields["comments"] += list(list(
						header = "Made by [state.name] ([state.rank]) on [GLOB.current_date_string] [station_time_timestamp()]",
						text = answer
					))
				if("print_cell_log")
					if(is_printing)
						return
					var/obj/item/paper/T
					for(var/obj/item/paper/P in GLOB.cell_logs)
						if(P.name == answer)
							T = P
							break
					if(!T)
						set_temp("Cell log not found!", "danger")
						return
					is_printing = TRUE
					playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
					addtimer(CALLBACK(src, PROC_REF(print_cell_log_finish), T.name, T.info), 5 SECONDS)
				else
					return FALSE
		else
			return FALSE

/**
  * Called when the print record timer finishes
  */
/obj/machinery/computer/secure_data/proc/print_record_finish()
	var/obj/item/paper/P = new(loc)
	P.info = "<center><b>Security Record</b></center><br>"
	if(record_general && GLOB.data_core.general.Find(record_general))
		P.info += {"Name: [record_general.fields["name"]] ID: [record_general.fields["id"]]
				<br>\nSex: [record_general.fields["sex"]]
				<br>\nAge: [record_general.fields["age"]]
				<br>\nFingerprint: [record_general.fields["fingerprint"]]
				<br>\nPhysical Status: [record_general.fields["p_stat"]]
				<br>\nMental Status: [record_general.fields["m_stat"]]<br>"}
		P.name = "paper - 'Security Record: [record_general.fields["name"]]'"
		var/obj/item/photo/photo = new(loc)
		var/icon/new_photo = icon('icons/effects/64x32.dmi', "records")
		new_photo.Blend(icon(record_general.fields["photo"], dir = SOUTH), ICON_OVERLAY, 0)
		new_photo.Blend(icon(record_general.fields["photo"], dir = WEST), ICON_OVERLAY, 32)
		new_photo.Scale(new_photo.Width() * 3, new_photo.Height() * 3)
		photo.img = new_photo
		photo.name = "photo - 'Security Record: [record_general.fields["name"]]'"
	else
		P.info += "<b>General Record Lost!</b><br>"
	if(record_security && GLOB.data_core.security.Find(record_security))
		P.info += {"<br>\n<center><b>Security Data</b></center>
		<br>\nCriminal Status: [record_security.fields["criminal"]]<br>\n
		<br>\nMinor Crimes: [record_security.fields["mi_crim"]]
		<br>\nDetails: [record_security.fields["mi_crim_d"]]<br>\n
		<br>\nMajor Crimes: [record_security.fields["ma_crim"]]
		<br>\nDetails: [record_security.fields["ma_crim_d"]]<br>\n
		<br>\nImportant Notes:
		<br>\n\t[record_security.fields["notes"]]<br>\n<br>\n<center><B>Comments/Log</B></center><br>"}
		for(var/c in record_security.fields["comments"])
			if(islist(c))
				P.info += "\"[c["text"]]\" Comment [c["header"]]<br>"
			else
				P.info += "[c]<br>"
	else
		P.info += "<b>Security Record Lost!</b><br>"
	is_printing = FALSE
	SStgui.update_uis(src)

/**
  * Called when the print cell log timer finishes
  */
/obj/machinery/computer/secure_data/proc/print_cell_log_finish(name, info)
	var/obj/item/paper/P = new(loc)
	P.name = name
	P.info = info
	is_printing = FALSE
	SStgui.update_uis(src)

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(10 / severity))
			switch(rand(1, 6))
				if(1)
					R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(AGE_MIN, AGE_MAX)
				if(4)
					R.fields["criminal"] = pick(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_SEARCH, SEC_RECORD_STATUS_MONITOR, SEC_RECORD_STATUS_DEMOTE, SEC_RECORD_STATUS_INCARCERATED, SEC_RECORD_STATUS_PAROLLED, SEC_RECORD_STATUS_RELEASED)
				if(5)
					R.fields["p_stat"] = pick("*Unconscious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger
  */
/obj/machinery/computer/secure_data/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp_notice = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "Nanotrasen Security laptop. Bringing modern compact computing to this century!"
	icon_state = "laptop"
	icon_keyboard = "seclaptop_key"
	icon_screen = "seclaptop"
	density = FALSE

#undef SEC_DATA_R_LIST
#undef SEC_DATA_RECORD
#undef SEC_FIELD
