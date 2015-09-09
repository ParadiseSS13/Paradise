/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon_state = "labcoat_open"
	item_state = "labcoat"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/device/analyzer,/obj/item/device/antibody_scanner,/obj/item/stack/medical,/obj/item/weapon/dnainjector,/obj/item/weapon/reagent_containers/dropper,/obj/item/weapon/reagent_containers/syringe,/obj/item/weapon/reagent_containers/hypospray,/obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen,/obj/item/weapon/reagent_containers/glass/bottle,/obj/item/weapon/reagent_containers/glass/beaker,/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/storage/pill_bottle,/obj/item/weapon/paper,/obj/item/device/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 50, rad = 0)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

	verb/toggle()
		set name = "Toggle Labcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		switch(icon_state)
			if("labcoat_open")
				src.icon_state = "labcoat"
				usr << "You button up the labcoat."
			if("labcoat")
				src.icon_state = "labcoat_open"
				usr << "You unbutton the labcoat."
			if("labcoat_cmo_open")
				src.icon_state = "labcoat_cmo"
				usr << "You button up the labcoat."
			if("labcoat_cmo")
				src.icon_state = "labcoat_cmo_open"
				usr << "You unbutton the labcoat."
			if("labcoat_gen_open")
				src.icon_state = "labcoat_gen"
				usr << "You button up the labcoat."
			if("labcoat_gen")
				src.icon_state = "labcoat_gen_open"
				usr << "You unbutton the labcoat."
			if("labcoat_chem_open")
				src.icon_state = "labcoat_chem"
				usr << "You button up the labcoat."
			if("labcoat_chem")
				src.icon_state = "labcoat_chem_open"
				usr << "You unbutton the labcoat."
			if("labcoat_vir_open")
				src.icon_state = "labcoat_vir"
				usr << "You button up the labcoat."
			if("labcoat_vir")
				src.icon_state = "labcoat_vir_open"
				usr << "You unbutton the labcoat."
			if("labcoat_tox_open")
				src.icon_state = "labcoat_tox"
				usr << "You button up the labcoat."
			if("labcoat_tox")
				src.icon_state = "labcoat_tox_open"
				usr << "You unbutton the labcoat."
			if("labgreen_open")
				src.icon_state = "labgreen"
				usr << "You button up the labcoat."
			if("labgreen")
				src.icon_state = "labgreen_open"
				usr << "You unbutton the labcoat."
			if("labcoat_mort_open")
				src.icon_state = "labcoat_mort"
				usr << "You button up the labcoat."
			if("labcoat_mort")
				src.icon_state = "labcoat_mort_open"
				usr << "You unbutton the labcoat."
			else
				usr << "You attempt to button-up the velcro on your [src], before promptly realising how retarded you are."
				return
		usr.update_inv_wear_suit()	//so our overlays update

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Bluer than the standard model."
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/mad
	name = "The Mad Scientist's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labcoat_green_open"
	item_state = "labcoat_green"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "Geneticist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a blue stripe on the shoulder."
	icon_state = "labcoat_gen_open"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "Chemist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has an orange stripe on the shoulder."
	icon_state = "labcoat_chem_open"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "Virologist Labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has a green stripe on the shoulder."
	icon_state = "labcoat_vir_open"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/science
	name = "Scientist Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a purple stripe on the shoulder."
	icon_state = "labcoat_tox_open"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/storage/labcoat/mortician
	name = "Coroner Labcoat"
	desc = "A suit that protects against minor chemical spills. Has a black stripe on the shoulder."
	icon_state = "labcoat_mort_open"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)
