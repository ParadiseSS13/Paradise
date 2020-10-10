#define MED_DATA_R_LIST	2	// Record list
#define MED_DATA_MAINT	3	// Records maintenance
#define MED_DATA_RECORD	4	// Record
#define MED_DATA_V_DATA	5	// Virus database
#define MED_DATA_MEDBOT	6	// Medbot monitor

#define FIELD(N, V, E) list(field = N, value = V, edit = E)
#define MED_FIELD(N, V, E, LB) list(field = N, value = V, edit = E, line_break = LB)

/obj/machinery/computer/med_data //TODO:SANITY
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_keyboard = "med_key"
	icon_screen = "medcomp"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/circuitboard/med_data
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/list/temp = null
	var/printing = null
	// The below are used to make modal generation more convenient
	var/static/list/field_edit_questions
	var/static/list/field_edit_choices

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/med_data/Initialize()
	..()
	field_edit_questions = list(
		// General
		"sex" = "Please select new sex:",
		"age" = "Please input new age:",
		"fingerprint" = "Please input new fingerprint hash:",
		"p_stat" = "Please select new physical status:",
		"m_stat" = "Please select new mental status:",
		// Medical
		"blood_type" = "Please select new blood type:",
		"b_dna" = "Please input new DNA:",
		"mi_dis" = "Please input new minor disabilities:",
		"mi_dis_d" = "Please summarize minor disabilities:",
		"ma_dis" = "Please input new major disabilities:",
		"ma_dis_d" = "Please summarize major disabilities:",
		"alg" = "Please input new allergies:",
		"alg_d" = "Please summarize allergies:",
		"cdi" = "Please input new current diseases:",
		"cdi_d" = "Please summarize current diseases:",
		"notes" = "Please input new important notes:",
	)
	field_edit_choices = list(
		// General
		"sex" = list("Male", "Female"),
		"p_stat" = list("*Deceased*", "*SSD*", "Active", "Physically Unfit", "Disabled"),
		"m_stat" = list("*Insane*", "*Unstable*", "*Watch*", "Stable"),
		// Medical
		"blood_type" = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"),
	)

/obj/machinery/computer/med_data/Destroy()
	active1 = null
	active2 = null
	return ..()

/obj/machinery/computer/med_data/attackby(obj/item/O, mob/user, params)
	if(ui_login_attackby(O, user))
		return
	return ..()

/obj/machinery/computer/med_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/med_data/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MedicalRecords", "Medical Records", 800, 380, master_ui, state)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/med_data/ui_data(mob/user)
	var/list/data = list()
	data["temp"] = temp
	data["screen"] = screen
	data["printing"] = printing
	// This proc appends login state to data.
	ui_login_data(data, user)
	if(data["loginState"]["logged_in"])
		switch(screen)
			if(MED_DATA_R_LIST)
				if(!isnull(GLOB.data_core.general))
					var/list/records = list()
					data["records"] = records
					for(var/datum/data/record/R in sortRecord(GLOB.data_core.general))
						records[++records.len] = list("ref" = "\ref[R]", "id" = R.fields["id"], "name" = R.fields["name"])
			if(MED_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
					var/list/fields = list()
					general["fields"] = fields
					fields[++fields.len] = FIELD("Name", active1.fields["name"], null)
					fields[++fields.len] = FIELD("ID", active1.fields["id"], null)
					fields[++fields.len] = FIELD("Sex", active1.fields["sex"], "sex")
					fields[++fields.len] = FIELD("Age", active1.fields["age"], "age")
					fields[++fields.len] = FIELD("Fingerprint", active1.fields["fingerprint"], "fingerprint")
					fields[++fields.len] = FIELD("Physical Status", active1.fields["p_stat"], "p_stat")
					fields[++fields.len] = FIELD("Mental Status", active1.fields["m_stat"], "m_stat")
					var/list/photos = list()
					general["photos"] = photos
					photos[++photos.len] = active1.fields["photo-south"]
					photos[++photos.len] = active1.fields["photo-west"]
					general["has_photos"] = (active1.fields["photo-south"] || active1.fields["photo-west"] ? 1 : 0)
					general["empty"] = 0
				else
					general["empty"] = 1

				var/list/medical = list()
				data["medical"] = medical
				if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
					var/list/fields = list()
					medical["fields"] = fields
					fields[++fields.len] = MED_FIELD("Blood Type", active2.fields["blood_type"], "blood_type", FALSE)
					fields[++fields.len] = MED_FIELD("DNA", active2.fields["b_dna"], "b_dna", TRUE)
					fields[++fields.len] = MED_FIELD("Minor Disabilities", active2.fields["mi_dis"], "mi_dis", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["mi_dis_d"], "mi_dis_d", TRUE)
					fields[++fields.len] = MED_FIELD("Major Disabilities", active2.fields["ma_dis"], "ma_dis", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["ma_dis_d"], "ma_dis_d", TRUE)
					fields[++fields.len] = MED_FIELD("Allergies", active2.fields["alg"], "alg", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["alg_d"], "alg_d", TRUE)
					fields[++fields.len] = MED_FIELD("Current Diseases", active2.fields["cdi"], "cdi", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["cdi_d"], "cdi_d", TRUE)
					fields[++fields.len] = MED_FIELD("Important Notes", active2.fields["notes"], "notes", TRUE)
					if(!active2.fields["comments"] || !islist(active2.fields["comments"]))
						active2.fields["comments"] = list()
					medical["comments"] = active2.fields["comments"]
					medical["empty"] = 0
				else
					medical["empty"] = 1
			if(MED_DATA_V_DATA)
				data["virus"] = list()
				for(var/D in typesof(/datum/disease))
					var/datum/disease/DS = new D(0)
					if(istype(DS, /datum/disease/advance))
						continue
					if(!DS.desc)
						continue
					data["virus"] += list(list("name" = DS.name, "D" = D))
			if(MED_DATA_MEDBOT)
				data["medbots"] = list()
				for(var/mob/living/simple_animal/bot/medbot/M in GLOB.bots_list)
					if(M.z != z)
						continue
					var/turf/T = get_turf(M)
					if(T)
						var/medbot = list()
						var/area/A = get_area(T)
						medbot["name"] = M.name
						medbot["area"] = A.name
						medbot["x"] = T.x
						medbot["y"] = T.y
						medbot["on"] = M.on
						if(!isnull(M.reagent_glass) && M.use_beaker)
							medbot["use_beaker"] = 1
							medbot["total_volume"] = M.reagent_glass.reagents.total_volume
							medbot["maximum_volume"] = M.reagent_glass.reagents.maximum_volume
						else
							medbot["use_beaker"] = 0
						data["medbots"] += list(medbot)

	data["modal"] = ui_modal_data(src)
	return data

/obj/machinery/computer/med_data/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(!GLOB.data_core.general.Find(active1))
		active1 = null
	if(!GLOB.data_core.medical.Find(active2))
		active2 = null

	. = TRUE
	if(ui_act_modal(action, params))
		return
	if(ui_login_act(action, params))
		return

	switch(action)
		if("cleartemp")
			temp = null
		else
			. = FALSE

	if(.)
		return

	if(ui_login_get().logged_in)
		. = TRUE
		switch(action)
			if("screen")
				screen = clamp(text2num(params["screen"]) || 0, MED_DATA_R_LIST, MED_DATA_MEDBOT)
				active1 = null
				active2 = null
			if("vir")
				var/type = text2path(params["vir"] || "")
				if(!ispath(type, /datum/disease))
					return

				var/datum/disease/D = new type(0)
				var/list/payload = list(
					name = D.name,
					max_stages = D.max_stages,
					spread_text = D.spread_text,
					cure = D.cure_text || "None",
					desc = D.desc,
					severity = D.severity
				)
				ui_modal_message(src, "virus", "", null, payload)
				qdel(D)
			if("del_all")
				for(var/datum/data/record/R in GLOB.data_core.medical)
					qdel(R)
				set_temp("All medical records deleted.")
			if("del_r")
				if(active2)
					set_temp("Medical record deleted.")
					qdel(active2)
			if("d_rec")
				var/datum/data/record/general_record = locate(params["d_rec"] || "")
				if(!GLOB.data_core.general.Find(general_record))
					set_temp("Record not found.", "danger")
					return

				var/datum/data/record/medical_record
				for(var/datum/data/record/M in GLOB.data_core.medical)
					if(M.fields["name"] == general_record.fields["name"] && M.fields["id"] == general_record.fields["id"])
						medical_record = M
						break

				active1 = general_record
				active2 = medical_record
				screen = MED_DATA_RECORD
			if("new")
				if(istype(active1, /datum/data/record) && !istype(active2, /datum/data/record))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = "Medical Record #[R.fields["id"]]"
					R.fields["blood_type"] = "Unknown"
					R.fields["b_dna"] = "Unknown"
					R.fields["mi_dis"] = "None"
					R.fields["mi_dis_d"] = "No minor disabilities have been declared."
					R.fields["ma_dis"] = "None"
					R.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
					R.fields["alg"] = "None"
					R.fields["alg_d"] = "No allergies have been detected in this patient."
					R.fields["cdi"] = "None"
					R.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
					R.fields["notes"] = "No notes."
					GLOB.data_core.medical += R
					active2 = R
					screen = MED_DATA_RECORD
					set_temp("Medical record created.", "success")
			if("del_c")
				var/index = text2num(params["del_c"] || "")
				if(!index || !istype(active2, /datum/data/record))
					return

				var/list/comments = active2.fields["comments"]
				index = clamp(index, 1, length(comments))
				if(comments[index])
					comments.Cut(index, index + 1)
			if("search")
				active1 = null
				active2 = null
				var/t1 = lowertext(params["t1"] || "")
				if(!length(t1))
					return

				for(var/datum/data/record/R in GLOB.data_core.medical)
					if(t1 == lowertext(R.fields["name"]) || t1 == lowertext(R.fields["id"]) || t1 == lowertext(R.fields["b_dna"]))
						active2 = R
						break
				if(!active2)
					set_temp("Medical record not found. You must enter the person's exact name, ID or DNA.", "danger")
					return
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == active2.fields["name"] && E.fields["id"] == active2.fields["id"])
						active1 = E
						break
				screen = MED_DATA_RECORD
			if("print_p")
				if(!printing)
					printing = TRUE
					playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
					SStgui.update_uis(src)
					addtimer(CALLBACK(src, .proc/print_finish), 5 SECONDS)
			else
				return FALSE

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/computer/med_data/proc/ui_act_modal(action, params)
	. = TRUE
	var/id = params["id"] // The modal's ID
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
				if("add_c")
					ui_modal_input(src, id, "Please enter your message:")
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

					if(istype(active2) && (field in active2.fields))
						active2.fields[field] = answer
					else if(istype(active1) && (field in active1.fields))
						active1.fields[field] = answer
				if("add_c")
					var/datum/ui_login/state = ui_login_get()
					if(!length(answer) || !istype(active2) || !length(state.name))
						return
					active2.fields["comments"] += list(list(
						header = "Made by [state.name] ([state.name]) on [GLOB.current_date_string] [station_time_timestamp()]",
						text = answer
					))
				else
					return FALSE
		else
			return FALSE

/**
  * Called when the print timer finishes
  */
/obj/machinery/computer/med_data/proc/print_finish()
	var/obj/item/paper/P = new /obj/item/paper(loc)
	P.info = "<center></b>Medical Record</b></center><br>"
	if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
		P.info += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]
		<br>\nSex: [active1.fields["sex"]]
		<br>\nAge: [active1.fields["age"]]
		<br>\nFingerprint: [active1.fields["fingerprint"]]
		<br>\nPhysical Status: [active1.fields["p_stat"]]
		<br>\nMental Status: [active1.fields["m_stat"]]<br>"}
	else
		P.info += "</b>General Record Lost!</b><br>"
	if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
		P.info += {"<br>\n<center></b>Medical Data</b></center>
		<br>\nBlood Type: [active2.fields["blood_type"]]
		<br>\nDNA: [active2.fields["b_dna"]]<br>\n
		<br>\nMinor Disabilities: [active2.fields["mi_dis"]]
		<br>\nDetails: [active2.fields["mi_dis_d"]]<br>\n
		<br>\nMajor Disabilities: [active2.fields["ma_dis"]]
		<br>\nDetails: [active2.fields["ma_dis_d"]]<br>\n
		<br>\nAllergies: [active2.fields["alg"]]
		<br>\nDetails: [active2.fields["alg_d"]]<br>\n
		<br>\nCurrent Diseases: [active2.fields["cdi"]] (per disease info placed in log/comment section)
		<br>\nDetails: [active2.fields["cdi_d"]]<br>\n
		<br>\nImportant Notes:
		<br>\n\t[active2.fields["notes"]]<br>\n
		<br>\n
		<center></b>Comments/Log</b></center><br>"}
		for(var/c in active2.fields["comments"])
			P.info += "[c]<br>"
	else
		P.info += "</b>Medical Record Lost!</b><br>"
	P.info += "</tt>"
	P.name = "paper - 'Medical Record: [active1.fields["name"]]'"
	printing = FALSE
	SStgui.update_uis(src)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger, virus
  */
/obj/machinery/computer/med_data/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/obj/machinery/computer/med_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return ..(severity)

	for(var/datum/data/record/R in GLOB.data_core.medical)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = pick("[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]", "[pick(GLOB.first_names_female)] [pick(GLOB.last_names_female)]")
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["blood_type"] = pick("A-", "B-", "AB-", "O-", "A+", "B+", "AB+", "O+")
				if(5)
					R.fields["p_stat"] = pick("*SSD*", "Active", "Physically Unfit", "Disabled")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/obj/machinery/computer/med_data/ui_login_on_login(datum/ui_login/state)
	active1 = null
	active2 = null
	screen = MED_DATA_R_LIST

/obj/machinery/computer/med_data/laptop
	name = "medical laptop"
	desc = "Cheap Nanotrasen laptop."
	icon_state = "laptop"
	icon_keyboard = "laptop_key"
	icon_screen = "medlaptop"
	density = 0

#undef MED_DATA_R_LIST
#undef MED_DATA_MAINT
#undef MED_DATA_RECORD
#undef MED_DATA_V_DATA
#undef MED_DATA_MEDBOT
#undef FIELD
#undef MED_FIELD
