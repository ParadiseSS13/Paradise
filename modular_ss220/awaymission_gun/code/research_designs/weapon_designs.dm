/datum/design/gate_gun
	name = "Gate Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor. Only works in the gate" //не отображаемое описание, т.к. печатается без кейса
	id = "gate_energy_gun"
	req_tech = list("combat" = 5, "magnets" = 3, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 2000, MAT_URANIUM = 1500, MAT_TITANIUM = 500)
	build_path = /obj/item/gun/energy/laser/awaymission_aeg/rnd
	locked = 0
	category = list("Weapons")
