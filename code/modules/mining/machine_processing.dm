#define SMELT_AMOUNT 10

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral
	process_start_flag = START_PROCESSING_MANUALLY
	process_speed_flag = FAST_PROCESS_SPEED
	use_machinery_signals = TRUE

	/// The current direction of `input_turf`, in relation to the machine.
	var/input_dir = NORTH
	/// The current direction of `output_turf`, in relation to the machine.
	var/output_dir = SOUTH
	/// The turf the machine listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null
	/// The turf that the machine will output items onto, either with the `unload_mineral` proc, or some other custom defined one.
	var/turf/output_turf = null
	/// Determines if this machine needs to pick up items. Used to avoid needlessly registering signals.
	var/needs_item_input = FALSE

/obj/machinery/mineral/Initialize(mapload)
	. = ..()
	if(needs_item_input)
		register_input_turf()
		RegisterSignal(src, COMSIG_OBJ_SETANCHORED, .proc/on_set_anchored)
		RegisterSignal(src, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), .proc/unregister_input_turf, TRUE)
		RegisterSignal(src, COMSIG_MACHINERY_POWER_RESTORED, .proc/register_input_turf, TRUE)
		output_turf = get_step(src, output_dir)

/// The machine regained power, start listening for signals again.
/obj/machinery/mineral/on_power_gain()
	if(needs_item_input)
		register_input_turf()

/// If the there's no power to this machine, there's no reason to listen for signals.
/obj/machinery/mineral/on_power_loss()
	unregister_input_turf()

/// Gets the turf in the `input_dir` direction adjacent to the machine, and registers signals for ATOM_ENTERED and ATOM_CREATED. Calls the `pickup_item()` proc when it recieves these signals.
/obj/machinery/mineral/proc/register_input_turf()
	if(!anchored || input_turf) // If we already have an input_turf or we are not anchored, return.
		return
	input_turf = get_step(src, input_dir)
	RegisterSignal(input_turf, list(COMSIG_ATOM_CREATED, COMSIG_ATOM_ENTERED), .proc/pickup_item)
	try_pickup_all_items() // Get any items that may already be on the input turf.

/// Unregisters signals that are registered to the machine's input turf, if it has one.
/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		UnregisterSignal(input_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_CREATED))
		input_turf = null

/**
	Base proc for all `/mineral` subtype machines to use. Place your item pickup behavior in this proc when you override it for your specific machine.

	Called when the `input_turf` recieves the COMSIG_ATOM_ENTERED or COMSIG_ATOM_CREATED signals.

	Arguments:
	* source - the turf that is listening for the signals.
	* target - the atom that just moved onto the `source` turf.
	* oldLoc - the old location that `target` was at before moving onto `source`.
*/
/obj/machinery/mineral/proc/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	return

/// Tries to pickup any valid item inside the input turf. Usually called when the machine regains power, or has it's input turf changed.
/obj/machinery/mineral/proc/try_pickup_all_items()
	if(!input_turf)
		return
	for(var/atom/movable/AM in input_turf)
		pickup_item(loc, AM)

/// Generic unloading proc. Takes an atom as an argument and forceMove's it onto the `output_turf`.
/obj/machinery/mineral/proc/unload_mineral(atom/movable/AM)
	AM.forceMove(drop_location())
	if(output_turf)
		AM.forceMove(output_turf)

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST

/obj/machinery/mineral/processing_unit_console/Initialize(mapload)
	. = ..()
	machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
	if(machine)
		machine.CONSOLE = src
	else
		return INITIALIZE_HINT_QDEL

/obj/machinery/mineral/processing_unit_console/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)
	if(..())
		return TRUE

	return ui_interact(user)

/obj/machinery/mineral/processing_unit_console/ui_interact(mob/user)
	. = ..()
	if(!machine)
		return

	var/dat = machine.get_machine_data()

	var/datum/browser/popup = new(user, "processing", "Smelting Console", 300, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return TRUE

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["material"])
		machine.selected_material = href_list["material"]
		machine.selected_alloy = null

	if(href_list["alloy"])
		machine.selected_material = null
		machine.selected_alloy = href_list["alloy"]

	if(href_list["set_on"])
		machine.on = (href_list["set_on"] == "on")
		machine.begin_processing()

	updateUsrDialog()
	return TRUE

/obj/machinery/mineral/processing_unit_console/Destroy()
	machine = null
	return ..()

/**********************Mineral processing unit**************************/

/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE
	needs_item_input = TRUE
	var/obj/machinery/mineral/CONSOLE = null
	var/on = FALSE
	var/selected_material = MAT_METAL
	var/selected_alloy = null
	var/datum/research/files
	var/datum/component/material_container/materials

/obj/machinery/mineral/processing_unit/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), INFINITY, TRUE, /obj/item/stack)
	files = new /datum/research/smelter(src)

/obj/machinery/mineral/processing_unit/Destroy()
	CONSOLE = null
	QDEL_NULL(files)
	materials.retrieve_all()
	return ..()

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	if(istype(target, /obj/item/stack/ore))
		addtimer(CALLBACK(src, .proc/process_ore, target), 2)

/obj/machinery/mineral/processing_unit/process()
	. = ..()
	if(on)
		if(selected_material)
			smelt_ore()

		else if(selected_alloy)
			smelt_alloy()

		if(CONSOLE)
			CONSOLE.updateUsrDialog()
	else
		end_processing()

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/stack/ore/O)
	var/material_amount = materials.get_item_material_amount(O)
	if(!materials.has_space(material_amount))
		unload_mineral(O)
	else
		materials.insert_item(O)
		qdel(O)
		if(CONSOLE)
			CONSOLE.updateUsrDialog()

/obj/machinery/mineral/processing_unit/proc/get_machine_data()
	var/dat = "<b>Smelter control console</b><br><br>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		dat += "<span class=\"res_name\">[M.name]: </span>[M.amount] cm&sup3;"
		if(selected_material == mat_id)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=[CONSOLE.UID()];material=[mat_id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	dat += "<b>Smelt Alloys</b><br>"

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		dat += "<span class=\"res_name\">[D.name] "
		if(selected_alloy == D.id)
			dat += " <i>Smelting</i>"
		else
			dat += " <A href='?src=[CONSOLE.UID()];alloy=[D.id]'><b>Not Smelting</b></A> "
		dat += "<br>"

	dat += "<br><br>"
	//On or off
	dat += "Machine is currently "
	if(on)
		dat += "<A href='?src=[CONSOLE.UID()];set_on=off'>On</A> "
	else
		dat += "<A href='?src=[CONSOLE.UID()];set_on=on'>Off</A> "

	return dat

/obj/machinery/mineral/processing_unit/proc/smelt_ore()
	var/datum/material/mat = materials.materials[selected_material]
	if(mat)
		var/sheets_to_remove = (mat.amount >= (MINERAL_MATERIAL_AMOUNT * SMELT_AMOUNT) ) ? SMELT_AMOUNT : round(mat.amount /  MINERAL_MATERIAL_AMOUNT)
		if(!sheets_to_remove)
			on = FALSE
		else
			var/out = get_step(src, output_dir)
			materials.retrieve_sheets(sheets_to_remove, selected_material, out)

/obj/machinery/mineral/processing_unit/proc/smelt_alloy()
	var/datum/design/alloy = files.FindDesignByID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		return

	var/amount = can_smelt(alloy)

	if(!amount)
		on = FALSE
		return

	materials.use_amount(alloy.materials, amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D)
	if(D.make_reagents.len)
		return FALSE

	var/build_amount = SMELT_AMOUNT

	for(var/mat_id in D.materials)
		var/M = D.materials[mat_id]
		var/datum/material/smelter_mat  = materials.materials[mat_id]

		if(!M || !smelter_mat)
			return FALSE

		build_amount = min(build_amount, round(smelter_mat.amount / M))

	return build_amount

/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

#undef SMELT_AMOUNT
