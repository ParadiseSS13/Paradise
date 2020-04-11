#define SKILL_DATA_R_LIST	1	// Record list
#define SKILL_DATA_MAINT	2	// Records maintenance
#define SKILL_DATA_RECORD	3	// Record

/obj/machinery/computer/skills//TODO:SANITY
	name = "employment records console"
	desc = "Used to view personnel's employment records"
	icon_state = "laptop"
	icon_keyboard = "laptop_key"
	icon_screen = "medlaptop"
	density = 0
	light_color = LIGHT_COLOR_GREEN
	req_one_access = list(ACCESS_HEADS)
	circuit = /obj/item/circuitboard/skills
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/temp = null
	var/printing = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

/obj/machinery/computer/skills/Destroy()
	active1 = null
	return ..()

/obj/machinery/computer/skills/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/card/id) && !scan)
		user.drop_item()
		O.forceMove(src)
		scan = O
		ui_interact(user)
		return
	return ..()

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/skills/attack_hand(mob/user)
	if(..())
		return
	if(is_away_level(z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/skills/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "skills_data.tmpl", name, 800, 380)
		ui.open()

/obj/machinery/computer/skills/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]
	data["temp"] = temp
	data["scan"] = scan ? scan.name : null
	data["authenticated"] = authenticated
	data["screen"] = screen
	if(authenticated)
		switch(screen)
			if(SKILL_DATA_R_LIST)
				if(!isnull(GLOB.data_core.general))
					for(var/datum/data/record/R in sortRecord(GLOB.data_core.general, sortBy, order))
						data["records"] += list(list("ref" = "\ref[R]", "id" = R.fields["id"], "name" = R.fields["name"], "rank" = R.fields["rank"], "fingerprint" = R.fields["fingerprint"]))
			if(SKILL_DATA_RECORD)
				var/list/general = list()
				data["general"] = general
				if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
					var/list/fields = list()
					general["fields"] = fields
					fields[++fields.len] = list("field" = "Name:", "value" = active1.fields["name"], "name" = "name")
					fields[++fields.len] = list("field" = "ID:", "value" = active1.fields["id"], "name" = "id")
					fields[++fields.len] = list("field" = "Sex:", "value" = active1.fields["sex"], "name" = "sex")
					fields[++fields.len] = list("field" = "Age:", "value" = active1.fields["age"], "name" = "age")
					fields[++fields.len] = list("field" = "Rank:", "value" = active1.fields["rank"], "name" = "rank")
					fields[++fields.len] = list("field" = "Fingerprint:", "value" = active1.fields["fingerprint"], "name" = "fingerprint")
					fields[++fields.len] = list("field" = "Physical Status:", "value" = active1.fields["p_stat"])
					fields[++fields.len] = list("field" = "Mental Status:", "value" = active1.fields["m_stat"])
					general["notes"] = active1.fields["notes"]
					var/list/photos = list()
					general["photos"] = photos
					photos[++photos.len] = list("photo" = active1.fields["photo-south"])
					photos[++photos.len] = list("photo" = active1.fields["photo-west"])
					general["has_photos"] += (active1.fields["photo-south"] || active1.fields["photo-west"] ? 1 : 0)
					general["empty"] = 0
				else
					general["empty"] = 1
	return data

/obj/machinery/computer/skills/Topic(href, href_list)
	if(..())
		return 1

	if(!GLOB.data_core.general.Find(active1))
		active1 = null

	if(href_list["temp"])
		temp = null

	if(href_list["temp_action"])
		var/temp_list = splittext(href_list["temp_action"], "=")
		switch(temp_list[1])
			if("del_all2")
				if(GLOB.PDA_Manifest && GLOB.PDA_Manifest.len)
					GLOB.PDA_Manifest.Cut()
				for(var/datum/data/record/R in GLOB.data_core.security)
					qdel(R)
				setTemp("<h3>All employment records deleted.</h3>")
			if("del_rg2")
				if(active1)
					if(GLOB.PDA_Manifest && GLOB.PDA_Manifest.len)
						GLOB.PDA_Manifest.Cut()
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["name"] == active1.fields["name"] && R.fields["id"] == active1.fields["id"])
							qdel(R)
					QDEL_NULL(active1)
				screen = SKILL_DATA_R_LIST
			if("rank")
				if(active1)
					if(GLOB.PDA_Manifest && GLOB.PDA_Manifest.len)
						GLOB.PDA_Manifest.Cut()
					active1.fields["rank"] = temp_list[2]
					if(temp_list[2] in GLOB.joblist)
						active1.fields["real_rank"] = temp_list[2]

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

		if(authenticated)
			active1 = null
			screen = SKILL_DATA_R_LIST

	if(authenticated)
		var/incapable = (usr.stat || usr.restrained() || (!in_range(src, usr) && !issilicon(usr)))
		if(href_list["logout"])
			authenticated = null
			screen = null
			active1 = null

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
				screen = SKILL_DATA_R_LIST

			active1 = null

		else if(href_list["d_rec"])
			var/datum/data/record/R = locate(href_list["d_rec"])
			if(!GLOB.data_core.general.Find(R))
				setTemp("<h3><span class='bad'>Record not found!</span></h3>")
				return 1
			active1 = R
			screen = SKILL_DATA_RECORD

		else if(href_list["del_all"])
			var/list/buttons = list()
			buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "val" = "del_all2=1", "status" = null)
			buttons[++buttons.len] = list("name" = "No", "icon" = "times", "val" = null, "status" = null)
			setTemp("<h3>Are you sure you wish to delete all employment records?</h3>", buttons)

		else if(href_list["del_rg"])
			if(active1)
				var/list/buttons = list()
				buttons[++buttons.len] = list("name" = "Yes", "icon" = "check", "val" = "del_rg2=1", "status" = null)
				buttons[++buttons.len] = list("name" = "No", "icon" = "times", "val" = null, "status" = null)
				setTemp("<h3>Are you sure you wish to delete the record (ALL)?</h3>", buttons)

		else if(href_list["new_g"])
			if(GLOB.PDA_Manifest.len)
				GLOB.PDA_Manifest.Cut()
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
			GLOB.data_core.general += G
			active1 = G

		else if(href_list["print_r"])
			if(!printing)
				printing = 1
				playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				sleep(50)
				var/obj/item/paper/P = new /obj/item/paper(loc)
				P.info = "<CENTER><B>Employment Record</B></CENTER><BR>"
				if(istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1))
					P.info += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]
							<BR>\nSex: [active1.fields["sex"]]
							<BR>\nAge: [active1.fields["age"]]
							<BR>\nFingerprint: [active1.fields["fingerprint"]]
							<BR>\nPhysical Status: [active1.fields["p_stat"]]
							<BR>\nMental Status: [active1.fields["m_stat"]]
							<BR>\nEmployment/Skills Summary:[active1.fields["notes"]]<BR>"}
				else
					P.info += "<B>General Record Lost!</B><BR>"
				P.info += "</TT>"
				P.name = "paper - 'Employment Record: [active1.fields["name"]]'"
				printing = 0

		if(href_list["field"])
			if(incapable)
				return 1
			var/a1 = active1
			switch(href_list["field"])
				if("name")
					if(istype(active1, /datum/data/record))
						var/t1 = reject_bad_name(clean_input("Please input name:", "Secure. records", active1.fields["name"], null))
						if(!t1 || !length(trim(t1)) || incapable || active1 != a1)
							return 1
						active1.fields["name"] = t1
				if("id")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || incapable || active1 != a1)
							return 1
						active1.fields["id"] = t1
				if("fingerprint")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null) as text)), 1, MAX_MESSAGE_LEN)
						if(!t1 || incapable || active1 != a1)
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
						if(!t1 || incapable || active1 != a1)
							return 1
						active1.fields["age"] = t1
				if("rank")
					var/list/L = list("Head of Personnel", "Captain", "AI")
					//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
					if(istype(active1, /datum/data/record) && L.Find(rank))
						var/list/buttons = list()
						for(var/rank in GLOB.joblist)
							buttons[++buttons.len] = list("name" = rank, "icon" = null, "val" = "rank=[rank]", "status" = (active1.fields["rank"] == rank ? "selected" : null))
						setTemp("<h3>Rank</h3>", buttons)
					else
						setTemp("<span class='bad'>You do not have the required rank to do this!</span>")
				if("species")
					if(istype(active1, /datum/data/record))
						var/t1 = copytext(trim(sanitize(input("Please enter race:", "General records", active1.fields["species"], null) as message)), 1, MAX_MESSAGE_LEN)
						if(!t1 || incapable || active1 != a1)
							return 1
						active1.fields["species"] = t1
	return 1

/obj/machinery/computer/skills/proc/setTemp(text, list/buttons = list())
	temp = list("text" = text, "buttons" = buttons, "has_buttons" = buttons.len > 0)

/obj/machinery/computer/skills/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
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

#undef SKILL_DATA_R_LIST
#undef SKILL_DATA_MAINT
#undef SKILL_DATA_RECORD
