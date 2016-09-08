//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/secure_data//TODO:SANITY
	name = "security records"
	desc = "Used to view and edit personnel's security records."
	icon_keyboard = "security_key"
	icon_screen = "security"
	req_one_access = list(access_security, access_forensics_lockers)
	circuit = /obj/item/weapon/circuitboard/secure_data
	var/obj/item/weapon/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/datum/data/record/active2 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending

	light_color = LIGHT_COLOR_RED


/obj/machinery/computer/secure_data/attackby(obj/item/O as obj, user as mob, params)
	if(istype(O, /obj/item/weapon/card/id) && !scan)
		usr.drop_item()
		O.loc = src
		scan = O
		to_chat(user, "You insert [O].")
	..()

/obj/machinery/computer/secure_data/attack_ai(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	if(is_away_level(src.z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	var/dat

	// search javascript
	var/head_content = {"
	<script src="libraries.min.js"></script>
	<script type='text/javascript'>

	function updateSearch(){
		var filter_text = document.getElementById('filter');
		var filter = filter_text.value.toLowerCase();

		if(complete_list != null && complete_list != ""){
			var mtbl = document.getElementById("maintable_data_archive");
			mtbl.innerHTML = complete_list;
		}

		if(filter.value == ""){
			return;
		}else{
			$("#maintable_data").children("tbody").children("tr").children("td").children("input").filter(function(index)
			{
				return $(this)\[0\].value.toLowerCase().indexOf(filter) == -1
			}).parent("td").parent("tr").hide()
		}
	}

	function selectTextField(){
		var filter_text = document.getElementById('filter');
		filter_text.focus();
		filter_text.select();
	}

	</script>
"}

	if(temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=[UID()];choice=Clear Screen'>Clear Screen</A>", temp)
	else
		dat = text("Confirm Identity: <A href='?src=[UID()];choice=Confirm Identity'>[]</A><HR>", (scan ? text("[]", scan.name) : "----------"))
		if(authenticated)
			switch(screen)
				if(1.0)

					//body tag start + onload and onkeypress (onkeyup) javascript event calls
					dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

					dat += {"
<p style='text-align:center;'>"}
					dat += "<A href='?src=[UID()];choice=New Record (General)'>New Record</A><BR>"
					//search bar
					dat += {"
						<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
							<tr id='search_tr'>
								<td align='center'>
									<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
								</td>
							</tr>
						</table>
					"}
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>

<span id='maintable_data_archive'>
<table id='maintable_data' style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=[UID()];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=[UID()];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=[UID()];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=[UID()];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
<th>Criminal Status</th>
</tr>"}
					if(!isnull(data_core.general))
						for(var/datum/data/record/R in sortRecord(data_core.general, sortBy, order))
							var/crimstat = ""
							for(var/datum/data/record/E in data_core.security)
								if((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
									crimstat = E.fields["criminal"]
							var/background
							switch(crimstat)
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
								if("")
									background = "''"
									crimstat = "No Record."
							dat += "<tr style=[background]>"
							dat += text("<td><input type='hidden' value='[] [] [] []'></input><A href='?src=[UID()];choice=Browse Record;d_rec=\ref[]'>[]</a></td>", R.fields["name"], R.fields["id"], R.fields["rank"], R.fields["fingerprint"], R, R.fields["name"])
							dat += text("<td>[]</td>", R.fields["id"])
							dat += text("<td>[]</td>", R.fields["rank"])
							dat += text("<td>[]</td>", R.fields["fingerprint"])
							dat += text("<td>[]</td></tr>", crimstat)
						dat += {"
						</table></span>
						<script type='text/javascript'>
							var maintable = document.getElementById("maintable_data_archive");
							var complete_list = maintable.innerHTML;
						</script>
						<hr width='75%' />"}
					dat += "<A href='?src=[UID()];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='?src=[UID()];choice=Log Out'>{Log Out}</A>"
				if(2.0)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=[UID()];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=[UID()];choice=Return'>Back</A>"
				if(3.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						dat += {"
							<table><tr><td>
								Name: <A href='?src=[UID()];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR>
								ID: <A href='?src=[UID()];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>
								Sex: <A href='?src=[UID()];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>
								Age: <A href='?src=[UID()];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>
								Rank: <A href='?src=[UID()];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>
								Fingerprint: <A href='?src=[UID()];choice=Edit Field;field=fingerprint'>[active1.fields["fingerprint"]]</A><BR>
								Physical Status: [active1.fields["p_stat"]]<BR>
								Mental Status: [active1.fields["m_stat"]]<BR>
							</td>
							<td align = center valign = top>
								Photo:<br>
								<img src=[active1.fields["photo-south"]] height=80 width=80 border=4>
								<img src=[active1.fields["photo-west"]] height=80 width=80 border=4><br>
								<a href='?src=[UID()];choice=Print Photo'>Print Photo</a>
							</td></tr></table>"}
					else
						dat += "<B>General Record Lost!</B><BR>"
					if((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=[UID()];choice=Edit Field;field=criminal'>[]</A><BR>\n<BR>\nMinor Crimes: <A href='?src=[UID()];choice=Edit Field;field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=[UID()];choice=Edit Field;field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=[UID()];choice=Edit Field;field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=[UID()];choice=Edit Field;field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=[UID()];choice=Edit Field;field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.fields["criminal"], active2.fields["mi_crim"], active2.fields["mi_crim_d"], active2.fields["ma_crim"], active2.fields["ma_crim_d"], active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=[UID()];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", active2.fields[text("com_[]", counter)], counter)
							counter++
						dat += "<A href='?src=[UID()];choice=Add Entry'>Add Entry</A><BR><BR>"
						dat += "<A href='?src=[UID()];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>"
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += "<A href='?src=[UID()];choice=New Record (Security)'>New Security Record</A><BR><BR>"
					dat += "\n<A href='?src=[UID()];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=[UID()];choice=Print Record'>Print Record</A><BR>\n<A href='?src=[UID()];choice=Return'>Back</A><BR>"
				else
		else
			dat += "<A href='?src=[UID()];choice=Log In'>{Log In}</A>"
	var/datum/browser/popup = new(user, "secure_rec", name, 600, 400)
	popup.set_content(dat)
	popup.add_head_content(head_content)
	popup.open(0)
	onclose(user, "secure_rec")
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return 1
	if(!( data_core.general.Find(active1) ))
		active1 = null
	if(!( data_core.security.Find(active2) ))
		active2 = null
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Confirm Identity")
				if(scan)
					if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
						usr.put_in_hands(scan)
					else
						scan.loc = get_turf(src)
					scan = null
				else
					var/obj/item/I = usr.get_active_hand()
					if(istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						scan = I

			if("Log Out")
				authenticated = null
				screen = null
				active1 = null
				active2 = null

			if("Log In")
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
					src.rank = R.braintype
					src.screen = 1
				else if(istype(scan, /obj/item/weapon/card/id))
					active1 = null
					active2 = null
					if(check_access(scan))
						authenticated = scan.registered_name
						rank = scan.assignment
						screen = 1
//RECORD FUNCTIONS
			if("Record Maintenance")
				screen = 2
				active1 = null
				active2 = null

			if("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if(!( data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
						if((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 3

/*			if("Search Fingerprints")
				var/t1 = input("Search String: (Fingerprint)", "Secure. records", null, null)  as text
				if((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!istype(usr, /mob/living/silicon))))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.general)
					if(lowertext(R.fields["fingerprint"]) == t1)
						active1 = R
				if(!( active1 ))
					temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.security)
						if((E.fields["name"] == active1.fields["name"] || E.fields["id"] == active1.fields["id"]))
							active2 = E
					screen = 3	*/

			if("Print Record")
				if(!( printing ))
					printing = 1
					playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
					if((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"], active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nMajor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.fields["criminal"], active2.fields["mi_crim"], active2.fields["mi_crim_d"], active2.fields["ma_crim"], active2.fields["ma_crim_d"], active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", active2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Security Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "paper - 'Security Record'"
					printing = null

			if("Print Photo")
				if(!printing)
					printing = 1
					playsound(loc, "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
					sleep(50)
					if(istype(active1, /datum/data/record) && data_core.general.Find(active1))
						create_record_photo(active1)
					printing = null

//RECORD DELETE
			if("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Security records?<br>"
				temp += "<a href='?src=[UID()];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=[UID()];choice=Clear Screen'>No</a>"

			if("Purge All Records")
				for(var/datum/data/record/R in data_core.security)
					qdel(R)
				temp = "All Security records deleted."

			if("Add Entry")
				if(!( istype(active2, /datum/data/record) ))
					return
				var/a2 = active2
				var/t1 = copytext(trim(sanitize(input("Add Comment:", "Secure. records", null, null)  as message)),1,MAX_MESSAGE_LEN)
				if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++
				active2.fields[text("com_[counter]")] = text("Made by [authenticated] ([rank]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], 2557<BR>[t1]")

			if("Delete Record (ALL)")
				if(active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=[UID()];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=[UID()];choice=Clear Screen'>No</a>"

			if("Delete Record (Security)")
				if(active2)
					temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
					temp += "<a href='?src=[UID()];choice=Delete Record (Security) Execute'>Yes</a><br>"
					temp += "<a href='?src=[UID()];choice=Clear Screen'>No</a>"

			if("Delete Entry")
				if((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if("New Record (Security)")
				if((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = text("Security Record #[]", R.fields["id"])
					R.fields["criminal"] = "None"
					R.fields["mi_crim"] = "None"
					R.fields["mi_crim_d"] = "No minor crime convictions."
					R.fields["ma_crim"] = "None"
					R.fields["ma_crim_d"] = "No major crime convictions."
					R.fields["notes"] = "No notes."
					data_core.security += R
					active2 = R
					screen = 3

			if("New Record (General)")
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
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

//FIELD FUNCTIONS
			if("Edit Field")
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("name")
						if(istype(active1, /datum/data/record))
							var/t1 = reject_bad_name(input("Please input name:", "Secure. records", active1.fields["name"], null)  as text)
							if((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["id"] = t1
					if("fingerprint")
						if(istype(active1, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null)  as text)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if(istype(active1, /datum/data/record))
							if(active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if(istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("mi_crim")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please input minor crimes list:", "Secure. records", active2.fields["mi_crim"], null)  as text)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["mi_crim"] = t1
					if("mi_crim_d")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please summarize minor crimes:", "Secure. records", active2.fields["mi_crim_d"], null)  as message)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["mi_crim_d"] = t1
					if("ma_crim")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please input major crimes list:", "Secure. records", active2.fields["ma_crim"], null)  as text)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["ma_crim"] = t1
					if("ma_crim_d")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please summarize major crimes:", "Secure. records", active2.fields["ma_crim_d"], null)  as message)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["ma_crim_d"] = t1
					if("notes")
						if(istype(active2, /datum/data/record))
							var/t1 = copytext(html_encode(trim(input("Please summarize notes:", "Secure. records", html_decode(active2.fields["notes"]), null)  as message)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["notes"] = t1
					if("criminal")
						if(istype(active2, /datum/data/record))
							temp = "<h5>Criminal Status:</h5>"
							temp += "<ul>"
							temp += "<li><a href='?src=[UID()];choice=Change Criminal Status;criminal2=none'>None</a></li>"
							temp += "<li><a href='?src=[UID()];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
							temp += "<li><a href='?src=[UID()];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
							temp += "<li><a href='?src=[UID()];choice=Change Criminal Status;criminal2=parolled'>Parolled</a></li>"
							temp += "<li><a href='?src=[UID()];choice=Change Criminal Status;criminal2=released'>Released</a></li>"
							temp += "</ul>"
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in joblist)
								temp += "<li><a href='?src=[UID()];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
					if("species")
						if(istype(active1, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please enter race:", "General records", active1.fields["species"], null)  as message)),1,MAX_MESSAGE_LEN)
							if((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["species"] = t1

//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if("Change Rank")
						if(active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in joblist)
								active1.fields["real_rank"] = href_list["real_rank"]

					if("Change Criminal Status")
						if(active2)
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("arrest")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("parolled")
									active2.fields["criminal"] = "Parolled"
								if("released")
									active2.fields["criminal"] = "Released"

							for(var/mob/living/carbon/human/H in mob_list)
								H.sec_hud_set_security_status()

					if("Delete Record (Security) Execute")
						if(active2)
							qdel(active2)

					if("Delete Record (ALL) Execute")
						if(active1)
							for(var/datum/data/record/R in data_core.medical)
								if((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									qdel(R)
								else
							qdel(active1)
						if(active2)
							qdel(active2)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/secure_data/proc/create_record_photo(datum/data/record/R)
	// basically copy-pasted from the camera code but different enough that it has to be redone
	var/icon/photoimage = get_record_photo(R)
	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

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

	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo(loc)
	Photo.construct(P)

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
					R.fields["name"] = "[pick(pick(first_names_male), pick(first_names_female))] [pick(last_names)]"
				if(2)
					R.fields["sex"]	= pick("Male", "Female")
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
