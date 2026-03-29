// Boxes
/obj/item/storage/box/swabs
	name = "box of forensic swabs"
	desc = "A sterile box full of forensic swabs, used to acquire DNA samples and test for lingering weapon residue."
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
	name = "box of fingerprint cards"
	desc = "A sealed box full of fingerprint cards, used to acquire print sets from humanoids."
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
	name = "crime scene kit"
	desc = "A stainless-steel case containing everything a detective could need. It's quite heavy."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "case"
	lefthand_file = 'icons/obj/forensics/items_lefthand.dmi'
	righthand_file = 'icons/obj/forensics/items_righthand.dmi'
	inhand_icon_state = "case"

/obj/item/storage/briefcase/crimekit/populate_contents()
	..()
	new /obj/item/storage/box/swabs(src)
	new /obj/item/storage/box/fingerprints(src)
	new /obj/item/forensics/sample_kit(src)
	new /obj/item/forensics/sample_kit/powder(src)
	new /obj/item/storage/csi_markers(src)

/obj/item/storage/csi_markers
	name = "crime scene markers box"
	desc = "A cardboard box full of crime scene marker cards."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "sec_box"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/csi_markers/populate_contents()
	new /obj/item/csi_marker/n1(src)
	new /obj/item/csi_marker/n2(src)
	new /obj/item/csi_marker/n3(src)
	new /obj/item/csi_marker/n4(src)
	new /obj/item/csi_marker/n5(src)
	new /obj/item/csi_marker/n6(src)
	new /obj/item/csi_marker/n7(src)
