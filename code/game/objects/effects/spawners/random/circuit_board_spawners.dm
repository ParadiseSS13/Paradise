/obj/effect/spawner/random/circuit
	name = "random circuit board spawner"
	icon_state = "circuit_board"

/obj/effect/spawner/random/circuit/mech
	name = "random mech circuit board spawner"
	loot = list(
		/obj/item/circuitboard/mecha/ripley/main = 100,
		/obj/item/circuitboard/mecha/ripley/peripherals = 100,
		/obj/item/circuitboard/mecha/odysseus/main = 25,
		/obj/item/circuitboard/mecha/odysseus/peripherals = 25,
		/obj/item/circuitboard/mecha/gygax/main = 20,
		/obj/item/circuitboard/mecha/gygax/peripherals = 20,
		/obj/item/circuitboard/mecha/gygax/targeting = 20,
		/obj/item/circuitboard/mecha/durand/main = 20,
		/obj/item/circuitboard/mecha/durand/peripherals = 20,
		/obj/item/circuitboard/mecha/durand/targeting = 20,
	)

/obj/effect/spawner/random/circuit/common
	name = "random common circuit board spawner"
	loot = list(
		/obj/item/circuitboard/biogenerator,
		/obj/item/circuitboard/cell_charger,
		/obj/item/circuitboard/chem_heater,
		/obj/item/circuitboard/chem_master,
		/obj/item/circuitboard/cryo_tube,
		/obj/item/circuitboard/cyborgrecharger,
		/obj/item/circuitboard/deepfryer,
		/obj/item/circuitboard/holopad,
		/obj/item/circuitboard/hydroponics,
		/obj/item/circuitboard/aiupload_broken,
		/obj/item/circuitboard/bottler,
		/obj/item/circuitboard/clonescanner,
		/obj/item/circuitboard/mech_recharger,
		/obj/item/circuitboard/mechfab,
		/obj/item/circuitboard/operating,
		/obj/item/circuitboard/microwave,
		/obj/item/circuitboard/ore_redemption,
		/obj/item/circuitboard/reagentgrinder,
		/obj/item/circuitboard/recharger,
		/obj/item/circuitboard/seed_extractor,
		/obj/item/circuitboard/emitter,
		/obj/item/circuitboard/smes,
		/obj/item/circuitboard/pacman,
		/obj/item/circuitboard/pacman/mrs,
	)

/obj/effect/spawner/random/circuit/rare
	name = "random rare circuit board spawner"
	loot = list(
		/obj/item/circuitboard/autolathe,
		/obj/item/circuitboard/aicore,
		/obj/item/circuitboard/chem_dispenser,
		/obj/item/circuitboard/teleporter_hub,
		/obj/item/circuitboard/teleporter,
		/obj/item/circuitboard/aicore,
		/obj/item/circuitboard/smes,
		/obj/item/circuitboard/pacman/super,
	)
