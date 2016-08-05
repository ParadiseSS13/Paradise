/obj/item/clothing/head/helmet/space/new_rig/ert

/obj/item/weapon/rig/ert
	name = "ERT-C hardsuit control module"
	desc = "A suit worn by the commander of an Emergency Response Team. Has blue highlights. Armoured and space ready."
	suit_type = "ERT commander"
	icon_state = "ert_commander_rig"

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/ert

	req_access = list(access_cent_specops)

	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/weapon/rcd, /obj/item/weapon/crowbar, \
	/obj/item/weapon/screwdriver, /obj/item/weapon/weldingtool, /obj/item/weapon/wirecutters, /obj/item/weapon/wrench, /obj/item/device/multitool, \
	/obj/item/device/radio, /obj/item/device/analyzer,/obj/item/weapon/storage/briefcase/inflatable, /obj/item/weapon/melee/baton, /obj/item/weapon/gun, \
	/obj/item/weapon/storage/firstaid, /obj/item/weapon/reagent_containers/hypospray, /obj/item/roller)

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/datajack,
		)

/obj/item/weapon/rig/ert/engineer
	name = "ERT-E suit control module"
	desc = "A suit worn by the engineering division of an Emergency Response Team. Has orange highlights. Armoured and space ready."
	suit_type = "ERT engineer"
	icon_state = "ert_engineer_rig"
	siemens_coefficient = 0

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/plasmacutter,
		// /obj/item/rig_module/device/rcd
		)

/obj/item/weapon/rig/ert/medical
	name = "ERT-M suit control module"
	desc = "A suit worn by the medical division of an Emergency Response Team. Has white highlights. Armoured and space ready."
	suit_type = "ERT medic"
	icon_state = "ert_medical_rig"

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/chem_dispenser/injector
		)

/obj/item/weapon/rig/ert/security
	name = "ERT-S suit control module"
	desc = "A suit worn by the security division of an Emergency Response Team. Has red highlights. Armoured and space ready."
	suit_type = "ERT security"
	icon_state = "ert_security_rig"

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/mounted/egun,
		)

/obj/item/weapon/rig/ert/assetprotection
	name = "Heavy Asset Protection suit control module"
	desc = "A heavy suit worn by the highest level of Asset Protection, don't mess with the person wearing this. Armoured and space ready."
	suit_type = "heavy asset protection"
	icon_state = "asset_protection_rig"

	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/maneuvering_jets,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/vision/multi,
		/obj/item/rig_module/mounted/egun,
		/obj/item/rig_module/chem_dispenser/injector,
		/obj/item/rig_module/device/plasmacutter,
		// /obj/item/rig_module/device/rcd,
		/obj/item/rig_module/datajack
		)