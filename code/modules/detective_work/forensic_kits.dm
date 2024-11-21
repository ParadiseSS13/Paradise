/obj/item/clothing/gloves/color/black/forensics
	transfer_prints = FALSE

// Boxes
/obj/item/storage/box/swabs
	name = "\improper Box of Forensic Swabs"
	desc = "Sterile equipment inside. Avoid contamination."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "sec_box"

/obj/item/storage/box/swabs/populate_contents()
	..()
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)

/obj/item/storage/box/fingerprints
	name = "\improper Box of Fingerprint Cards"
	desc = "Sterile equipment inside. Avoid contamination."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "id_prisoner_box"

/obj/item/storage/box/fingerprints/populate_contents()
	..()
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)
	new /obj/item/sample/print(src)

// Crime scene kit
/obj/item/storage/briefcase/crimekit
	name = "\improper Crime Scene Kit"
	desc = "Stainless steel coated case containing everything a detective could need. Feels heavy."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "case"
	lefthand_file = 'icons/obj/forensics/items_lefthand.dmi'
	righthand_file = 'icons/obj/forensics/items_righthand.dmi'
	item_state = "case"

/obj/item/storage/briefcase/crimekit/populate_contents()
	..()
	new /obj/item/storage/box/swabs(src)
	new /obj/item/storage/box/fingerprints(src)
	new /obj/item/forensics/sample_kit(src)
	new /obj/item/forensics/sample_kit/powder(src)
	new /obj/item/detective_scanner(src)

/datum/supply_packs/security/forensics
	contains = list(/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/det_hat,
					/obj/item/storage/box/swabs,
					/obj/item/storage/box/fingerprints,
					/obj/item/storage/briefcase/crimekit)

/obj/structure/closet/secure_closet/detective/populate_contents()
	new /obj/item/storage/briefcase/crimekit(src)
	. = ..()
