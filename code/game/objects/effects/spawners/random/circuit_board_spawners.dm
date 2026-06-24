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
		/obj/item/circuitboard/biogenerator = 5,
		/obj/item/circuitboard/cell_charger = 5,
		/obj/item/circuitboard/chem_heater = 5,
		/obj/item/circuitboard/chem_master = 5,
		/obj/item/circuitboard/cryo_tube = 5,
		/obj/item/circuitboard/cyborgrecharger = 5,
		/obj/item/circuitboard/deepfryer = 5,
		/obj/item/circuitboard/holopad = 5,
		/obj/item/circuitboard/hydroponics = 5,
		/obj/item/circuitboard/aiupload_broken = 5,
		/obj/item/circuitboard/bottler = 5,
		/obj/item/circuitboard/clonescanner = 5,
		/obj/item/circuitboard/mech_recharger = 5,
		/obj/item/circuitboard/mechfab = 5,
		/obj/item/circuitboard/operating = 5,
		/obj/item/circuitboard/microwave = 5,
		/obj/item/circuitboard/ore_redemption = 5,
		/obj/item/circuitboard/reagentgrinder = 5,
		/obj/item/circuitboard/recharger = 5,
		/obj/item/circuitboard/seed_extractor = 5,
		/obj/item/circuitboard/emitter = 5,
		/obj/item/circuitboard/smes = 5,
		/obj/item/circuitboard/pacman = 5,
		/obj/item/circuitboard/pacman/mrs = 5,
	)

/obj/effect/spawner/random/circuit/rare
	name = "random rare circuit board spawner"
	loot = list(
		/obj/item/circuitboard/autolathe = 5,
		/obj/item/circuitboard/aicore = 5,
		/obj/item/circuitboard/chem_dispenser = 5,
		/obj/item/circuitboard/teleporter_hub = 5,
		/obj/item/circuitboard/teleporter = 5,
		/obj/item/circuitboard/aicore = 5,
		/obj/item/circuitboard/smes = 5,
		/obj/item/circuitboard/pacman/super = 5,
	)
