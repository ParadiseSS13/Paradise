/obj/machinery/computer/telecomms
	req_access = list(ACCESS_TCOMSAT)
	check_access = TRUE
	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitor"
	icon_screen = "comm_logs"


	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/universal_translate = 0 // set to 1 if it can translate nonhuman speech

	circuit = /obj/item/circuitboard/comm_server

/obj/machinery/computer/telecomms/server/attack_hand(mob/user as mob)
	if(..())
		return TRUE
	user.set_machine(src)
	var/list/dat = list()
	dat += "<TITLE>Telecommunication Server Monitor</TITLE><center><b>Telecommunications Server Monitor</b></center>"

	switch(screen)


	  // --- Main Menu ---

		if(0)
			dat += "<br>[temp]<br>"
			dat += "<br>Current Network: <a href='?src=[UID()];network=1'>[network]</a><br>"
			if(servers.len)
				dat += "<br>Detected Telecommunication Servers:<ul>"
				for(var/obj/machinery/telecomms/T in servers)
					dat += "<li><a href='?src=[UID()];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=[UID()];operation=release'>\[Flush Buffer\]</a>"

			else
				dat += "<br>No servers detected. Scan for servers: <a href='?src=[UID()];operation=scan'>\[Scan\]</a>"


	  // --- Viewing Server ---

		if(1)
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=[UID()];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=[UID()];operation=refresh'>\[Refresh\]</a></center>"
			dat += "<br>Current Network: [network]"
			dat += "<br>Selected Server: [SelectedServer.id]"

			if(SelectedServer.totaltraffic >= 1024)
				dat += "<br>Total recorded traffic: [round(SelectedServer.totaltraffic / 1024)] Terrabytes<br><br>"
			else
				dat += "<br>Total recorded traffic: [SelectedServer.totaltraffic] Gigabytes<br><br>"

			dat += "Stored Logs: <ol>"

			var/i = 0
			for(var/datum/comm_log_entry/C in SelectedServer.log_entries)
				i++
				// If the log is a speech file
				if(C.input_type == "Speech File")
					dat += "<li><font color = #008F00>[C.name]</font>  <font color = #FF0000><a href='?src=[UID()];delete=[i]'>\[X\]</a></font><br>"

					// -- If the orator is a human, or universal translate is active, OR mob has universal speech on --

					if(user.say_understands(null, C.parameters["language"]) || universal_translate || C.parameters["uspeech"])
						dat += "<u><font color = #18743E>Data type</font></u>: [C.input_type]<br>"
						dat += "<u><font color = #18743E>Source</font></u>: [C.parameters["name"]] (Job: [C.parameters["job"]])<br>"
						dat += "<u><font color = #18743E>Class</font></u>: [C.parameters["race"]]<br>"
						dat += "<u><font color = #18743E>Contents</font></u>: \"[C.parameters["message"]]\"<br>"


					// -- Orator is not human and universal translate not active --

					else
						dat += "<u><font color = #18743E>Data type</font></u>: Audio File<br>"
						dat += "<u><font color = #18743E>Source</font></u>: <i>Unidentifiable</i><br>"
						dat += "<u><font color = #18743E>Class</font></u>: [C.parameters["race"]]<br>"
						dat += "<u><font color = #18743E>Contents</font></u>: <i>Unintelligble</i><br>"

					dat += "</li><br>"

				else if(C.input_type == "Execution Error")

					dat += "<li><font color = #990000>[C.name]</font>  <font color = #FF0000><a href='?src=[UID()];delete=[i]'>\[X\]</a></font><br>"
					dat += "<u><font color = #787700>Output</font></u>: \"[C.parameters["message"]]\"<br>"
					dat += "</li><br>"


			dat += "</ol>"



	user << browse(dat.Join(""), "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

	temp = ""

/obj/machinery/computer/telecomms/server/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				servers = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("scan")
				if(servers.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font>"

				else
					for(var/obj/machinery/telecomms/server/T in range(25, src))
						if(T.network == network)
							servers.Add(T)

					if(!servers.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font>"
					else
						temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font>"

					screen = 0

	if(href_list["delete"])

		if(!allowed(usr) && !emagged)
			to_chat(usr, "<span class='warning'>ACCESS DENIED.</span>")
			return

		if(SelectedServer)

			var/datum/comm_log_entry/D = SelectedServer.log_entries[text2num(href_list["delete"])]

			temp = "<font color = #336699>- DELETED ENTRY: [D.name] -</font>"

			SelectedServer.log_entries.Remove(D)
			qdel(D)

		else
			temp = "<font color = #D70B00>- FAILED: NO SELECTED MACHINE -</font>"

	if(href_list["network"])

		var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text

		if(newnet && ((usr in range(1, src) || issilicon(usr))))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font>"

			else

				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font>"

	updateUsrDialog()
	return
