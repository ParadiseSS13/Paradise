//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there are two ways around
this dire fate:
- The easiest way is to go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
to have physical access to the other console to send data back. Note: An R&D console is on Centcom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.
- The second method is with Technology Disks and Design Disks. Each of these disks can hold a single technology or design datum in
it's entirety. You can then take the disk to any R&D console and upload it's data to it. This method is a lot more secure (since it
won't update every console in existence) but it's more of a hassle to do. Also, the disks can be stolen.


*/

/obj/machinery/computer/rdconsole
	name = "\improper R&D console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/weapon/circuitboard/rdconsole
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/screen = 1.0	//Which screen is currently showing.

	var/menu = 0 // Current menu.
	var/submenu = 0
	var/wait_message = 0

	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console

	req_access = list(access_tox)	//Data and setting manipulation requires scientist access.

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function

/proc/CallTechName(ID) //A simple helper proc to find the name of a tech with a given ID.
	for(var/T in subtypesof(/datum/tech))
		var/datum/tech/tt = T
		if(initial(tt.id) == ID)
			return initial(tt.name)

/proc/CallMaterialName(ID)
	if(copytext(ID, 1, 2) == "$")
		var/return_name = copytext(ID, 2)
		switch(return_name)
			if("metal")
				return_name = "Metal"
			if("glass")
				return_name = "Glass"
			if("gold")
				return_name = "Gold"
			if("silver")
				return_name = "Silver"
			if("plasma")
				return_name = "Solid Plasma"
			if("uranium")
				return_name = "Uranium"
			if("diamond")
				return_name = "Diamond"
			if("clown")
				return_name = "Bananium"
			if("mime")
				return_name = "Tranquillite"
		return return_name
	else
		for(var/R in subtypesof(/datum/reagent))
			var/datum/reagent/rt = R
			if(initial(rt.id) == ID)
				return initial(rt.name)

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in range(3,src))
		if(!isnull(D.linked_console) || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src
	return

//Have it automatically push research to the centcom server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in world)
		files.push_data(C.files)

/obj/machinery/computer/rdconsole/proc/Maximize()
	files.known_tech=files.possible_tech
	for(var/datum/tech/KT in files.known_tech)
		if(KT.level < KT.max_level)
			KT.level=KT.max_level

/obj/machinery/computer/rdconsole/New()
	..()
	files = new /datum/research(src) //Setup the research data holder.
	matching_designs = list()
	if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in world)
			S.initialize()
			break

/obj/machinery/computer/rdconsole/initialize()
	..()
	SyncRDevices()

/obj/machinery/computer/rdconsole/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/weapon/disk/tech_disk)) t_disk = D
		else if(istype(D, /obj/item/weapon/disk/design_disk)) d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.drop_item())
			return
		D.loc = src
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		..()
	nanomanager.update_uis(src)
	return

/obj/machinery/computer/rdconsole/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		req_access = list()
		emagged = 1
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	if(..())
		return 1

	if(!allowed(usr) && !isobserver(usr))
		return 1

	add_fingerprint(usr)

	usr.set_machine(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		menu = temp_screen
	if(href_list["submenu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["submenu"])
		submenu = temp_screen

	if(href_list["category"])
		var/compare

		matching_designs.Cut()

		if(menu == 4)
			compare = PROTOLATHE
		else
			compare = IMPRINTER

		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(!(D.build_type & compare))
				continue
			if(href_list["category"] in D.category)
				matching_designs.Add(D)
		submenu = 1

		selected_category = "Viewing Category [href_list["category"]]"

	else if(href_list["updt_tech"]) //Update the research holder with information from the technology disk.
		wait_message = "Updating Database...."
		spawn(50)
			wait_message = 0
			files.AddTech2Known(t_disk.stored)
			nanomanager.update_uis(src)
			griefProtection() //Update centcom too

	else if(href_list["clear_tech"]) //Erase data on the technology disk.
		if(t_disk)
			t_disk.wipe_tech()

	else if(href_list["eject_tech"]) //Eject the technology disk.
		if(t_disk)
			t_disk.loc = src.loc
			t_disk = null
		menu = 0
		submenu = 0

	else if(href_list["copy_tech"]) //Copy some technology data from the research holder to the disk.
		// Somehow this href makes me very nervous
		t_disk.stored = files.known_tech[href_list["copy_tech_ID"]]
		menu = 2
		submenu = 0

	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		wait_message = "Updating Database...."
		spawn(50)
			wait_message = 0
			files.AddDesign2Known(d_disk.blueprint)
			nanomanager.update_uis(src)
			griefProtection() //Update centcom too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			d_disk.wipe_blueprint()

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		menu = 0
		submenu = 0

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		// This href ALSO makes me very nervous
		var/datum/design/D = files.known_designs[href_list["copy_design_ID"]]
		if(D)
			// eeeeeep design datums are global be careful!
			var/autolathe_friendly = 1
			for(var/x in D.materials)
				if( !(x in list(MAT_METAL, MAT_GLASS)))
					autolathe_friendly = 0
					D.category -= "Imported"
			if(D.locked)
				autolathe_friendly = 0
				D.category -= "Imported"
			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprint = D
		menu = 2
		submenu = 0

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'> The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				menu = 3

	else if(href_list["maxresearch"]) //Eject the item inside the destructive analyzer.
		if(!check_rights(R_ADMIN))
			return
		wait_message = "Updating Database...."
		if(alert("Are you sure you want to maximize research levels?","Confirmation","Yes","No")=="No")
			return
		log_admin("[key_name(usr)] has maximized the research levels.")
		message_admins("[key_name_admin(usr)] has maximized the research levels.")
		spawn(30)
			Maximize()
			wait_message = ""
			nanomanager.update_uis(src)
			griefProtection() //Update centcomm too

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy) return
				linked_destroy.busy = 1
				wait_message = "Processing and Updating Database..."
				nanomanager.update_uis(src)
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					if(linked_destroy)
						linked_destroy.busy = 0
						if(!linked_destroy.hacked)
							if(!linked_destroy.loaded_item)
								to_chat(usr, "<span class='danger'>The destructive analyzer appears to be empty.</span>")
								wait_message = 0
								menu = 0
								submenu = 0
								return
							if((linked_destroy.loaded_item.reliability >= 99 - (linked_destroy.decon_mod * 3)) || linked_destroy.loaded_item.crit_fail)
								var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
								for(var/T in temp_tech)
									if(prob(linked_destroy.loaded_item.reliability))               //If deconstructed item is not reliable enough its just being wasted, else it is pocessed
										files.UpdateTech(T, temp_tech[T])                          //Check if deconstructed item has research levels higher/same/one less than current ones
								files.UpdateDesigns(linked_destroy.loaded_item, temp_tech, src)    //If if such reseach type found all the known designs are checked for having this research type in them
								wait_message = 0                                                   //If design have it it gains some reliability
								menu = 0
								submenu = 0
							else                                                                   //Same design always gain quality
								wait_message = 0                                                   //Crit fail gives the same design a lot of reliability, like really a lot
								menu = 2
								submenu = 0
							if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
								for(var/material in linked_destroy.loaded_item.materials)
									linked_lathe.materials.insert_amount(min((linked_lathe.materials.max_amount - linked_lathe.materials.total_amount), (linked_destroy.loaded_item.materials[material]*(linked_destroy.decon_mod/10))), material)
							linked_destroy.loaded_item = null
						else
							wait_message = 0
							menu = 0
							submenu = 0
						for(var/obj/I in linked_destroy.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
								var/obj/item/stack/sheet/S = I
								if(S.amount > 1)
									S.amount--
									linked_destroy.loaded_item = S
								else
									qdel(S)
									linked_destroy.icon_state = "d_analyzer"
							else
								if(!(I in linked_destroy.component_parts))
									qdel(I)
									linked_destroy.icon_state = "d_analyzer"
						use_power(250)
						nanomanager.update_uis(src)

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		wait_message = "Updating Database...."
		if(!sync)
			to_chat(usr, "<span class='danger'>You must connect to the network first!</span>")
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in world)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							files.push_data(S.files)
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							S.files.push_data(files)
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat(100)
					wait_message = 0
					nanomanager.update_uis(src)

	else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync

	else if(href_list["build"]) //Causes the Protolathe to build something.
		var/coeff
		if(linked_lathe)
			coeff = linked_lathe.efficiency_coeff
		else
			coeff = 1
		var/g2g = 1
		if(linked_lathe)
			var/datum/design/being_built = files.known_designs[href_list["build"]]
			if(being_built)
				var/power = 2000
				var/amount=text2num(href_list["amount"])
				amount = max(1, min(10, amount))
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] * amount / 5)
				power = max(2000, power)
				wait_message = "Constructing Prototype. Please Wait..."
				if(linked_lathe.busy)
					g2g = 0
				var/key = usr.key	//so we don't lose the info during the spawn delay
				if(!(being_built.build_type & PROTOLATHE))
					g2g = 0
					message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")



				if(g2g) //If input is incorrect, nothing happens
					var/enough_materials = 1
					linked_lathe.busy = 1
					flick("protolathe_n",linked_lathe)
					use_power(power)

					var/list/efficient_mats = list()
					for(var/MAT in being_built.materials)
						efficient_mats[MAT] = being_built.materials[MAT]

					if(!linked_lathe.materials.has_materials(efficient_mats, amount))
						src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough materials to complete prototype.\"</span>")
						enough_materials = 0
						g2g = 0
					else
						for(var/R in being_built.reagents)
							if(!linked_lathe.reagents.has_reagent(R, being_built.reagents[R]))
								src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough reagents to complete prototype.\"</span>")
								enough_materials = 0
								g2g = 0

					if(enough_materials)
						linked_lathe.materials.use_amount(efficient_mats, amount)
						for(var/R in being_built.reagents)
							linked_lathe.reagents.remove_reagent(R, being_built.reagents[R])

					var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
					var/O = being_built.locked

					coeff *= being_built.lathe_time_factor

					spawn(32*amount/coeff)
						if(g2g) //And if we only fail the material requirements, we still spend time and power
							for(var/i = 0, i<amount, i++)
								var/obj/item/new_item = new P(src)
								if( new_item.type == /obj/item/weapon/storage/backpack/holding )
									new_item.investigate_log("built by [key]","singulo")
								new_item.reliability = 100
								if(!istype(new_item, /obj/item/stack/sheet)) // To avoid materials dupe glitches
									new_item.materials = efficient_mats.Copy()
								if(O)
									var/obj/item/weapon/storage/lockbox/L = new/obj/item/weapon/storage/lockbox(linked_lathe.loc)
									new_item.loc = L
									L.name += " ([new_item.name])"
									L.origin_tech = new_item.origin_tech
									L.req_access = being_built.access_requirement
									var/list/lockbox_access
									for(var/A in L.req_access)
										lockbox_access += "[get_access_desc(A)] "
									L.desc = "A locked box. It is locked to [lockbox_access]access."
								else
									new_item.loc = linked_lathe.loc
						linked_lathe.busy = 0
						wait_message = 0
						nanomanager.update_uis(src)

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/coeff = linked_imprinter.efficiency_coeff
		var/g2g = 1
		if(linked_imprinter)
			var/datum/design/being_built = null
			being_built = files.known_designs[href_list["imprint"]]
			if(being_built)
				var/power = 2000
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(2000, power)
				wait_message = "Imprinting Circuit. Please Wait..."
				if(linked_imprinter.busy)
					g2g = 0
				if(!(being_built.build_type & IMPRINTER))
					g2g = 0
					message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")

				if(g2g) //Again, if input is wrong, do nothing
					linked_imprinter.busy = 1
					flick("circuit_imprinter_ani",linked_imprinter)
					use_power(power)

					for(var/M in being_built.materials)
						if(!linked_imprinter.check_mat(being_built, M))
							src.visible_message("<span class='notice'>The [src.name] beeps, \"Not enough materials to complete prototype.\"</span>")
							g2g = 0
							break
						switch(M)
							if(MAT_GLASS)
								linked_imprinter.g_amount = max(0, (linked_imprinter.g_amount-being_built.materials[M]/coeff))
							if(MAT_GOLD)
								linked_imprinter.gold_amount = max(0, (linked_imprinter.gold_amount-being_built.materials[M]/coeff))
							if(MAT_DIAMOND)
								linked_imprinter.diamond_amount = max(0, (linked_imprinter.diamond_amount-being_built.materials[M]/coeff))
							else
								linked_imprinter.reagents.remove_reagent(M, being_built.materials[M]/coeff)

					var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
					spawn(16)
						if(g2g)
							var/obj/item/new_item = new P(src)
							new_item.reliability = 100
							new_item.loc = linked_imprinter.loc
						linked_imprinter.busy = 0
						wait_message = 0
						nanomanager.update_uis(src)

	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["disposeI"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["disposeP"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["lathe_ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets
		if(href_list["lathe_ejectsheet_amt"] == "custom")
			desired_num_sheets = input("How many sheets would you like to eject from the machine?", "How much?", 1) as null|num
			desired_num_sheets = max(0,desired_num_sheets) // If you input too high of a number, the mineral datum will take care of it either way
			if(!desired_num_sheets)
				return
			desired_num_sheets = round(desired_num_sheets) // No partial-sheet goofery
		else
			desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		linked_lathe.materials.retrieve_sheets(desired_num_sheets, href_list["lathe_ejectsheet"])

	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		if(href_list["imprinter_ejectsheet_amt"] == "custom")
			desired_num_sheets = input("How many sheets would you like to eject from the machine?", "How much?", 1) as null|num
			desired_num_sheets = max(0,desired_num_sheets) // for the imprinter they have something hacky, that still will guard against shenanigans. eh
			if(!desired_num_sheets)
				return
			desired_num_sheets = round(desired_num_sheets) // No partial-sheet goofery
		else
			desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		var/res_amount, type
		switch(href_list["imprinter_ejectsheet"])
			if(MAT_GLASS)
				type = /obj/item/stack/sheet/glass
				res_amount = "g_amount"
			if(MAT_GOLD)
				type = /obj/item/stack/sheet/mineral/gold
				res_amount = "gold_amount"
			if(MAT_DIAMOND)
				type = /obj/item/stack/sheet/mineral/diamond
				res_amount = "diamond_amount"
		if(ispath(type) && hasvar(linked_imprinter, res_amount))
			var/obj/item/stack/sheet/sheet = new type(linked_imprinter.loc)
			var/available_num_sheets = round(linked_imprinter.vars[res_amount]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_imprinter.vars[res_amount] = max(0, (linked_imprinter.vars[res_amount]-sheet.amount * sheet.perunit))
			else
				qdel(sheet)

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		wait_message = "Updating Database...."
		spawn(20)
			SyncRDevices()
			wait_message = 0
			nanomanager.update_uis(src)

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null

	else if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "R&D Console Database Reset", "Continue", "Cancel")
		if(choice == "Continue")
			wait_message = "Updating Database...."
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				wait_message = 0
				nanomanager.update_uis(src)

	else if(href_list["search"]) //Search for designs with name matching pattern
		var/compare

		matching_designs.Cut()

		if(menu == 4)
			compare = PROTOLATHE
		else
			compare = IMPRINTER

		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(!(D.build_type & compare))
				continue
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)
		submenu = 1

		selected_category = "Search Results for '[href_list["to_search"]]'"

	nanomanager.update_uis(src)
	return


/obj/machinery/computer/rdconsole/attack_hand(mob/user as mob)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1
	ui_interact(user)

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key="main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/data = list()

	files.RefreshResearch()

	data["menu"] = menu
	data["submenu"] = submenu
	data["wait_message"] = wait_message
	data["src_ref"] = UID()

	data["linked_destroy"] = linked_destroy ? 1 : 0
	data["linked_lathe"] = linked_lathe ? 1 : 0
	data["linked_imprinter"] = linked_imprinter ? 1 : 0
	data["sync"] = sync
	data["admin"] = check_rights(R_ADMIN,0)
	data["disk_type"] = d_disk ? 2 : (t_disk ? 1 : 0)
	data["category"] = selected_category

	if(menu == 0 || menu == 1)
		var/list/tech_levels = list()
		data["tech_levels"] = tech_levels
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			if(T.level <= 0)
				continue
			var/list/this_tech_list = list()
			this_tech_list["name"] = T.name
			this_tech_list["level"] = T.level
			this_tech_list["desc"] = T.desc
			tech_levels[++tech_levels.len] = this_tech_list

	if(menu == 2)

		if(t_disk != null && t_disk.stored != null && submenu == 0) //Technology Disk Menu
			var/list/disk_data = list()
			data["disk_data"] = disk_data
			disk_data["name"] = t_disk.stored.name
			disk_data["level"] = t_disk.stored.level
			disk_data["desc"] = t_disk.stored.desc

		if(t_disk != null && submenu == 1)
			var/list/to_copy = list()
			data["to_copy"] = to_copy
			for(var/v in files.known_tech)
				var/datum/tech/T = files.known_tech[v]
				var/list/item = list()
				to_copy[++to_copy.len] = item
				if(T.level <= 0)
					continue
				item["name"] = T.name
				item["id"] = T.id

		if(d_disk != null && d_disk.blueprint != null && submenu == 0)
			var/list/disk_data = list()
			data["disk_data"] = disk_data
			disk_data["name"] = d_disk.blueprint.name
			disk_data["reliability"] = d_disk.blueprint.reliability
			var/b_type = d_disk.blueprint.build_type
			var/list/lathe_types = list()
			disk_data["lathe_types"] = lathe_types
			if(b_type)
				if(b_type & IMPRINTER) lathe_types += "Circuit Imprinter"
				if(b_type & PROTOLATHE) lathe_types += "Protolathe"
				if(b_type & AUTOLATHE) lathe_types += "Autolathe"
				if(b_type & MECHFAB) lathe_types += "Mech Fabricator"
				if(b_type & PODFAB) lathe_types += "Spacepod Fabricator"
			var/list/materials = list()
			disk_data["materials"] = materials
			for(var/M in d_disk.blueprint.materials)
				var/list/material = list()
				materials[++materials.len] = material
				material["name"] = CallMaterialName(M)
				material["amount"] = d_disk.blueprint.materials[M]

		if(d_disk != null && submenu == 1)
			var/list/to_copy = list()
			data["to_copy"] = to_copy
			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				var/list/item = list()
				to_copy[++to_copy.len] = item
				item["name"] = D.name
				item["id"] = D.id

	if(menu == 3 && linked_destroy && linked_destroy.loaded_item)
		var/list/loaded_item_list = list()
		data["loaded_item"] = loaded_item_list
		loaded_item_list["name"] = linked_destroy.loaded_item.name
		loaded_item_list["reliability"] = linked_destroy.loaded_item.reliability
		var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
		var/list/tech_list = list()
		loaded_item_list["origin_tech"] = tech_list
		for(var/T in temp_tech)
			var/list/tech_item = list()
			tech_list[++tech_list.len] = tech_item
			tech_item["name"] = CallTechName(T)
			tech_item["object_level"] = temp_tech[T]
			for(var/v in files.known_tech)
				var/datum/tech/F = files.known_tech[v]
				if(F.name == CallTechName(T))
					tech_item["current_level"] = F.level
					break

	if(menu == 4 && linked_lathe)
		data["total_materials"] = linked_lathe.materials.total_amount
		data["max_materials"] = linked_lathe.materials.max_amount
		data["total_chemicals"] = linked_lathe.reagents.total_volume
		data["max_chemicals"] = linked_lathe.reagents.maximum_volume
		data["categories"] = linked_lathe.categories
		if(submenu == 1)
			var/list/designs_list = list()
			data["matching_designs"] = designs_list
			for(var/datum/design/D in matching_designs)
				var/list/design_list = list()
				designs_list[++designs_list.len] = design_list
				var/list/materials_list = list()
				design_list["materials"] = materials_list
				design_list["id"] = D.id
				design_list["name"] = sanitize(D.name)
				var/c = 50
				for(var/M in D.materials)
					var/list/material_list = list()
					materials_list[++materials_list.len] = material_list
					material_list["name"] = CallMaterialName(M)
					material_list["amount"] = D.materials[M]
					var/t = linked_lathe.check_mat(D, M)

					if(t < 1)
						material_list["is_red"] = 1
					else
						material_list["is_red"] = 0
					c = min(c, t)

				for(var/R in D.reagents)
					var/list/material_list = list()
					materials_list[++materials_list.len] = material_list
					material_list["name"] = CallMaterialName(R)
					material_list["amount"] = D.reagents[R]
					var/t = linked_lathe.check_mat(D, R)

					if(t < 1)
						material_list["is_red"] = 1
					else
						material_list["is_red"] = 0
					c = min(c, t)
				design_list["can_build"] = c
		if(submenu == 2)
			var/list/materials_list = list()
			data["loaded_materials"] = materials_list
			materials_list[++materials_list.len] = list("name" = "Metal", "id" = MAT_METAL, "amount" = linked_lathe.materials.amount(MAT_METAL))
			materials_list[++materials_list.len] = list("name" = "Glass", "id" = MAT_GLASS, "amount" = linked_lathe.materials.amount(MAT_GLASS))
			materials_list[++materials_list.len] = list("name" = "Gold", "id" = MAT_GOLD, "amount" = linked_lathe.materials.amount(MAT_GOLD))
			materials_list[++materials_list.len] = list("name" = "Silver", "id" = MAT_SILVER, "amount" = linked_lathe.materials.amount(MAT_SILVER))
			materials_list[++materials_list.len] = list("name" = "Plasma", "id" = MAT_PLASMA, "amount" = linked_lathe.materials.amount(MAT_PLASMA))
			materials_list[++materials_list.len] = list("name" = "Uranium", "id" = MAT_URANIUM, "amount" = linked_lathe.materials.amount(MAT_URANIUM))
			materials_list[++materials_list.len] = list("name" = "Diamond", "id" = MAT_DIAMOND, "amount" = linked_lathe.materials.amount(MAT_DIAMOND))
			materials_list[++materials_list.len] = list("name" = "Bananium", "id" = MAT_BANANIUM, "amount" = linked_lathe.materials.amount(MAT_BANANIUM))
			materials_list[++materials_list.len] = list("name" = "Tranquillite", "id" = MAT_TRANQUILLITE, "amount" = linked_lathe.materials.amount(MAT_TRANQUILLITE))
		if(submenu == 3)
			var/list/loaded_chemicals = list()
			data["loaded_chemicals"] = loaded_chemicals
			for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
				var/list/loaded_chemical = list()
				loaded_chemicals[++loaded_chemicals.len] = loaded_chemical
				loaded_chemical["name"] = R.name
				loaded_chemical["volume"] = R.volume
				loaded_chemical["id"] = R.id

	if(menu == 5 && linked_imprinter)
		data["total_materials"] = linked_imprinter.TotalMaterials()
		data["total_chemicals"] = linked_imprinter.reagents.total_volume
		data["categories"] = linked_imprinter.categories
		if(submenu == 1)
			var/list/designs_list = list()
			data["matching_designs"] = designs_list
			var/coeff = linked_imprinter.efficiency_coeff
			for(var/datum/design/D in matching_designs)
				var/list/design_list = list()
				designs_list[++designs_list.len] = design_list
				var/list/materials_list = list()
				design_list["materials"] = materials_list
				design_list["id"] = D.id
				design_list["name"] = sanitize(D.name)
				var/check_materials = 1
				for(var/M in D.materials)
					var/list/material_list = list()
					materials_list[++materials_list.len] = material_list
					material_list["name"] = CallMaterialName(M)
					material_list["amount"] = D.materials[M] / coeff
					if(!linked_imprinter.check_mat(D, M))
						check_materials = 0
						material_list["is_red"] = 1
					else
						material_list["is_red"] = 0
				design_list["can_build"] = check_materials
		if(submenu == 2)
			var/list/materials_list = list()
			data["loaded_materials"] = materials_list
			materials_list[++materials_list.len] = list("name" = "Glass", "id" = MAT_GLASS, "amount" = linked_imprinter.g_amount)
			materials_list[++materials_list.len] = list("name" = "Gold", "id" = MAT_GOLD, "amount" = linked_imprinter.gold_amount)
			materials_list[++materials_list.len] = list("name" = "Diamond", "id" = MAT_DIAMOND, "amount" = linked_imprinter.diamond_amount)
		if(submenu == 3)
			var/list/loaded_chemicals = list()
			data["loaded_chemicals"] = loaded_chemicals
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
				var/list/loaded_chemical = list()
				loaded_chemicals[++loaded_chemicals.len] = loaded_chemical
				loaded_chemical["name"] = R.name
				loaded_chemical["volume"] = R.volume
				loaded_chemical["id"] = R.id

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "r_n_d.tmpl", src.name, 800, 550)
		ui.set_initial_data(data)
		ui.open()

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(var/list/categories, var/menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/dat = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=[UID()];category=[C];menu=[menu_num]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/computer/rdconsole/core
	name = "core R&D console"
	desc = "A console used to interface with R&D tools."
	id = 1

/obj/machinery/computer/rdconsole/robotics
	name = "robotics R&D console"
	desc = "A console used to interface with R&D tools."
	id = 2
	req_access = list(access_robotics)
	circuit = /obj/item/weapon/circuitboard/rdconsole/robotics

/obj/machinery/computer/rdconsole/experiment
	name = "\improper E.X.P.E.R.I-MENTOR R&D console"
	desc = "A console used to interface with R&D tools."
	id = 3
	circuit = /obj/item/weapon/circuitboard/rdconsole/experiment

/obj/machinery/computer/rdconsole/mechanics
	name = "mechanics R&D console"
	desc = "A console used to interface with R&D tools."
	id = 4
	req_access = list(access_mechanic)
	circuit = /obj/item/weapon/circuitboard/rdconsole/mechanics

/obj/machinery/computer/rdconsole/public
	name = "public R&D console"
	desc = "A console used to interface with R&D tools."
	id = 5
	req_access = list()
	circuit = /obj/item/weapon/circuitboard/rdconsole/public
