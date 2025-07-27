/obj/effect/spawner/random/tech_storage
	name = "generic circuit board spawner"
	icon_state = "circuit_board"
	spawn_loot_split = TRUE
	spawn_loot_split_pixel_offsets = 3
	spawn_all_loot = TRUE

/obj/effect/spawner/random/tech_storage/medical
	name = "medical circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/bodyscanner,
		/obj/item/circuitboard/clonepod,
		/obj/item/circuitboard/clonescanner,
		/obj/item/circuitboard/cloning,
		/obj/item/circuitboard/cryo_tube,
		/obj/item/circuitboard/pandemic,
		/obj/item/circuitboard/sleeper,
	)

/obj/effect/spawner/random/tech_storage/security
	name = "security circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/camera,
		/obj/item/circuitboard/prisoner,
		/obj/item/circuitboard/secure_data,
	)

/obj/effect/spawner/random/tech_storage/engineering
	name = "engineering circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/atmos_alert,
		/obj/item/circuitboard/powermonitor,
		/obj/item/circuitboard/smes,
		/obj/item/circuitboard/stationalert,
	)

/obj/effect/spawner/random/tech_storage/teleporter
	name = "teleporter circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/teleporter_station,
		/obj/item/circuitboard/teleporter_hub,
		/obj/item/circuitboard/teleporter,
		/obj/item/circuitboard/message_monitor,
	)

/obj/effect/spawner/random/tech_storage/supply
	name = "supply circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/ore_redemption,
		/obj/item/circuitboard/autolathe,
		/obj/item/circuitboard/power_hammer,
		/obj/item/circuitboard/lava_furnace,
		/obj/item/circuitboard/casting_basin,
		/obj/item/circuitboard/smart_hopper,
		/obj/item/circuitboard/magma_crucible,
	)

/obj/effect/spawner/random/tech_storage/service
	name = "service circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/seed_extractor,
		/obj/item/circuitboard/plantgenes,
		/obj/item/circuitboard/hydroponics,
		/obj/item/circuitboard/cooking/stove,
		/obj/item/circuitboard/cooking/deep_fryer,
		/obj/item/circuitboard/cooking/ice_cream_mixer,
		/obj/item/circuitboard/cooking/oven,
	)

/obj/effect/spawner/random/tech_storage/research
	name = "research circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/protolathe,
		/obj/item/circuitboard/scientific_analyzer,
		/obj/item/circuitboard/rdserver,
		/obj/item/circuitboard/rdconsole,
		/obj/item/circuitboard/aifixer,
	)

/obj/effect/spawner/random/tech_storage/robotics
	name = "robotics circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/mechfab,
		/obj/item/circuitboard/mech_recharger,
		/obj/item/circuitboard/mech_bay_power_console,
		/obj/item/circuitboard/cyborgrecharger,
	)

/obj/effect/spawner/random/tech_storage/silicon
	name = "secure silicon circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/aicore,
		/obj/item/circuitboard/aiupload,
		/obj/item/circuitboard/borgupload,
	)

/obj/effect/spawner/random/tech_storage/comms
	name = "secure command circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/card,
		/obj/item/circuitboard/communications,
	)

/obj/effect/spawner/random/tech_storage/rnd
	name = "secure science circuit boards spawner"
	loot = list(
		/obj/item/circuitboard/rnd_network_controller,
		/obj/item/circuitboard/rnd_backup_console,
		/obj/item/circuitboard/mecha_control,
		/obj/item/circuitboard/robotics,
	)
