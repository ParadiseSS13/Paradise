/datum/design/gate_gun_mk1
	name = "Gate Energy Gun MK1"
	desc = "An energy gun with an experimental miniaturized reactor. Only works in the gate" //не отображаемое описание, т.к. печатается без кейса
	id = "gate_energy_gun"
	req_tech = list("combat" = 3, "magnets" = 3, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1500, MAT_URANIUM = 1500, MAT_TITANIUM = 500)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/rnd
	locked = 0
	category = list("Weapons")

/datum/design/gate_gun_mk2
	name = "Gate Energy Gun MK2"
	desc = "An energy gun with an experimental miniaturized reactor. Only works in the gate" //не отображаемое описание, т.к. печатается без кейса
	id = "gate_energy_gun_mk2"
	req_tech = list("combat" = 5, "magnets" = 3, "powerstorage" = 5, "programming" = 3, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 2000, MAT_URANIUM = 2000, MAT_TITANIUM = 500, MAT_SILVER = 1000)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/rnd/mk2
	locked = 0
	category = list("Weapons")
