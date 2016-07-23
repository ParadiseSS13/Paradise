/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat_open"
	ignore_suitadjust = 0
	suit_adjusted = 1
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/food/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/device/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 50, rad = 0)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo_open"

/obj/item/clothing/suit/storage/labcoat/mad
	name = "mad scientist's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labcoat_green_open"
	item_state = "labcoat_green_open"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"
	item_state = "labcoat_gen_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"
	item_state = "labcoat_chem_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir_open"

/obj/item/clothing/suit/storage/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox_open"
	item_state = "labcoat_tox_open"

/obj/item/clothing/suit/storage/labcoat/mortician
	name = "coroner labcoat"
	desc = "A suit that protects against minor chemical spills. Has a black stripe on the shoulder."
	icon_state = "labcoat_mort_open"
	item_state = "labcoat_mort_open"

/obj/item/clothing/suit/storage/labcoat/emt
	name = "EMT labcoat"
	desc = "A comfortable suit for paramedics. Has dark colours."
	icon_state = "labcoat_emt_open"
	item_state = "labcoat_emt_open"
