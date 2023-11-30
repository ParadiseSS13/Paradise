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

// Who likes #defines?
// I don't!
// but I gotta add 'em anyways because we have a bias against /const statements for some reason
#define TECH_UPDATE_DELAY 50
#define DESIGN_UPDATE_DELAY 50
#define PROTOLATHE_CONSTRUCT_DELAY 32
#define SYNC_RESEARCH_DELAY 30
#define DECONSTRUCT_DELAY 24
#define SYNC_DEVICE_DELAY 20
#define RESET_RESEARCH_DELAY 20
#define IMPRINTER_DELAY 16

// SUBMENU_MAIN also used by other menus
// MENU_LEVELS is not accessible normally
#define MENU_MAIN 0
#define MENU_LEVELS 1
#define MENU_DISK 2
#define MENU_DESTROY 3
#define MENU_LATHE 4
#define MENU_IMPRINTER 5
#define MENU_SETTINGS 6
#define SUBMENU_MAIN 0
#define SUBMENU_DISK_COPY 1
#define SUBMENU_LATHE_CATEGORY 1
#define SUBMENU_LATHE_MAT_STORAGE 2
#define SUBMENU_LATHE_CHEM_STORAGE 3
#define SUBMENU_SETTINGS_DEVICES 1

#define BUILD_POWER 2000
#define DECONSTRUCT_POWER 250

/obj/machinery/computer/rdconsole
	name = "\improper R&D console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdconsole
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/menu = MENU_MAIN
	var/submenu = SUBMENU_MAIN
	var/wait_message = 0
	var/wait_message_timer = 0

	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = TRUE		//If sync if FALSE, it doesn't show up on Server Control Console
	///Range to search for rnd devices in proximity to console
	var/range = 3

	req_access = list(ACCESS_TOX)	//Data and setting manipulation requires scientist access.

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
			if("titanium")
				return_name = "Titanium"
			if("bluespace")
				return_name = "Bluespace Mesh"
			if("plastic")
				return_name = "Plastic"
		return return_name
	else
		for(var/R in subtypesof(/datum/reagent))
			var/datum/reagent/rt = R
			if(initial(rt.id) == ID)
				return initial(rt.name)

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in range(range, src))
		if(!isnull(D.linked_console) || D.panel_open)
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

//Have it automatically push research to the centcom server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in GLOB.machines)
		files.push_data(C.files)

/obj/machinery/computer/rdconsole/proc/Maximize()
	for(var/datum/tech/T in files.possible_tech)
		files.known_tech[T.id] = T
	for(var/v in files.known_tech)
		var/datum/tech/KT = files.known_tech[v]
		KT.level = 8
	files.RefreshResearch()

/obj/machinery/computer/rdconsole/Initialize(mapload)
	. = ..()
	files = new /datum/research(src) //Setup the research data holder.
	matching_designs = list()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	QDEL_NULL(files)
	QDEL_NULL(t_disk)
	QDEL_NULL(d_disk)
	matching_designs.Cut()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null

	if(wait_message_timer)
		deltimer(wait_message_timer)
		wait_message_timer = 0
	return ..()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(obj/item/D as obj, mob/user as mob, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/disk/tech_disk)) t_disk = D
		else if(istype(D, /obj/item/disk/design_disk)) d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.drop_item())
			return
		D.loc = src
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		..()
	SStgui.update_uis(src)
	return

/obj/machinery/computer/rdconsole/emag_act(user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		req_access = list()
		emagged = TRUE
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/obj/machinery/computer/rdconsole/proc/valid_nav(next_menu, next_submenu)
	switch(next_menu)
		if(MENU_MAIN, MENU_LEVELS, MENU_DESTROY)
			return next_submenu in list(SUBMENU_MAIN)
		if(MENU_DISK)
			return next_submenu in list(SUBMENU_MAIN, SUBMENU_DISK_COPY)
		if(MENU_LATHE, MENU_IMPRINTER)
			return next_submenu in list(SUBMENU_MAIN, SUBMENU_LATHE_CATEGORY, SUBMENU_LATHE_MAT_STORAGE, SUBMENU_LATHE_CHEM_STORAGE)
		if(MENU_SETTINGS)
			return next_submenu in list(SUBMENU_MAIN, SUBMENU_SETTINGS_DEVICES)
	return FALSE

/obj/machinery/computer/rdconsole/proc/prompt_eject_sheets(obj/machinery/r_n_d/machine, material_id, amount)
	if(!machine)
		return
	if(!(material_id in machine.materials.materials))
		return

	var/desired_num_sheets = 0
	if(amount == "custom")
		desired_num_sheets = input("How many sheets would you like to eject from the machine?", "How much?", 1) as null|num
		if(isnull(desired_num_sheets))
			desired_num_sheets = 0
	else
		desired_num_sheets = text2num(amount)

	desired_num_sheets = max(0, round(desired_num_sheets)) // If you input too high of a number, the mineral datum will take care of it either way
	if(desired_num_sheets)
		machine.materials.retrieve_sheets(desired_num_sheets, material_id)



/obj/machinery/computer/rdconsole/proc/update_from_disk()
	clear_wait_message()
	if(d_disk && d_disk.blueprint)
		files.AddDesign2Known(d_disk.blueprint)
	else if(t_disk && t_disk.stored)
		files.AddTech2Known(t_disk.stored)
	SStgui.update_uis(src)
	griefProtection() //Update centcom too

/obj/machinery/computer/rdconsole/proc/sync_research()
	if(!sync)
		return
	var/list/temp_unblacklist = files.unblacklisted_designs
	files.unblacklisted_designs = list() //Remove this asap, else it will stick around
	clear_wait_message()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		var/server_processed = FALSE

		if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
			S.files.blacklisted_designs -= temp_unblacklist
			files.push_data(S.files)
			server_processed = TRUE

		if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)))
			S.files.push_data(files)
			server_processed = TRUE

		if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
			S.produce_heat(100)

	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/reset_research()
	qdel(files)
	files = new /datum/research(src)
	clear_wait_message()
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	clear_wait_message()
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/start_destroyer(mob/user)
	if(!linked_destroy)
		return

	if(linked_destroy.busy)
		to_chat(user, "<span class='danger'>[linked_destroy] is busy at the moment.</span>")
		return

	if(!linked_destroy.loaded_item)
		to_chat(user, "<span class='danger'>[linked_destroy] appears to be empty.</span>")
		return

	var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
	var/pointless = FALSE

	for(var/T in temp_tech)
		if(files.IsTechHigher(T, temp_tech[T]))
			pointless = TRUE
			break

	if(!pointless)
		var/choice = input("This item does not raise tech levels. Proceed destroying loaded item anyway?") in list("Proceed", "Cancel")
		if(choice == "Cancel" || !linked_destroy)
			return

	linked_destroy.busy = TRUE
	add_wait_message("Processing and Updating Database...", DECONSTRUCT_DELAY)
	flick("d_analyzer_process", linked_destroy)
	addtimer(CALLBACK(src, PROC_REF(finish_destroyer), user, temp_tech), DECONSTRUCT_DELAY)

// Sends salvaged materials to a linked protolathe, if any.
/obj/machinery/computer/rdconsole/proc/send_mats()
	if(!linked_lathe || !linked_destroy || !linked_destroy.loaded_item)
		return

	for(var/material in linked_destroy.loaded_item.materials)
		var/space = linked_lathe.materials.max_amount - linked_lathe.materials.total_amount
		// as item rating increases, amount salvageable increases
		var/salvageable = linked_destroy.loaded_item.materials[material] * (linked_destroy.decon_mod / 10)
		// but you shouldn't salvage more than the raw materials amount
		var/available = linked_destroy.loaded_item.materials[material]
		var/can_insert = min(space, salvageable, available)
		linked_lathe.materials.insert_amount(can_insert, material)

/obj/machinery/computer/rdconsole/proc/finish_destroyer(mob/user, list/temp_tech)
	clear_wait_message()
	if(!linked_destroy || !temp_tech)
		return

	if(!linked_destroy.loaded_item)
		to_chat(user, "<span class='danger'>[linked_destroy] appears to be empty.</span>")
	else
		for(var/T in temp_tech)
			files.UpdateTech(T, temp_tech[T])
		send_mats()
		linked_destroy.loaded_item = null

	for(var/obj/I in linked_destroy.contents)
		for(var/mob/M in I.contents)
			M.death()
		if(istype(I, /obj/item/stack))//Only deconstructs one item in a stack at a time instead of the entire stack
			var/obj/item/stack/S = I
			if(S.amount > 1)
				S.amount--
				linked_destroy.loaded_item = S
			else
				qdel(S)
				linked_destroy.icon_state = "d_analyzer"
		else if(!(I in linked_destroy.component_parts))
			qdel(I)
			linked_destroy.icon_state = "d_analyzer"

	linked_destroy.busy = FALSE
	use_power(DECONSTRUCT_POWER)
	menu = MENU_DESTROY
	submenu = SUBMENU_MAIN
	SStgui.update_uis(src)



/obj/machinery/computer/rdconsole/proc/start_machine(obj/machinery/r_n_d/machine, design_id, amount)
	if(!machine)
		to_chat(usr, "<span class='danger'>No linked device detected.</span>")
		return

	var/is_lathe = istype(machine, /obj/machinery/r_n_d/protolathe)
	var/is_imprinter = istype(machine, /obj/machinery/r_n_d/circuit_imprinter)

	if(!is_lathe && !is_imprinter)
		to_chat(usr, "<span class='danger'>Unexpected linked device type.</span>")
		return

	if(machine.busy)
		to_chat(usr, "<span class='danger'>[machine] is busy at the moment.</span>")
		return

	var/datum/design/being_built = files.known_designs[design_id]
	if(!being_built)
		to_chat(usr, "<span class='danger'>Unknown design specified.</span>")
		return

	if(!(being_built.build_type & (is_lathe ? PROTOLATHE : IMPRINTER)))
		message_admins("[machine] exploit attempted by [key_name(usr, TRUE)]!")
		return

	if(being_built.make_reagents.len) // build_type should equal BIOGENERATOR though..
		return

	var/max_amount = is_lathe ? 10 : 1
	amount = max(1, min(max_amount, amount))

	var/power = BUILD_POWER
	for(var/M in being_built.materials)
		power += round(being_built.materials[M] * amount / 5)
	power = max(BUILD_POWER, power)

	// goes down (1 -> 0.4) with upgrades
	var/coeff = machine.efficiency_coeff

	var/time_to_construct = 0
	if(is_imprinter)
		time_to_construct = IMPRINTER_DELAY * amount
	else
		time_to_construct = PROTOLATHE_CONSTRUCT_DELAY * coeff * being_built.lathe_time_factor * amount ** 0.8

	if(is_lathe)
		add_wait_message("Constructing Prototype. Please Wait...", time_to_construct)
		flick("protolathe_n", machine)
	else
		add_wait_message("Imprinting Circuit. Please Wait...", time_to_construct)
		flick("circuit_imprinter_ani", machine)

	machine.busy = TRUE
	use_power(power)

	var/list/efficient_mats = list()
	for(var/MAT in being_built.materials)
		efficient_mats[MAT] = being_built.materials[MAT] * coeff

	var/enough_materials = TRUE

	if(!machine.materials.has_materials(being_built.materials, coeff))
		atom_say("Not enough materials to complete prototype.")
		enough_materials = FALSE
	else
		for(var/R in being_built.reagents_list)
			if(!machine.reagents.has_reagent(R, being_built.reagents_list[R] * coeff))
				atom_say("Not enough reagents to complete prototype.")
				enough_materials = FALSE

	if(enough_materials)
		machine.materials.use_amount(efficient_mats, amount)
		for(var/R in being_built.reagents_list)
			machine.reagents.remove_reagent(R, being_built.reagents_list[R] * coeff)

	var/key = usr.key
	addtimer(CALLBACK(src, PROC_REF(finish_machine), key, amount, enough_materials, machine, being_built, efficient_mats), time_to_construct)

/obj/machinery/computer/rdconsole/proc/finish_machine(key, amount, enough_materials,  obj/machinery/r_n_d/machine, datum/design/being_built, list/efficient_mats)
	if(machine)
		if(enough_materials && being_built)
			SSblackbox.record_feedback("nested tally", "RND Production List", amount, list("[being_built.category]", "[being_built.name]"))
			for(var/i in 1 to amount)
				var/obj/item/new_item = new being_built.build_path(src)
				new_item.pixel_x = rand(-5, 5)
				new_item.pixel_y = rand(-5, 5)
				if(istype(new_item, /obj/item/storage/backpack/holding))
					new_item.investigate_log("built by [key]","singulo")
				if(!istype(new_item, /obj/item/stack/sheet)) // To avoid materials dupe glitches
					new_item.materials = efficient_mats.Copy()
				if(being_built.locked)
					var/obj/item/storage/lockbox/research/L = new/obj/item/storage/lockbox/research(machine.loc)
					new_item.forceMove(L)
					L.name += " ([new_item.name])"
					L.origin_tech = new_item.origin_tech
					L.req_access = being_built.access_requirement
					var/list/lockbox_access
					for(var/A in L.req_access)
						lockbox_access += "[get_access_desc(A)] "
					L.desc = "A locked box. It is locked to [lockbox_access]access."
				else
					new_item.loc = machine.loc
		machine.busy = FALSE

	clear_wait_message()
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/ui_act(action, list/params)
	if(..())
		return

	if(!allowed(usr) && !isobserver(usr))
		return

	add_fingerprint(usr)


	switch(action)
		if("nav") //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
			var/next_menu = text2num(params["menu"])
			var/next_submenu = text2num(params["submenu"])
			if(valid_nav(next_menu, next_submenu))
				menu = next_menu
				submenu = next_submenu

		if("setCategory")
			var/next_category = params["category"]
			var/compare

			if(submenu != SUBMENU_MAIN)
				return FALSE

			if(menu == MENU_LATHE)
				compare = PROTOLATHE
				if(!linked_lathe || !(next_category in linked_lathe.categories))
					return FALSE
			else if(menu == MENU_IMPRINTER)
				compare = IMPRINTER
				if(!linked_imprinter || !(next_category in linked_imprinter.categories))
					return FALSE
			else
				return FALSE

			matching_designs.Cut()

			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(!(D.build_type & compare))
					continue
				if(next_category in D.category)
					matching_designs.Add(D)
			submenu = SUBMENU_LATHE_CATEGORY

			selected_category = "Viewing Category [next_category]"

		if("updt_tech") //Update the research holder with information from the technology disk.
			add_wait_message("Updating Database...", TECH_UPDATE_DELAY)
			addtimer(CALLBACK(src, PROC_REF(update_from_disk)), TECH_UPDATE_DELAY)

		if("clear_tech") //Erase data on the technology disk.
			if(t_disk)
				t_disk.wipe_tech()

		if("eject_tech") //Eject the technology disk.
			if(t_disk)
				t_disk.forceMove(loc)
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(t_disk)
				t_disk = null
			menu = MENU_MAIN
			submenu = SUBMENU_MAIN

		if("copy_tech") //Copy some technology data from the research holder to the disk.
			// Somehow this href makes me very nervous
			var/datum/tech/known = files.known_tech[params["id"]]
			if(t_disk && known)
				t_disk.load_tech(known)
			menu = MENU_DISK
			submenu = SUBMENU_MAIN

		if("updt_design") //Updates the research holder with design data from the design disk.
			add_wait_message("Updating Database...", DESIGN_UPDATE_DELAY)
			addtimer(CALLBACK(src, PROC_REF(update_from_disk)), DESIGN_UPDATE_DELAY)

		if("clear_design") //Erases data on the design disk.
			if(d_disk)
				d_disk.wipe_blueprint()

		if("eject_design") //Eject the design disk.
			if(d_disk)
				d_disk.forceMove(loc)
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(d_disk)
				d_disk = null
			menu = MENU_MAIN
			submenu = SUBMENU_MAIN

		if("copy_design") //Copy design data from the research holder to the design disk.
			// This href ALSO makes me very nervous
			var/datum/design/design = files.known_designs[params["id"]]
			if(design && d_disk && can_copy_design(design))
				d_disk.blueprint = design
			menu = MENU_DISK
			submenu = SUBMENU_MAIN

		if("eject_item") //Eject the item inside the destructive analyzer.
			if(linked_destroy)
				if(linked_destroy.busy)
					to_chat(usr, "<span class='danger'>[linked_destroy] is busy at the moment.</span>")

				else if(linked_destroy.loaded_item)
					linked_destroy.loaded_item.forceMove(linked_destroy.loc)
					linked_destroy.loaded_item = null
					linked_destroy.icon_state = "d_analyzer"
					menu = MENU_DESTROY

		if("maxresearch")
			if(!check_rights(R_ADMIN))
				return
			if(alert("Are you sure you want to maximize research levels?","Confirmation","Yes","No")=="No")
				return
			log_admin("[key_name(usr)] has maximized the research levels.")
			message_admins("[key_name_admin(usr)] has maximized the research levels.")
			Maximize()
			griefProtection() //Update centcomm too

		if("deconstruct") //Deconstruct the item in the destructive analyzer and update the research holder.
			start_destroyer(usr)

		if("sync") //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
			if(!sync)
				to_chat(usr, "<span class='danger'>You must connect to the network first!</span>")
			else
				add_wait_message("Syncing Database...", SYNC_RESEARCH_DELAY)
				addtimer(CALLBACK(src, PROC_REF(sync_research)), SYNC_RESEARCH_DELAY)

		if("togglesync") //Prevents the console from being synced by other consoles. Can still send data.
			sync = !sync

		if("build") //Causes the Protolathe to build something.
			start_machine(linked_lathe, params["id"], text2num(params["amount"]))

		if("imprint") //Causes the Circuit Imprinter to build something.
			start_machine(linked_imprinter, params["id"], text2num(params["amount"]))

		if("disposeI")  //Causes the circuit imprinter to dispose of a single reagent (all of it)
			if(linked_imprinter)
				linked_imprinter.reagents.del_reagent(params["id"])

		if("disposeallI") //Causes the circuit imprinter to dispose of all it's reagents.
			if(linked_imprinter)
				linked_imprinter.reagents.clear_reagents()

		if("disposeP")  //Causes the protolathe to dispose of a single reagent (all of it)
			if(linked_lathe)
				linked_lathe.reagents.del_reagent(params["id"])

		if("disposeallP") //Causes the protolathe to dispose of all it's reagents.
			if(linked_lathe)
				linked_lathe.reagents.clear_reagents()

		if("lathe_ejectsheet") //Causes the protolathe to eject a sheet of material
			prompt_eject_sheets(linked_lathe, params["id"], params["amount"])

		if("imprinter_ejectsheet") //Causes the protolathe to eject a sheet of material
			prompt_eject_sheets(linked_imprinter, params["id"], params["amount"])

		if("find_device") //The R&D console looks for devices nearby to link up with.
			add_wait_message("Syncing with nearby devices...", SYNC_DEVICE_DELAY)
			addtimer(CALLBACK(src, PROC_REF(find_devices)), SYNC_DEVICE_DELAY)

		if("disconnect") //The R&D console disconnects with a specific device.
			switch(params["item"])
				if("destroy")
					if(linked_destroy)
						linked_destroy.linked_console = null
						linked_destroy = null
				if("lathe")
					if(linked_lathe)
						linked_lathe.linked_console = null
						linked_lathe = null
				if("imprinter")
					if(linked_imprinter)
						linked_imprinter.linked_console = null
						linked_imprinter = null

		if("reset") //Reset the R&D console's database.
			griefProtection()
			var/choice = alert("Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "R&D Console Database Reset", "Continue", "Cancel")
			if(choice == "Continue")
				add_wait_message("Resetting Database...", RESET_RESEARCH_DELAY)
				addtimer(CALLBACK(src, PROC_REF(reset_research)), RESET_RESEARCH_DELAY)

		if("search") //Search for designs with name matching pattern
			var/query = params["to_search"]
			var/compare


			if(menu == MENU_LATHE)
				compare = PROTOLATHE
			else if(menu == MENU_IMPRINTER)
				compare = IMPRINTER
			else
				return FALSE

			matching_designs.Cut()

			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(!(D.build_type & compare))
					continue
				if(findtext(D.name, query))
					matching_designs.Add(D)
			submenu = SUBMENU_LATHE_CATEGORY

			selected_category = "Search Results for '[query]'"

	return TRUE // update uis


/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE
	ui_interact(user)

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RndConsole", name, 800, 550, master_ui, state)
		ui.open()

/obj/machinery/computer/rdconsole/proc/ui_machine_data(obj/machinery/r_n_d/machine, list/data)
	if(!machine)
		return

	data["total_materials"] = machine.materials.total_amount
	data["max_materials"] = machine.materials.max_amount
	data["total_chemicals"] = machine.reagents.total_volume
	data["max_chemicals"] = machine.reagents.maximum_volume
	data["categories"] = machine.categories

	var/list/designs_list = list()
	var/list/materials_list = list()
	var/list/loaded_chemicals = list()
	data["matching_designs"] = designs_list
	data["loaded_materials"] = materials_list
	data["loaded_chemicals"] = loaded_chemicals

	var/is_lathe = istype(machine, /obj/machinery/r_n_d/protolathe)
	var/is_imprinter = istype(machine, /obj/machinery/r_n_d/circuit_imprinter)

	if(!is_lathe && !is_imprinter)
		return

	var/coeff = machine.efficiency_coeff

	if(submenu == SUBMENU_LATHE_CATEGORY)
		for(var/datum/design/D in matching_designs)
			var/list/design_list = list()
			designs_list[++designs_list.len] = design_list
			var/list/design_materials_list = list()
			design_list["materials"] = design_materials_list
			design_list["id"] = D.id
			design_list["name"] = D.name
			var/can_build = is_imprinter ? 1 : 50

			for(var/M in D.materials)
				var/list/material_list = list()
				design_materials_list[++design_materials_list.len] = material_list
				material_list["name"] = CallMaterialName(M)
				material_list["amount"] = D.materials[M] * coeff
				var/t = machine.check_mat(D, M)
				material_list["is_red"] = t < 1
				can_build = min(can_build, t)

			for(var/R in D.reagents_list)
				var/list/material_list = list()
				design_materials_list[++design_materials_list.len] = material_list
				material_list["name"] = CallMaterialName(R)
				material_list["amount"] = D.reagents_list[R] * coeff
				var/t = machine.check_mat(D, R)
				material_list["is_red"] = t < 1
				can_build = min(can_build, t)

			design_list["can_build"] = can_build

	else if(submenu == SUBMENU_LATHE_MAT_STORAGE)
		materials_list[++materials_list.len] = list("name" = "Metal", "id" = MAT_METAL, "amount" = machine.materials.amount(MAT_METAL))
		materials_list[++materials_list.len] = list("name" = "Glass", "id" = MAT_GLASS, "amount" = machine.materials.amount(MAT_GLASS))
		materials_list[++materials_list.len] = list("name" = "Gold", "id" = MAT_GOLD, "amount" = machine.materials.amount(MAT_GOLD))
		materials_list[++materials_list.len] = list("name" = "Silver", "id" = MAT_SILVER, "amount" = machine.materials.amount(MAT_SILVER))
		materials_list[++materials_list.len] = list("name" = "Solid Plasma", "id" = MAT_PLASMA, "amount" = machine.materials.amount(MAT_PLASMA))
		materials_list[++materials_list.len] = list("name" = "Uranium", "id" = MAT_URANIUM, "amount" = machine.materials.amount(MAT_URANIUM))
		materials_list[++materials_list.len] = list("name" = "Diamond", "id" = MAT_DIAMOND, "amount" = machine.materials.amount(MAT_DIAMOND))
		materials_list[++materials_list.len] = list("name" = "Bananium", "id" = MAT_BANANIUM, "amount" = machine.materials.amount(MAT_BANANIUM))
		materials_list[++materials_list.len] = list("name" = "Tranquillite", "id" = MAT_TRANQUILLITE, "amount" = machine.materials.amount(MAT_TRANQUILLITE))
		materials_list[++materials_list.len] = list("name" = "Titanium", "id" = MAT_TITANIUM, "amount" = machine.materials.amount(MAT_TITANIUM))
		materials_list[++materials_list.len] = list("name" = "Plastic", "id" = MAT_PLASTIC, "amount" = machine.materials.amount(MAT_PLASTIC))
		materials_list[++materials_list.len] = list("name" = "Bluespace Mesh", "id" = MAT_BLUESPACE, "amount" = machine.materials.amount(MAT_BLUESPACE))
	else if(submenu == SUBMENU_LATHE_CHEM_STORAGE)
		for(var/datum/reagent/R in machine.reagents.reagent_list)
			var/list/loaded_chemical = list()
			loaded_chemicals[++loaded_chemicals.len] = loaded_chemical
			loaded_chemical["name"] = R.name
			loaded_chemical["volume"] = R.volume
			loaded_chemical["id"] = R.id


/obj/machinery/computer/rdconsole/proc/can_copy_design(datum/design/D)
	if(D)
		if(D.build_type & PROTOLATHE)
			return TRUE

		if(D.build_type & AUTOLATHE)
			for(var/M in D.materials)
				if(M != MAT_METAL && M != MAT_GLASS)
					return FALSE
			return TRUE

	return FALSE

/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()

	files.RefreshResearch()

	data["menu"] = menu
	data["submenu"] = submenu
	data["wait_message"] = wait_message
	data["src_ref"] = UID()

	data["linked_destroy"] = linked_destroy ? 1 : 0
	data["linked_lathe"] = linked_lathe ? 1 : 0
	data["linked_imprinter"] = linked_imprinter ? 1 : 0
	data["sync"] = sync
	data["admin"] = check_rights(R_ADMIN, FALSE, user)
	data["disk_type"] = d_disk ? "design" : (t_disk ? "tech" : null)
	data["disk_data"] = null
	data["loaded_item"] = null
	data["category"] = selected_category

	if(menu == MENU_MAIN || menu == MENU_LEVELS)
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

	else if(menu == MENU_DISK)

		if(t_disk != null && t_disk.stored != null && submenu == SUBMENU_MAIN)
			var/list/disk_data = list()
			data["disk_data"] = disk_data
			disk_data["name"] = t_disk.stored.name
			disk_data["level"] = t_disk.stored.level
			disk_data["desc"] = t_disk.stored.desc

		else if(t_disk != null && submenu == SUBMENU_DISK_COPY)
			var/list/to_copy = list()
			data["to_copy"] = to_copy
			for(var/v in files.known_tech)
				var/datum/tech/T = files.known_tech[v]
				if(T.level <= 0)
					continue
				var/list/item = list()
				to_copy[++to_copy.len] = item
				item["name"] = T.name
				item["id"] = T.id

		else if(d_disk != null && d_disk.blueprint != null && submenu == SUBMENU_MAIN)
			var/list/disk_data = list()
			data["disk_data"] = disk_data
			disk_data["name"] = d_disk.blueprint.name
			var/b_type = d_disk.blueprint.build_type
			var/list/lathe_types = list()
			disk_data["lathe_types"] = lathe_types
			if(b_type)
				if(b_type & IMPRINTER) lathe_types += "Circuit Imprinter"
				if(b_type & PROTOLATHE) lathe_types += "Protolathe"
				if(b_type & AUTOLATHE) lathe_types += "Autolathe"
				if(b_type & MECHFAB) lathe_types += "Mech Fabricator"
				if(b_type & BIOGENERATOR) lathe_types += "Biogenerator"
				if(b_type & SMELTER) lathe_types += "Smelter"
			var/list/materials = list()
			disk_data["materials"] = materials
			for(var/M in d_disk.blueprint.materials)
				var/list/material = list()
				materials[++materials.len] = material
				material["name"] = CallMaterialName(M)
				material["amount"] = d_disk.blueprint.materials[M]

		else if(d_disk != null && submenu == SUBMENU_DISK_COPY)
			var/list/to_copy = list()
			data["to_copy"] = to_copy
			for(var/v in files.known_designs)
				var/datum/design/D = files.known_designs[v]
				if(!can_copy_design(D))
					continue
				var/list/item = list()
				to_copy[++to_copy.len] = item
				item["name"] = D.name
				item["id"] = D.id

	else if(menu == MENU_DESTROY && linked_destroy && linked_destroy.loaded_item)
		var/list/loaded_item_list = list()
		data["loaded_item"] = loaded_item_list
		loaded_item_list["name"] = linked_destroy.loaded_item.name
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

	else if(menu == MENU_LATHE && linked_lathe)
		ui_machine_data(linked_lathe, data)
	else if(menu == MENU_IMPRINTER && linked_imprinter)
		ui_machine_data(linked_imprinter, data)

	return data

//helper proc that guarantees the wait message will not freeze the UI
/obj/machinery/computer/rdconsole/proc/add_wait_message(message, delay)
	wait_message = message
	wait_message_timer = addtimer(CALLBACK(src, PROC_REF(clear_wait_message)), delay, TIMER_UNIQUE | TIMER_STOPPABLE)

// This is here to guarantee that we never lock the console, so long as the timer
// process is running
// So long as the spawns never runtime, though, the timer should be stopped
// before it gets the chance to fire
// Since the timer process can have significant delays, you should call this
// in the operations that take time, once they complete
/obj/machinery/computer/rdconsole/proc/clear_wait_message()
	wait_message = ""
	if(wait_message_timer)
		// This could be expensive, and will still be called
		// if the timer calls this function
		deltimer(wait_message_timer)
		wait_message_timer = null
	SStgui.update_uis(src)


/obj/machinery/computer/rdconsole/core
	name = "core R&D console"
	desc = "A console used to interface with R&D tools."
	id = 1

/obj/machinery/computer/rdconsole/robotics
	name = "robotics R&D console"
	desc = "A console used to interface with R&D tools."
	id = 2
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/rdconsole/robotics

/obj/machinery/computer/rdconsole/experiment
	name = "\improper E.X.P.E.R.I-MENTOR R&D console"
	desc = "A console used to interface with R&D tools."
	id = 3
	range = 5
	circuit = /obj/item/circuitboard/rdconsole/experiment

/obj/machinery/computer/rdconsole/public
	name = "public R&D console"
	desc = "A console used to interface with R&D tools."
	id = 5
	req_access = list()
	circuit = /obj/item/circuitboard/rdconsole/public

#undef TECH_UPDATE_DELAY
#undef DESIGN_UPDATE_DELAY
#undef PROTOLATHE_CONSTRUCT_DELAY
#undef SYNC_RESEARCH_DELAY
#undef DECONSTRUCT_DELAY
#undef SYNC_DEVICE_DELAY
#undef RESET_RESEARCH_DELAY
#undef IMPRINTER_DELAY
#undef MENU_MAIN
#undef MENU_LEVELS
#undef MENU_DISK
#undef MENU_DESTROY
#undef MENU_LATHE
#undef MENU_IMPRINTER
#undef MENU_SETTINGS
#undef SUBMENU_MAIN
#undef SUBMENU_DISK_COPY
#undef SUBMENU_LATHE_CATEGORY
#undef SUBMENU_LATHE_MAT_STORAGE
#undef SUBMENU_LATHE_CHEM_STORAGE
#undef SUBMENU_SETTINGS_DEVICES
#undef BUILD_POWER
#undef DECONSTRUCT_POWER
