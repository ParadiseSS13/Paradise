/obj/machinery/computer3/cloning
	default_prog = /datum/file/program/cloning
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/storage/removable,/obj/item/part/computer/networking/prox)

/datum/file/program/cloning
	name = "cloning console"
	desc = "Connects to cloning machinery through the local network."
	active_state = "dna_old"

	req_access = list(access_heads) //Only used for record deletion right now.

	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.

	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp = "Ready to Scan"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/data/record/active_record = null
	var/loading = 0 // Nice loading text
	var/has_disk = 0

	proc/updatemodules()
		if(!computer.net) return

		if(scanner && pod1)
			if(!computer.net.verify_machine(scanner))
				scanner = null
			if(!computer.net.verify_machine(pod1))
				pod1 = null

		if(!scanner || !pod1)
			var/list/nearby = computer.net.get_machines()
			scanner	= locate(/obj/machinery/dna_scannernew) in nearby
			pod1	= locate(/obj/machinery/clonepod) in nearby

		if (pod1)
			pod1.connected = src // Some variable the pod needs

	proc/ScanningMenu()
		if (isnull(scanner))
			return "<font class='bad'>ERROR: No Scanner detected!</font><br>"

		var/dat = "<h3>Scanner Functions</h3>"
		dat += "<div class='statusDisplay'>"

		if (!scanner.occupant)
			dat += "Scanner Unoccupied"
		else if(loading)
			dat += "[scanner.occupant] => Scanning..."
		else
			if (scanner.occupant.ckey != scantemp_ckey)
				scantemp = "Ready to Scan"
				scantemp_ckey = scanner.occupant.ckey
			dat += "[scanner.occupant] => [scantemp]"

		dat += "</div>"

		if (scanner.occupant)
			dat += topic_link(src,"scan","Start Scan") + "<br>"
			if(scanner.locked)
				dat += topic_link(src,"lock","Unlock Scanner")
			else
				dat += topic_link(src,"lock","Lock Scanner")
		else
			dat += fake_link("Start Scan")

		// Footer
		dat += "<h3>Database Functions</h3>"
		if (records.len > 0)
			dat += topic_link(src,"menu=2","View Records ([records.len])") + "<br>"
		else
			dat += fake_link("View Records (0)")

		if (has_disk)
			dat += topic_link(src,"eject_disk","Eject Disk") + "<br>"
		return dat

	proc/RecordsList()
		var/dat = "<h3>Current records</h3>"
		dat += topic_link(src,"menu=1","<< Back") + "<br><br>"
		for(var/datum/data/record/R in records)
			dat += "<h4>[R.fields["name"]]</h4>Scan ID [R.fields["id"]] " + topic_link(src,"view_rec=\ref[R]","View Record")
		return dat

	proc/ShowRecord()
		var/dat = "<h3>Selected Record</h3>"
		dat += topic_link(src,"menu=2","<< Back") + "<br><br>"

		if (!active_record)
			dat += "<font class='bad'>Record not found.</font>"
		else
			dat += "<h4>[active_record.fields["name"]]</h4>"
			dat += "Scan ID [active_record.fields["id"]] [topic_link(src,"clone","Clone")]<br>"

			var/obj/item/weapon/implant/health/H = locate(active_record.fields["imp"])

			if ((H) && (istype(H)))
				dat += "<b>Health Implant Data:</b><br />[H.sensehealth()]<br><br />"
			else
				dat += "<font class='bad'>Unable to locate Health Implant.</font><br /><br />"

			dat += "<b>Unique Identifier:</b><br /><span class='highlight'>[active_record.fields["UI"]]</span><br>"
			dat += "<b>Structural Enzymes:</b><br /><span class='highlight'>[active_record.fields["SE"]]</span><br>"

			if (has_disk)
				dat += "<div class='block'>"
				dat += "<h4>Inserted Disk</h4>"
				dat += "<b>Contents:</b> "
				if (computer.floppy.inserted.files.len == 0)
					dat += "<i>Empty</i>"
				else
					for(var/datum/file/data/genome/G in computer.floppy.inserted.files)
						dat += topic_link(src,"loadfile=\ref[G]","[G.name]") + "<br>"

				dat += "<br /><br /><b>Save to Disk:<b><br />"
				dat += topic_link(src,"save_disk=ue","Unique Identifier + Unique Enzymes") + "<br />"
				dat += topic_link(src,"save_disk=ui","Unique Identifier") + "<br />"
				dat += topic_link(src,"save_disk=se","Structural Enzymes") + "<br />"
				dat += "</div>"

			dat += "<font size=1>[topic_link(src,"del_rec","Delete Record")]</font>"
		return dat
	proc/ConfirmDelete()
		var/dat = "[temp]<br>"
		dat += "<h3>Confirm Record Deletion</h3>"

		dat += "<b>[topic_link(src,"del_rec","Scan card to confirm")]</b><br>"
		dat += "<b>[topic_link(src,"menu=3","Cancel")]</b>"
		return dat

	interact()
		if(!interactable())
			return

		updatemodules()

		var/dat = ""
		dat += topic_link(src,"refresh","Refresh")
		dat += "<h3>Cloning Pod Status</h3>"
		dat += "<div class='statusDisplay'>[temp]&nbsp;</div>"

		has_disk = (computer.floppy && computer.floppy.inserted)
		if(!active_record && menu > 2)
			menu = 2

		switch(menu)
			if(1)
				dat += ScanningMenu()

			if(2)
				dat += RecordsList()

			if(3)
				dat += ShowRecord()

			if(4)
				dat = ConfirmDelete() // not (+=), this is how it used to be, just putting it in a function

		if(!popup)
			popup = new(usr, "\ref[computer]", "Cloning System Control")
			popup.set_title_image(usr.browse_rsc_icon(overlay.icon, overlay.icon_state))

		popup.set_content(dat)
		popup.open()
		return

	Topic(var/href, var/list/href_list)
		if(loading || !interactable())
			return

		if (href_list["menu"])
			menu = text2num(href_list["menu"])
		else if (("scan" in href_list) && !isnull(scanner))
			scantemp = ""

			loading = 1
			computer.updateUsrDialog()

			spawn(20)
				scan_mob(scanner.occupant)

				loading = 0
				computer.updateUsrDialog()


			//No locking an open scanner.
		else if (("lock" in href_list) && !isnull(scanner))
			if ((!scanner.locked) && (scanner.occupant))
				scanner.locked = 1
			else
				scanner.locked = 0

		else if ("view_rec" in href_list)
			active_record = locate(href_list["view_rec"])
			if(istype(active_record,/datum/data/record))
				if ( !active_record.fields["ckey"] || active_record.fields["ckey"] == "" )
					del(active_record)
					temp = "<font class='bad'>Record Corrupt</font>"
				else
					menu = 3
			else
				active_record = null
				temp = "Record missing."

		else if ("del_rec" in href_list)
			if ((!active_record) || (menu < 3))
				return
			if (menu == 3) //If we are viewing a record, confirm deletion
				temp = "Delete record?"
				menu = 4

			else if (menu == 4)
				var/obj/item/weapon/card/id/C = usr.get_active_hand()
				if (istype(C)||istype(C, /obj/item/device/pda))
					if(check_access(C))
						temp = "[active_record.fields["name"]] => Record deleted."
						records.Remove(active_record)
						del(active_record)
						menu = 2
					else
						temp = "<font class='bad'>Access Denied.</font>"

		else if ("eject_disk" in href_list)
			if(computer.floppy)
				computer.floppy.eject_disk()

		else if("loadfile" in href_list)

			var/datum/file/data/genome/G = locate(href_list["loadfile"]) in computer.floppy.files
			if(!istype(G))
				temp = "<font class='bad'>Load error.</font>"
				computer.updateUsrDialog()
				return
			switch(G.type)
				if(/datum/file/data/genome/UI)
					active_record.fields["UI"] = G.content
				if(/datum/file/data/genome/UE)
					active_record.fields["name"] = G.real_name
				if(/datum/file/data/genome/SE)
					active_record.fields["SE"] = G.content
				if(/datum/file/data/genome/cloning)
					active_record = G:record
		else if("savefile" in href_list)
			if (!active_record || !computer || !computer.floppy)
				temp = "<font class='bad'>Save error.</font>"
				computer.updateUsrDialog()
				return
			var/rval = 0
			switch(href_list["save_disk"])
				if("ui")
					var/datum/file/data/genome/UI/ui = new
					ui.content = active_record.fields["UI"]
					ui.real_name = active_record.fields["name"]
					rval = computer.floppy.addfile(ui)
				if("ue")
					var/datum/file/data/genome/UI/UE/ui = new
					ui.content = active_record.fields["UI"]
					ui.real_name = active_record.fields["name"]
					rval = computer.floppy.addfile(ui)
				if("se")
					var/datum/file/data/genome/SE/se = new
					se.content = active_record.fields["SE"]
					se.real_name = active_record.fields["name"]
					rval = computer.floppy.addfile(se)
				if("clone")
					var/datum/file/data/genome/cloning/c = new
					c.record = active_record
					c.real_name = active_record.fields["name"]
					rval = computer.floppy.addfile(c)
			if(!rval)
				temp = "<font class='bad'>Disk write error.</font>"

		else if ("refresh" in href_list)
			computer.updateUsrDialog()

		else if ("clone" in href_list)
			//Look for that player! They better be dead!
			if(active_record)
				//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
				if(!pod1)
					temp = "<font class='bad'>No Clonepod detected.</font>"
				else if(pod1.occupant)
					temp = "<font class='bad'>Clonepod is currently occupied.</font>"
				else if(pod1.mess)
					temp = "<font class='bad'>Clonepod malfunction.</font>"
				else if(!config.revival_cloning)
					temp = "<font class='bad'>Unable to initiate cloning cycle.</font>"
				else if(pod1.growclone(active_record.fields["ckey"], active_record.fields["name"], active_record.fields["UI"], active_record.fields["SE"], active_record.fields["mind"], active_record.fields["mrace"]))
					temp = "[active_record.fields["name"]] => <font class='good'>Cloning cycle in progress...</font>"
					records.Remove(active_record)
					del(active_record)
					menu = 1
				else
					temp = "[active_record.fields["name"]] => <font class='bad'>Initialisation failure.</font>"

			else
				temp = "<font class='bad'>Data corruption.</font>"

		computer.add_fingerprint(usr)
		computer.updateUsrDialog()
		return

	proc/scan_mob(mob/living/carbon/human/subject as mob)
		if ((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna))
			scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
			return
		if (!getbrain(subject))
			scantemp = "<font class='bad'>No signs of intelligence detected.</font>"
			return
		if (subject.suiciding == 1)
			scantemp = "<font class='bad'>Subject's brain is not responding to scanning stimuli.</font>"
			return
		if ((!subject.ckey) || (!subject.client))
			scantemp = "<font class='bad'>Mental interface failure.</font>"
			return
		if (NOCLONE in subject.mutations)
			scantemp = "<font class='bad'>Mental interface failure.</font>"
			return
		if (!isnull(find_record(subject.ckey)))
			scantemp = "<font class='average'>Subject already in database.</font>"
			return

		subject.dna.check_integrity()

		var/datum/data/record/R = new /datum/data/record(  )
		if(subject.dna)
			R.fields["mrace"] = subject.dna.mutantrace
			R.fields["UI"] = subject.dna.uni_identity
			R.fields["SE"] = subject.dna.struc_enzymes
		else
			R.fields["mrace"] = null
			R.fields["UI"] = null
			R.fields["SE"] = null
		R.fields["ckey"] = subject.ckey
		R.fields["name"] = subject.real_name
		R.fields["id"] = copytext(md5(subject.real_name), 2, 6)



		//Add an implant if needed
		var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
		if (isnull(imp))
			imp = new /obj/item/weapon/implant/health(subject)
			imp.implanted = subject
			R.fields["imp"] = "\ref[imp]"
		//Update it if needed
		else
			R.fields["imp"] = "\ref[imp]"

		if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
			R.fields["mind"] = "\ref[subject.mind]"

		records += R
		scantemp = "Subject successfully scanned."

//Find a specific record by key.
	proc/find_record(var/find_key)
		for(var/datum/data/record/R in records)
			if (R.fields["ckey"] == find_key)
				return R
		return null
