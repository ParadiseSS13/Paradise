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




// The disk itself - does nothing other than exist to hold variables.
/obj/item/disk/rnd_backup_disk
	name = "rnd backup disk"
	desc = "A disk for storing technology data for backup purposes."
	icon_state = "datadisk2"
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	/// Assoc list of tech levels. Key is tech path, value is tech level
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
