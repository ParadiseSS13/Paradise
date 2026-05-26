/obj/effect/spawner/random/salvage/part
	//icon_state = "matter_bin"
	icon_state = "wrench"

/obj/effect/spawner/random/salvage/part/capacitor
	loot = list(
			/obj/item/stock_parts/capacitor = 120,
			/obj/item/stock_parts/capacitor/adv = 20,
			/obj/item/stock_parts/capacitor/super = 5,
		)

/obj/effect/spawner/random/salvage/part/scanning
	loot = list(
			/obj/item/stock_parts/scanning_module = 120,
			/obj/item/stock_parts/scanning_module/adv = 20,
			/obj/item/stock_parts/scanning_module/phasic = 5,
		)

/obj/effect/spawner/random/salvage/part/manipulator
	loot = list(
			/obj/item/stock_parts/manipulator = 120,
			/obj/item/stock_parts/manipulator/nano = 20,
			/obj/item/stock_parts/manipulator/pico = 5,
		)

/obj/effect/spawner/random/salvage/part/matter_bin
	loot = list(
			/obj/item/stock_parts/matter_bin = 120,
			/obj/item/stock_parts/matter_bin/adv = 20,
			/obj/item/stock_parts/matter_bin/super = 5,
		)

/obj/effect/spawner/random/salvage_laser
	loot = list(
			/obj/item/stock_parts/micro_laser = 120,
			/obj/item/stock_parts/micro_laser/high = 20,
			/obj/item/stock_parts/micro_laser/ultra = 5,
		)

//PROTOLATHE

/obj/effect/spawner/random/salvage
	name = "salvage mats spawner"
	icon_state = "rods"
	loot = list(
		/obj/item/stack/ore/iron,
		/obj/item/stack/ore/gold,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/silver,
		/obj/item/stack/ore/titanium,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/ore/uranium
	)


/obj/effect/spawner/random/salvage/destructive_analyzer
	loot = list(
			/obj/item/storage/toolbox/syndicate/empty = 650,
			/obj/item/gun/energy/kinetic_accelerator = 500,
			/obj/item/gun/energy/kinetic_accelerator/pistol = 500,
			/obj/item/camera_bug = 300,
			/obj/item/clothing/gloves/combat = 200,
			/obj/item/clothing/head/chameleon = 200,
			/obj/item/reagent_containers/hypospray/safety = 100,
			/obj/item/grenade/chem_grenade/metalfoam = 100,

			/obj/item/wrench/ = 30,
			/obj/item/screwdriver/nuke = 30,
			/obj/item/crowbar/small = 30,
			/obj/item/wirecutters = 30,
			/obj/item/multitool/red = 30,
			/obj/item/multitool/ai_detect = 30,
		)

/obj/effect/spawner/random/salvage/machine
	name = "salvageable machine spawner"
	icon_state = "arcade"
	loot = list(
		/obj/structure/salvageable/protolathe,
		/obj/structure/salvageable/circuit_imprinter,
		/obj/structure/salvageable/server,
		/obj/structure/salvageable/machine,
		/obj/structure/salvageable/autolathe,
		/obj/structure/salvageable/computer,
		/obj/structure/salvageable/destructive_analyzer
	)

/obj/effect/spawner/random/salvage/half
	name = "50% salvage spawner"
	spawn_loot_chance = 50
	loot = list(
		/obj/effect/spawner/random/maintenance,
		/obj/effect/spawner/random/salvage/machine,
		// /obj/effect/spawner/random/exotic/ripley,
		/obj/structure/closet/crate/secure/loot,
	)

/obj/effect/spawner/random/salvage/ore/Initialize(mapload)
	spawn_loot_count = pick(list(
		1,
		2,
		3,
		4
	))
	return ..()

/obj/effect/spawner/random/salvage/ore/metal
	loot = list(
		/obj/item/stack/ore/iron
	)

/obj/effect/spawner/random/salvage/ore/gold
	loot = list(
		/obj/item/stack/ore/gold
	)

/obj/effect/spawner/random/salvage/ore/plasma
	loot = list(
		/obj/item/stack/ore/plasma
	)

/obj/effect/spawner/random/salvage/ore/silver
	loot = list(
		/obj/item/stack/ore/silver
	)

/obj/effect/spawner/random/salvage/ore/titanium
	loot = list(
		/obj/item/stack/ore/titanium
	)

/obj/effect/spawner/random/salvage/ore/bluespace
	loot = list(
		/obj/item/stack/ore/bluespace_crystal
	)

/obj/effect/spawner/random/salvage/ore/uranium
	loot = list(
		/obj/item/stack/ore/uranium
	)
