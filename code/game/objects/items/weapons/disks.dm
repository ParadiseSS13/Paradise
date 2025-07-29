/obj/item/disk
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk0"
	inhand_icon_state = "card-id"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'
	w_class = WEIGHT_CLASS_TINY

/obj/item/disk/data
	name = "Cloning Data Disk"
	var/datum/dna2_record/buf = null
	var/read_only = FALSE //Well,it's still a floppy disk

/obj/item/disk/data/proc/initialize_data()
	buf = new
	buf.dna = new

/obj/item/disk/data/Destroy()
	QDEL_NULL(buf)
	return ..()

/obj/item/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = TRUE

/obj/item/disk/data/demo/New()
	. = ..()
	initialize_data()
	buf.types = DNA2_BUF_UE|DNA2_BUF_UI
	buf.dna.real_name = "God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI = list(0x066,0x000,0x033,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0xAF0,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x000,0x033,0x066,0x0FF,0x4DB,0x002,0x690,0x000,0x000,0x000,0x328,0x045,0x5FC,0x053,0x035,0x035,0x035)
	if(length(buf.dna.UI) != DNA_UI_LENGTH) //If there's a disparity b/w the dna UI string lengths, 0-fill the extra blocks in this UI.
		for(var/i in length(buf.dna.UI) to DNA_UI_LENGTH)
			buf.dna.UI += 0x000
	buf.dna.ResetSE()
	buf.dna.UpdateUI()

/obj/item/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/disk/data/monkey/New()
	. = ..()
	initialize_data()
	buf.types = DNA2_BUF_SE
	var/list/new_SE = list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i = length(new_SE); i <= DNA_SE_LENGTH; i++)
		new_SE += rand(1, 1024)
	buf.dna.SE = new_SE
	buf.dna.SetSEValueRange(GLOB.monkeyblock, 0xDAC, 0xFFF)

//Disk stuff.
/obj/item/disk/data/New()
	. = ..()
	var/diskcolor = pick(0, 1, 2, 3, 4, 5)
	icon_state = "datadisk[diskcolor]"

/obj/item/disk/data/attack_self__legacy__attackchain(mob/user)
	read_only = !read_only
	to_chat(user, "You flip the write-protect tab to [read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/examine(mob/user)
	. = ..()
	. += "The write-protect tab is set to [read_only ? "protected" : "unprotected"]."

/obj/item/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_box"

/obj/item/storage/box/disks/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/disk/data(src)
