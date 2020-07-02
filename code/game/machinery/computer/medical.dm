#define MED_DATA_R_LIST	2	// Record list
#define MED_DATA_MAINT	3	// Records maintenance
#define MED_DATA_RECORD	4	// Record
#define MED_DATA_V_DATA	5	// Virus database
#define MED_DATA_MEDBOT	6	// Medbot monitor

#define FIELD(N, V, Q, QC, E) list(field = N, value = V, question = Q, question_choices = QC, edit = E)
#define MED_FIELD(N, V, Q, QC, E, LB) list(field = N, value = V, question = Q, question_choices = QC, edit = E, line_break = LB)

/obj/machinery/computer/med_data //TODO:SANITY
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_keyboard = "med_key"
	icon_screen = "medcomp"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_FORENSICS_LOCKERS)
	circuit = /obj/item/circuitboard/med_data
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/list/temp = null
	var/printing = null
	var/list/questionmodal = null

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/med_data/Destroy()
	active1 = null
	active2 = null
	return ..()

/obj/machinery/computer/med_data/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id) && !scan)
		usr.drop_item()
		O.forceMove(src)
		scan = O
		tgui_interact(user)
		return
	return ..()

/obj/machinery/computer/med_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/computer/med_data/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MedData", name, 800, 380, master_ui, state)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/med_data/tgui_data(mob/user)
	var/data[0]
	data["temp"] = temp
	data["scan"] = scan ? scan.name : null
	data["authenticated"] = authenticated
	data["screen"] = screen
	data["printing"] = printing
	if(authenticated)
		data["questionmodal"] = questionmodal
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
					fields[++fields.len] = FIELD("Name", active1.fields["name"], null, null, null)
					fields[++fields.len] = FIELD("ID", active1.fields["id"], null, null, null)
					fields[++fields.len] = FIELD("Sex", active1.fields["sex"], "Please input new sex:", list("Male", "Female"), "sex")
					fields[++fields.len] = FIELD("Age", active1.fields["age"], "Please input new age:", null, "age")
					fields[++fields.len] = FIELD("Fingerprint", active1.fields["fingerprint"], "Please input new fingerprint hash:", null, "fingerprint")
					fields[++fields.len] = FIELD("Physical Status", active1.fields["p_stat"], "Please input new physical status:", list("*Deceased*", "*SSD*", "Active", "Physically Unfit", "Disabled"), "p_stat")
					fields[++fields.len] = FIELD("Mental Status", active1.fields["m_stat"], "Please input new mental status:", list("*Insane*", "*Unstable*", "*Watch*", "Stable"), "m_stat")
					var/list/photos = list()
					general["photos"] = photos
					// Disabled for now - ByondGui need improving
					// var/icon/photoSouth = icon(active1.fields["photo-south-icon"])
					// var/icon/photoWest = icon(active1.fields["photo-west-icon"])
					// photoSouth.Scale(128, 128)
					// photoWest.Scale(128, 128)
					// photoSouth = fcopy_rsc(photoSouth)
					// photoWest = fcopy_rsc(photoWest)
					// user << browse_rsc(photoSouth);
					// user << browse_rsc(photoWest);
					// photos[++photos.len] = list("photo" = "\ref[photoSouth]")
					// photos[++photos.len] = list("photo" = "\ref[photoWest]")
					general["has_photos"] = (active1.fields["photo-south"] || active1.fields["photo-west"] ? 1 : 0)
					general["empty"] = 0
				else
					general["empty"] = 1

				var/list/medical = list()
				data["medical"] = medical
				if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
					var/list/fields = list()
					medical["fields"] = fields
					fields[++fields.len] = MED_FIELD("Blood Type", active2.fields["blood_type"], "Please input new blood type:", list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"), "blood_type", FALSE)
					fields[++fields.len] = MED_FIELD("DNA", active2.fields["b_dna"], "Please input new blood type:", null, "b_dna", TRUE)
					fields[++fields.len] = MED_FIELD("Minor Disabilities", active2.fields["mi_dis"], "Please input new minor disabilities:", null, "mi_dis", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["mi_dis_d"], "Please summarize minor disabilities:", null, "mi_dis_d", TRUE)
					fields[++fields.len] = MED_FIELD("Major Disabilities", active2.fields["ma_dis"], "Please input new major disabilities:", null, "ma_dis", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["ma_dis_d"], "Please summarize major disabilities:", null, "ma_dis_d", TRUE)
					fields[++fields.len] = MED_FIELD("Allergies", active2.fields["alg"], "Please input new allergies:", null, "alg", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["alg_d"], "Please summarize allergies:", null, "alg_d", TRUE)
					fields[++fields.len] = MED_FIELD("Current Diseases", active2.fields["cdi"], "Please input new current diseases:", null, "cdi", FALSE)
					fields[++fields.len] = MED_FIELD("Details", active2.fields["cdi_d"], "Please summarize current diseases:", null, "cdi_d", TRUE)
					fields[++fields.len] = MED_FIELD("Important Notes", active2.fields["notes"], "Please input new important notes:", null, "notes", FALSE)
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
	return data

/obj/machinery/computer/med_data/tgui_act(action, params)
	if(..())
		return

	if(!GLOB.data_core.general.Find(active1))
		active1 = null
	if(!GLOB.data_core.medical.Find(active2))
		active2 = null

	switch(action)
		if("cleartemp")
			temp = null
			. = TRUE
		if("scan")
			if(scan)
				scan.forceMove(loc)
				if(ishuman(usr) && !usr.get_active_hand())
					usr.put_in_hands(scan)
				scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id))
					usr.drop_item()
					I.forceMove(src)
					scan = I
			. = TRUE
		if("login")
			if(isAI(usr))
				authenticated = usr.name
				rank = "AI"
			else if(isrobot(usr))
				authenticated = usr.name
				var/mob/living/silicon/robot/R = usr
				rank = "[R.modtype] [R.braintype]"
			else if(istype(scan, /obj/item/card/id))
				if(check_access(scan))
					authenticated = scan.registered_name
					rank = scan.assignment

			if(authenticated)
				active1 = null
				active2 = null
				screen = MED_DATA_R_LIST
				. = TRUE

	if(.)
		return

	if(authenticated)
		switch(action)
			if("logout")
				if(scan)
					scan.forceMove(loc)
					if(ishuman(usr) && !usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				authenticated = null
				screen = null
				active1 = null
				active2 = null
				. = TRUE
			if("screen")
				screen = clamp(text2num(params["screen"]) || MED_DATA_R_LIST, MED_DATA_R_LIST, MED_DATA_MEDBOT)
				active1 = null
				active2 = null
				. = TRUE
			if("vir")
				. = TRUE
				var/type = text2path(params["vir"] || "")
				if(!ispath(type, /datum/disease))
					return

				var/datum/disease/D = new type(0)
				set_temp(list(
					name = D.name,
					max_stages = D.max_stages,
					spread_text = D.spread_text,
					cure = D.cure_text || "None",
					desc = D.desc,
					severity = D.severity
				), "virus")
				qdel(D)
			if("del_all")
				. = TRUE
				for(var/datum/data/record/R in GLOB.data_core.medical)
					qdel(R)
				set_temp("All medical records deleted.")
			if("del_r")
				. = TRUE
				if(active2)
					set_temp("Medical record deleted.")
					qdel(active2)
			if("d_rec")
				. = TRUE
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
					. = TRUE
					set_temp("Medical record created.", "success")
			if("del_c")
				var/index = text2num(params["del_c"] || "")
				if(!index || !istype(active2, /datum/data/record))
					return

				var/list/comments = active2.fields["comments"]
				index = clamp(index, 1, length(comments))
				if(comments[index])
					comments.Cut(index, index + 1)
				. = TRUE
			if("search")
				. = TRUE
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
					sleep(5 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper(loc)
					P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
					if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
						P.info += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]
						<BR>\nSex: [active1.fields["sex"]]
						<BR>\nAge: [active1.fields["age"]]
						<BR>\nFingerprint: [active1.fields["fingerprint"]]
						<BR>\nPhysical Status: [active1.fields["p_stat"]]
						<BR>\nMental Status: [active1.fields["m_stat"]]<BR>"}
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if(istype(active2, /datum/data/record) && GLOB.data_core.medical.Find(active2))
						P.info += {"<BR>\n<CENTER><B>Medical Data</B></CENTER>
						<BR>\nBlood Type: [active2.fields["blood_type"]]
						<BR>\nDNA: [active2.fields["b_dna"]]<BR>\n
						<BR>\nMinor Disabilities: [active2.fields["mi_dis"]]
						<BR>\nDetails: [active2.fields["mi_dis_d"]]<BR>\n
						<BR>\nMajor Disabilities: [active2.fields["ma_dis"]]
						<BR>\nDetails: [active2.fields["ma_dis_d"]]<BR>\n
						<BR>\nAllergies: [active2.fields["alg"]]
						<BR>\nDetails: [active2.fields["alg_d"]]<BR>\n
						<BR>\nCurrent Diseases: [active2.fields["cdi"]] (per disease info placed in log/comment section)
						<BR>\nDetails: [active2.fields["cdi_d"]]<BR>\n
						<BR>\nImportant Notes:
						<BR>\n\t[active2.fields["notes"]]<BR>\n
						<BR>\n
						<CENTER><B>Comments/Log</B></CENTER><BR>"}
						for(var/c in active2.fields["comments"])
							P.info += "[c]<BR>"
					else
						P.info += "<B>Medical Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "paper- 'Medical Record: [active1.fields["name"]]'"
					printing = FALSE
					. = TRUE

		// Modal handling
		if(action == "questionmodal")
			questionmodal = length(params["id"]) && list(
				id = params["id"],
				question = params["question"],
				choices = params["choices"],
				value = params["value"]
			)
			return TRUE
		else if((action == "questionmodal_answer") && questionmodal)
			. = TRUE
			var/id = questionmodal["id"]
			var/answer = params["answer"]
			var/general_data_exist = istype(active1, /datum/data/record)
			var/medical_data_exist = istype(active2, /datum/data/record)

			if(general_data_exist)
				switch(id)
					if("sex")
						active1.fields["sex"] = (answer in list("Male", "Female")) ? answer : active1.fields["sex"]
					if("age")
						var/new_age = text2num(answer)
						if(!new_age || new_age < AGE_MIN || new_age > AGE_MAX)
							set_temp("Invalid age. It must be between [AGE_MIN] and [AGE_MAX].", "danger")
							questionmodal = null
							return
						active1.fields["age"] = new_age
					if("p_stat")
						active1.fields["p_stat"] = (answer in list("*Deceased*", "*SSD*", "Active", "Physically Unfit", "Disabled")) ? answer : active1.fields["p_stat"]
					if("m_stat")
						active1.fields["m_stat"] = (answer in list("*Insane*", "*Unstable*", "*Watch*", "Stable")) ? answer : active1.fields["m_stat"]
					if("fingerprint")
						active1.fields["fingerprint"] = answer
			if(medical_data_exist)
				switch(id)
					if("blood_type")
						active2.fields["blood_type"] = (answer in list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")) ? answer : active2.fields["blood_type"]
					if("add_c")
						if(length(answer))
							active2.fields["comments"] += list(list(
								header = "Made by [authenticated] ([rank]) on [GLOB.current_date_string] [station_time_timestamp()]",
								text = answer
							))
					else // Generic field, no need a specific if for 'em
						if(active2.fields[id])
							active2.fields[id] = answer
			questionmodal = null
			return
		else if(action == "questionmodal_close")
			questionmodal = null
			return TRUE

	// If we're doing an action other than start a question modal, delete the modal
	if(questionmodal)
		questionmodal = null
		return TRUE

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
					R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
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
