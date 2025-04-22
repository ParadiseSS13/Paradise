/obj/effect/spawner/random/engineering
	icon_state = "wrench"
	record_spawn = TRUE

/obj/effect/spawner/random/engineering/misc
	name = "miscellaneous engineering supplies spawner"
	loot = list(
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/firealarm_electronics,
		/obj/item/apc_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/camera_assembly,
	)

/obj/effect/spawner/random/engineering/tools
	name = "Tool spawner"
	loot = list(
		/obj/item/wrench = 2,
		/obj/item/wirecutters = 2,
		/obj/item/screwdriver = 2,
		/obj/item/crowbar = 2,
		/obj/item/weldingtool = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/analyzer = 2,
		/obj/item/t_scanner = 2,
		/obj/item/geiger_counter = 2,
		/obj/item/multitool = 1,
	)

/obj/effect/spawner/random/engineering/materials
	name = "Materials spawner"
	icon_state = "metal"
	loot = list(
		list(
			/obj/item/stack/rods,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/glass,
			/obj/item/stack/sheet/rglass,
			/obj/item/stack/sheet/wood,
		) = 8,

		list(
			/obj/item/stack/sheet/plastic,
			/obj/item/stack/sheet/plasteel,
			/obj/item/stack/sheet/mineral/plasma,
		) = 2,
	)

/obj/effect/spawner/random/engineering/materials/make_item(spawn_loc, type_path_to_make)
	var/obj/item/stack/item = ..()
	if(istype(item))
		item.amount = rand(1, 10)
		item.update_icon()

	return item

/obj/effect/spawner/random/engineering/toolbox
	name = "Toolbox spawner"
	icon_state = "toolbox"
	loot = list(
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/emergency
	)
