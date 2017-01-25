/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 5
	max_temperature = 20000
	health = 200
	lights_power = 7
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"fire"=1,"bullet"=0.8,"laser"=0.9,"energy"=1,"bomb"=0.6)
	max_equip = 6
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15

/obj/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/ripley/Destroy()
	while(damage_absorption.["brute"] < 0.6)
		new /obj/item/asteroid/goliath_hide(loc)
		damage_absorption.["brute"] = damage_absorption.["brute"] + 0.1 //If a goliath-plated ripley gets killed, all the plates drop
	for(var/atom/movable/A in cargo)
		A.forceMove(loc)
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/go_out()
	..()
	if(damage_absorption.["brute"] < 0.6 && damage_absorption.["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-open")
	else if(damage_absorption.["brute"] == 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full-open")

/obj/mecha/working/ripley/moved_inside(var/mob/living/carbon/human/H as mob)
	..()
	if(damage_absorption.["brute"] < 0.6 && damage_absorption.["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if(damage_absorption.["brute"] == 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")

/obj/mecha/working/ripley/mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
	..()
	if(damage_absorption.["brute"] < 0.6 && damage_absorption.["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if(damage_absorption.["brute"] == 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")

/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	health = 250
	burn_state = LAVA_PROOF
	lights_power = 7
	damage_absorption = list("brute"=0.6,"fire"=0.5,"bullet"=0.7,"laser"=0.7,"energy"=1,"bomb"=0.4)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 2
	opacity=0
	max_temperature = 65000
	health = 300
	lights_power = 7
	damage_absorption = list("brute"=0.6,"fire"=0.4,"bullet"=0.6,"laser"=0.6,"energy"=1,"bomb"=0.3)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""

/obj/mecha/working/ripley/mining/New()
	..()
	//Attach drill
	if(prob(25)) //Possible diamond drill... Feeling lucky?
		var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/drill/D = new /obj/item/mecha_parts/mecha_equipment/drill
		D.attach(src)

	//Add possible plasma cutter
	if(prob(25))
		var/obj/item/mecha_parts/mecha_equipment/M = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
		M.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydrolic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in contents)//Deletes the beacon so it can't be found easily
		qdel(B)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new /obj/item/mecha_parts/mecha_equipment/mining_scanner
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in cargo)
			occupant_message("\blue You unload [O].")
			O.loc = get_turf(src)
			cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - cargo.len]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=[UID()];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/Destroy()
	for(var/mob/M in src)
		if(M == occupant)
			continue
		M.loc = get_turf(src)
		M.loc.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in cargo)
		A.loc = get_turf(src)
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	return ..()

/obj/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = environment.return_pressure()

	if(pressure < 20)
		step_in = 3
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = 5
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)