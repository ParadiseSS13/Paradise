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
	armor = list(MELEE = 40, BULLET = 20, LASER = 10, ENERGY = 20, BOMB = 40, RAD = 0, FIRE = 100, ACID = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15
	var/hides = 0

/obj/mecha/working/ripley/Move()
	. = ..()
	if(.)
		collect_ore()
	update_pressure()

/obj/mecha/working/ripley/proc/collect_ore()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in equipment)
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in cargo
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, src))
				if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc)) //we can reach it and it's in front of us? grab it!
					ore.forceMove(ore_box)

/obj/mecha/working/ripley/Destroy()
	for(var/i=1, i <= hides, i++)
		new /obj/item/stack/sheet/animalhide/goliath_hide(loc) //If a goliath-plated ripley gets killed, all the plates drop
	for(var/atom/movable/A in cargo)
		A.forceMove(loc)
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/go_out()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/update_desc()
	. = ..()
	if(!hides) // Just in case if hides are somehow removed
		desc = initial(desc)
		return
	if(hides == 3)
		desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
	else
		desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."

/obj/mecha/working/ripley/update_overlays()
	. = ..()
	if(!hides)
		return
	if(hides == 3)
		. += occupant ? "ripley-g-full" : "ripley-g-full-open"
	else
		. += occupant ? "ripley-g" : "ripley-g-open"

/obj/mecha/working/ripley/firefighter
	desc = "A standard APLU chassis that was refitted with additional thermal protection and a cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	max_integrity = 250
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	lights_power = 7
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 60, RAD = 70, FIRE = 100)
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
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 70, RAD = 0, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	normal_step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "APLU \"Miner\""
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
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
	QDEL_LIST_CONTENTS(trackers) //Deletes the beacon so it can't be found easily

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in cargo))
			occupant_message("<span class='notice'>You unload [O].</span>")
			O.loc = get_turf(src)
			cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - length(cargo)]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(length(cargo))
		for(var/obj/O in cargo)
			output += "<a href='byond://?src=[UID()];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
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

/obj/mecha/working/ripley/ex_act(severity)
	..()
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30 / severity))
			cargo -= O
			O.forceMove(drop_location())

/obj/mecha/working/ripley/proc/update_pressure()
	if(thrusters_active)
		return // Don't calculate this if they have thrusters on, this is calculated right after domove because of course it is

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
		desc += "</br><span class='danger'>The mech's equipment slots spark dangerously!</span>"
	return ..()
