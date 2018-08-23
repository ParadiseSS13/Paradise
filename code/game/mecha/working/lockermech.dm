/obj/mecha/working/ripley/makeshift
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that ressembles the functions of a mech."
	name = "Locker Mech"
	icon_state = "lockermech"
	initial_icon = "lockermech"
	deflect_chance = 0 //no armor unlike the ripley
	lights_power = 5
	step_in = 6 //Slower than ripley
	max_temperature = 5000
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0) //no armor
	damage_absorption = list("brute"= 1, "fire"= 1, "bullet"= 1, "laser"= 1, "energy"= 1, "bomb"= 1) // no armor
	max_equip = 2
	wreckage = null
	cargo_capacity = 5

/obj/mecha/working/ripley/makeshift/Destroy()
	new /obj/structure/closet(loc)
	..()

/obj/mecha/working/ripley/makeshift/update_pressure()
	return() //unlike the ripley, does not go faster in low pressure environments