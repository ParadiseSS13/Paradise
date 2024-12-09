//Station goal stuff goes here
/datum/station_goal/bluespace_tap
	name = "Bluespace Harvester"
	var/goal = 45000

/datum/station_goal/bluespace_tap/get_report()
	return {"<b>Bluespace Harvester Experiment</b><br>
	Another research station has developed a device called a Bluespace Harvester.
	It reaches through bluespace into other dimensions to shift through them for interesting objects.<br>
	Due to unforseen circumstances the large-scale test of the prototype could not be completed on the original research station. It will instead be carried out on your station.
	Acquire the circuit board, construct the device over a wire knot and feed it enough power to generate [goal] mining points by shift end.
	<br><br>
	Be advised that the device is experimental and might act in slightly unforseen ways if sufficiently powered.
	<br>
	Nanotrasen Science Directorate"}

/datum/station_goal/bluespace_tap/on_report()
	var/datum/supply_packs/misc/station_goal/bluespace_tap/P = SSeconomy.supply_packs["[/datum/supply_packs/misc/station_goal/bluespace_tap]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_tap/check_completion()
	if(..())
		return TRUE
	var/highscore = 0
	for(var/obj/machinery/power/bluespace_tap/T in GLOB.machines)
		highscore = max(highscore, T.total_points)
	to_chat(world, "<b>Bluespace Harvester Highscore</b>: [highscore >= goal ? "<span class='greenannounce'>": "<span class='boldannounceic'>"][highscore]</span>")
	if(highscore >= goal)
		return TRUE
	return FALSE

//needed for the vending part of it
/datum/data/bluespace_tap_product
	var/product_name = "generic"
	var/product_path = null
	var/product_cost = 100	//cost in mining points to generate


/datum/data/bluespace_tap_product/New(name, path, cost)
	product_name = name
	product_path = path
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
	power_state = NO_POWER_USE	// power usage is handelled manually
	density = TRUE
	interact_offline = TRUE
	luminosity = 1

	/// list of possible products
	var/static/product_list = list(
	new /datum/data/bluespace_tap_product("Unknown Exotic Hat", /obj/effect/spawner/random/bluespace_tap/hat, 5000),
	new /datum/data/bluespace_tap_product("Unknown Snack", /obj/effect/spawner/random/bluespace_tap/food, 6000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/random/bluespace_tap/cultural, 15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact", /obj/effect/spawner/random/bluespace_tap/organic, 20000)
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
	var/list/active_nether_portals = list()
	/// The amount of portals waiting to be spawned. Used mostly for UI and icon stuff.
	var/spawning = 0

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
		mining_power = mining_power - mining_power % (1 MW)

	// Always try to use all available power for mining if emagged
	if(emagged)
		desired_mining_power = mining_power

	/*
	* Stabilizers activate above 15MW of mining power
	* Stabilizers consume up to 1MW for each 1MW of mining power, consuming less between 15 and 30MW of mining power
	* If stabilizers have priority they will always consume enough power to stabilize the BSH, limiting mining
	* Emagging disables stabilizers
	*/
	if(stabilizer_priority)
		// stabilizer power is what we need to stabilize the current mining level, but no more than half the available power.
		stabilizer_power = \
		clamp(\
		desired_mining_power - clamp(30 MW - desired_mining_power, 0, 15 MW), \
		0, \
		mining_power / 2) \
		* (stabilizers && !emagged)
	else
		// stabilizer power is however much power we have left, but no more than we need to stabilize our desired mining power.
		stabilizer_power = \
		clamp(mining_power - desired_mining_power, \
		0, \
		desired_mining_power - clamp(30 MW - desired_mining_power, 0, 15 MW)) \
		* (stabilizers && !emagged)

	// Actual mining power is what the desired mining power we set, unless we don't have enough power to satisfty that.
	mining_power = min(desired_mining_power, mining_power - stabilizer_power)

	consume_direct_power(mining_power + stabilizer_power)

	// 2 points per 50 KW up to 20 and 4 points per MW (or 5 when emmaged).
	mined_points = min(BASE_POINTS * (mining_power / (50 KW)) , 20) + mining_power * (POINTS_PER_W + emagged / (1 MW))
	points += mined_points
	total_points += mined_points
	update_icon()
	/*
	* Portal chance is 0.1% per cycle per difference of 1MW between the stabilizer and mining power
	* This should translate to portals spawning every 33:20 minutes for 1 difference of 1MW
	* And about every 3:20 minutes for a 10MW difference
	* Emagging guarantees a chance of at least 5%
	* Prob treats values less than 0 as 0.
	* Emagging garuantees a chance of at least 5%.
	* Prob treats values less than 0 as 0.
	*/

	if(prob((mining_power - clamp(30 MW - mining_power, 0, 15 MW) - stabilizer_power)  / (10 MW)) + (emagged * 5))
		var/area/our_area = get_area(src)
		if((!spawning || !length(active_nether_portals)))
			GLOB.major_announcement.Announce("Unexpected power spike during Bluespace Harvester Operation. Extra-dimensional intruder alert. Expected location: [our_area.name]. [emagged ? "DANGER: Emergency shutdown failed! Please proceed with manual shutdown." : auto_shutdown ? "Emergency shutdown initiated." : "Automatic shutdown disabled."]", "Bluespace Harvester Malfunction", 'sound/AI/harvester.ogg')
		if(!emagged && auto_shutdown)
			desired_mining_power = 0	//emergency shutdown unless it is disabled
		// An extra portal for each 30MW above 15
		start_nether_portaling(rand(1 , 3) + round(max((mining_power - 15 MW) / (30 MW) , 0)), TRUE)

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
/obj/machinery/power/bluespace_tap/proc/produce(key)
	if(key <= 0 || key > length(product_list))	//invalid key
		return
	var/datum/data/bluespace_tap_product/A = product_list[key]
	if(!A)
		return
	if(A.product_cost > points)
		return
	points -= A.product_cost
	A.product_cost = round(1.2 * A.product_cost, 1)
	playsound(src, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, src)
	new A.product_path(get_turf(src))
	flick_overlay_view(image(icon, src, "flash", FLY_LAYER))

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
			produce(key)
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
