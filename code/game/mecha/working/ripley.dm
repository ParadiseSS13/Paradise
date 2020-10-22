/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 4 //Move speed, lower is faster.
	var/fast_pressure_step_in = 2 //step_in while in normal pressure conditions
	var/slow_pressure_step_in = 4 //step_in while in better pressure conditions
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 20, "laser" = 10, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/hides = 0

/obj/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/ripley/update_icon()
	..()
	if(hides)
		cut_overlays()
		if(hides < 3)
			add_overlay(occupant ? "ripley-g" : "ripley-g-open")
		else
			add_overlay(occupant ? "ripley-g-full" : "ripley-g-full-open")

/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	max_integrity = 250
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 0, "rad" = 70, "fire" = 100, "acid" = 100)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 3
	slow_pressure_step_in = 3
	opacity=0
	max_temperature = 65000
	max_integrity = 300
	lights_power = 7
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	normal_step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/New()
	..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	//Attach drill
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)
	QDEL_LIST(trackers) //Deletes the beacon so it can't be found easily

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/ex_act(severity)
	..()
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30 / severity))
			cargo -= O
			O.forceMove(drop_location())

/obj/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

/obj/mecha/working/ripley/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You slide the card through [src]'s ID slot.</span>")
		playsound(loc, "sparks", 100, 1)
		desc += "</br><span class='danger'>The mech's equipment slots spark dangerously!</span>"
	else
		to_chat(user, "<span class='warning'>[src]'s ID slot rejects the card.</span>")
