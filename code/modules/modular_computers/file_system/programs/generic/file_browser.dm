/datum/computer_file/program/filemanager
	filename = "filemanager"
	filedesc = "NTOS File Manager"
	extended_desc = "This program allows management of files."
	program_icon_state = "generic"
	size = 8
	requires_ntnet = 0
	available_on_ntnet = 0
	undeletable = 1
	var/open_file
	var/error

/datum/computer_file/program/filemanager/proc/prepare_printjob(t, font = PRINTER_FONT) // Additional stuff to parse if we want to print it and make a happy Head of Personnel. Forms FTW.
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext(t, "\[sign\]", "<span class=\"paper_field\"></span>")
	t = pencode_to_html(t, sign = 0, fields = 0, deffont = font)
	return t

/datum/computer_file/program/filemanager/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "file_manager.tmpl", "NTOS File Manager", 575, 700)
		ui.set_auto_update(1)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/filemanager/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/portable/RHDD = computer.all_components[MC_SDD]
	if(error)
		data["error"] = error
	if(open_file)
		var/datum/computer_file/data/file

		if(!computer || !HDD)
			data["error"] = "I/O ERROR: Unable to access hard drive."
		else
			file = HDD.find_file_by_name(open_file)
			if(!istype(file))
				data["error"] = "I/O ERROR: Unable to open file."
			else
				data["filedata"] = pencode_to_html(file.stored_data, format = 1, sign = 0, fields = 0)
				data["filename"] = "[file.filename].[file.filetype]"
	else
		if(!computer || !HDD)
			data["error"] = "I/O ERROR: Unable to access hard drive."
		else
			var/list/files[0]
			for(var/datum/computer_file/F in HDD.stored_files)
				files.Add(list(list(
					"name" = F.filename,
					"type" = F.filetype,
					"size" = F.size,
					"undeletable" = F.undeletable,
					"encrypted" = !!F.password
				)))
			data["files"] = files
			if(RHDD)
				data["usbconnected"] = 1
				var/list/usbfiles[0]
				for(var/datum/computer_file/F in RHDD.stored_files)
					usbfiles.Add(list(list(
						"name" = F.filename,
						"type" = F.filetype,
						"size" = F.size,
						"undeletable" = F.undeletable,
						"encrypted" = !!F.password
					)))
				data["usbfiles"] = usbfiles

	return data

/datum/computer_file/program/filemanager/Topic(href, list/href_list)
	if(..())
		return 1

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/RHDD = computer.all_components[MC_SDD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]

	switch(href_list["action"])
		if("PRG_openfile")
			. = 1
			var/datum/computer_file/F = HDD.find_file_by_name(href_list["name"])
			if(!F.can_access_file(usr))
				return
			open_file = href_list["name"]
		if("PRG_newtextfile")
			. = 1
			var/newname = stripped_input(usr, "Enter file name or leave blank to cancel:", "File rename", max_length=50)
			if(!newname)
				return 1
			if(!HDD)
				return 1
			var/datum/computer_file/data/F = new/datum/computer_file/data()
			F.filename = newname
			F.filetype = "TXT"
			HDD.store_file(F)
		if("PRG_deletefile")
			. = 1
			if(!HDD)
				return 1
			var/datum/computer_file/file = HDD.find_file_by_name(href_list["name"])
			if(!file || file.undeletable)
				return 1
			HDD.remove_file(file)
		if("PRG_usbdeletefile")
			. = 1
			if(!RHDD)
				return 1
			var/datum/computer_file/file = RHDD.find_file_by_name(href_list["name"])
			if(!file || file.undeletable)
				return 1
			RHDD.remove_file(file)
		if("PRG_closefile")
			. = 1
			open_file = null
			error = null
		if("PRG_clone")
			. = 1
			if(!HDD)
				return 1
			var/datum/computer_file/F = HDD.find_file_by_name(href_list["name"])
			if(!F || !istype(F))
				return 1
			var/newname = stripped_input(usr, "Enter clone file name:", "File clone", "Copy of " + F.filename, max_length=50)
			if(F && newname)
				var/datum/computer_file/C = F.clone(1)
				C.filename = newname
				if(!HDD.store_file(C))
					error = "I/O error: Unable to clone file. Hard drive is probably full."
		if("PRG_rename")
			. = 1
			if(!HDD)
				return 1
			var/datum/computer_file/file = HDD.find_file_by_name(href_list["name"])
			if(!file || !istype(file))
				return 1
			var/newname = stripped_input(usr, "Enter new file name:", "File rename", file.filename, max_length=50)
			if(file && newname)
				file.filename = newname
		if("PRG_edit")
			. = 1
			if(!open_file)
				return 1
			if(!HDD)
				return 1
			var/datum/computer_file/data/F = HDD.find_file_by_name(open_file)
			if(!F || !istype(F))
				return 1
			if(F.do_not_edit && (alert("WARNING: This file is not compatible with editor. Editing it may result in permanently corrupted formatting or damaged data consistency. Edit anyway?", "Incompatible File", "No", "Yes") == "No"))
				return 1
			// 16384 is the limit for file length in characters. Currently, papers have value of 2048 so this is 8 times as long, since we can't edit parts of the file independently.
			var/newtext = stripped_multiline_input(usr, "Editing file [open_file]. You may use most tags used in paper formatting:", "Text Editor", html_decode(F.stored_data), 16384, TRUE)
			if(!newtext)
				return
			if(F)
				var/datum/computer_file/data/backup = F.clone()
				HDD.remove_file(F)
				F = backup.clone() //When the file gets removed from the HDD, it gets queued for garbage collection. Hacky fix is to make a copy.
				F.stored_data = newtext
				F.calculate_size()
				// We can't store the updated file, it's probably too large. Print an error and restore backed up version.
				// This is mostly intended to prevent people from losing texts they spent lot of time working on due to running out of space.
				// They will be able to copy-paste the text from error screen and store it in notepad or something.
				if(!HDD.store_file(F))
					error = "I/O error: Unable to overwrite file. Hard drive is probably full. You may want to backup your changes before closing this window:<br><br>[F.stored_data]<br><br>"
					HDD.store_file(backup)
		if("PRG_printfile")
			. = 1
			if(!open_file)
				return 1
			if(!HDD)
				return 1
			var/datum/computer_file/data/F = HDD.find_file_by_name(open_file)
			if(!F || !istype(F))
				return 1
			if(!printer)
				error = "Missing Hardware: Your computer does not have required hardware to complete this operation."
				return 1
			if(!printer.print_text(prepare_printjob(F.stored_data, computer.emagged ? CRAYON_FONT : PRINTER_FONT), open_file))
				error = "Hardware error: Printer was unable to print the file. It may be out of paper."
				return 1
		if("PRG_copytousb")
			. = 1
			if(!HDD || !RHDD)
				return 1
			var/datum/computer_file/F = HDD.find_file_by_name(href_list["name"])
			if(!F || !istype(F))
				return 1
			var/datum/computer_file/C = F.clone(0)
			RHDD.store_file(C)
		if("PRG_copyfromusb")
			. = 1
			if(!HDD || !RHDD)
				return 1
			var/datum/computer_file/F = RHDD.find_file_by_name(href_list["name"])
			if(!F || !istype(F))
				return 1
			var/datum/computer_file/C = F.clone(0)
			HDD.store_file(C)
		if("PRG_encrypt")
			. = 1
			if(!HDD)
				return 1
			var/datum/computer_file/F = HDD.find_file_by_name(href_list["name"])
			if(!F || F.undeletable)
				return 1
			if(F.password)
				return
			var/new_password = sanitize(input(usr, "Enter an encryption key:", "Encrypt File"))
			if(!new_password)
				to_chat(usr, "<span class='warning'>File not encrypted.</span>")
				return
			F.password=new_password
		if("PRG_decrypt")
			. = 1
			if(!HDD)
				return 1
			var/datum/computer_file/F = HDD.find_file_by_name(href_list["name"])
			if(!F || F.undeletable)
				return 1
			if(F.can_access_file(usr))
				F.password = ""
