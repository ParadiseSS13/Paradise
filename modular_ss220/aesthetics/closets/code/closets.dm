/obj/structure/closet/cabinet
	icon = 'modular_ss220/aesthetics/closets/icons/closets.dmi'

/obj/structure/closet/secure_closet/detective
	icon = 'modular_ss220/aesthetics/closets/icons/closets.dmi'

/obj/structure/closet/secure_closet/bar
	icon = 'modular_ss220/aesthetics/closets/icons/closets.dmi'

/obj/structure/closet/secure_closet/personal/cabinet
	icon = 'modular_ss220/aesthetics/closets/icons/closets.dmi'

// MARK: Ghost Bar
/obj/structure/closet/secure_closet/medical_ghostbar
	name = "medical doctor's locker"
	icon_state = "med_secure"
	opened_door_sprite = "white_secure"

/obj/structure/closet/secure_closet/medical_ghostbar/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/under/rank/medical/doctor(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/shoes/sandal/white(src)
