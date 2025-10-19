/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 4 //Move speed, lower is faster.
	var/fast_pressure_step_in = 2 //step_in while in normal pressure conditions
	var/slow_pressure_step_in = 4 //step_in while in better pressure conditions
	mech_enter_time = 3 SECONDS
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor = list(MELEE = 40, BULLET = 20, LASER = 10, ENERGY = 20, BOMB = 40, RAD = 0, FIRE = 100, ACID = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/list/cargo = list()
	var/cargo_capacity = 15

	/// How many goliath hides does the Ripley have? Does not stack with other armor
	var/hides = 0

	/// How many drake hides does the Ripley have? Does not stack with other armor
	var/drake_hides = 0

	/// How many plates does the Ripley have? Does not stack with other armor
	var/plates = 0

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
	for(var/i in 1 to hides)
		new /obj/item/stack/sheet/animalhide/goliath_hide(get_turf(src))  //If a armor-plated ripley gets killed, all the armor drop
	for(var/i in 1 to plates)
		new /obj/item/stack/sheet/animalhide/armor_plate(get_turf(src))
	for(var/i in 1 to drake_hides)
		new /obj/item/stack/sheet/animalhide/ashdrake(get_turf(src))
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
	if(!hides && !plates && !drake_hides) // Just in case if armor is removed
		desc = initial(desc)
		return

	// Goliath hides
	if(hides)
		if(hides == HIDES_COVERED_FULL)
			desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
		else
			desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
		return

	// Metal plates
	if(plates)
		if(plates == PLATES_COVERED_FULL)
			desc = "Autonomous Power Loader Unit. Its armor is completely lined with metal plating."
		else
			desc = "Autonomous Power Loader Unit. Its armor is reinforced with some metal plating."
		return

	// Drake hides
	if(drake_hides)
		if(drake_hides == DRAKE_HIDES_COVERED_FULL)
			desc = "Autonomous Power Loader Unit. Its every corner is covered in ancient hide, creating a powerful shield. The pilot of this exosuit must be prepared for battles on the level of legend."
		if(drake_hides == DRAKE_HIDES_COVERED_MODERATE)
			desc = "Autonomous Power Loader Unit. Its armor is adorned with dragon hide plates, instilling fear in its enemies and guarding its pilot."
		if(drake_hides == DRAKE_HIDES_COVERED_SLIGHT)
			desc = "Autonomous Power Loader Unit. The armor of this exosuit only touches the mythical: a few plates of dragon hide adorn its plating like rare warrior trophies."
		return

/obj/mecha/working/ripley/update_overlays()
	. = ..()
// hides
	if(hides)
		if(hides == HIDES_COVERED_FULL)
			. += occupant ? "ripley-g-full" : "ripley-g-full-open"
		else
			. += occupant ? "ripley-g" : "ripley-g-open"
//plates
	if(plates)
		if(plates == PLATES_COVERED_FULL)
			. += occupant ? "ripley-m-full" : "ripley-m-full-open"
		else
			. += occupant ? "ripley-m" : "ripley-m-open"
//drake hides
	if(drake_hides)
		if(drake_hides == DRAKE_HIDES_COVERED_FULL)
			underlays.Cut()
			underlays += emissive_appearance(emissive_appearance_icon, occupant ? "ripley-d-full_lightmask" : "ripley-d-full-open_lightmask")
			. += occupant ? "ripley-d-full" : "ripley-d-full-open"
		else if(drake_hides == DRAKE_HIDES_COVERED_MODERATE)
			. += occupant ? "ripley-d-2" : "ripley-d-2-open"
		else if(drake_hides == DRAKE_HIDES_COVERED_SLIGHT)
			. += occupant ? "ripley-d" : "ripley-d-open"

/obj/mecha/working/ripley/examine_more(mob/user)
	. = ..()
	. += "<i>The Ripley is a robust, venerable utility exosuit originally produced by Hephaestus Industries. \
	It now sees widespread use in and around the Orion sector, being one of the most pervasive mechs ever produced. \
	Shortly after initial production, Hephaestus licensed production rights for the Ripley to other corporations, earning royalties as the exosuit grew more popular.</i>"
	. += ""
	. += "<i>Depending on the configuration, the Ripley can be used for many purposes, including mining, construction, and even goods transport. \
	To this day, it remains one of the most valuable mechs ever produced, and Hephaestus enjoys a substantial profit from sales of this aging but rugged design. \
	As with all station-side mechs, Nanotrasen has purchased the license to make the Ripley in their facilities.</i>"

/obj/mecha/working/ripley/firefighter
	desc = "A standard APLU chassis that was refitted with additional thermal protection and a cistern."
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	max_integrity = 250
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 60, RAD = 70, FIRE = 100, ACID = 100)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/firefighter/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Based on the venerable Ripley chassis, designed initially by Hephaestus Industries, the Firefighter is a retrofit created by Nanotrasen as their mining operations expanded, and a robust, fireproof exosuit was needed. \
	Adapted to fit heat-resistant shielding, the Firefighter became a popular mech for mining teams in dangerous environments.</i>"
	. += ""
	. += "<i>Since Nanotrasen's expansion into Epsilon Eridani and their mining operations on Lavaland, the Firefighter has grown more popular among seasoned miners looking for a safer, armored way to mine in even the hottest of biomes. \
	Additionally, it has seen some use among atmospherics crews and is admired for its ability to control even the toughest of plasmafires while protecting its pilot.</i>"

/obj/mecha/working/ripley/deathripley
	name = "DEATH-RIPLEY"
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE!"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 3
	slow_pressure_step_in = 3
	max_temperature = 65000
	max_integrity = 300
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 70, RAD = 0, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	normal_step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/deathripley/examine_more(mob/user)
	..()
	. = list()
	. += "<i>A functioning, well-made collectable for the popular Nanotrasen-Funded holovid show, 'Deathsquad'. \
	A retrofitted and repainted Ripley chassis, the Death Ripley was created and used by the leader of the Deathsquad, Master Sergeant Killjoy, during the climactic battle with the Spider Queen “Xerxes” at the end of Season 4. \
	The mech bears the signature mark of the team's engineer, Corporal Ironhead, who assisted Killjoy in its construction.</i>"
	. += ""
	. += "<i>Replicas such as this are sought-after collectibles among the biggest fans of Deathsquad. \
	An altercation even occurred where an individual dressed in a poorly-made Killjoy costume attempted to kill a collector to gain a Death Ripley, who was later sent to a mental institution after screaming, “THE DEATHSQUAD IS REAL.</i>"

/obj/mecha/working/ripley/mining
	name = "APLU \"Miner\""

/obj/mecha/working/ripley/mining/proc/prepare_equipment()
	SHOULD_CALL_PARENT(FALSE)

	// Diamond drill as a treat
	var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
	D.attach(src)

	// Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	// Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	prepare_equipment()

/obj/mecha/working/ripley/mining/old
	desc = "An old, dusty mining ripley."
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/old/add_cell()
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge

/obj/mecha/working/ripley/mining/old/prepare_equipment()
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
	if(..())
		return
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
