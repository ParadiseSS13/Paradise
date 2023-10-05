// R&D backup console - just saves tech levels
/obj/machinery/computer/rnd_backup
	name = "rnd backup console"
	desc = "Can be used to backup an R&D network's research data"
	icon_screen = "comm_logs" // looks good enough
	/// ID to autolink to, used in mapload
	var/autolink_id = null
	/// UID of the network that we use
	var/network_manager_uid = null
	/// Inserted disk
	var/obj/item/disk/rnd_backup_disk/inserted_disk


/obj/machinery/computer/rnd_backup/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/computer/rnd_backup/LateInitialize()
	for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
		if(RNC.network_name == autolink_id)
			network_manager_uid = RNC.UID()
			RNC.backupconsoles += UID()


/obj/machinery/computer/rnd_backup/proc/unlink()
	network_manager_uid = null
	SStgui.update_uis(src)


/obj/machinery/computer/rnd_backup/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/rnd_backup_disk) && istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(!H.unEquip(O))
			return TRUE

		O.forceMove(src)
		inserted_disk = O
		to_chat(user, "<span class='notice'>You insert [O] into [src].</span<")
		return TRUE

	return ..()


/obj/machinery/computer/rnd_backup/proc/eject_disk()
	if(!inserted_disk)
		return

	inserted_disk.forceMove(get_turf(src))
	inserted_disk = null


/obj/machinery/computer/rnd_backup/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)


/obj/machinery/computer/rnd_backup/ui_data(mob/user)
	var/list/data = list()

	if(inserted_disk)
		data["disk_name"] = inserted_disk.name
		data["last_timestamp"] = inserted_disk.last_backup_time || "None"


	var/has_network = FALSE

	var/list/tech_assoc_temp = list()

	if(network_manager_uid)
		var/obj/machinery/computer/rnd_network_controller/RNC = locateUID(network_manager_uid)
		if(RNC)
			var/datum/research/files = RNC.research_files
			has_network = TRUE
			network_manager_uid = null

			data["linked"] = TRUE
			data["network_name"] = RNC.network_name
			data["techs"] = list()

			for(var/tech_id in files.known_tech)
				if(!(tech_id in tech_assoc_temp))
					tech_assoc_temp[tech_id] = list()

				var/datum/tech/T = files.known_tech[tech_id]
				var/list/tech_data = tech_assoc_temp[tech_id]
				tech_data["name"] = T.name
				tech_data["network_level"] = T.level

	if(inserted_disk)
		for(var/tech_id in inserted_disk.stored_tech_assoc)
			if(!(tech_id in tech_assoc_temp))
				tech_assoc_temp[tech_id] = list()

			var/tech_name = GLOB.rnd_tech_id_to_name[tech_id]
			var/list/tech_data = tech_assoc_temp[tech_id]
			tech_data["name"] = tech_name
			tech_data["disk_level"] = inserted_disk.stored_tech_assoc[tech_id]

	if(!has_network)
		data["linked"] = FALSE
		var/list/controllers = list()
		for(var/obj/machinery/computer/rnd_network_controller/RNC in GLOB.rnd_network_managers)
			controllers += list(list("addr" = RNC.UID(), "net_id" = RNC.network_name))

		data["controllers"] = controllers

	return data


/obj/machinery/computer/rnd_backup/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RndBackupConsole", name, 400, 300, master_ui, state)
		ui.open()


// The disk itself - does nothing other than exist to hold variables.
/obj/item/disk/rnd_backup_disk
	name = "rnd backup disk"
	desc = "A disk for storing technology data for backup purposes."
	icon_state = "datadisk2"
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	/// Assoc list of tech levels. Key is tech ID, value is tech level
	var/list/stored_tech_assoc = list()
	/// Text of last backup time
	var/last_backup_time


/obj/item/disk/rnd_backup_disk/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/disk/rnd_backup_disk/examine(mob/user)
	. = ..()
	if (last_backup_time)
		. += "The timestamp label reads '[last_backup_time]'."
	else
		. += "The timestamp label is empty."


/obj/item/disk/rnd_backup_disk/admin
	name = "admin rnd backup disk"
	desc = "You shouldnt have this."


/obj/item/disk/rnd_backup_disk/admin/Initialize(mapload)
	. = ..()
	// Just make it 10 on everything - who cares
	for(var/tech_id in GLOB.rnd_tech_id_to_name)
		stored_tech_assoc[tech_id] = 10
