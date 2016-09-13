/*
	I hate to make this a todo, but I cannot possibly complete all of computer3
	if I have to rearchitecture datacores and everything else that uses them right now.

	In the future the datacore should probably be a server, perhaps on station, perhaps on centcom,
	with data records as files probably.  It's not difficult unless you're trying to do a million
	impossible things before breakfast.
*/

/obj/machinery/computer3/med_data
	default_prog	= /datum/file/program/med_data
	spawn_parts		= list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/cardslot,/obj/item/part/computer/networking/radio)


/obj/machinery/computer3/laptop/medical
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/cardslot,/obj/item/part/computer/networking/radio)
	spawn_files = list(/datum/file/program/arcade,/datum/file/program/crew,/datum/file/program/med_data)

/datum/file/program/med_data
	name = "Medical Records"
	desc = "This can be used to check medical records."
	active_state = "medcomp"
	req_one_access = list(access_medical, access_forensics_lockers)

	var/obj/item/weapon/card/id/scan = null
	var/obj/item/weapon/card/id/scan2 = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null


	proc/authenticate()
		if(access_medical in scan.access)
			return 1
		if(istype(usr,/mob/living/silicon/ai))
			return 1
		return 0

	interact()
		if(!computer.cardslot)
			computer.Crash(MISSING_PERIPHERAL)
			return
		usr.set_machine(src)
		scan = computer.cardslot.reader
		if(!interactable())
			return
		if(is_away_level(computer.z))
			to_chat(usr, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
			return
		var/dat

		if(temp)
			dat = text("<TT>[src.temp]</TT><BR><BR><A href='?src=[UID()];temp=1'>Clear Screen</A>")
		else
			dat = text("Confirm Identity (R): <A href='?src=[UID()];cardr=1'>[]</A><HR>", (scan ? text("[]", scan.name) : "----------"))
			if(computer.cardslot.dualslot)
				dat += text("Check Identity (W): <A href='?src=[UID()];cardw=1'>[]</A><BR>", (scan2 ? text("[]", scan2.name) : "----------"))
				if(scan2 && !scan)
					dat += text("<div class='notice'>Insert card into reader slot to log in.</div><br>")

			if(src.authenticated)
				switch(src.screen)
					if(1.0)
						dat += {"
<A href='?src=[UID()];search=1'>Search Records</A>
<BR><A href='?src=[UID()];screen=2'>List Records</A>
<BR>
<BR><A href='?src=[UID()];screen=5'>Virus Database</A>
<BR><A href='?src=[UID()];screen=6'>Medbot Tracking</A>
<BR>
<BR><A href='?src=[UID()];screen=3'>Record Maintenance</A>
<BR><A href='?src=[UID()];logout=1'>{Log Out}</A><BR>
"}
					if(2.0)
						dat += "<B>Record List</B>:<HR>"
						if(!isnull(data_core.general))
							for(var/datum/data/record/R in sortRecord(data_core.general))
								dat += text("<A href='?src=[UID()];d_rec=\ref[]'>[]: []<BR>", R, R.fields["id"], R.fields["name"])
								//Foreach goto(132)
						dat += "<HR><A href='?src=[UID()];screen=1'>Back</A>"
					if(3.0)
						dat += "<B>Records Maintenance</B><HR>\n<A href='?src=[UID()];back=1'>Backup To Disk</A><BR>\n<A href='?src=[UID()];u_load=1'>Upload From disk</A><BR>\n<A href='?src=[UID()];del_all=1'>Delete All Records</A><BR>\n<BR>\n<A href='?src=[UID()];screen=1'>Back</A>"
					if(4.0)
						dat += "<CENTER><B>Medical Record</B></CENTER><BR>"
						if((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
							dat += "<table><tr><td>Name: [active1.fields["name"]] \
									ID: [active1.fields["id"]]<BR>\n	\
									Sex: <A href='?src=[UID()];field=sex'>[active1.fields["sex"]]</A><BR>\n	\
									Age: <A href='?src=[UID()];field=age'>[active1.fields["age"]]</A><BR>\n	\
									Fingerprint: <A href='?src=[UID()];field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>\n	\
									Physical Status: <A href='?src=[UID()];field=p_stat'>[active1.fields["p_stat"]]</A><BR>\n	\
									Mental Status: <A href='?src=[UID()];field=m_stat'>[active1.fields["m_stat"]]</A><BR></td><td align = center valign = top> \
									Photo:<br><img src=[active1.fields["photo-south"]] height=64 width=64 border=5> \
									<img src=[active1.fields["photo-west"]] height=64 width=64 border=5></td></tr></table>"
						else
							dat += "<B>General Record Lost!</B><BR>"
						if((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
							dat += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: <A href='?src=[UID()];field=b_type'>[]</A><BR>\nDNA: <A href='?src=[UID()];field=b_dna'>[]</A><BR>\n<BR>\nMinor Disabilities: <A href='?src=[UID()];field=mi_dis'>[]</A><BR>\nDetails: <A href='?src=[UID()];field=mi_dis_d'>[]</A><BR>\n<BR>\nMajor Disabilities: <A href='?src=[UID()];field=ma_dis'>[]</A><BR>\nDetails: <A href='?src=[UID()];field=ma_dis_d'>[]</A><BR>\n<BR>\nAllergies: <A href='?src=[UID()];field=alg'>[]</A><BR>\nDetails: <A href='?src=[UID()];field=alg_d'>[]</A><BR>\n<BR>\nCurrent Diseases: <A href='?src=[UID()];field=cdi'>[]</A> (per disease info placed in log/comment section)<BR>\nDetails: <A href='?src=[UID()];field=cdi_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[UID()];field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src.active2.fields["b_type"], src.active2.fields["b_dna"], src.active2.fields["mi_dis"], src.active2.fields["mi_dis_d"], src.active2.fields["ma_dis"], src.active2.fields["ma_dis_d"], src.active2.fields["alg"], src.active2.fields["alg_d"], src.active2.fields["cdi"], src.active2.fields["cdi_d"], decode(src.active2.fields["notes"]))
							var/counter = 1
							while(src.active2.fields[text("com_[]", counter)])
								dat += text("[]<BR><A href='?src=[UID()];del_c=[]'>Delete Entry</A><BR><BR>", src.active2.fields[text("com_[]", counter)], counter)
								counter++
							dat += "<A href='?src=[UID()];add_c=1'>Add Entry</A><BR><BR>"
							dat += "<A href='?src=[UID()];del_r=1'>Delete Record (Medical Only)</A><BR><BR>"
						else
							dat += "<B>Medical Record Lost!</B><BR>"
							dat += text("<A href='?src=[UID()];new=1'>New Record</A><BR><BR>")
						dat += "\n<A href='?src=[UID()];print_p=1'>Print Record</A><BR>\n<A href='?src=[UID()];screen=2'>Back</A><BR>"
					if(5.0)
						dat += "<CENTER><B>Virus Database</B></CENTER>"
						for(var/Dt in typesof(/datum/disease/))
							var/datum/disease/Dis = new Dt(0)
							if(istype(Dis, /datum/disease/advance))
								continue // TODO (tm): Add advance diseases to the virus database which no one uses.
							if(!Dis.desc)
								continue
							dat += "<br><a href='?src=[UID()];vir=[Dt]'>[Dis.name]</a>"
						dat += "<br><a href='?src=[UID()];screen=1'>Back</a>"
					if(6.0)
						dat += "<center><b>Medical Robot Monitor</b></center>"
						dat += "<a href='?src=[UID()];screen=1'>Back</a>"
						dat += "<br><b>Medical Robots:</b>"
						var/bdat = null
						for(var/mob/living/simple_animal/bot/medbot/M in world)

							if(M.z != computer.z)	continue	//only find medibots on the same z-level as the computer
							var/turf/bl = get_turf(M)
							if(bl)	//if it can't find a turf for the medibot, then it probably shouldn't be showing up
								bdat += "[M.name] - <b>\[[bl.x],[bl.y]\]</b> - [M.on ? "Online" : "Offline"]<br>"
								if((!isnull(M.reagent_glass)) && M.use_beaker)
									bdat += "Reservoir: \[[M.reagent_glass.reagents.total_volume]/[M.reagent_glass.reagents.maximum_volume]\]<br>"
								else
									bdat += "Using Internal Synthesizer.<br>"
						if(!bdat)
							dat += "<br><center>None detected</center>"
						else
							dat += "<br>[bdat]"

					else
			else
				dat += "<A href='?src=[UID()];login=1'>{Log In}</A>"
		popup.width = 600
		popup.height = 400
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))
		popup.open()
		return

	Topic(href, href_list)
		if(!interactable() || !computer.cardslot || ..(href,href_list))
			return
		if(!( data_core.general.Find(src.active1) ))
			src.active1 = null
		if(!( data_core.medical.Find(src.active2) ))
			src.active2 = null

		if(href_list["temp"])
			src.temp = null

		if(href_list["cardr"])
			if(scan)
				if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
					computer.cardslot.remove(1)
				else
					scan.loc = get_turf(src)
				scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					computer.cardslot.insert(I, 1)
					scan = I

		if(href_list["cardw"])
			if(scan2)
				if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
					computer.cardslot.remove(2)
				else
					scan2.loc = get_turf(src)
				scan2 = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					computer.cardslot.insert(I, 2)
					scan2 = I

		else if(href_list["logout"])
			src.authenticated = null
			src.screen = null
			src.active1 = null
			src.active2 = null

		else if(href_list["login"])

			if(istype(usr, /mob/living/silicon/ai))
				src.active1 = null
				src.active2 = null
				src.authenticated = usr.name
				src.rank = "AI"
				src.screen = 1

			else if(istype(usr, /mob/living/silicon/robot))
				src.active1 = null
				src.active2 = null
				src.authenticated = usr.name
				var/mob/living/silicon/robot/R = usr
				src.rank = "[R.modtype] [R.braintype]"
				src.screen = 1

			else if(istype(src.scan, /obj/item/weapon/card/id))
				src.active1 = null
				src.active2 = null

				if(src.check_access(src.scan))
					src.authenticated = src.scan.registered_name
					src.rank = src.scan.assignment
					src.screen = 1

		if(src.authenticated)

			if(href_list["screen"])
				src.screen = text2num(href_list["screen"])
				if(src.screen < 1)
					src.screen = 1

				src.active1 = null
				src.active2 = null

			if(href_list["vir"])
				var/datum/data/record/v = locate(href_list["vir"])
				src.temp = "<center>GNAv2 based virus lifeform V-[v.fields["id"]]</center>"
				src.temp += "<br><b>Name:</b> <A href='?src=[UID()];field=vir_name;edit_vir=\ref[v]'>[v.fields["name"]]</A>"
				src.temp += "<br><b>Antigen:</b> [v.fields["antigen"]]"
				src.temp += "<br><b>Spread:</b> [v.fields["spread type"]] "
				src.temp += "<br><b>Details:</b><br> <A href='?src=[UID()];field=vir_desc;edit_vir=\ref[v]'>[v.fields["description"]]</A>"

			if(href_list["del_all"])
				src.temp = "Are you sure you wish to delete all records?<br>\n\t<A href='?src=[UID()];temp=1;del_all2=1'>Yes</A><br>\n\t<A href='?src=[UID()];temp=1'>No</A><br>"

			if(href_list["del_all2"])
				for(var/datum/data/record/R in data_core.medical)
					//R = null
					qdel(R)
					//Foreach goto(494)
				src.temp = "All records deleted."

			if(href_list["field"])
				var/a1 = src.active1
				var/a2 = src.active2
				switch(href_list["field"])
					if("fingerprint")
						if(istype(src.active1, /datum/data/record))
							var/t1 = trim(sanitize(copytext(input("Please input fingerprint hash:", "Med. records", src.active1.fields["fingerprint"], null)  as text,1,MAX_MESSAGE_LEN)))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["fingerprint"] = t1
					if("sex")
						if(istype(src.active1, /datum/data/record))
							if(src.active1.fields["sex"] == "Male")
								src.active1.fields["sex"] = "Female"
							else
								src.active1.fields["sex"] = "Male"
					if("age")
						if(istype(src.active1, /datum/data/record))
							var/t1 = input("Please input age:", "Med. records", src.active1.fields["age"], null)  as num
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["age"] = t1
					if("mi_dis")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please input minor disabilities list:", "Med. records", src.active2.fields["mi_dis"], null)  as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["mi_dis"] = t1
					if("mi_dis_d")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please summarize minor dis.:", "Med. records", src.active2.fields["mi_dis_d"], null)  as message,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["mi_dis_d"] = t1
					if("ma_dis")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please input major diabilities list:", "Med. records", src.active2.fields["ma_dis"], null) as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["ma_dis"] = t1
					if("ma_dis_d")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please summarize major dis.:", "Med. records", src.active2.fields["ma_dis_d"], null)  as message,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["ma_dis_d"] = t1
					if("alg")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please state allergies:", "Med. records", src.active2.fields["alg"], null)  as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["alg"] = t1
					if("alg_d")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please summarize allergies:", "Med. records", src.active2.fields["alg_d"], null)  as message,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["alg_d"] = t1
					if("cdi")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please state diseases:", "Med. records", src.active2.fields["cdi"], null)  as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["cdi"] = t1
					if("cdi_d")
						if(istype(src.active2, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please summarize diseases:", "Med. records", src.active2.fields["cdi_d"], null)  as message,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["cdi_d"] = t1
					if("notes")
						if(istype(src.active2, /datum/data/record))
							var/t1 = html_encode(trim(copytext(input("Please summarize notes:", "Med. records", html_decode(src.active2.fields["notes"]), null)  as message,1,MAX_MESSAGE_LEN)))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
								return
							src.active2.fields["notes"] = t1
					if("p_stat")
						if(istype(src.active1, /datum/data/record))
							src.temp = "<B>Physical Condition:</B><BR>\n\t<A href='?src=[UID()];temp=1;p_stat=deceased'>*Deceased*</A><BR>\n\t<A href='?src=[UID()];temp=1;p_stat=ssd'>*SSD*</A><BR>\n\t<A href='?src=[UID()];temp=1;p_stat=active'>Active</A><BR>\n\t<A href='?src=[UID()];temp=1;p_stat=unfit'>Physically Unfit</A><BR>\n\t<A href='?src=[UID()];temp=1;p_stat=disabled'>Disabled</A><BR>"
					if("m_stat")
						if(istype(src.active1, /datum/data/record))
							src.temp = "<B>Mental Condition:</B><BR>\n\t<A href='?src=[UID()];temp=1;m_stat=insane'>*Insane*</A><BR>\n\t<A href='?src=[UID()];temp=1;m_stat=unstable'>*Unstable*</A><BR>\n\t<A href='?src=[UID()];temp=1;m_stat=watch'>*Watch*</A><BR>\n\t<A href='?src=[UID()];temp=1;m_stat=stable'>Stable</A><BR>"
					if("b_type")
						if(istype(src.active2, /datum/data/record))
							src.temp = "<B>Blood Type:</B><BR>\n\t<A href='?src=[UID()];temp=1;b_type=an'>A-</A> <A href='?src=[UID()];temp=1;b_type=ap'>A+</A><BR>\n\t<A href='?src=[UID()];temp=1;b_type=bn'>B-</A> <A href='?src=[UID()];temp=1;b_type=bp'>B+</A><BR>\n\t<A href='?src=[UID()];temp=1;b_type=abn'>AB-</A> <A href='?src=[UID()];temp=1;b_type=abp'>AB+</A><BR>\n\t<A href='?src=[UID()];temp=1;b_type=on'>O-</A> <A href='?src=[UID()];temp=1;b_type=op'>O+</A><BR>"
					if("b_dna")
						if(istype(src.active1, /datum/data/record))
							var/t1 = sanitize(copytext(input("Please input DNA hash:", "Med. records", src.active1.fields["dna"], null)  as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							src.active1.fields["dna"] = t1
					if("vir_name")
						var/datum/data/record/v = locate(href_list["edit_vir"])
						if(v)
							var/t1 = sanitize(copytext(input("Please input pathogen name:", "VirusDB", v.fields["name"], null)  as text,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							v.fields["name"] = t1
					if("vir_desc")
						var/datum/data/record/v = locate(href_list["edit_vir"])
						if(v)
							var/t1 = sanitize(copytext(input("Please input information about pathogen:", "VirusDB", v.fields["description"], null)  as message,1,MAX_MESSAGE_LEN))
							if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active1 != a1))
								return
							v.fields["description"] = t1
					else

			if(href_list["p_stat"])
				if(src.active1)
					switch(href_list["p_stat"])
						if("deceased")
							src.active1.fields["p_stat"] = "*Deceased*"
						if("ssd")
							src.active1.fields["p_stat"] = "*SSD*"
						if("active")
							src.active1.fields["p_stat"] = "Active"
						if("unfit")
							src.active1.fields["p_stat"] = "Physically Unfit"
						if("disabled")
							src.active1.fields["p_stat"] = "Disabled"

			if(href_list["m_stat"])
				if(src.active1)
					switch(href_list["m_stat"])
						if("insane")
							src.active1.fields["m_stat"] = "*Insane*"
						if("unstable")
							src.active1.fields["m_stat"] = "*Unstable*"
						if("watch")
							src.active1.fields["m_stat"] = "*Watch*"
						if("stable")
							src.active1.fields["m_stat"] = "Stable"


			if(href_list["b_type"])
				if(src.active2)
					switch(href_list["b_type"])
						if("an")
							src.active2.fields["b_type"] = "A-"
						if("bn")
							src.active2.fields["b_type"] = "B-"
						if("abn")
							src.active2.fields["b_type"] = "AB-"
						if("on")
							src.active2.fields["b_type"] = "O-"
						if("ap")
							src.active2.fields["b_type"] = "A+"
						if("bp")
							src.active2.fields["b_type"] = "B+"
						if("abp")
							src.active2.fields["b_type"] = "AB+"
						if("op")
							src.active2.fields["b_type"] = "O+"


			if(href_list["del_r"])
				if(src.active2)
					src.temp = "Are you sure you wish to delete the record (Medical Portion Only)?<br>\n\t<A href='?src=[UID()];temp=1;del_r2=1'>Yes</A><br>\n\t<A href='?src=[UID()];temp=1'>No</A><br>"

			if(href_list["del_r2"])
				if(src.active2)
					//src.active2 = null
					qdel(src.active2)

			if(href_list["d_rec"])
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/datum/data/record/M = locate(href_list["d_rec"])
				if(!( data_core.general.Find(R) ))
					src.temp = "Record Not Found!"
					return
				for(var/datum/data/record/E in data_core.medical)
					if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
					else
						//Foreach continue //goto(2540)
				src.active1 = R
				src.active2 = M
				src.screen = 4

			if(href_list["new"])
				if((istype(src.active1, /datum/data/record) && !( istype(src.active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record(  )
					R.fields["name"] = src.active1.fields["name"]
					R.fields["id"] = src.active1.fields["id"]
					R.name = text("Medical Record #[]", R.fields["id"])
					R.fields["b_type"] = "Unknown"
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
					data_core.medical += R
					src.active2 = R
					src.screen = 4

			if(href_list["add_c"])
				if(!( istype(src.active2, /datum/data/record) ))
					return
				var/a2 = src.active2
				var/t1 = sanitize(copytext(input("Add Comment:", "Med. records", null, null)  as message,1,MAX_MESSAGE_LEN))
				if((!( t1 ) || !( src.authenticated ) || usr.stat || usr.restrained() || (!interactable() && (!istype(usr, /mob/living/silicon))) || src.active2 != a2))
					return
				var/counter = 1
				while(src.active2.fields[text("com_[]", counter)])
					counter++
				src.active2.fields[text("com_[counter]")] = text("Made by [authenticated] ([rank]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

			if(href_list["del_c"])
				if((istype(src.active2, /datum/data/record) && src.active2.fields[text("com_[]", href_list["del_c"])]))
					src.active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"

			if(href_list["search"])
				var/t1 = input("Search String: (Name, DNA, or ID)", "Med. records", null, null)  as text
				if((!( t1 ) || usr.stat || !( src.authenticated ) || usr.restrained() || ((!interactable()) && (!istype(usr, /mob/living/silicon)))))
					return
				src.active1 = null
				src.active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.medical)
					if((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"]) || t1 == lowertext(R.fields["b_dna"])))
						src.active2 = R
					else
						//Foreach continue //goto(3229)
				if(!( src.active2 ))
					src.temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.general)
						if((E.fields["name"] == src.active2.fields["name"] || E.fields["id"] == src.active2.fields["id"]))
							src.active1 = E
						else
							//Foreach continue //goto(3334)
					src.screen = 4

			if(href_list["print_p"])
				if(!( src.printing ))
					src.printing = 1
					var/datum/data/record/record1 = null
					var/datum/data/record/record2 = null
					if((istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1)))
						record1 = active1
					if((istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2)))
						record2 = active2
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( computer.loc )
					P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
					if(record1)
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", record1.fields["name"], record1.fields["id"], record1.fields["sex"], record1.fields["age"], record1.fields["fingerprint"], record1.fields["p_stat"], record1.fields["m_stat"])
						P.name = text("Medical Record ([])", record1.fields["name"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
						P.name = "Medical Record"
					if(record2)
						P.info += text("<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: []<BR>\nDNA: []<BR>\n<BR>\nMinor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nMajor Disabilities: []<BR>\nDetails: []<BR>\n<BR>\nAllergies: []<BR>\nDetails: []<BR>\n<BR>\nCurrent Diseases: [] (per disease info placed in log/comment section)<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", record2.fields["b_type"], record2.fields["b_dna"], record2.fields["mi_dis"], record2.fields["mi_dis_d"], record2.fields["ma_dis"], record2.fields["ma_dis_d"], record2.fields["alg"], record2.fields["alg_d"], record2.fields["cdi"], record2.fields["cdi_d"], decode(record2.fields["notes"]))
						var/counter = 1
						while(record2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", record2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Medical Record Lost!</B><BR>"
					P.info += "</TT>"
					src.printing = null

		interact()
		return
