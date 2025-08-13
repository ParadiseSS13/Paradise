/obj/structure/closet/secure_closet/expedition
	name = "expeditors locker"
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "explorer"
	req_access = list(ACCESS_EXPEDITION)

/obj/structure/closet/secure_closet/expedition/populate_contents()
	new /obj/item/gun/energy/laser/awaymission_aeg/rnd(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/paper/pamphlet/gateway(src)

/obj/structure/closet/secure_closet/geneticist
	name = "geneticist's locker"
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "gen"
	req_access = list(ACCESS_GENETICS)

/obj/structure/closet/secure_closet/geneticist/populate_contents()
	new /obj/item/storage/backpack/genetics(src)
	new /obj/item/storage/backpack/satchel_gen(src)
	new /obj/item/clothing/under/rank/rnd/geneticist(src)
	new /obj/item/clothing/under/rank/rnd/geneticist/skirt(src)
	new /obj/item/clothing/suit/storage/labcoat/genetics(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/sandal/white(src)
	new /obj/item/radio/headset/headset_medsci(src)
	new /obj/item/radio/headset/headset_medsci(src)
	new /obj/item/storage/box/disks(src)
	new /obj/item/storage/box/syringes(src)

/obj/structure/closet/crate/freezer/iv_storage/organ
	name = "organ freezer"
	desc = "Холодильник для хранения органов и пакетов с кровью."
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "organ_freezer"
	icon_opened = "organ_freezer_open"
	icon_closed = "organ_freezer"
	storage_capacity = 60

/obj/structure/closet/secure_closet/freezer/products
	name = "refrigerator"
	icon_state = "freezer"

/obj/structure/closet/secure_closet/freezer/products/populate_contents()
	new /obj/item/storage/box/donkpockets(src)
	new /obj/item/storage/box/donkpockets(src)
	new /obj/item/storage/fancy/egg_box(src)
	new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/paramedic/populate_contents()
	. = ..()
	new /obj/item/clothing/suit/storage/paramedic/pmed_jacket_new(src)
	new /obj/item/clothing/suit/storage/paramedic/pmed_jacket_new(src)

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

// MARK: Wall Lockers
/obj/structure/closet/walllocker
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "generic"
	door_anim_time = 2.0
	enable_door_overlay = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker, 32, 32)

/obj/structure/closet/walllocker/emerglocker
	door_anim_time = 2

/obj/structure/closet/walllocker/firelocker
	name = "fire-safety locker"
	icon_state = "firecloset"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/firelocker, 32, 32)

/obj/structure/closet/walllocker/firelocker/populate_contents()
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/clothing/head/hardhat/red(src)
	new /obj/item/crowbar/red(src)

/obj/structure/closet/walllocker/medlocker
	name = "medicine locker"
	icon_state = "medcloset"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/walllocker/medlocker, 32, 32)

/obj/structure/closet/walllocker/medlocker/populate_contents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/stack/medical/splint(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/epinephrine(src)

// MARK: Wall Locker Frame
/obj/item/mounted/frame/wall_locker
	name = "wall locker frame"
	desc = "Used for building lockers on the walls, so they won't bother you from walking around. Amazing."
	icon = 'modular_ss220/objects/icons/closets.dmi'
	icon_state = "wall_locker_frame"
	w_class = WEIGHT_CLASS_NORMAL
	mount_requirements = MOUNTED_FRAME_SIMFLOOR | MOUNTED_FRAME_NOSPACE
	metal_sheets_refunded = 2
	allow_floor_mounting = FALSE

/obj/item/mounted/frame/wall_locker/do_build(turf/on_wall, mob/user)
	new /obj/structure/closet/walllocker(get_turf(src), get_dir(user, on_wall), TRUE)
	qdel(src)

/obj/structure/closet/walllocker/Initialize(mapload, direction, building)
	. = ..()

	if(building)
		setDir(direction)
		set_pixel_offsets_from_dir(32, -32, 32, -32)
