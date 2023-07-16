// R&D backup console - just saves tech levels
/obj/machinery/computer/rnd_backup
	name = "rnd backup console"
	desc = "Can be used to backup an R&D network's research data"
	icon_screen = "comm_logs" // looks good enough



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
