/obj/item/clothing/head/helmet/space/new_rig/merc

/obj/item/rig/merc
	name = "crimson hardsuit control module"
	desc = "A blood-red hardsuit featuring some fairly illegal technology."
	icon_state = "merc_rig"
	suit_type = "crimson hardsuit"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	active_slowdown = 1
	offline_slowdown = 3
	offline_vision_restriction = 1

	helm_type = /obj/item/clothing/head/helmet/space/new_rig/merc
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/gun,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword,/obj/item/restraints/handcuffs)

	initial_modules = list(
		/obj/item/rig_module/mounted,
		/obj/item/rig_module/vision/thermal,
		/obj/item/rig_module/grenade_launcher,
		/obj/item/rig_module/ai_container,
		// /obj/item/rig_module/power_sink,
		/obj/item/rig_module/electrowarfare_suite,
		/obj/item/rig_module/chem_dispenser/combat,
		// /obj/item/rig_module/fabricator/energy_net
		)

//Has most of the modules removed
/obj/item/rig/merc/empty
	initial_modules = list(
		/obj/item/rig_module/ai_container,
		/obj/item/rig_module/electrowarfare_suite, //might as well
		)
