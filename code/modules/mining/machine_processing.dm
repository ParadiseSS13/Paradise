#define SMELT_AMOUNT 10

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral
	var/input_dir = NORTH // the direction the machine takes in items
	var/output_dir = SOUTH // the direction the machine outputs items
	var/turf/input_turf = null // the turf that is to the north/south/east/west from this machine. Used for registering a signal when something crosses into the turf
	processing_flags = START_PROCESSING_MANUALLY | FAST_PROCESS_SPEED // all /obj/machinery/mineral type machines should being processing only when certain conditions are met

/obj/machinery/mineral/Initialize(mapload)
	. = ..()
	register_input_turf()

/obj/machinery/mineral/Destroy()
	. = ..()
	unregister_input_turf()

/obj/machinery/mineral/proc/unload_mineral(atom/movable/S)
	S.forceMove(drop_location())
	var/turf/T = get_step(src,output_dir)
	if(T)
		S.forceMove(T)

obj/machinery/mineral/proc/register_input_turf()
	input_turf = get_step(src, input_dir) // get the turf that players need to place the ore/items onto, defaults to NORTH at round start
	if(input_turf && istype(input_turf)) // make sure there is actually a turf
		RegisterSignal(input_turf, COMSIG_ATOM_ENTERED, .proc/begin_processing, TRUE) // listens for when an atom ENTERS the input_turf, tells the machine to begin processing
		return TRUE
	return FALSE

obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		UnregisterSignal(input_turf, COMSIG_ATOM_ENTERED)

/obj/machinery/mineral/begin_processing()
	. = ..()
	// unregistering here prevents `begin_processing` getting called for every item thats dropped onto the `input_turf`
	// if we did not unregister, that means when someone drops 200 ore stacks, it would call begin_processing 200 times. Not good, and also unnecessary.
	unregister_input_turf()

/obj/machinery/mineral/end_processing()
	. = ..()
	 // re-register the signal we unregistered in begin_processing
	register_input_turf()

/obj/machinery/mineral/process()
	if(!..())
		return FALSE
	if(!input_turf) // there's no input turf
		if(!register_input_turf()) // try to find one
			end_processing() // there's no valid turf in whichever direction input_dir is set to
			return FALSE
	return TRUE

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
	var/obj/machinery/mineral/CONSOLE = null
	var/on = FALSE
	var/selected_material = MAT_METAL
	var/selected_alloy = null
	var/datum/research/files

/obj/machinery/mineral/processing_unit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), INFINITY, TRUE, /obj/item/stack)
	files = new /datum/research/smelter(src)

/obj/machinery/mineral/processing_unit/Destroy()
	CONSOLE = null
	QDEL_NULL(files)
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/mineral/processing_unit/process()
	if(!..())
		return

	for(var/obj/item/stack/ore/O in input_turf)
		process_ore(O)
		CHECK_TICK

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
	GET_COMPONENT(materials, /datum/component/material_container)
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
	GET_COMPONENT(materials, /datum/component/material_container)
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
	GET_COMPONENT(materials, /datum/component/material_container)
	var/datum/material/mat = materials.materials[selected_material]
	if(mat)
		var/sheets_to_remove = (mat.amount >= (MINERAL_MATERIAL_AMOUNT * SMELT_AMOUNT) ) ? SMELT_AMOUNT : round(mat.amount /  MINERAL_MATERIAL_AMOUNT)
		if(!sheets_to_remove)
			on = FALSE
			end_processing()
		else
			var/out = get_step(src, output_dir)
			materials.retrieve_sheets(sheets_to_remove, selected_material, out)

/obj/machinery/mineral/processing_unit/proc/smelt_alloy()
	var/datum/design/alloy = files.FindDesignByID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		end_processing()
		return

	var/amount = can_smelt(alloy)

	if(!amount)
		on = FALSE
		end_processing()
		return

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.use_amount(alloy.materials, amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D)
	if(D.make_reagents.len)
		return FALSE

	var/build_amount = SMELT_AMOUNT

	GET_COMPONENT(materials, /datum/component/material_container)

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