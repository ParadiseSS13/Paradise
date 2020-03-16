#define SEC_DATA_R_LIST	1	// Record list
#define SEC_DATA_MAINT	2	// Records maintenance
#define SEC_DATA_RECORD	3	// Record

/obj/machinery/computer/secure_data//TODO:SANITY
	name = "security records"
	desc = "Used to view and edit personnel's security records."
	icon_keyboard = "security_key"
	icon_screen = "security"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = /obj/item/circuitboard/secure_data
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/list/authcard_access = list()
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/temp = null
	var/printing = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/secure_data/Destroy()
	active1 = null
	active2 = null
	return ..()

/obj/machinery/computer/secure_data/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id) && !scan)
		user.drop_item()
		O.forceMove(src)
		scan = O
		ui_interact(user)
		return
	return ..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/secure_data/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "secure_data.tmpl", name, 800, 800)
		ui.open()

/obj/machinery/computer/secure_data/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["temp"] = temp
	data["scan"] = scan ? scan.name : null
	data["authenticated"] = authenticated
	data["screen"] = screen
	if(authenticated)
		switch(screen)
			if(SEC_DATA_R_LIST)
				if(!isnull(data_core.general))
					for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
						var/crimstat = "null"
						for(var/datum/data/record/E in data_core.security)
							if(E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"])
								crimstat = E.fields["criminal"]
								break
						var/background = "''"
						switch(crimstat)
							if("*Execute*")
								background = "'background-color:#5E0A1A'"
							if("*Arrest*")
								background = "'background-color:#890E26'"
							if("Incarcerated")
								background = "'background-color:#743B03'"
							if("Parolled")
								background = "'background-color:#743B03'"
							if("Released")
								background = "'background-color:#216489'"
							if("None")
								background = "'background-color:#007f47'"
							if("null")
								crimstat = "No record."
						data["records"] += list(list("ref" = "\ref[R]", "id" = R.fields["id"], "name" = R.fields["name"], "rank" = R.fields["rank"], "fingerprint" = R.fields["fingerprint"], "background" = background, "crimstat" = crimstat))
			if(SEC_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(istype(active1, /datum/data/record) && data_core.general.Find(active1))
					var/list/fields = list()
					general["fields"] = fields
					fields[++fields.len] = list("field" = "Name:", "value" = active1.fields["name"], "edit" = "name")
					fields[++fields.len] = list("field" = "ID:", "value" = active1.fields["id"], "edit" = "id")
					fields[++fields.len] = list("field" = "Sex:", "value" = active1.fields["sex"], "edit" = "sex")
					fields[++fields.len] = list("field" = "Age:", "value" = active1.fields["age"], "edit" = "age")
					fields[++fields.len] = list("field" = "Rank:", "value" = active1.fields["rank"], "edit" = "rank")
					fields[++fields.len] = list("field" = "Fingerprint:", "value" = active1.fields["fingerprint"], "edit" = "fingerprint")
					fields[++fields.len] = list("field" = "Physical Status:", "value" = active1.fields["p_stat"], "edit" = null)
					fields[++fields.len] = list("field" = "Mental Status:", "value" = active1.fields["m_stat"], "edit" = null)
					var/list/photos = list()
					general["photos"] = photos
					photos[++photos.len] = list("photo" = active1.fields["photo-south"])
					photos[++photos.len] = list("photo" = active1.fields["photo-west"])
					general["has_photos"] += (active1.fields["photo-south"] || active1.fields["photo-west"] ? 1 : 0)
					general["empty"] = 0
				else
					general["empty"] = 1

				var/list/security = list()
				data["security"] = security
				if(istype(active2, /datum/data/record) && data_core.security.Find(active2))
					var/list/fields = list()
					security["fields"] = fields
					fields[++fields.len] = list("field" = "Criminal Status:", "value" = active2.fields["criminal"], "edit" = "criminal", "line_break" = 1)
					fields[++fields.len] = list("field" = "Minor Crimes:", "value" = active2.fields["mi_crim"], "edit" = "mi_crim", "line_break" = 0)
					fields[++fields.len] = list("field" = "Details:", "value" = active2.fields["mi_crim_d"], "edit" = "mi_crim_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Major Crimes:", "value" = active2.fields["ma_crim"], "edit" = "ma_crim", "line_break" = 0)
					fields[++fields.len] = list("field" = "Details:", "value" = active2.fields["ma_crim_d"], "edit" = "ma_crim_d", "line_break" = 1)
					fields[++fields.len] = list("field" = "Important Notes:", "value" = active2.fields["notes"], "edit" = "notes", "line_break" = 0)
					if(!active2.fields["comments"] || !islist(active2.fields["comments"]))
						active2.fields["comments"] = list()
					security["comments"] = active2.fields["comments"]
					security["empty"] = 0
				else
					security["empty"] = 1
	return data

/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return 1

	if(!data_core.general.Find(active1))
		active1 = null
	if(!data_core.security.Find(active2))
		active2 = null

	if(href_list["temp"])
		temp = null

	if(href_list["temp_action"])
		var/temp_href = splittext(href_list["temp_action"], "=")
		switch(temp_href[1])
			if("del_all2")
				for(var/datum/data/record/R in data_core.security)
					qdel(R)
				update_all_mob_security_hud()
				setTemp("<h3>All records deleted.</h3>")
			if("del_alllogs2")
				if(GLOB.cell_logs.len)
					setTemp("<h3>All cell logs deleted.</h3>")
					GLOB.cell_logs.Cut()
				else
					to_chat(usr, "<span class='notice'>Error; No cell logs to delete.</span>")
			if("del_r2")
				if(active2)
					qdel(active2)
					update_all_mob_security_hud()
			if("del_rg2")
				if(active1)
					for(var/datum/data/record/R in data_core.medical)
						if(R.fields["name"] == active1.fields["name"] && R.fields["id"] == active1.fields["id"])
							qdel(R)
					QDEL_NULL(active1)
				QDEL_NULL(active2)
				update_all_mob_security_hud()
				screen = SEC_DATA_R_LIST
			if("criminal")
				if(active2)
					var/t1
					if(temp_href[2] == "execute")
						t1 = copytext(trim(sanitize(input("Explain why they are being executed. Include a list of their crimes, and victims.", "EXECUTION ORDER", null, null) as text)), 1, MAX_MESSAGE_LEN)
					else
						t1 = copytext(trim(sanitize(input("Enter Reason:", "Secure. records", null, null) as text)), 1, MAX_MESSAGE_LEN)
					if(!t1)
						t1 = "(none)"
					if(!set_criminal_status(usr, active2, temp_href[2], t1, rank, authcard_access))
						setTemp("<h3 class='bad'>Error: permission denied.</h3>")
						return 1
			if("rank")
				if(active1)
					active1.fields["rank"] = temp_href[2]
					if(temp_href[2] in GLOB.joblist)
						active1.fields["real_rank"] = temp_href[2]

	if(href_list["scan"])
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

	if(href_list["login"])
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
				authcard_access = scan.access

		if(authenticated)
			active1 = null
			active2 = null
			screen = SEC_DATA_R_LIST

	if(authenticated)
		if(href_list["logout"])
			authenticated = null
			screen = null
			active1 = null
			active2 = null
			authcard_access = list()

		else if(href_list["sort"])
			// Reverse the order if clicked twice
			if(sortBy == href_list["sort"])
				if(order == 1)
					order = -1
				else
					order = 1
			else
				sortBy = href_list["sort"]
				order = initial(order)

		else if(href_list["screen"])
			screen = text2num(href_list["screen"])
			if(screen < 1)
				screen = SEC_DATA_R_LIST

			active1 = null
			active2 = null

		else if(href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			var/datum/data/record/M = locate(href_list["d_rec"])
			if(!data_core.general.Find(R))
				setTemp("<h3 class='bad'>Record not found!</h3>")
				return 1
			for(var/datum/data/record/E in data_core.security)
				if(E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"])
					M = E
			active1 = R
			active2 = M
			screen = SEC_DATA_RECORD

		else if(href_list["del_all"])
			var/list/buttons = list()
			buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "href" = "del_all2=1", "status" = null)
			buttons[++buttons.len] = list("name" = "No", "icon" = "times", "href" = null, "status" = null)
			setTemp("<h3>Are you sure you wish to delete all records?</h3>", buttons)

		else if(href_list["del_alllogs"])
			var/list/buttons = list()
			buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "href" = "del_alllogs2=1", "status" = null)
			buttons[++buttons.len] = list("name" = "No", "icon" = "times", "href" = null, "status" = null)
			setTemp("<h3>Are you sure you wish to delete all cell logs?</h3>", buttons)

		else if(href_list["del_rg"])
			if(active1)
				var/list/buttons = list()
				buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "href" = "del_rg2=1", "status" = null)
				buttons[++buttons.len] = list("name" = "No", "icon" = "times", "href" = null, "status" = null)
				setTemp("<h3>Are you sure you wish to delete the record (ALL)?</h3>", buttons)

		else if(href_list["del_r"])
			if(active1)
				var/list/buttons = list()
				buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "href" = "del_r2=1", "status" = null)
				buttons[++buttons.len] = list("name" = "No", "icon" = "times", "href" = null, "status" = null)
				setTemp("<h3>Are you sure you wish to delete the record (Security Portion Only)?</h3>", buttons)

		else if(href_list["new_s"])
			if(istype(active1, /datum/data/record) && !istype(active2, /datum/data/record))
				var/datum/data/record/R = new /datum/data/record()
				R.fields["name"] = active1.fields["name"]
				R.fields["id"] = active1.fields["id"]
				R.name = "Security Record #[R.fields["id"]]"
				R.fields["criminal"] = "None"
				R.fields["mi_crim"] = "None"
				R.fields["mi_crim_d"] = "No minor crime convictions."
				R.fields["ma_crim"] = "None"
				R.fields["ma_crim_d"] = "No major crime convictions."
				R.fields["notes"] = "No notes."
				data_core.security += R
				active2 = R
				screen = SEC_DATA_RECORD

		else if(href_list["new_g"])
			var/datum/data/record/G = new /datum/data/record()
			G.fields["name"] = "New Record"
			G.fields["id"] = "[add_zero(num2hex(rand(1, 1.6777215E7)), 6)]"
			G.fields["rank"] = "Unassigned"
			G.fields["real_rank"] = "Unassigned"
			G.fields["sex"] = "Male"
			G.fields["age"] = "Unknown"
			G.fields["fingerprint"] = "Unknown"
			G.fields["p_stat"] = "Active"
			G.fields["m_stat"] = "Stable"
			G.fields["species"] = "Human"
			data_core.general += G
			active1 = G
			active2 = null

		else if(href_list["print_r"])
			if(!printing)
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper(loc)
				P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
				if(istype(active1, /datum/data/record) && data_core.general.Find(active1))
					P.info += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]
							<BR>\nSex: [active1.fields["sex"]]
							<BR>\nAge: [active1.fields["age"]]
							<BR>\nFingerprint: [active1.fields["fingerprint"]]
							<BR>\nPhysical Status: [active1.fields["p_stat"]]
							<BR>\nMental Status: [active1.fields["m_stat"]]<BR>"}
				else
					P.info += "<B>General Record Lost!</B><BR>"
				if(istype(active2, /datum/data/record) && data_core.security.Find(active2))
					P.info += {"<BR>\n<CENTER><B>Security Data</B></CENTER>
					<BR>\nCriminal Status: [active2.fields["criminal"]]<BR>\n
					<BR>\nMinor Crimes: [active2.fields["mi_crim"]]
					<BR>\nDetails: [active2.fields["mi_crim_d"]]<BR>\n
					<BR>\nMajor Crimes: [active2.fields["ma_crim"]]
					<BR>\nDetails: [active2.fields["ma_crim_d"]]<BR>\n
					<BR>\nImportant Notes:
					<BR>\n\t[active2.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"}
					for(var/c in active2.fields["comments"])
						P.info += "[c]<BR>"
				else
					P.info += "<B>Security Record Lost!</B><BR>"
				P.info += "</TT>"
				P.name = "paper - 'Security Record: [active1.fields["name"]]'"
				printing = 0

/* Removed due to BYOND issue
		else if(href_list["print_p"])
			if(!printing)
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				sleep(50)
				if(istype(active1, /datum/data/record) && data_core.general.Find(active1))
					create_record_photo(active1)
				printing = 0
*/

		else if(href_list["printlogs"])
			if(GLOB.cell_logs.len && !printing)
				var/obj/item/paper/P = input(usr, "Select log to print", "Available Cell Logs") as null|anything in GLOB.cell_logs
				if(!P)
					return 0
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				to_chat(usr, "<span class='notice'>Printing file [P.name].</span>")
				sleep(50)
				var/obj/item/paper/log = new /obj/item/paper(loc)
				log.name = P.name
				log.info = P.info
				printing = 0
				return 1
			else
				to_chat(usr, "<span class='notice'>[src] has no logs stored or is already printing.</span>")


		else if(href_list["add_c"])
			if(istype(active2, /datum/data/record))
				var/a2 = active2
				var/t1 = copytext(trim(sanitize(input("Add Comment:", "Secure. records", null, null) as message)), 1, MAX_MESSAGE_LEN)
				if(!t1 || ..() || active2 != a2)
					return 1
				active2.fields["comments"] += "Made by [authenticated] ([rank]) on [current_date_string] [station_time_timestamp()]<BR>[t1]"

		else if(href_list["del_c"])
			var/index = min(max(text2num(href_list["del_c"]) + 1, 1), length(active2.fields["comments"]))
			if(istype(active2, /datum/data/record) && active2.fields["comments"][index])
				active2.fields["comments"] -= active2.fields["comments"][index]

		if(href_list["field"])
			if(..())
				return 1
			var/a1 = active1
			var/a2 = active2
			switch(href_list["field"])
				if("name")
					if(istype(active1, /datum/data/record))
						var/t1 = reject_bad_name(clean_input("Please input name:", "Secure. records", active1.fields["name"], null))
						if(!t1 || !length(trim(t1)) || ..() || active1 != a1)
							return 1
						active1.fields["name"] = t1
						if(istype(active2, /datum/data/record))
							active2.fields["name"] = t1
				if("id")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["id"] = t1
						if(istype(active2, /datum/data/record))
							active2.fields["id"] = t1
				if("fingerprint")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["fingerprint"] = t1
				if("sex")
					if(istype(active1, /datum/data/record))
						if(active1.fields["sex"] == "Male")
							active1.fields["sex"] = "Female"
						else
							active1.fields["sex"] = "Male"
				if("age")
					if(istype(active1, /datum/data/record))
						var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null) as num
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["age"] = t1
				if("mi_crim")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input minor crimes list:", "Secure. records", active2.fields["mi_crim"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["mi_crim"] = t1
				if("mi_crim_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please summarize minor crimes:", "Secure. records", active2.fields["mi_crim_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["mi_crim_d"] = t1
				if("ma_crim")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input major crimes list:", "Secure. records", active2.fields["ma_crim"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["ma_crim"] = t1
				if("ma_crim_d")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please summarize major crimes:", "Secure. records", active2.fields["ma_crim_d"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["ma_crim_d"] = t1
				if("notes")
					if(istype(active2, /datum/data/record))
						var/t1 = copytext(html_encode(trim(input("Please summarize notes:", "Secure. records", html_decode(active2.fields["notes"]), null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active2 != a2)
							return 1
						active2.fields["notes"] = t1
				if("criminal")
					if(istype(active2, /datum/data/record))
						var/list/buttons = list()
						buttons[++buttons.len] = list("name" = "None", "icon" = "unlock", "href" = "criminal=none", "status" = (active2.fields["criminal"] == "None" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "*Arrest*", "icon" = "lock", "href" = "criminal=arrest", "status" = (active2.fields["criminal"] == "*Arrest*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Incarcerated", "icon" = "lock", "href" = "criminal=incarcerated", "status" = (active2.fields["criminal"] == "Incarcerated" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "*Execute*", "icon" = "lock", "href" = "criminal=execute", "status" = (active2.fields["criminal"] == "*Execute*" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Parolled", "icon" = "unlock-alt", "href" = "criminal=parolled", "status" = (active2.fields["criminal"] == "Parolled" ? "selected" : null))
						buttons[++buttons.len] = list("name" = "Released", "icon" = "unlock", "href" = "criminal=released", "status" = (active2.fields["criminal"] == "Released" ? "selected" : null))
						setTemp("<h3>Criminal Status</h3>", buttons)
				if("rank")
					var/list/L = list("Head of Personnel", "Captain", "AI")
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if(istype(active1, /datum/data/record) && L.Find(rank))
						var/list/buttons = list()
						for(var/rank in GLOB.joblist)
							buttons[++buttons.len] = list("name" = rank, "icon" = null, "href" = "rank=[rank]", "status" = (active1.fields["rank"] == rank ? "selected" : null))
						setTemp("<h3>Rank</h3>", buttons)
					else
						setTemp("<h3 class='bad'>You do not have the required rank to do this!</h3>")
				if("species")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please enter race:", "General records", active1.fields["species"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || ..() || active1 != a1)
							return 1
						active1.fields["species"] = t1
	return 1

/obj/machinery/computer/secure_data/proc/setTemp(text, list/buttons = list())
	temp = list("text" = text, "buttons" = buttons, "has_buttons" = buttons.len > 0)

/* Proc disabled due to BYOND Issue

/obj/machinery/computer/secure_data/proc/create_record_photo(datum/data/record/R)
	// basically copy-pasted from the camera code but different enough that it has to be redone
	var/icon/photoimage = get_record_photo(R)
	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img, ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img, ICON_OVERLAY, 12, 19)

	var/datum/picture/P = new()
	P.fields["name"] = "File Photo - [R.fields["name"]]"
	P.fields["author"] = "Central Command"
	P.fields["icon"] = ic
	P.fields["tiny"] = pc
	P.fields["img"] = photoimage
	P.fields["desc"] = "You can see [R.fields["name"]] on the photo."
	P.fields["pixel_x"] = rand(-10, 10)
	P.fields["pixel_y"] = rand(-10, 10)
	P.fields["size"] = 2

	var/obj/item/photo/PH = new/obj/item/photo(loc)
	PH.construct(P)

*/

/obj/machinery/computer/secure_data/proc/get_record_photo(datum/data/record/R)
	// similar to the code to make a photo, but of course the actual rendering is completely different
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	// will be 2x2 to fit the 2 directions
	res.Scale(2 * 32, 2 * 32)
	// transparent background (it's a plastic transparency, you see) with the front and side icons
	res.Blend(icon(R.fields["photo"], dir = SOUTH), ICON_OVERLAY, 1, 17)
	res.Blend(icon(R.fields["photo"], dir = WEST), ICON_OVERLAY, 33, 17)

	return res

/obj/machinery/computer/secure_data/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Parolled", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			qdel(R)
			continue

	..(severity)

/obj/machinery/computer/secure_data/detective_computer
	icon = 'icons/obj/computer.dmi'
	icon_state = "messyfiles"

/obj/machinery/computer/secure_data/laptop
	name = "security laptop"
	desc = "Nanotrasen Security laptop. Bringing modern compact computing to this century!"
	icon_state = "laptop"
	icon_keyboard = "seclaptop_key"
	icon_screen = "seclaptop"
	density = 0

#undef SEC_DATA_R_LIST
#undef SEC_DATA_MAINT
#undef SEC_DATA_RECORD
