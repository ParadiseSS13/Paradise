/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Scientific Analyzer, Protolathe, and Circuit
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

#define MENU_MAIN 0
#define MENU_DISK 2
#define MENU_ANALYZER 3
#define MENU_LATHE 4
#define MENU_IMPRINTER 5
#define MENU_SETTINGS 6
#define MIN_MENU MENU_MAIN
#define MAX_MENU MENU_SETTINGS
#define SUBMENU_PRINTER_MAIN 0
#define SUBMENU_PRINTER_SEARCH 1
#define SUBMENU_PRINTER_MATERIALS 2
#define SUBMENU_PRINTER_CHEMICALS 3
#define MIN_SUBMENU_PRINTER SUBMENU_PRINTER_MAIN
#define MAX_SUBMENU_PRINTER SUBMENU_PRINTER_CHEMICALS

#define BUILD_POWER 2000
#define DECONSTRUCT_POWER 250

/obj/machinery/computer/rdconsole
	name = "\improper R&D console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	light_color = LIGHT_COLOR_FADEDPURPLE
	circuit = /obj/item/circuitboard/rdconsole
	/// Holder for our inserted technology disk
	var/obj/item/disk/tech_disk/t_disk = null
	/// Holder for the inserted design disk
	var/obj/item/disk/design_disk/d_disk = null
	/// Linked scientific analyser
	var/obj/machinery/r_n_d/scientific_analyzer/linked_analyzer = null
	/// Linked protolathe
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null
	/// Linked circuit imprinter
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null

	/// The ID of the top-level menu, such as protolathe, analyzer, etc.
	var/menu = MENU_MAIN
	/// The ID of the protolathe submenu, such as materials, chemicals, crafting etc.
	var/submenu_protolathe = SUBMENU_PRINTER_MAIN
	/// The ID of the circuit imprinter submenu. Shares the same submenus as the protolathe.
	var/submenu_imprinter = SUBMENU_PRINTER_MAIN
	var/wait_message = 0
	var/wait_message_timer = 0
	///Range to search for rnd devices in proximity to console
	var/range = 3

	req_one_access = list(ACCESS_TOX, ACCESS_ROBOTICS)

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function

/obj/machinery/computer/rdconsole/proc/get_files()
	if(!network_manager_uid)
		return null

	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(!RNC)
		network_manager_uid = null
		return null

	return RNC.research_files

/proc/CallMaterialName(return_name)
	switch(return_name)
		if("plasma")
			return_name = "Solid Plasma"
		if("clown")
			return_name = "Bananium"
		if("mime")
			return_name = "Tranquillite"
		if("bluespace")
			return_name = "Bluespace Mesh"
		else
			var/datum/reagent/our_reagent = GLOB.chemical_reagents_list[return_name]
			if(our_reagent && initial(our_reagent.id) == return_name)
				return_name = initial(our_reagent.name)
	return capitalize(return_name)

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in range(range, src))
		if(!isnull(D.linked_console) || D.panel_open)
			continue

		if(istype(D, /obj/machinery/r_n_d/scientific_analyzer))
			if(linked_analyzer == null)
				linked_analyzer = D
				D.linked_console = src

		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src

		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize(mapload)
	. = ..()
	matching_designs = list()
	SyncRDevices()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/rdconsole/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.consoles += UID()

/obj/machinery/computer/rdconsole/Destroy()
	QDEL_NULL(t_disk)
	QDEL_NULL(d_disk)
	matching_designs.Cut()
	if(linked_analyzer)
		linked_analyzer.linked_console = null
		linked_analyzer = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null

	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	if(RNC)
		// Unlink us
		RNC.consoles -= UID()

	if(wait_message_timer)
		deltimer(wait_message_timer)
		wait_message_timer = 0
	return ..()

/obj/machinery/computer/rdconsole/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	//Loading a disk into it.
	if(istype(used, /obj/item/disk))
		. = ITEM_INTERACT_COMPLETE
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(used, /obj/item/disk/tech_disk)) t_disk = used
		else if(istype(used, /obj/item/disk/design_disk)) d_disk = used
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		if(!user.transfer_item_to(used, src))
			return
		playsound(src, used.drop_sound, DROP_SOUND_VOLUME, ignore_walls = FALSE) // Highly important auditory feedback
		to_chat(user, "<span class='notice'>You add the disk to the machine!</span>")
	else if(!(linked_analyzer && linked_analyzer.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		return ..()

	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/emag_act(user as mob)
	if(!emagged)
		playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
		req_one_access = list()
		emagged = TRUE
		to_chat(user, "<span class='notice'>You disable the security protocols</span>")
		return TRUE

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
	var/datum/research/files = get_files()
	if(!files)
		return
	if(d_disk && d_disk.blueprint)
		files.AddDesign2Known(d_disk.blueprint)
	else if(t_disk && t_disk.tech_id)
		var/datum/tech/tech = files.find_possible_tech_with_id(t_disk.tech_id)
		if(!isnull(tech))
			tech.level = t_disk.tech_level
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	clear_wait_message()
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/start_analyzer_destroy(mob/user)
	if(!linked_analyzer)
		return

	if(linked_analyzer.busy)
		to_chat(user, "<span class='danger'>[linked_analyzer] is busy at the moment.</span>")
		return

	if(!linked_analyzer.loaded_item)
		to_chat(user, "<span class='danger'>[linked_analyzer] appears to be empty.</span>")
		return

	var/datum/research/files = get_files()
	if(!files)
		return

	var/list/temp_tech = linked_analyzer.ConvertReqString2List(linked_analyzer.loaded_item.origin_tech)
	var/pointless = FALSE

	for(var/T in temp_tech)
		if(files.IsTechHigher(T, temp_tech[T]))
			pointless = TRUE
			break

	if(!pointless)
		var/choice = alert(user, "This item does not raise tech levels. Proceed destroying loaded item anyway?", "Are you sure you want to destroy this item?", "Proceed", "Cancel")
		if(choice == "Cancel" || !linked_analyzer)
			return

	linked_analyzer.busy = TRUE
	add_wait_message("Processing and Updating Database...", DECONSTRUCT_DELAY)
	flick("s_analyzer_process", linked_analyzer)
	addtimer(CALLBACK(src, PROC_REF(finish_analyzer), user, temp_tech), DECONSTRUCT_DELAY)


/obj/machinery/computer/rdconsole/proc/start_analyzer_discover(mob/user)
	if(!linked_analyzer)
		return

	if(linked_analyzer.busy)
		to_chat(user, "<span class='danger'>[linked_analyzer] is busy at the moment.</span>")
		return

	if(!linked_analyzer.loaded_item)
		to_chat(user, "<span class='danger'>[linked_analyzer] appears to be empty.</span>")
		return

	if(!istype(linked_analyzer.loaded_item, /obj/item/relic))
		message_admins("[key_name_admin(user)] attempted to discover something that isnt a strange object. Possible HREF exploit.")
		return

	var/obj/item/relic/R = linked_analyzer.loaded_item
	visible_message("[linked_analyzer] scans [linked_analyzer.loaded_item], revealing its true nature!")
	playsound(loc, 'sound/effects/supermatter.ogg', 50, 3, -1)

	// LETS GO GAMBLING
	R.reveal()
	R.forceMove(get_turf(linked_analyzer))
	linked_analyzer.loaded_item = null
	investigate_log("Scientific analyser has revealed a relic with effect ID <span class='danger'>[R.function_id]</span> effect.", "strangeobjects")
	linked_analyzer.icon_state = "s_analyzer"
	SStgui.update_uis(src)


// Sends salvaged materials to a linked protolathe, if any.
/obj/machinery/computer/rdconsole/proc/send_mats()
	if(!linked_lathe || !linked_analyzer || !linked_analyzer.loaded_item)
		return

	for(var/material in linked_analyzer.loaded_item.materials)
		var/space = linked_lathe.materials.max_amount - linked_lathe.materials.total_amount
		// as item rating increases, amount salvageable increases
		var/salvageable = linked_analyzer.loaded_item.materials[material] * (linked_analyzer.decon_mod / 10)
		// but you shouldn't salvage more than the raw materials amount
		var/available = linked_analyzer.loaded_item.materials[material]
		var/can_insert = min(space, salvageable, available)
		linked_lathe.materials.insert_amount(can_insert, material)

/obj/machinery/computer/rdconsole/proc/finish_analyzer(mob/user, list/temp_tech)
	clear_wait_message()
	if(!linked_analyzer || !temp_tech)
		return

	var/datum/research/files = get_files()
	if(!files)
		return

	if(!linked_analyzer.loaded_item)
		to_chat(user, "<span class='danger'>[linked_analyzer] appears to be empty.</span>")
	else
		for(var/T in temp_tech)
			files.UpdateTech(T, temp_tech[T])
		send_mats()
		linked_analyzer.loaded_item = null

	for(var/obj/I in linked_analyzer.contents)
		for(var/mob/M in I.contents)
			M.death()
		if(istype(I, /obj/item/stack))//Only deconstructs one item in a stack at a time instead of the entire stack
			var/obj/item/stack/S = I
			if(S.amount > 1)
				S.amount--
				linked_analyzer.loaded_item = S
			else
				qdel(S)
				linked_analyzer.icon_state = "s_analyzer"
		else if(!(I in linked_analyzer.component_parts))
			qdel(I)
			linked_analyzer.icon_state = "s_analyzer"

	linked_analyzer.busy = FALSE
	use_power(DECONSTRUCT_POWER)
	menu = MENU_ANALYZER
	SStgui.update_uis(src)



/obj/machinery/computer/rdconsole/proc/start_machine(obj/machinery/r_n_d/machine, design_id, amount)
	if(!machine)
		to_chat(usr, "<span class='danger'>No linked device detected.</span>")
		return

	var/datum/research/files = get_files()
	if(!files)
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

	if(length(being_built.make_reagents)) // build_type should equal BIOGENERATOR though..
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
			if(is_station_level(z))
				SSblackbox.record_feedback("tally", "station_protolathe_production", amount, "[being_built.type]")
			for(var/i in 1 to amount)
				var/obj/item/new_item = new being_built.build_path(src)
				new_item.scatter_atom()
				if(istype(new_item, /obj/item/storage/backpack/holding))
					new_item.investigate_log("built by [key]",INVESTIGATE_SINGULO)
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

/obj/machinery/computer/rdconsole/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!allowed(ui.user) && !isobserver(ui.user))
		return

	add_fingerprint(ui.user)


	// We switch these actions first because they can be done without files
	switch(action)
		if("unlink")
			if(!network_manager_uid)
				return
			var/choice = tgui_alert(usr, "Are you SURE you want to unlink this console?\nYou won't be able to re-link without the network manager password", "Unlink", list("Yes", "No"))
			if(choice == "Yes")
				unlink()

			return TRUE

		if("maxresearch")
			if(!check_rights(R_ADMIN))
				return
			if(!network_manager_uid)
				return
			var/choice = tgui_alert(ui.user, "Are you sure you want to maximize research levels?", "Confirmation", list("Yes", "No"))
			if(choice == "Yes")
				log_admin("[key_name(ui.user)] has maximized the research levels at network [network_manager_uid].")
				message_admins("[key_name_admin(ui.user)] has maximized the research levels at network [network_manager_uid].")
				maximize()

			return TRUE

		// You should only be able to link if its not linked, to prevent weirdness
		if("linktonetworkcontroller")
			if(network_manager_uid)
				return
			var/obj/machinery/computer/rnd_network_controller/C = locateUID(params["target_controller"])
			if(istype(C, /obj/machinery/computer/rnd_network_controller))
				if(!atoms_share_level(C, src))
					return
				var/user_pass = input(usr, "Please enter network password", "Password Entry")
				// Check the password
				if(user_pass == C.network_password)
					C.consoles += UID()
					network_manager_uid = C.UID()
					to_chat(usr, "<span class='notice'>Successfully linked to <b>[C.network_name]</b>.</span>")
				else
					to_chat(usr, "<span class='alert'><b>ERROR:</b> Password incorrect.</span>")
			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Controller not found. Please file an issue report.</span>")

			return TRUE

	// Now we do a files check
	var/datum/research/files = get_files()
	if(!files)
		to_chat(usr, "<span class='danger'>Error - No research network linked.</span>")
		return


	switch(action)
		if("nav") //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
			var/next_menu = text2num(params["menu"])
			if(isnull(next_menu) || !ISINTEGER(next_menu) || !ISINRANGE(next_menu, MIN_MENU, MAX_MENU))
				return
			menu = next_menu

		if("nav_protolathe")
			var/new_menu = text2num(params["menu"])
			if(isnull(new_menu) || !ISINTEGER(new_menu) || !ISINRANGE(new_menu, MIN_SUBMENU_PRINTER, MAX_SUBMENU_PRINTER))
				return
			submenu_protolathe = new_menu

		if("nav_imprinter")
			var/new_menu = text2num(params["menu"])
			if(isnull(new_menu) || !ISINTEGER(new_menu) || !ISINRANGE(new_menu, MIN_SUBMENU_PRINTER, MAX_SUBMENU_PRINTER))
				return
			submenu_imprinter = new_menu

		if("setCategory")
			var/next_category = params["category"]
			var/compare

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
			if(menu == MENU_LATHE)
				submenu_protolathe = SUBMENU_PRINTER_SEARCH
				if(submenu_imprinter == SUBMENU_PRINTER_SEARCH)
					submenu_imprinter = SUBMENU_PRINTER_MAIN
			else if(menu == MENU_IMPRINTER)
				submenu_imprinter = SUBMENU_PRINTER_SEARCH
				if(submenu_protolathe == SUBMENU_PRINTER_SEARCH)
					submenu_protolathe = SUBMENU_PRINTER_MAIN

			selected_category = "Viewing Category [next_category]"

		if("updt_tech") //Update the research holder with information from the technology disk.
			add_wait_message("Updating Database...", TECH_UPDATE_DELAY)
			addtimer(CALLBACK(src, PROC_REF(update_from_disk)), TECH_UPDATE_DELAY)

		if("eject_disk")
			if(t_disk)
				t_disk.forceMove(loc)
				if(Adjacent(ui.user) && !issilicon(ui.user))
					ui.user.put_in_hands(t_disk)
				t_disk = null
			if(d_disk)
				d_disk.forceMove(loc)
				if(Adjacent(ui.user) && !issilicon(ui.user))
					ui.user.put_in_hands(d_disk)
				d_disk = null

		if("erase_disk")
			if(t_disk && d_disk)
				to_chat(ui.user, "<span class='warning'>Can not simultaneously wipe tech disk and design disk.</span>")
				return FALSE
			if(t_disk)
				t_disk.wipe_tech()
			if(d_disk)
				d_disk.wipe_blueprint()

		if("copy_tech") //Copy some technology data from the research holder to the disk.
			// Somehow this href makes me very nervous
			var/datum/tech/known = files.known_tech[params["id"]]
			if(t_disk && known)
				t_disk.load_tech(known)

		if("updt_design") //Updates the research holder with design data from the design disk.
			add_wait_message("Updating Database...", DESIGN_UPDATE_DELAY)
			addtimer(CALLBACK(src, PROC_REF(update_from_disk)), DESIGN_UPDATE_DELAY)

		if("copy_design") //Copy design data from the research holder to the design disk.
			// This href ALSO makes me very nervous
			var/datum/design/design = files.known_designs[params["id"]]
			if(design && d_disk && can_copy_design(design))
				d_disk.blueprint = design

		if("eject_item") //Eject the item inside the scientific analyzer.
			if(linked_analyzer)
				if(linked_analyzer.busy)
					to_chat(ui.user, "<span class='danger'>[linked_analyzer] is busy at the moment.</span>")

				else if(linked_analyzer.loaded_item)
					linked_analyzer.loaded_item.forceMove(linked_analyzer.loc)
					linked_analyzer.loaded_item = null
					linked_analyzer.icon_state = "s_analyzer"

		if("deconstruct") //Deconstruct the item in the scientific analyzer and update the research holder.
			start_analyzer_destroy(ui.user)

		if("discover") // Analyse the object in the scientific analyser and discover it
			start_analyzer_discover(ui.user)

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
				if("analyze")
					if(linked_analyzer)
						linked_analyzer.linked_console = null
						linked_analyzer = null
				if("lathe")
					if(linked_lathe)
						linked_lathe.linked_console = null
						linked_lathe = null
						submenu_protolathe = SUBMENU_PRINTER_MAIN
				if("imprinter")
					if(linked_imprinter)
						linked_imprinter.linked_console = null
						linked_imprinter = null
						submenu_imprinter = SUBMENU_PRINTER_MAIN

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
			if(menu == MENU_LATHE)
				submenu_protolathe = SUBMENU_PRINTER_SEARCH
				if(submenu_imprinter == SUBMENU_PRINTER_SEARCH)
					submenu_imprinter = SUBMENU_PRINTER_MAIN
			else if(menu == MENU_IMPRINTER)
				submenu_imprinter = SUBMENU_PRINTER_SEARCH
				if(submenu_protolathe == SUBMENU_PRINTER_SEARCH)
					submenu_protolathe = SUBMENU_PRINTER_MAIN

			selected_category = "Search Results for '[query]'"


		if("unlink")
			if(!network_manager_uid)
				return
			var/choice = alert(usr, "Are you SURE you want to unlink this console?\nYou wont be able to re-link without the network manager password", "Unlink","Yes","No")
			if(choice == "Yes")
				unlink()

		// You should only be able to link if its not linked, to prevent weirdness
		if("linktonetworkcontroller")
			if(network_manager_uid)
				return
			var/obj/machinery/computer/rnd_network_controller/C = locateUID(params["target_controller"])
			if(istype(C, /obj/machinery/computer/rnd_network_controller))
				var/user_pass = input(usr, "Please enter network password", "Password Entry")
				// Check the password
				if(user_pass == C.network_password)
					network_manager_uid = C.UID()
					to_chat(usr, "<span class='notice'>Successfully linked to <b>[C.network_name]</b>.</span>")
				else
					to_chat(usr, "<span class='alert'><b>ERROR:</b> Password incorrect.</span>")
			else
				to_chat(usr, "<span class='alert'><b>ERROR:</b> Controller not found. Please file an issue report.</span>")

	return TRUE // update uis

/obj/machinery/computer/rdconsole/proc/unlink()
	var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
	RNC.consoles -= UID()
	network_manager_uid = null
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/maximize()
	var/datum/research/files = get_files()
	if(!files)
		return
	for(var/T in files.known_tech)
		files.UpdateTech(T, 8)
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE
	ui_interact(user)

/obj/machinery/computer/rdconsole/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RndConsole", name)
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

	if(menu == MENU_LATHE || menu == MENU_IMPRINTER)
		var/submenu = menu == MENU_LATHE ? submenu_protolathe : submenu_imprinter
		if(submenu == SUBMENU_PRINTER_SEARCH)
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

		else if(submenu == SUBMENU_PRINTER_MATERIALS)
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
		else if(submenu == SUBMENU_PRINTER_CHEMICALS)
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

	var/datum/research/files = get_files()
	// If we have no linked files, dont even process anything else, just get a link up
	if(!files)
		data["linked"] = FALSE

		var/list/controllers = list()
		for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
			if(atoms_share_level(RNC, src))
				controllers += list(list("addr" = RNC.UID(), "net_id" = RNC.network_name))
		data["controllers"] = controllers

		return data

	data["linked"] = TRUE
	files.RefreshResearch()

	data["admin"] = check_rights(R_ADMIN, FALSE, user)
	data["menu"] = menu
	data["submenu_protolathe"] = submenu_protolathe
	data["submenu_imprinter"] = submenu_imprinter
	data["wait_message"] = wait_message
	data["src_ref"] = UID()

	data["linked_analyzer"] = linked_analyzer ? 1 : 0
	data["linked_lathe"] = linked_lathe ? 1 : 0
	data["linked_imprinter"] = linked_imprinter ? 1 : 0
	data["disk_type"] = d_disk ? "design" : (t_disk ? "tech" : null)
	data["disk_data"] = null
	data["loaded_item"] = null
	data["category"] = selected_category

	if(menu == MENU_MAIN)
		var/list/tech_levels = list()
		data["tech_levels"] = tech_levels
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			if(T.level <= 0)
				continue
			var/list/this_tech_list = list()
			this_tech_list["id"] = T.id
			this_tech_list["name"] = T.name
			this_tech_list["level"] = T.level
			this_tech_list["desc"] = T.desc
			this_tech_list["ui_icon"] = T.ui_icon
			tech_levels[++tech_levels.len] = this_tech_list

	else if(menu == MENU_DISK)

		if(t_disk != null)
			if(t_disk.tech_id == null)
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
			else
				var/datum/tech/stored_tech = files.find_possible_tech_with_id(t_disk.tech_id)
				var/list/disk_data = list()
				data["disk_data"] = disk_data
				if(isnull(stored_tech))
					disk_data["name"] = "Unknown"
					disk_data["level"] = 0
					disk_data["desc"] = "Unrecognized technology detected in disk."
				else
					disk_data["name"] = stored_tech.name
					disk_data["level"] = stored_tech.level
					disk_data["desc"] = stored_tech.desc

		else if(d_disk != null)
			if(d_disk.blueprint == null)
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
			else
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

	else if(menu == MENU_ANALYZER && linked_analyzer && linked_analyzer.loaded_item)
		var/list/loaded_item_list = list()
		data["loaded_item"] = loaded_item_list
		data["can_discover"] = istype(linked_analyzer.loaded_item, /obj/item/relic)
		loaded_item_list["name"] = linked_analyzer.loaded_item.name
		var/list/temp_tech = linked_analyzer.ConvertReqString2List(linked_analyzer.loaded_item.origin_tech)
		var/list/tech_levels = list()
		data["tech_levels"] = tech_levels
		for(var/v in files.known_tech)
			var/datum/tech/T = files.known_tech[v]
			if(T.level <= 0)
				continue
			var/list/this_tech_list = list()
			this_tech_list["id"] = T.id
			this_tech_list["name"] = T.name
			this_tech_list["level"] = T.level
			this_tech_list["desc"] = T.desc
			this_tech_list["ui_icon"] = T.ui_icon
			this_tech_list["object_level"] = temp_tech[T.id]
			tech_levels[++tech_levels.len] = this_tech_list

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
	autolink_id = "station_rnd"

/obj/machinery/computer/rdconsole/public
	name = "public R&D console"
	req_one_access = list()
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
#undef MENU_DISK
#undef MENU_ANALYZER
#undef MENU_LATHE
#undef MENU_IMPRINTER
#undef MENU_SETTINGS
#undef MIN_MENU
#undef MAX_MENU
#undef SUBMENU_PRINTER_MAIN
#undef SUBMENU_PRINTER_SEARCH
#undef SUBMENU_PRINTER_MATERIALS
#undef SUBMENU_PRINTER_CHEMICALS
#undef MIN_SUBMENU_PRINTER
#undef MAX_SUBMENU_PRINTER
#undef BUILD_POWER
#undef DECONSTRUCT_POWER
