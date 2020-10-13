/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

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
#define MENU_TECHWEBS 7
#define MENU_TECHWEBS_NODEVIEW 8
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
	var/datum/techweb/stored_research		//Reference to global science techweb.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter	//Linked Circuit Imprinter

	var/datum/techweb_node/selected_node
	var/datum/design/selected_design

	var/screen = 1.0	//Which screen is currently showing.

	var/menu = MENU_MAIN
	var/submenu = SUBMENU_MAIN
	var/wait_message = 0
	var/wait_message_timer = 0

	req_access = list(ACCESS_TOX)	//Data and setting manipulation requires scientist access.

	var/selected_category
	var/list/datum/design/matching_designs = list() //for the search function
	/// If true, the console has WRITE access to R&D. If false, it can only READ tech levels. This stops robotics and the mechanic using all the points.
	/// It has to be ID because thats what shitty circuit boards use
	var/id = TRUE

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

/obj/machinery/computer/rdconsole/Initialize()
	..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	matching_designs = list()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	matching_designs = null
	selected_node = null
	selected_design = null
	if(wait_message_timer)
		deltimer(wait_message_timer)
		wait_message_timer = 0
	return ..()

/*	Instead of calling this every tick, it is only being called when needed
/obj/machinery/computer/rdconsole/process()
	griefProtection()
*/

/obj/machinery/computer/rdconsole/attackby(var/obj/item/D as obj, var/mob/user as mob, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/disk/design_disk))
			d_disk = D
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
		if(MENU_MAIN, MENU_LEVELS, MENU_DESTROY, MENU_TECHWEBS, MENU_TECHWEBS_NODEVIEW)
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
		stored_research.add_design(d_disk.blueprint)
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	clear_wait_message()
	SStgui.update_uis(src)

/obj/machinery/computer/rdconsole/proc/start_destroyer(id)
	if(!linked_destroy)
		return

	if(linked_destroy.busy)
		to_chat(usr, "<span class='danger'>[linked_destroy] is busy at the moment.</span>")
		return

	if(!linked_destroy.loaded_item)
		to_chat(usr, "<span class='danger'>[linked_destroy] appears to be empty.</span>")
		return

	if(linked_destroy.user_try_decon_id(id, usr))
		linked_destroy.busy = TRUE
		add_wait_message("Processing and Updating Database...", DECONSTRUCT_DELAY)
		flick("d_analyzer_process", linked_destroy)
		addtimer(CALLBACK(src, .proc/finish_destroyer), DECONSTRUCT_DELAY)

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

/obj/machinery/computer/rdconsole/proc/finish_destroyer()
	clear_wait_message()
	if(!linked_destroy)
		return

	if(!linked_destroy.hacked)
		if(!linked_destroy.loaded_item)
			to_chat(usr, "<span class='danger'>[linked_destroy] appears to be empty.</span>")
		else
			send_mats()
			linked_destroy.loaded_item = null

	for(var/obj/I in linked_destroy.contents)
		for(var/mob/M in I.contents)
			M.death()
		if(istype(I, /obj/item/stack/sheet))//Only deconstructs one sheet at a time instead of the entire stack
			var/obj/item/stack/sheet/S = I
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
	menu = MENU_MAIN
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

	var/datum/design/being_built = stored_research.researched_designs[design_id]
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

	if(!machine.materials.has_materials(efficient_mats, amount))
		atom_say("Not enough materials to complete prototype.")
		enough_materials = FALSE
	else
		for(var/R in being_built.reagents_list)
			if(!machine.reagents.has_reagent(R, being_built.reagents_list[R]) * coeff)
				atom_say("Not enough reagents to complete prototype.")
				enough_materials = FALSE

	if(enough_materials)
		machine.materials.use_amount(efficient_mats, amount)
		for(var/R in being_built.reagents_list)
			machine.reagents.remove_reagent(R, being_built.reagents_list[R] * coeff)

	var/key = usr.key
	addtimer(CALLBACK(src, .proc/finish_machine, key, amount, enough_materials, machine, being_built, efficient_mats), time_to_construct)

/obj/machinery/computer/rdconsole/proc/finish_machine(key, amount, enough_materials,  obj/machinery/r_n_d/machine, datum/design/being_built, list/efficient_mats)
	if(machine)
		if(enough_materials && being_built)
			for(var/i in 1 to amount)
				var/obj/item/new_item = new being_built.build_path(src)
				if(istype(new_item, /obj/item/storage/backpack/holding))
					new_item.investigate_log("built by [key]","singulo")
				if(!istype(new_item, /obj/item/stack/sheet)) // To avoid materials dupe glitches
					new_item.materials = efficient_mats.Copy()
				if(being_built.locked)
					var/obj/item/storage/lockbox/research/L = new/obj/item/storage/lockbox/research(machine.loc)
					new_item.forceMove(L)
					L.name += " ([new_item.name])"
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

/obj/machinery/computer/rdconsole/tgui_act(action, list/params)
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

			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(D.build_type & compare))
					continue
				if(next_category in D.category)
					matching_designs.Add(D)
			submenu = SUBMENU_LATHE_CATEGORY

			selected_category = "Viewing Category [next_category]"

		if("updt_design") //Updates the research holder with design data from the design disk.
			add_wait_message("Updating Database...", DESIGN_UPDATE_DELAY)
			addtimer(CALLBACK(src, .proc/update_from_disk), DESIGN_UPDATE_DELAY)

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
			var/datum/design/design = stored_research.researched_designs[params["id"]]
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

		if("deconstruct") //Deconstruct the item in the destructive analyzer and update the research holder.
			start_destroyer(params["id"], usr)

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
			addtimer(CALLBACK(src, .proc/find_devices), SYNC_DEVICE_DELAY)

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

			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(D.build_type & compare))
					continue
				if(findtext(D.name, query))
					matching_designs.Add(D)
			submenu = SUBMENU_LATHE_CATEGORY

			selected_category = "Search Results for '[query]'"

		// All techweb acts below here
		if("TW_viewNode")
			menu = MENU_TECHWEBS_NODEVIEW
			selected_node = SSresearch.get_techweb_node_by_id(params["id"])

		if("TW_back")
			menu = MENU_TECHWEBS
			selected_node = null

		if("TW_research")
			if(id)
				research_node(params["id"], usr)

	return TRUE // update uis


/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		atom_say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_nodes[id]
	if(!istype(TN))
		atom_say("Node unlock failed: Unknown error.")
		return FALSE
	var/price = TN.get_price(stored_research)
	if(stored_research.research_points >= price)
		investigate_log("[key_name_admin(user)] researched [id]([price]) on techweb id [stored_research.id].")
		if(stored_research.research_node(SSresearch.techweb_nodes[id]))
			atom_say("Sucessfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_hand()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			stored_research.research_logs += "[logname] researched node id [id] for [price] points."
			return TRUE
		else
			atom_say("Failed to research node: Internal database error!")
			return FALSE
	atom_say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/attack_hand(mob/user)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return TRUE
	tgui_interact(user)

/obj/machinery/computer/rdconsole/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RndConsole", name, 800, 550, master_ui, state)
		ui.open()

/obj/machinery/computer/rdconsole/proc/tgui_machine_data(obj/machinery/r_n_d/machine, list/data)
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

	if (!is_lathe && !is_imprinter)
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
		if(D.build_type & AUTOLATHE)
			return TRUE

		if(D.build_type & PROTOLATHE)
			for(var/M in D.materials)
				if(M != MAT_METAL && M != MAT_GLASS)
					return FALSE
			return TRUE

	return FALSE

/obj/machinery/computer/rdconsole/tgui_data(mob/user)
	var/list/data = list()

	data["menu"] = menu
	data["submenu"] = submenu
	data["wait_message"] = wait_message
	data["can_research"] = id

	data["linked_destroy"] = linked_destroy ? 1 : 0
	data["linked_lathe"] = linked_lathe ? 1 : 0
	data["linked_imprinter"] = linked_imprinter ? 1 : 0
	data["disk_data"] = null
	data["loaded_item"] = null
	data["category"] = selected_category

	if(menu == MENU_DISK)
		if(d_disk != null && d_disk.blueprint != null && submenu == SUBMENU_MAIN)
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
				if(b_type & PODFAB) lathe_types += "Spacepod Fabricator"
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
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
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

		var/list/boostable_nodes = list()

		var/list/listin = techweb_item_boost_check(linked_destroy.loaded_item)
		for(var/node_id in listin)
			var/datum/techweb_node/N = SSresearch.get_techweb_node_by_id(node_id)
			var/worth = listin[N.id]
			if(!stored_research.researched_nodes[N.id] && !stored_research.boosted_nodes[N.id])
				boostable_nodes += list(list("id" = N.id, "name" = N.display_name, "worth" = worth, "boostable" = TRUE))
			else
				boostable_nodes += list(list("id" = N.id, "name" = N.display_name, "worth" = worth, "boostable" = FALSE))

		var/point_value = techweb_item_point_check(linked_destroy.loaded_item)
		if(point_value && isnull(stored_research.deconstructed_items[linked_destroy.loaded_item.type]))
			boostable_nodes += list(list("id" = null, "name" = "Deconstruct For Research Points", "worth" = point_value, "boostable" = TRUE))

		data["nodes_to_boost"] = boostable_nodes

	else if(menu == MENU_LATHE && linked_lathe)
		tgui_machine_data(linked_lathe, data)
	else if(menu == MENU_IMPRINTER && linked_imprinter)
		tgui_machine_data(linked_imprinter, data)
	else if(menu == MENU_TECHWEBS)
		var/list/available = list()
		var/list/unavailable = list()
		var/list/researched = list()

		for(var/v in stored_research.researched_nodes)
			var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(v)
			var/list/designs = list()
			for(var/id in TN.design_ids)
				designs += list(list("name" = SSresearch.id_name_cache[id]))
			// We can assume unlocked=TRUE here since its an unlocked node
			researched += list(list("id" = TN.id, "displayname" = TN.display_name, "description" = TN.description, "research_cost" = TN.research_cost, "designs" = designs))

		for(var/v in stored_research.available_nodes)
			if(stored_research.researched_nodes[v])
				continue
			var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(v)
			var/list/designs = list()
			for(var/id in TN.design_ids)
				designs += list(list("name" = SSresearch.id_name_cache[id]))
			available += list(list("id" = TN.id, "displayname" = TN.display_name, "description" = TN.description, "research_cost" = TN.research_cost, "designs" = designs))

		for(var/v in SSresearch.techweb_nodes)
			if(stored_research.available_nodes[v] || stored_research.researched_nodes[v])
				continue
			var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(v)
			var/list/designs = list()
			for(var/id in TN.design_ids)
				designs += list(list("name" = SSresearch.id_name_cache[id]))
			unavailable += list(list("id" = TN.id, "displayname" = TN.display_name, "description" = TN.description, "research_cost" = TN.research_cost, "designs" = designs))

		data["available"] = available
		data["unavailable"] = unavailable
		data["researched"] = researched
		data["researchpoints"] = stored_research.research_points

	else if(menu == MENU_TECHWEBS_NODEVIEW)
		data["researchpoints"] = stored_research.research_points
		data["nodename"] = selected_node.display_name
		data["nodedesc"] = selected_node.description
		data["nodecost"] = selected_node.research_cost
		data["nodeid"] = selected_node.id
		var/list/designs = list()
		for(var/id in selected_node.design_ids)
			designs += list(list("name" = SSresearch.id_name_cache[id]))
		data["node_designs"] = designs

		var/list/requirements = list()

		// Build required nodes
		for(var/v in selected_node.prerequisites)
			var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(v)
			var/unlocked = FALSE
			if(stored_research.researched_nodes[v])
				unlocked = TRUE
			requirements += list(list("id" = TN.id, "displayname" = TN.display_name, "description" = TN.description, "research_cost" = TN.research_cost, "unlocked" = unlocked))

		data["node_requirements"] = requirements


		// Build unlocks
		var/list/unlocks = list()
		for(var/v in selected_node.unlocks)
			var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(v)
			unlocks += list(list("id" = TN.id, "displayname" = TN.display_name, "description" = TN.description, "research_cost" = TN.research_cost))

		data["node_unlocks"] = unlocks




	return data

//helper proc that guarantees the wait message will not freeze the UI
/obj/machinery/computer/rdconsole/proc/add_wait_message(message, delay)
	wait_message = message
	wait_message_timer = addtimer(CALLBACK(src, .proc/clear_wait_message), delay, TIMER_UNIQUE | TIMER_STOPPABLE)

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

/obj/machinery/computer/rdconsole/robotics
	name = "robotics R&D console"
	desc = "A console used to interface with R&D tools."
	id = FALSE
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/rdconsole/robotics

/obj/machinery/computer/rdconsole/experiment
	name = "\improper E.X.P.E.R.I-MENTOR R&D console"
	desc = "A console used to interface with R&D tools."
	id = TRUE
	circuit = /obj/item/circuitboard/rdconsole/experiment

/obj/machinery/computer/rdconsole/mechanics
	name = "mechanics R&D console"
	desc = "A console used to interface with R&D tools."
	id = FALSE
	req_access = list(ACCESS_MECHANIC)
	circuit = /obj/item/circuitboard/rdconsole/mechanics

/obj/machinery/computer/rdconsole/public
	name = "public R&D console"
	desc = "A console used to interface with R&D tools."
	id = FALSE
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
