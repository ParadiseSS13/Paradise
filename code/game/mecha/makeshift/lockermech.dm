/obj/mecha/makeshift
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that ressembles the functions of a mech."
	name = "Locker Mech"
	icon_state = "lockermech"
	health = 200 //same health as ripley but without any of the armor/deflections making it very vulnerable
	deflect_chance = 0
	lights_power = 5
	step_in = 5 //Slower than ripley
	max_temperature = 5000
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	damage_absorption = list("brute"=1,"fire"=1,"bullet"=1,"laser"=1,"energy"=1,"bomb"=1)
	max_equip = 2
	wreckage = null
	var/list/cargo = list()
	var/cargo_capacity = 5

/obj/mecha/makeshift/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(sanitize(href_list["drop_from_cargo"]))
		if(O && O in cargo)
			occupant_message("<span class='notice'>You unload [O].</span>")
			O.forceMove(loc)
			cargo -= O
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return

/obj/mecha/makeshift/go_out()
	..()
	update_icon()

/obj/mecha/makeshift/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon()


/obj/mecha/makeshift/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/makeshift/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/makeshift/Destroy()
	new /obj/structure/closet(loc)
	..()