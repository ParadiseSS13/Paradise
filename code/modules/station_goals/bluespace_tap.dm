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

/obj/effect/spawner/lootdrop/bluespace_tap
	name = "bluespace harvester reward spawner"
	lootcount = 1

/obj/effect/spawner/lootdrop/bluespace_tap/hat
	name = "exotic hat"
	loot = list(
			/obj/item/clothing/head/collectable/chef,	//same weighing on all of them
			/obj/item/clothing/head/collectable/paper,
			/obj/item/clothing/head/collectable/tophat,
			/obj/item/clothing/head/collectable/captain,
			/obj/item/clothing/head/collectable/beret,
			/obj/item/clothing/head/collectable/welding,
			/obj/item/clothing/head/collectable/flatcap,
			/obj/item/clothing/head/collectable/pirate,
			/obj/item/clothing/head/collectable/kitty,
			/obj/item/clothing/head/crown/fancy,
			/obj/item/clothing/head/collectable/rabbitears,
			/obj/item/clothing/head/collectable/wizard,
			/obj/item/clothing/head/collectable/hardhat,
			/obj/item/clothing/head/collectable/HoS,
			/obj/item/clothing/head/collectable/thunderdome,
			/obj/item/clothing/head/collectable/swat,
			/obj/item/clothing/head/collectable/slime,
			/obj/item/clothing/head/collectable/police,
			/obj/item/clothing/head/collectable/slime,
			/obj/item/clothing/head/collectable/xenom,
			/obj/item/clothing/head/collectable/petehat
	)


/obj/effect/spawner/lootdrop/bluespace_tap/cultural
	name = "cultural artifacts"
	loot = list(
		/obj/vehicle/space/speedbike/red = 10,
		/obj/item/grenade/clusterbuster/honk = 10,
		/obj/item/toy/katana = 10,
		/obj/item/stack/tile/brass/fifty = 20,
		/obj/item/stack/sheet/mineral/abductor/fifty = 20,
		/obj/item/sord = 20,
		/obj/item/toy/syndicateballoon = 15,
		/obj/item/lighter/zippo/gonzofist = 5,
		/obj/item/lighter/zippo/engraved = 5,
		/obj/item/lighter/zippo/nt_rep = 5,
		/obj/item/gun/projectile/automatic/c20r/toy = 1,
		/obj/item/gun/projectile/automatic/l6_saw/toy = 1,
		/obj/item/gun/projectile/automatic/toy/pistol = 2,
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 1,
		/obj/item/gun/projectile/shotgun/toy = 1,
		/obj/item/gun/projectile/shotgun/toy/crossbow = 1,
		/obj/item/gun/projectile/shotgun/toy/tommygun = 1,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy = 1,
		/obj/item/dualsaber/toy = 5,
		/obj/machinery/snow_machine = 10,
		/obj/item/clothing/head/kitty = 5,
		/obj/item/coin/antagtoken = 5,
		/obj/item/toy/prizeball/figure = 15,
		/obj/item/toy/prizeball/therapy = 10,
		/obj/item/bedsheet/patriot = 2,
		/obj/item/bedsheet/rainbow = 2,
		/obj/item/bedsheet/captain = 2,
		/obj/item/bedsheet/centcom = 1, //mythic rare rarity
		/obj/item/bedsheet/syndie = 2,
		/obj/item/bedsheet/cult = 2,
		/obj/item/bedsheet/wiz = 2,
		/obj/item/stack/sheet/mineral/tranquillite/fifty = 3,
		/obj/item/clothing/gloves/combat = 5,
		/obj/item/blank_tarot_card = 5,
		/obj/item/tarot_card_pack = 5,
		/obj/item/tarot_card_pack/jumbo = 3,
		/obj/item/tarot_card_pack/mega = 2
	)

/obj/effect/spawner/lootdrop/bluespace_tap/organic
	name = "organic objects"
	loot = list(
		/obj/item/seeds/random/labelled = 50,
		/obj/item/guardiancreator/biological = 5,
		/obj/item/organ/internal/vocal_cords/adamantine = 15,
		/obj/item/storage/pill_bottle/random_meds/labelled = 25,
		/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 15,
		/obj/item/dnainjector/telemut = 5,
		/obj/item/dnainjector/small_size = 5,
		/obj/item/dnainjector/morph = 5,
		/obj/item/dnainjector/regenerate = 5,
		/mob/living/simple_animal/pet/dog/corgi/ = 5,
		/mob/living/simple_animal/pet/cat = 5,
		/mob/living/simple_animal/pet/dog/fox/ = 5,
		/mob/living/simple_animal/pet/penguin/baby = 5,
		/mob/living/simple_animal/pig = 5,
		/obj/item/slimepotion/sentience = 5,
		/obj/item/clothing/mask/cigarette/cigar/havana = 3,
		/obj/item/stack/sheet/mineral/bananium/fifty = 2,	//bananas are organic, clearly.
		/obj/item/storage/box/monkeycubes = 5,
		/obj/item/stack/tile/carpet/twenty = 10,
		/obj/item/stack/tile/carpet/black/twenty = 10,
		/obj/item/soap/deluxe = 5
	)

/obj/effect/spawner/lootdrop/bluespace_tap/food
	name = "fancy food"
	lootcount = 3
	loot = list(
		/obj/item/food/wingfangchu,
		/obj/item/food/hotdog,
		/obj/item/food/sliceable/turkey,
		/obj/item/food/plumphelmetbiscuit,
		/obj/item/food/appletart,
		/obj/item/food/sliceable/cheesecake,
		/obj/item/food/sliceable/bananacake,
		/obj/item/food/sliceable/chocolatecake,
		/obj/item/food/soup/meatballsoup,
		/obj/item/food/soup/mysterysoup,
		/obj/item/food/soup/stew,
		/obj/item/food/soup/hotchili,
		/obj/item/food/burrito,
		/obj/item/food/fishburger,
		/obj/item/food/cubancarp,
		/obj/item/food/fishandchips,
		/obj/item/food/meatpie,
		/obj/item/pizzabox/hawaiian, //it ONLY gives hawaiian. MUHAHAHA
		/obj/item/food/sliceable/xenomeatbread //maybe add some dangerous/special food here, ie robobuger?
	)

#define BASE_ENERGY_CONVERSION 4e-6
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
	/// For faking having a big machine, dummy 'machines' that are hidden inside the large sprite and make certain tiles dense. See new and destroy.
	var/list/obj/structure/fillers = list()
	power_state = NO_POWER_USE	// power usage is handelled manually
	density = TRUE
	interact_offline = TRUE
	luminosity = 1

	/// Correspond to power required for a mining level, first entry for level 1, etc.
	var/list/power_needs = list(1 KW, 2 KW, 5 KW, 10 KW, 15 KW,
								25 KW, 50 KW, 100 KW, 250 KW, 500 KW,
								1 MW, 2 MW, 5 MW, 10 MW, 15 MW,
								20 MW, 25 MW, 30 MW, 40 MW, 50 MW,
								60 MW, 70 MW, 80 MW, 90 MW, 100 MW)

	/// list of possible products
	var/static/product_list = list(
	new /datum/data/bluespace_tap_product("Unknown Exotic Hat", /obj/effect/spawner/lootdrop/bluespace_tap/hat, 5000),
	new /datum/data/bluespace_tap_product("Unknown Snack", /obj/effect/spawner/lootdrop/bluespace_tap/food, 6000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/cultural, 15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/organic, 20000)
	)

	/// The level the machine is currently mining at. 0 means off
	var/input_level = 0
	/// The machine you WANT the machine to mine at. It will try to match this.
	var/desired_level = 0
	/// Available mining points
	var/points = 0
	/// The total points earned by this machine so far, for tracking station goal and highscore
	var/total_points = 0
	/// How much power the machine needs per processing tick at the current level.
	var/actual_power_usage = 0


	// Tweak these and active_power_consumption to balance power generation

	/// Max power input level, I don't expect this to be ever reached. It has been reached.
	var/max_level = 25
	/// amount of points generated per level for the first 10 levels
	var/base_points = BASE_POINTS
	/// amount of points generated per process cycle per unit of energy consumed
	var/conversion_ratio = BASE_ENERGY_CONVERSION
	/// How high the machine can be run before it starts having a chance for dimension breaches.
	var/safe_levels = 15
	/// Whether or not auto shutdown will engage when portals open
	var/auto_shutdown = TRUE
	/// Whether or not stabilizers will engage to prevent or reduce the chance of portals opening
	var/stabilizers = TRUE
	/// Amount of power the stabilizers consume
	var/stabilizer_power = 0
	/// Amount of overhead in levels. Each level of overhead allows stabilizing 15+overhead.
	var/overhead = 0
	/// When event triggers this will hold references to all portals so we can fix the sprite after they're broken
	var/list/active_nether_portals = list()

/obj/machinery/power/bluespace_tap/Initialize(mapload)
	. = ..()
	//more code stolen from dna vault, inculding comment below. Taking bets on that datum being made ever.
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(NORTH, NORTHEAST, NORTHWEST, EAST, WEST, SOUTHEAST, SOUTHWEST))
		occupied += get_step(src, direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/bluespace_tap(null)
	for(var/i = 1 to 5)	//five of each
		component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
		component_parts += new /obj/item/stack/ore/bluespace_crystal(null)
	if(!powernet)
		connect_to_network()

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

	if(length(active_nether_portals))
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
	switch(input_level)
		if(0)
			return 0
		if(1 to 3)
			return 1
		if(4 to 8)
			return 2
		if(9 to 11)
			return 3
		if(12 to 15)
			return 4
		if(16 to INFINITY)
			return 5

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

/obj/machinery/power/bluespace_tap/Destroy()
	QDEL_LIST_CONTENTS(fillers)
	return ..()

/**
  * Increases the desired mining level
  *
  * Increases the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT increase the actual mining level directly.
  */
/obj/machinery/power/bluespace_tap/proc/increase_level()
	if(desired_level < max_level)
		desired_level++
/**
  * Decreases the desired mining level
  *
  * Decreases the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT decrease the actual mining level directly.
  */
/obj/machinery/power/bluespace_tap/proc/decrease_level()
	if(desired_level > 0)
		desired_level--

/**
  * Sets the desired mining level
  *
  * Sets the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT change the actual mining level directly.
  * Arguments:
  * * t_level - The level we try to set it at, between 0 and max_level
 */
/obj/machinery/power/bluespace_tap/proc/set_level(t_level)
	if(t_level < 0)
		return
	if(t_level > max_level)
		return
	desired_level = t_level

/**
  * Gets the amount of power at a set input level
  *
  * Gets the amount of power (in W) a set input level needs.
  * Note that this is not necessarily the current power use.
  * * i_level - The hypothetical input level for which we want to know the power use.
  */
/obj/machinery/power/bluespace_tap/proc/get_power_use(i_level)
	if(!i_level)
		return 0
	return power_needs[i_level]

/obj/machinery/power/bluespace_tap/process()
	actual_power_usage = get_power_use(input_level)
	if(get_surplus() < actual_power_usage)	//not enough power, so turn down a level
		input_level--
		update_icon()
		return	// and no mining gets done
	if(actual_power_usage)
		consume_direct_power(actual_power_usage)
		//2 points per level up to level 10 and 4 points per MW (or 5 when emmaged).
		var/points_to_add = min(base_points * 10, base_points * input_level) + actual_power_usage * (conversion_ratio + emagged * 1e-6)
		points += points_to_add	// point generation, emagging gets you 'free' points at the cost of higher anomaly chance
		total_points += points_to_add
	// Between levels 15 and 18 get one level of overhead per 5MW of surplus power. Above level 18 get 1 level per 10MW of surplus power.
	overhead = input_level >= 18  ? get_surplus() * 1e-7 : get_surplus() * 2e-7
	stabilizer_power = stabilizers && input_level > 15 ? input_level >= 18 ? min(get_surplus() , (input_level - 15) * 1e7) : min(get_surplus() , (input_level - 15) * 0.5e7) : 0
	consume_direct_power(stabilizer_power)
	// actual input level changes slowly
	// holy shit every proccess this
	if(input_level < desired_level && (get_surplus() + get_power_use(input_level) + stabilizer_power >= get_power_use(input_level + 1)))
		input_level++
		update_icon()
	else if(input_level > desired_level)
		input_level--
		update_icon()
	// Stabilizers reduce the chance of portals. prob with values less than 0 treat it as 0.
	if(prob(input_level - (safe_levels + stabilizers * overhead) + (emagged * 5)))
		var/area/our_area = get_area(src)
		if(!length(active_nether_portals))
			GLOB.major_announcement.Announce("Unexpected power spike during Bluespace Harvester Operation. Extra-dimensional intruder alert. Expected location: [our_area.name]. [emagged ? "DANGER: Emergency shutdown failed! Please proceed with manual shutdown." : auto_shutdown ? "Emergency shutdown initiated." : "Automatic shutdown disabled."]", "Bluespace Harvester Malfunction", 'sound/AI/harvester.ogg')
		if(!emagged && auto_shutdown)
			input_level = 0	//emergency shutdown unless it is disabled
			desired_level = 0
		start_nether_portaling(rand(1 , 3) + max((level - 15 - overhead) / 3 , 0))

/obj/machinery/power/bluespace_tap/proc/start_nether_portaling(amount)
	var/turf/location = locate(x + rand(-5, 5), y + rand(-5, 5), z)
	var/obj/structure/spawner/nether/bluespace_tap/P = new /obj/structure/spawner/nether/bluespace_tap(location)
	amount--
	active_nether_portals += P
	P.linked_source_object = src
	// 1 Extra mob for each 2 levels above 15.
	P.max_mobs = 5 + max((input_level - 15) / 2, 0)
	update_icon()
	if(amount)
		addtimer(CALLBACK(src, PROC_REF(start_nether_portaling), amount), rand(3, 5) SECONDS)

/obj/machinery/power/bluespace_tap/ui_data(mob/user)
	var/list/data = list()

	data["desiredLevel"] = desired_level
	data["inputLevel"] = input_level
	data["points"] = points
	data["totalPoints"] = total_points
	data["powerUse"] = actual_power_usage + stabilizer_power
	data["availablePower"] = get_surplus()
	data["maxLevel"] = max_level
	data["emagged"] = emagged
	data["safeLevels"] = safe_levels
	data["nextLevelPower"] = get_power_use(input_level + 1)
	data["autoShutown"] = auto_shutdown
	data["overhead"] = overhead
	data["stabilizers"] = stabilizers
	data["stabilizerPower"] = stabilizer_power

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
	if(length(active_nether_portals))		//this would be cool if we made unique TGUI for this
		to_chat(user, "<span class='warning'>UNKNOWN INTERFERENCE ... UNRESPONSIVE</span>")
		return
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ai(mob/user)
	if(length(active_nether_portals))		//this would be cool if we made unique TGUI for this
		to_chat(user, "<span class='warning'>UNKNOWN INTERFERENCE ... UNRESPONSIVE</span>")
		return
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
		if("decrease")
			decrease_level()
		if("increase")
			increase_level()
		if("set")
			set_level(text2num(params["set_level"]))
		if("vend")//it's not really vending as producing, but eh
			var/key = text2num(params["target"])
			produce(key)
		if("auto_shutdown")
			auto_shutdown = !auto_shutdown
		if("stabilizers")
			stabilizers = !stabilizers

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
	desired_level = max_level
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

#undef BASE_ENERGY_CONVERSION
#undef BASE_POINTS
