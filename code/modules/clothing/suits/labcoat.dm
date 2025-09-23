/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "A suit that protects against minor chemical spills."
	icon = 'icons/obj/clothing/suits/labcoat.dmi'
	icon_state = "labcoat_open"
	inhand_icon_state = "labcoat"
	worn_icon = 'icons/mob/clothing/suits/labcoat.dmi'
	ignore_suitadjust = 0
	suit_adjusted = 1
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/robotanalyzer)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	species_exception = list(/datum/species/golem)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suits/labcoat.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/labcoat.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/labcoat.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/labcoat.dmi'
		)
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"
	permeability_coefficient = 0.35

/obj/item/clothing/suit/storage/labcoat/medical
	name = "medical doctor's labcoat"
	desc = "A suit that protects against minor chemical spills. Has blue medical markings."
	icon_state = "labcoat_medical_open"

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Fancier than the standard model. Has blue medical markings."
	icon_state = "labcoat_cmo_open"
	insert_max = 2
	permeability_coefficient = 0.2

/obj/item/clothing/suit/storage/labcoat/mad
	name = "mad scientist's labcoat"
	desc = "It makes you look capable of konking someone on the noggin and shooting them into space."
	icon_state = "labcoat_mad_open"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "geneticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has wine research markings."
	icon_state = "labcoat_genetics_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "chemist labcoat"
	desc = "A suit that protects against minor chemical spills. Has orange medical markings."
	icon_state = "labcoat_chemist_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "virologist labcoat"
	desc = "A suit that protects against minor chemical spills. Offers slightly more protection against biohazards than the standard model. Has green medical markings."
	icon_state = "labcoat_viro_open"
	permeability_coefficient = 0.2

/obj/item/clothing/suit/storage/labcoat/science
	name = "scientist labcoat"
	desc = "A suit that protects against minor chemical spills. Has purple research markings."
	icon_state = "labcoat_science_open"

/obj/item/clothing/suit/storage/labcoat/mortician
	name = "coroner labcoat"
	desc = "A suit that protects against minor chemical spills. Has black medical markings."
	icon_state = "labcoat_coroner_open"

/obj/item/clothing/suit/storage/labcoat/emt
	name = "\improper EMT labcoat"
	desc = "A comfortable suit for paramedics. Has dark colours and white medical markings."
	icon_state = "labcoat_paramedic_open"

/obj/item/clothing/suit/storage/labcoat/psych
	name = "psychologist labcoat"
	desc = "A suit that protects against minor chemical spills. Has cyan medical markings."
	icon_state = "labcoat_psyche_open"

/obj/item/clothing/suit/storage/labcoat/robowhite
	name = "roboticist labcoat"
	desc = "A suit that protects against minor chemical spills. Has brown research markings."
	icon_state = "labcoat_robowhite_open"

/obj/item/clothing/suit/storage/labcoat/roboblack
	name = "bioengineer labcoat"
	desc = "A black suit that protects against minor chemical spills. Has brown research markings."
	icon_state = "labcoat_roboblack_open"

/obj/item/clothing/suit/storage/labcoat/rd
	name = "research director's labcoat"
	desc = "Fancier than the standard model. Purple with white research markings."
	icon_state = "labcoat_rd_open"
	insert_max = 2

/obj/item/clothing/suit/storage/labcoat/hydro
	name = "hydroponics labcoat"
	desc = "A suit that protects against minor chemical spills. Has green research markings."
	icon_state = "labcoat_botany_open"
	allowed = list(/obj/item/plant_analyzer, /obj/item/reagent_containers/glass/bottle, /obj/item/storage/bag/plants, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/glass/beaker, /obj/item/paper)

/obj/item/clothing/suit/storage/labcoat/abductor
	name = "alien labcoat"
	desc = "A comfortable suit for alien scientists. Has pink markings."
	icon_state = "labcoat_abductor_open"
	allowed = list(/obj/item/abductor/silencer, /obj/item/abductor/gizmo, /obj/item/abductor/mind_device)
