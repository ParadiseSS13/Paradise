#define NEAREST_MW(power)((power) - (power) % (1 MW))
//Station goal stuff goes here
/datum/station_goal/bluespace_tap
	name = "Bluespace Harvester"
	var/goal = 45000

/datum/station_goal/bluespace_tap/get_report()
	return {"<b>Bluespace Harvester Experiment</b><br>
	Another research station has developed a device called a Bluespace Harvester.
	It reaches through bluespace into other dimensions to shift through them for interesting objects.<br>
	Due to unforseen circumstances the large-scale test of the prototype could not be completed on the original research station. It will instead be carried out on your station.
	Acquire the circuit board, construct the device over a wire knot and feed it enough power to strike a motherlode of objects, located [goal] points deep.
	<br><br>
	Be advised that the device is experimental and might act in slightly unforseen ways if sufficiently powered. It may also require maintenance irregularly.
	<br>
	Nanotrasen Science Directorate"}

/datum/station_goal/bluespace_tap/on_report()
	var/datum/supply_packs/misc/station_goal/bluespace_tap/P = SSeconomy.supply_packs["[/datum/supply_packs/misc/station_goal/bluespace_tap]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_tap/check_completion()
	if(..())
		return TRUE
	var/highscore = 0
	for(var/obj/machinery/power/bluespace_tap/T in SSmachines.get_by_type(/obj/machinery/power/bluespace_tap))
		highscore = max(highscore, T.total_points)
	to_chat(world, "<b>Bluespace Harvester Highscore</b>: [highscore >= goal ? "<span class='greenannounce'>": "<span class='boldannounceic'>"][highscore]</span>")
	if(highscore >= goal)
		return TRUE
	return FALSE

//needed for the vending part of it
/datum/data/bluespace_tap_product
	/// Name of the product
	var/product_name = "generic"
	/// The path to a list containing the common drops
	var/product_path_common = null
	/// The path to a list containing the uncommon drops
	var/product_path_uncommon = null
	/// The path to a list containing the rare drops
	var/product_path_rare = null
	/// How much the product costs to produce
	var/product_cost = 100	//cost in mining points to generate

/datum/data/bluespace_tap_product/New(name, path_common, path_uncommon, path_rare, cost)
	product_name = name
	product_path_common = path_common
	product_path_uncommon = path_uncommon
	product_path_rare = path_rare
	product_cost = cost

/obj/item/circuitboard/machine/bluespace_tap
	board_name = "Bluespace Harvester"
	icon_state = "command"
	build_path = /obj/machinery/power/bluespace_tap
	origin_tech = "engineering=2;combat=2;bluespace=3"
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,//Probably okay, right?
							/obj/item/stack/ore/bluespace_crystal = 5)

/// Points generated per cycle for each Watt of power consumption
#define POINTS_PER_W 4e-6
/// Amount of points generated per cycle per 50KW for the first 500KW
#define BASE_POINTS 2


/**
  * # Bluespace Harvester
  *
  * A station goal that consumes enormous amounts of power to generate (mostly fluff) rewards
  *
  * A machine that takes power each tick, generates points based on it
  * and lets you spend those points on rewards. A certain amount of points
  * has to be generated for the station goal to count as completed.
  */
/obj/machinery/power/bluespace_tap
	name = "Bluespace harvester"
	icon = 'icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"
	base_icon_state = "bluespace_tap"
	max_integrity = 300
	pixel_x = -32	//shamelessly stolen from dna vault
	pixel_y = -32
	density = TRUE
	interact_offline = TRUE
	luminosity = 1

	/// list of possible products
	var/static/product_list = list(
	new /datum/data/bluespace_tap_product("Unknown Exotic Clothing",
		/obj/effect/spawner/random/bluespace_tap/clothes_common,
		/obj/effect/spawner/random/bluespace_tap/clothes_uncommon,
		/obj/effect/spawner/random/bluespace_tap/clothes_rare,
		5000),
	new /datum/data/bluespace_tap_product("Unknown Food",
		/obj/effect/spawner/random/bluespace_tap/food_common,
		/obj/effect/spawner/random/bluespace_tap/food_uncommon,
		/obj/effect/spawner/random/bluespace_tap/food_rare,
		6000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact",
		/obj/effect/spawner/random/bluespace_tap/cultural_common,
		/obj/effect/spawner/random/bluespace_tap/cultural_uncommon,
		/obj/effect/spawner/random/bluespace_tap/cultural_rare,
		15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact",
		/obj/effect/spawner/random/bluespace_tap/organic_common,
		/obj/effect/spawner/random/bluespace_tap/organic_uncommon,
		/obj/effect/spawner/random/bluespace_tap/organic_rare,
		20000)
	)

	/// The amount of power being used for mining at the moment (Watts)
	var/mining_power = 0
	/// The power you WANT the machine to use for mining. It will try to match this. (Watts)
	var/desired_mining_power = 0
	/// Points mined this cycle
	var/mined_points = 0
	/// Available mining points
	var/points = 0
	/// The total points earned by this machine so far, for tracking station goal and highscore
	var/total_points = 0
	/// The point interval where the machine will automatically spawn a clothing item
	var/clothing_interval = 7500
	/// The point interval where the machine will automatically spawn a food item
	var/food_interval = 10000
	/// The point interval where the machine will automatically spawn a cultural item
	var/cultural_interval = 15000
	/// The point interval where the machine will automatically spawn an organic item
	var/organic_interval = 20000
	/// The point interval where the machine will strike a motherlode
	var/motherlode_interval = 45000
	/// How much power the machine needs per processing tick at the current level.
	var/actual_power_usage = 0

	// Tweak these and active_power_consumption to balance power generation

	/// Whether or not auto shutdown will engage when portals open
	var/auto_shutdown = TRUE
	/// Whether or not stabilizers will engage to prevent or reduce the chance of portals opening
	var/stabilizers = TRUE
	/// Amount of power the stabilizers consume (Watts)
	var/stabilizer_power = 0
	/// Whether or not mining power will be prevented from exceedingn stabilizer power
	var/stabilizer_priority = TRUE
	/// When event triggers this will hold references to all portals so we can fix the sprite after they're broken
	/// Amount of overhead in levels. Each level of overhead allows stabilizing 15+overhead.
	var/overhead = 0
	/// When portal event triggers this will hold references to all portals so we can fix the sprite after they're broken
	var/list/active_nether_portals = list()
	/// The amount of portals waiting to be spawned. Used mostly for UI and icon stuff.
	var/spawning = 0
	/// When a filth event triggers, this will stop the operation until it is cleaned
	var/dirty = FALSE
	/// Internal radio to handle announcements over engineering
	var/obj/item/radio/radio

/obj/machinery/power/bluespace_tap/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/bluespace_tap()
	for(var/i in 1 to 5)	//five of each
		component_parts += new /obj/item/stock_parts/capacitor/quadratic()
		component_parts += new /obj/item/stack/ore/bluespace_crystal()
	if(!powernet)
		connect_to_network()

	AddComponent(/datum/component/multitile, list(
		list(1, 1,		   1),
		list(1, MACH_CENTER, 1),
		list(1, 0,		   1),
	))
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Engineering" = 0))

/obj/machinery/power/bluespace_tap/examine(mob/user)
	. = ..()
	. += "An alien looking device that gathers all manner of objects from different dimensions"
	if(dirty)
		. += "It's gummed up with filth!"

/obj/machinery/power/bluespace_tap/cleaning_act(mob/user, atom/cleaner, cleanspeed, text_verb, text_description, text_targetname)
	. = ..()
	dirty = FALSE

/obj/machinery/power/bluespace_tap/update_icon_state()
	. = ..()

	if(length(active_nether_portals))
		icon_state = "cascade_tap"
		return

	if(get_available_power() <= 0)
		icon_state = base_icon_state
	else
		icon_state = "[base_icon_state][get_icon_state_number()]"


/obj/machinery/power/bluespace_tap/update_overlays()
	. = ..()

	underlays.Cut()

	if(length(active_nether_portals) || spawning)
		. += "cascade"
		set_light(15, 5, "#ff0000")
		return

	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(1, 1, "#353535")

	if(get_available_power())
		if(dirty)
			. += "screen_dirty"
		else
			. += "screen"
		if(light)
			underlays += emissive_appearance(icon, "light_mask")

/obj/machinery/power/bluespace_tap/proc/get_icon_state_number()
	switch(mining_power)
		if(50 KW to 3 MW)
			return 1
		if(3 MW to 8 MW)
			return 2
		if(8 MW to 11 MW)
			return 3
		if(11 MW to 15 MW)
			return 4
		if(15 MW to INFINITY)
			return 5
		else
			return 0

/obj/machinery/power/bluespace_tap/power_change()
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(1, 1, "#353535")
	if(.)
		update_icon()


/obj/machinery/power/bluespace_tap/connect_to_network()
	. = ..()
	if(.)
		update_icon()

/obj/machinery/power/bluespace_tap/disconnect_from_network()
	. = ..()
	if(.)
		update_icon()

/**
  * Sets the desired mining power (Watts)
  *
  * Sets the desired mining power, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT change the actual mining power directly.
  * Arguments:
  * * t_power - The power we try to set it at, between 0 and max_level
 */

/obj/machinery/power/bluespace_tap/proc/set_power(t_power)
	desired_mining_power = max(t_power, 0)
	// Round down to nearest MW if above 1 MW
	if(desired_mining_power > 1 MW)
		desired_mining_power = desired_mining_power - (desired_mining_power % (1 MW))

/obj/machinery/power/bluespace_tap/process()
	// Power we could mine with (Watts)
	mining_power = get_surplus()

	// Round down to the nearest MW if above a MW
	if(mining_power > 1 MW)
		mining_power = NEAREST_MW(mining_power)

	// Always try to use all available power for mining if emagged and disable the stabilizers
	if(emagged)
		desired_mining_power = mining_power
		stabilizer_power = 0

	/*
	* Stabilizers activate above 15MW of mining power
	* Stabilizers consume up to 1MW for each 1MW of mining power, consuming less between 15MW and 30MW of mining power
	* If stabilizers have priority they will always consume enough power to stabilize the BSH, limiting mining power
	*/
	else if(stabilizers)
		if(stabilizer_priority)
			// Lowest between enough to stabilize our desired mining power and enough to stabilize the highest mining power we could sustain with our current power budget.
			stabilizer_power =\
			min(max(mining_power - max(NEAREST_MW(mining_power / 2), NEAREST_MW((mining_power + 30 MW) / 3)), 0), \
			clamp(desired_mining_power - clamp((30 MW) - desired_mining_power, 0, 15 MW), 0, desired_mining_power))

			// Stabilizers take priority so we subtract them from the available total straight away
			mining_power = mining_power - stabilizer_power
		else
			// stabilizer power is however much power we have left, but no more than we need to stabilize our desired mining power.
			stabilizer_power = \
			clamp(mining_power - desired_mining_power, \
			0, \
			desired_mining_power - clamp(30 MW - desired_mining_power, 0, 15 MW))
	else
		stabilizer_power = 0

	// Now that we know our actual power budget we can finally set our mining power
	mining_power = min(mining_power, desired_mining_power)

	consume_direct_power(mining_power + stabilizer_power)

	// 2 points per 50 KW up to 20 and 4 points per MW (or 5 when emmaged).
	// A dirty machine does not produce points
	if(!dirty)
		mined_points = min(BASE_POINTS * (mining_power / (50 KW)) , 20) + mining_power * (POINTS_PER_W + emagged / (1 MW))
		points += mined_points
		total_points += mined_points
		update_icon()

	// Handle automatic spawning of loot. Extra loot spawns in maints if stabilizers are off to incentivise risk taking
	if(total_points > clothing_interval)
		produce(product_list[1], FALSE, !stabilizers)
		radio.autosay("<b>Bluespace harvester progress detected: [src] has produced unknown clothes!</b>", name, "Engineering")
		clothing_interval += 7500

	if(total_points > food_interval)
		produce(product_list[2], FALSE, !stabilizers)
		radio.autosay("<b>Bluespace harvester progress detected: [src] has produced unknown food!</b>", name, "Engineering")
		food_interval += 10000

	if(total_points > cultural_interval)
		produce(product_list[3], FALSE, !stabilizers)
		radio.autosay("<b>Bluespace harvester progress detected: [src] has produced something unknown with cultural value!</b>", name, "Engineering")
		cultural_interval += 15000

	if(total_points > organic_interval)
		produce(product_list[4], FALSE, !stabilizers)
		radio.autosay("<b>Bluespace harvester progress detected: [src] has produced something organic!</b>", name, "Engineering")
		organic_interval += 20000

	if(total_points > motherlode_interval)
		produce_motherlode()
		motherlode_interval += 45000

	/*
	* Portal chance is 0.1% per cycle per difference of 1MW between the stabilizer and mining power
	* This should translate to portals spawning every 33:20 minutes for 1 difference of 1MW
	* And about every 3:20 minutes for a 10MW difference
	* Emagging guarantees a chance of at least 5%
	* Prob treats values less than 0 as 0.
	* Emagging garuantees a chance of at least 5%.
	* Prob treats values less than 0 as 0.
	*/

	if(prob((mining_power - clamp(30 MW - mining_power, 0, 15 MW) - stabilizer_power)  / (10 MW) + (emagged * 5)))
		var/area/our_area = get_area(src)
		if((!spawning || !length(active_nether_portals)))
			GLOB.major_announcement.Announce("Unexpected power spike during Bluespace Harvester Operation. Extra-dimensional intruder alert. Expected location: [our_area.name]. [emagged ? "DANGER: Emergency shutdown failed! Please proceed with manual shutdown." : auto_shutdown ? "Emergency shutdown initiated." : "Automatic shutdown disabled."]", "Bluespace Harvester Malfunction", 'sound/AI/harvester.ogg')
		if(!emagged && auto_shutdown)
			desired_mining_power = 0	//emergency shutdown unless it is disabled
		// An extra portal for each 30MW above 15
		start_nether_portaling(rand(1 , 3) + round(max((mining_power - 15 MW) / (30 MW) , 0)), TRUE)
	try_events()

/obj/machinery/power/bluespace_tap/proc/start_nether_portaling(amount, new_incursion = FALSE)
	if(new_incursion)
		spawning += amount
	var/turf/location = locate(x + rand(-5, 5), y + rand(-5, 5), z)
	var/obj/structure/spawner/nether/bluespace_tap/P = new /obj/structure/spawner/nether/bluespace_tap(location)
	amount--
	spawning--
	active_nether_portals += P
	P.linked_source_object = src
	// 1 Extra mob for each 20 MW of mining power above 15MW.
	P.max_mobs = 5 + max((mining_power - 15 MW) / (20 MW), 0)
	update_icon()
	if(amount)
		addtimer(CALLBACK(src, PROC_REF(start_nether_portaling), amount), rand(3, 5) SECONDS)

/obj/machinery/power/bluespace_tap/ui_data(mob/user)
	var/list/data = list()

	data["desiredMiningPower"] = desired_mining_power
	data["miningPower"] = mining_power
	data["points"] = points
	data["totalPoints"] = total_points
	data["powerUse"] = mining_power + stabilizer_power
	data["availablePower"] = get_surplus()
	data["emagged"] = emagged
	data["dirty"] = dirty
	data["autoShutown"] = auto_shutdown
	data["stabilizers"] = stabilizers
	data["stabilizerPower"] = stabilizer_power
	data["stabilizerPriority"]  = stabilizer_priority
	data["portaling"] = (length(active_nether_portals) || spawning)

	/// A list of lists, each inner list equals a datum
	var/list/listed_items = list()
	for(var/key = 1 to length(product_list))
		var/datum/data/bluespace_tap_product/A = product_list[key]
		listed_items[++listed_items.len] = list(
				"key" = key,
				"name" = A.product_name,
				"price" = A.product_cost)
	data["product"] = listed_items
	return data


/obj/machinery/power/bluespace_tap/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ai(mob/user)	//this would be cool if we made unique TGUI for this
	ui_interact(user)

/**
  * Produces the product with the desired key and increases product cost accordingly
  */
/obj/machinery/power/bluespace_tap/proc/produce(datum/data/bluespace_tap_product/product, purchased = FALSE, double_chance = FALSE)
	if(!product)
		return
	if(purchased)
		if(product.product_cost > points)
			return
		points -= product.product_cost
		product.product_cost = round(1.2 * product.product_cost, 1)
	playsound(src, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, src)

	var/spawn_location = find_spawn_location()
	if(!spawn_location)
		// If there is no valid space, spawn the item on the BSH harvester itself
		spawn_item(get_turf(src))
	else
		spawn_item(product, spawn_location)

	if(prob(25) && double_chance)
		// Spawn second item in random spot on station - places it where NADs can respawn
		spawn_location = find_spawn_location(TRUE)
		if(!spawn_location)
			// If there is no valid space, do not spawn the item
			return
		spawn_item(product, spawn_location)

/// Handles a motherlode - each product is spawned 5 times at both the machine and around the station
/obj/machinery/power/bluespace_tap/proc/produce_motherlode()
	// Announce lootsplosion
	radio.autosay("<b>Power spike detected during Bluespace Harvester Operation. Large bluespace payload inbound.</b>", name, "Engineering")
	// Build location list cache once
	var/list/possible_spawns = list()
	var/list/random_spawns = GLOB.maints_loot_spawns
	// Build list of spawn positions
	for(var/turf/current_target_turf in view(3, src))
		possible_spawns.Add(current_target_turf)

	// Spawn lootsplosion
	for(var/datum/data/bluespace_tap_product/product in product_list)
		for(var/i in 1 to 5)
			var/turf/spawn_location = pick_n_take(possible_spawns)
			if(spawn_location.density)
				var/list/open_turfs = spawn_location.AdjacentTurfs(open_only = TRUE)
				if(length(open_turfs))
					spawn_location = pick(open_turfs)
			spawn_item(product, spawn_location)

			if(!random_spawns)
				continue
			spawn_location = pick(random_spawns)
			spawn_location = pick(spawn_location.AdjacentTurfs(open_only = TRUE))
			if(spawn_location.density)
				var/list/open_turfs = spawn_location.AdjacentTurfs(open_only = TRUE)
				if(length(open_turfs))
					spawn_location = pick(open_turfs)
			spawn_item(product, spawn_location)

/obj/machinery/power/bluespace_tap/proc/find_spawn_location(random = FALSE)
	var/list/possible_spawns = list()
	if(random)
		possible_spawns = GLOB.maints_loot_spawns
	else
		// Build list of spawn positions
		for(var/turf/current_target_turf in view(3, src))
			possible_spawns.Add(current_target_turf)

	while(length(possible_spawns))
		var/turf/current_spawn = pick_n_take(possible_spawns)
		if(!current_spawn.density)
			return current_spawn
		// Someone built a wall over it, check the surroundings
		var/list/open_turfs = current_spawn.AdjacentTurfs(open_only = TRUE)
		if(length(open_turfs))
			return pick(open_turfs)

/obj/machinery/power/bluespace_tap/proc/spawn_item(datum/data/bluespace_tap_product/product, turf)
	if(!product)
		return
	var/list/loot_rarities = list(
		product.product_path_common = 60,
		product.product_path_uncommon = 30,
		product.product_path_rare = 10
	)
	var/obj/effect/spawner/random/bluespace_tap/product_path = pickweight(loot_rarities)
	var/obj/effect/portal/tap_portal = new /obj/effect/portal(turf, null, src, 10)
	tap_portal.name = "Bluespace Harvester Portal"
	playsound(src, 'sound/magic/blink.ogg', 50)
	new product_path(turf)
	flick_overlay_view(image(icon, src, "flash", FLY_LAYER))
	log_game("Bluespace harvester product spawned at [turf]")

// Highest possible probabilty of an event
#define PROB_CAP 5
// Higher number means approaching the limit slower
#define PROB_CURVE 250

/obj/machinery/power/bluespace_tap/proc/try_events()
	if(!mining_power)
		return
	// Calculate prob of event based on mining power. Return if no event.
	var/megawatts = mining_power / 1000000
	var/event_prob = (PROB_CAP * megawatts / (megawatts + PROB_CURVE)) + (emagged * 5)
	if(!prob(event_prob))
		return
	var/static/list/event_list = list(
		/datum/engi_event/bluespace_tap_event/dirty,
		/datum/engi_event/bluespace_tap_event/electric_arc,
		/datum/engi_event/bluespace_tap_event/radiation,
		/datum/engi_event/bluespace_tap_event/gas
	)
	var/datum/engi_event/bluespace_tap_event/event = pick(event_list)
	run_event(event)

/obj/machinery/power/bluespace_tap/proc/run_event(datum/engi_event/bluespace_tap_event/event) // mostly admin testing and stuff
	if(ispath(event))
		event = new event(src)
	if(!istype(event))
		log_debug("Attempted bluespace tap event aborted due to incorrect path. Incorrect path type: [event.type].")
		return
	event.start_event()

#undef PROB_CAP
#undef PROB_CURVE
//UI stuff below

/obj/machinery/power/bluespace_tap/ui_act(action, params)
	if(..())
		return
	. = TRUE	// we want to refresh in all the cases below
	switch(action)
		if("set")
			set_power(text2num(params["set_power"]))
		if("vend")//it's not really vending as producing, but eh
			var/key = text2num(params["target"])
			if(key <= 0 || key > length(product_list)) // invalid key
				return
			produce(product_list[key], TRUE, TRUE)
		if("auto_shutdown")
			auto_shutdown = !auto_shutdown
		if("stabilizers")
			stabilizers = !stabilizers
		if("stabilizer_priority")
			stabilizer_priority = !stabilizer_priority

/obj/machinery/power/bluespace_tap/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/bluespace_tap/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceTap", name)
		ui.open()

//emaging provides slightly more points but at much greater risk
/obj/machinery/power/bluespace_tap/emag_act(mob/living/user as mob)
	if(emagged)
		return
	emagged = TRUE
	do_sparks(5, FALSE, src)
	if(user)
		user.visible_message("<span class='warning'>[user] disables the [src]'s safeties'.</span>", "<span class='warning'>You disable the [src]'s safeties'.</span>")
	return TRUE

/obj/structure/spawner/nether/bluespace_tap
	spawn_time = 30 SECONDS
	max_mobs = 5 // Don't want them overrunning the station
	max_integrity = 250
	/// the BSH that spawned this portal
	var/obj/machinery/power/bluespace_tap/linked_source_object

/obj/structure/spawner/nether/bluespace_tap/deconstruct(disassembled)
	new /obj/item/stack/ore/bluespace_crystal(loc)	//have a reward
	return ..()

/obj/structure/spawner/nether/bluespace_tap/Destroy()
	. = ..()
	if(linked_source_object)
		linked_source_object.active_nether_portals -= src
		linked_source_object.update_icon()

/obj/item/paper/bluespace_tap
	name = "paper- 'The Experimental NT Bluespace Harvester - Mining other universes for science and profit!'"
	info = "<h1>Important Instructions!</h1>Please follow all setup instructions to ensure proper operation. <br>\
	1. Create a wire node with ample access to spare power. The device operates independently of APCs. <br>\
	2. Create a machine frame as normal on the wire node, taking into account the device's dimensions (3 by 3 meters). <br>\
	3. Insert wiring, circuit board and required components and finish construction according to NT engineering standards. <br>\
	4. Ensure the device is connected to the proper power network and the network contains sufficient power. <br>\
	5. Set machine to desired level. Check periodically on machine progress. <br>\
	6. Optionally, spend earned points on fun and exciting rewards. <br><hr>\
	<h2>Operational Principles</h2> \
	<p>The Bluespace Harvester is capable of accepting a nearly limitless amount of power to search other universes for valuables to recover. The speed of this search is controlled via the 'level' control of the device. \
	While it can be run on a low level by almost any power generation system, higher levels require work by a dedicated engineering team to power. \
	As we are interested in testing how the device performs under stress, we wish to encourage you to stress-test it and see how much power you can provide it. \
	For this reason, total shift point production will be calculated and announced at shift end. High totals may result in bonus payments to members of the Engineering department. <p>\
	<p>NT Science Directorate, Extradimensional Exploitation Research Group</p> \
	<p><small>Device highly experimental. Not for sale. Do not operate near small children or vital NT assets. Do not tamper with machine. In case of existential dread, stop machine immediately. \
	Please document any and all extradimensional incursions. In case of imminent death, please leave said documentation in plain sight for clean-up teams to recover.</small></p>"

#undef POINTS_PER_W
#undef BASE_POINTS
#undef NEAREST_MW
