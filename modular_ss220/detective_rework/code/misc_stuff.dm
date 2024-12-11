/obj/item/clothing/gloves/color/black/forensics
	transfer_prints = FALSE

// Boxes
/obj/item/storage/box/swabs
	name = "\improper коробка с наборами для взятия образцов"
	desc = "Стерильное оборудование внутри. Не допускать загрязнения."
	icon = 'modular_ss220/aesthetics/boxes/icons/boxes.dmi'
	icon_state = "dnakit"

/obj/item/storage/box/swabs/populate_contents()
	..()
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)
	new /obj/item/forensics/swab(src)

/obj/item/storage/box/fingerprints
	name = "\improper коробка со дактилоскопическими картами"
	desc = "Стерильное оборудование внутри. Не допускать загрязнения."
	icon = 'modular_ss220/aesthetics/boxes/icons/boxes.dmi'
	icon_state = "dnakit"

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
	name = "\improper набор для осмотра места преступления"
	desc = "Чемодан с покрытием из нержавеющей стали для всех ваших криминалистических нужд. По ощущениям тяжелый."
	icon = 'modular_ss220/detective_rework/icons/forensics.dmi'
	icon_state = "case"
	lefthand_file = 'modular_ss220/detective_rework/icons/items_lefthand.dmi'
	righthand_file = 'modular_ss220/detective_rework/icons/items_righthand.dmi'
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
