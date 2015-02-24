/*
	Computer devices that can store programs, files, etc.
*/

/obj/item/part/computer/storage
	name			= "Storage Device"
	desc			= "A device used for storing and retrieving digital information."

	// storage capacity, kb
	var/volume		= 0
	var/max_volume	= 64		// should be enough for anyone

	var/driveletter	= null		// drive letter according to the computer

	var/list/files	= list()	// a list of files in the memory (ALL files)
	var/removeable	= 0			// determinse if the storage device is a removable hard drive (ie floppy)


	var/writeprotect = 0		// determines if the drive forbids writing.
								// note that write-protect is hardware and does not respect emagging.

	var/list/spawnfiles = list()// For mappers, special drives, and data disks

	New()
		..()
		if(islist(spawnfiles))
			if(removeable && spawnfiles.len)
				var/obj/item/part/computer/storage/removable/R = src
				R.inserted = new(src)
				if(writeprotect)
					R.inserted.writeprotect = 1
			for(var/typekey in spawnfiles)
				addfile(new typekey(),1)

	// Add a file to the hard drive, returns 0 if failed
	// forced is used when spawning files on a write-protect drive
	proc/addfile(var/datum/file/F,var/forced = 0)
		if(!F || crit_fail || (F in files))
			return 1
		if(writeprotect && !forced)
			return 0
		if(volume + F.volume > max_volume)
			if(!forced)
				return 0
			max_volume = volume + F.volume

		files.Add(F)
		volume += F.volume
		F.computer = computer
		F.device = src
		return 1
	proc/removefile(var/datum/file/F,var/forced = 0)
		if(!F || !(F in files))
			return 1
		if(writeprotect && !forced)
			return 0

		files -= F
		volume -= F.volume
		if(F.device == src)
			F.device = null
			F.computer = null
		return 1

	init(var/obj/machinery/computer/target)
		computer = target
		for(var/datum/file/F in files)
			F.computer = computer

/*
	Standard hard drives for computers. Used in computer construction
*/

/obj/item/part/computer/storage/hdd
	name = "Hard Drive"
	max_volume = 25000
	icon_state = "hdd1"


/obj/item/part/computer/storage/hdd/big
	name = "Big Hard Drive"
	max_volume = 50000
	icon_state = "hdd2"

/obj/item/part/computer/storage/hdd/gigantic
	name = "Gigantic Hard Drive"
	max_volume = 75000
	icon_state = "hdd3"

/*
	Removeable hard drives for portable storage
*/

/obj/item/part/computer/storage/removable
	name = "Disk Drive"
	max_volume = 3000
	removeable = 1

	attackby_types = list(/obj/item/weapon/disk/file, /obj/item/weapon/pen)
	var/obj/item/weapon/disk/file/inserted = null

	proc/eject_disk(var/forced = 0)
		if(!forced)
			return
		files = list()
		inserted.loc = computer.loc
		if(usr)
			if(!usr.get_active_hand())
				usr.put_in_active_hand(inserted)
			else if(forced && !usr.get_inactive_hand())
				usr.put_in_inactive_hand(inserted)
		for(var/datum/file/F in inserted.files)
			F.computer = null
		inserted = null


	attackby(obj/O as obj, mob/user as mob)
		if(inserted && istype(O,/obj/item/weapon/pen))
			usr << "You use [O] to carefully pry [inserted] out of [src]."
			eject_disk(forced = 1)
			return

		if(istype(O,/obj/item/weapon/disk/file))
			if(inserted)
				usr << "There's already a disk in [src]!"
				return

			usr << "You insert [O] into [src]."
			usr.drop_item()
			O.loc = src
			inserted = O
			writeprotect = inserted.writeprotect

			files = inserted.files
			for(var/datum/file/F in inserted.files)
				F.computer = computer

			return

		..()

	addfile(var/datum/file/F)
		if(!F || !inserted)
			return 0

		if(F in inserted.files)
			return 1

		if(inserted.volume + F.volume > inserted.max_volume)
			return 0

		inserted.files.Add(F)
		F.computer = computer
		F.device = inserted
		return 1

/*
	Removable hard drive presents...
	removeable disk!
*/

/obj/item/weapon/disk/file
	//parent_type = /obj/item/part/computer/storage // todon't: do this
	name = "Data Disk"
	desc = "A device that can be inserted and removed into computers easily as a form of portable data storage. This one stores 1 Megabyte"
	var/list/files
	var/list/spawn_files = list()
	var/writeprotect = 0
	var/volume = 0
	var/max_volume = 1028


	New()
		..()
		icon_state = "datadisk[rand(0,6)]"
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)
		files = list()
		if(istype(spawn_files))
			for(var/typekey in spawn_files)
				var/datum/file/F = new typekey()
				F.device = src
				files += F
				volume += F.volume
