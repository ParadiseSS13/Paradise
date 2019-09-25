/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 4 //Move speed, lower is faster.
	var/fast_pressure_step_in = 2 //step_in while in normal pressure conditions
	var/slow_pressure_step_in = 4 //step_in while in better pressure conditions
	max_temperature = 20000
	health = 200
	lights_power = 7
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"fire"=1,"bullet"=0.8,"laser"=0.9,"energy"=1,"bomb"=0.6)
	armor = list(melee = 40, bullet = 20, laser = 10, energy = 20, bomb = 40, bio = 0, rad = 0)
	max_equip = 6
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15

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
	while(damage_absorption["brute"] < 0.6)
		new /obj/item/stack/sheet/animalhide/goliath_hide(loc)
		damage_absorption["brute"] = damage_absorption["brute"] + 0.1 //If a goliath-plated ripley gets killed, all the plates drop
	for(var/atom/movable/A in cargo)
		A.forceMove(loc)
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/go_out()
	..()
	if(damage_absorption["brute"] < 0.6 && damage_absorption["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-open")
	else if(damage_absorption["brute"] == 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full-open")

/obj/mecha/working/ripley/moved_inside(var/mob/living/carbon/human/H as mob)
	..()
	if(damage_absorption["brute"] < 0.6 && damage_absorption["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if(damage_absorption["brute"] == 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")

/obj/mecha/working/ripley/mmi_moved_inside(var/obj/item/mmi/mmi_as_oc as obj,mob/user as mob)
	..()
	if(damage_absorption["brute"] < 0.6 && damage_absorption["brute"] > 0.3)
		overlays = null
		overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if(damage_absorption["brute"] == 0.3)
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
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 60, bio = 0, rad = 0)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "DEATH-RIPLEY"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 3
	slow_pressure_step_in = 3
	opacity=0
	max_temperature = 65000
	health = 300
	lights_power = 7
	damage_absorption = list("brute"=0.6,"fire"=0.4,"bullet"=0.6,"laser"=0.6,"energy"=1,"bomb"=0.3)
	wreckage = /obj/effect/decal/mecha_wreckage/ripley/deathripley
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
	for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)//Deletes the beacon so it can't be found easily
		qdel(B)

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
		if(O && O in cargo)
			occupant_message("<span class='notice'>You unload [O].</span>")
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
