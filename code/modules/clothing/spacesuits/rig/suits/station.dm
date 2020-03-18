/obj/item/clothing/head/helmet/space/new_rig/industrial

/obj/item/clothing/head/helmet/space/new_rig/ce

/obj/item/clothing/head/helmet/space/new_rig/eva

/obj/item/clothing/head/helmet/space/new_rig/hazmat

/obj/item/clothing/head/helmet/space/new_rig/medical

/obj/item/clothing/head/helmet/space/new_rig/hazard

/obj/item/rig/internalaffairs
	name = "augmented tie"
	suit_type = "augmented suit"
	desc = "Prepare for paperwork."
	icon_state = "internalaffairs_rig"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	active_slowdown = 0
	offline_slowdown = 0
	offline_vision_restriction = 0

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/storage/briefcase,/obj/item/storage/secure/briefcase)

	req_access = list()
	req_one_access = list()

	glove_type = null
	helm_type = null
	boot_type = null

/obj/item/rig/internalaffairs/equipped

	req_access = list(ACCESS_LAWYER)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/device/flash,
		/obj/item/rig_module/device/paperdispenser,
		/obj/item/rig_module/device/pen,
		/obj/item/rig_module/device/stamp
		)

	glove_type = null
	helm_type = null
	boot_type = null

/obj/item/rig/industrial
	name = "industrial suit control module"
	suit_type = "industrial hardsuit"
	desc = "A heavy, powerful rig used by construction crews and mining corporations."
	icon_state = "engineering_rig"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	active_slowdown = 3
	offline_slowdown = 10
	offline_vision_restriction = 2
	emp_protection = -20

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/industrial

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/storage/bag/ore,/obj/item/t_scanner,/obj/item/pickaxe, /obj/item/rcd)

	req_access = list()
	req_one_access = list()


/obj/item/rig/industrial/equipped

	initial_modules = list(
		/obj/item/rig_module/device/plasmacutter,
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/orescanner,
		// /obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson
		)

/obj/item/rig/eva
	name = "EVA suit control module"
	suit_type = "EVA hardsuit"
	desc = "A light rig for repairs and maintenance to the outside of habitats and vessels."
	icon_state = "eva_rig"
	active_slowdown = 0
	offline_slowdown = 1
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/eva

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/storage/toolbox,/obj/item/storage/briefcase/inflatable,/obj/item/t_scanner,/obj/item/rcd)

	req_access = list()
	req_one_access = list()

/obj/item/rig/eva/equipped

	initial_modules = list(
		/obj/item/rig_module/device/plasmacutter,
		/obj/item/rig_module/maneuvering_jets,
		// /obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson
		)

//Chief Engineer's rig. This is sort of a halfway point between the old hardsuits (voidsuits) and the rig class.
/obj/item/rig/ce

	name = "advanced voidsuit control module"
	suit_type = "advanced voidsuit"
	desc = "An advanced voidsuit that protects against hazardous, low pressure environments. Shines with a high polish."
	icon_state = "ce_rig"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	active_slowdown = 0
	offline_slowdown = 0
	offline_vision_restriction = 0

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/ce

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/storage/bag/ore,/obj/item/t_scanner,/obj/item/pickaxe, /obj/item/rcd)


	req_access = list()
	req_one_access = list()

	boot_type =  null
	glove_type = null

/obj/item/rig/ce/equipped

	req_access = list(ACCESS_CE)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/plasmacutter,
		// /obj/item/rig_module/device/rcd,
		/obj/item/rig_module/vision/meson
		)

	chest_type = /obj/item/clothing/suit/space/new_rig/ce
	boot_type =  null
	glove_type = null

/obj/item/clothing/suit/space/new_rig/ce
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/rig/hazmat

	name = "AMI control module"
	suit_type = "hazmat hardsuit"
	desc = "An Anomalous Material Interaction hardsuit that protects against the strangest energies the universe can throw at it."
	icon_state = "science_rig"
	active_slowdown = 1
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/hazmat

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/ert

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/pickaxe,/obj/item/healthanalyzer,/obj/item/gps,/obj/item/radio/beacon)

	req_access = list()
	req_one_access = list()

/obj/item/rig/hazmat/equipped

	req_access = list(ACCESS_RD)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets)

/obj/item/rig/medical

	name = "rescue suit control module"
	suit_type = "rescue hardsuit"
	desc = "A durable suit designed for medical rescue in high risk areas."
	icon_state = "medical_rig"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)
	active_slowdown = 1
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/medical

	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical,/obj/item/roller )

	req_access = list()
	req_one_access = list()

/obj/item/rig/medical/equipped

	initial_modules = list(
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/vision/medhud
		)

/obj/item/rig/hazard
	name = "hazard hardsuit control module"
	suit_type = "hazard hardsuit"
	desc = "A Security hardsuit designed for prolonged EVA in dangerous environments."
	icon_state = "hazard_rig"
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
	active_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/hazard

	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/melee/baton)

	req_access = list()
	req_one_access = list()


/obj/item/rig/hazard/equipped

	initial_modules = list(
		/obj/item/rig_module/vision/sechud,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/mounted/taser
		)
