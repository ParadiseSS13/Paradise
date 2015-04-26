/////////////////////////////////////////
/////////////////Misc Designs////////////
/////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Miscellaneous")
	
/datum/design/intellicard
	name = "Intellicard"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$gold" = 200)
	build_path = /obj/item/device/aicard
	category = list("Miscellaneous")
	
/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 500, "$metal" = 500)
	build_path = /obj/item/device/paicard
	category = list("Miscellaneous")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Miscellaneous")

/datum/design/digital_camera
	name = "Digital Camera"
	desc = "Produce an enhanced version of the standard issue camera."
	id = "digitalcamera"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 500, "$glass" = 300)
	build_path = /obj/item/device/camera/digital
	category = list("Miscellaneous")