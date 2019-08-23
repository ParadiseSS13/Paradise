//Station goal stuff goes here
/datum/station_goal/bluespace_tap
	name = "Bluespace Tap"
	var/goal = 500000

/datum/station_goal/bluespace_tap/get_report()
	return {"<b>Bluespace Mining Tap Experiment</b><br>
	Our search for new resources to exploit is nearing a tremendous break-through. One of our research stations in a nearby sector has recently finished a prototype for a device called a Bluespace Tap.
	It reaches through bluespace into other dimensions to mine them for rare and valuable resources, though the process is very energy intensive.<br>
	Due to unforseen circumstances the large-scale test of the prototype could not be completed on the original research station. It will instead be carried out on your station.
	Acquire the circuit board, construct the device over a wire knot and feed it enough power to generate [goal] mining points by shift end.
	<br><br>
	Be advised that the device is experimental and might act in slightly unforseen ways if sufficiently powered.
	<br>
	Nanotrasen Science Directorate"}

/datum/station_goal/bluespace_tap/on_report()
	var/datum/supply_packs/misc/bluespace_tap/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/bluespace_tap]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_tap/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/power/bluespace_tap/T in GLOB.machines)
		if(T.total_points >= goal)
			return TRUE
	return FALSE

//needed for the vending part of it
/datum/data/bluespace_tap_product
	var/product_name = "generic"
	var/product_path = null
	var/product_cost = 100	//cost in mining points to generate
	var/amount_bought = 0	//how often it has been bought so far (don't know if I'll even need this later, tbh)
	var/base_cost = 100		//base cost before cost increases


/datum/data/bluespace_tap_product/New(name, path, cost)
	product_name = name
	product_path = path
	product_cost = cost
	base_cost = cost

//circuit board for building it
/obj/item/circuitboard/machine/bluespace_tap
	name = "Bluespace Tap (Machine Board)"
	build_path = /obj/machinery/power/bluespace_tap
	origin_tech = "engineering=2;combat=2;bluespace=3"
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,//Probably okay, right?
							/obj/item/stack/ore/bluespace_crystal = 5)

/obj/effect/spawner/lootdrop/bluespace_tap
	name = "bluespace tap reward spawner"
	lootcount = 1
	color = "#00FFFF"

/obj/effect/spawner/lootdrop/bluespace_tap/cultural
	name = "cultural artifacts"
	loot = list(
		/obj/vehicle/space/speedbike/red = 10,
		/obj/item/grenade/clusterbuster/honk = 10,
		/obj/item/clothing/head/collectable/tophat = 10,
		/obj/item/clothing/head/crown/fancy = 10,
		/obj/item/clothing/head/collectable/rabbitears = 10,
		/obj/item/toy/katana = 20,
		/obj/item/storage/belt/champion = 15,
		/obj/item/stack/tile/brass/fifty = 30,
		/obj/item/stack/sheet/mineral/abductor/fifty = 30,
		/obj/item/voodoo = 5
	)

/obj/effect/spawner/lootdrop/bluespace_tap/organic
	name = "organic objects"
	loot = list(
		/obj/item/seeds/random/labelled = 50,
		/obj/item/guardiancreator/biological = 5,
		/obj/item/organ/internal/heart/gland/heals = 10,
		/obj/item/organ/internal/heart/gland/ventcrawling = 10,
		/obj/item/organ/internal/heart/gland/emp = 10,
		/obj/item/organ/internal/vocal_cords/adamantine = 15,
		/obj/item/storage/pill_bottle/random_meds/labelled = 25,
		/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 15,
		/obj/item/dnainjector/xraymut = 10,
		/mob/living/simple_animal/pet/corgi = 15
	)

/obj/effect/spawner/lootdrop/bluespace_tap/eldritch
	name = "things man was not meant to see"
	loot = list(
		/obj/item/clothing/mask/cursedclown = 20
		//TODO Talk to maints/heads what this should actually do

	)


//WIP machine that consumes enormous amounts of power
/obj/machinery/power/bluespace_tap
	name = "Bluespace mining tap"
	icon = 'icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"	//sprites by Ionward
	pixel_x = -32	//shamelessly stolen off of dna vault code, hope this works
	pixel_y = -64
	var/list/obj/structure/fillers = list()
	use_power = NO_POWER_USE	//don't pull automatic power
	active_power_usage = 500//value that will be multiplied with mining level to generate actual power use
	var/input_level = 0	//the level the machine is set to mine at. 0 means off
	var/points = 0	//mining points
	var/actual_power_usage = 500
	var/total_points = 0	//total amount of points ever earned, for tracking station goal
	density = 1
	interact_offline = 1
	luminosity = 1
	var/max_level = 20	//max power input level, I don't expect this to be ever reached
	var/static/product_list = list(	//list of items the bluespace tap can produce, lots of discussion needed
	new /datum/data/bluespace_tap_product("Metal", /obj/item/stack/sheet/metal/fifty, 100),
	new /datum/data/bluespace_tap_product("Glass", /obj/item/stack/sheet/glass/fifty, 150),
	new /datum/data/bluespace_tap_product("Diamond", /obj/item/stack/sheet/mineral/diamond/fifty, 15000),
	new /datum/data/bluespace_tap_product("Plasma", /obj/item/stack/sheet/mineral/plasma/fifty, 10000),
	new /datum/data/bluespace_tap_product("Unknown Organic Material", /obj/effect/spawner/lootdrop/bluespace_tap/organic, 20000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/cultural, 25000),
	new /datum/data/bluespace_tap_product("Bananium", /obj/item/stack/sheet/mineral/bananium/fifty, 300000),
	new /datum/data/bluespace_tap_product("Tranquillite", /obj/item/stack/sheet/mineral/tranquillite/fifty, 300000),
	new /datum/data/bluespace_tap_product("Anomaly Core", /obj/item/assembly/signaler/anomaly/random, 5000000),
	new /datum/data/bluespace_tap_product("Unknown $&ER*OR!&", /obj/effect/spawner/lootdrop/bluespace_tap/eldritch, 6660000)
	)

/obj/machinery/power/bluespace_tap/New()
	..()
	//more code stolen from dna vault, inculding comment below. Taking bets on that datum being made ever.
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,SOUTHEAST,SOUTHWEST))
		occupied += get_step(src,direct)
	occupied += locate(x+1,y-2,z)
	occupied += locate(x-1,y-2,z)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F
	if(!powernet)
		connect_to_network()

/obj/machinery/power/bluespace_tap/Destroy()
	for(var/V in fillers)
		var/obj/structure/filler/filler = V
		filler.parent = null
		qdel(filler)
	fillers.Cut()
	. = ..()

/obj/machinery/power/bluespace_tap/proc/increase_level()
	if(input_level < max_level)
		input_level++

/obj/machinery/power/bluespace_tap/proc/decrease_level()
	if(input_level > 0)
		input_level--


/obj/machinery/power/bluespace_tap/proc/set_level(desired_level)
	if(desired_level < 0)
		return
	if(desired_level > max_level)
		return

	input_level = desired_level



//stuff that happens regularily, ie power use and point generation
/obj/machinery/power/bluespace_tap/process()
	if(input_level == 0)
		actual_power_usage = 0
		return
	actual_power_usage = (10 ** input_level) * active_power_usage	//each level takes one order of magnitude more power than the previous one
	if(surplus() < actual_power_usage)
		decrease_level()	//turn down a level when lacking power, don't want to suck the powernet dry
		return
	else
		add_load(actual_power_usage)
		var/points_to_add = (input_level + emagged) * 10
		points += points_to_add	//point generation, emagging gets you 'free' points at the cost of higher anomaly chance
		total_points += points_to_add
		if(prob(input_level - 7 + (emagged * 5)))	//at dangerous levels, start doing freaky shit. prob with values less than 0 treat it as 0, so only occurs if input level > 7
			event_announcement.Announce("Unexpected power spike during Bluespace Tap Operation. Extra-dimensional intruder alert. Expected location: [get_area(src).name].", "Bluespace Tap Malfunction")
			if(!emagged)
				input_level = 0	//as hilarious as it would be for the tap to spawn in even more nasties because you can't get to it to turn it off, that might be too much for now. Unless sabotage is involved
			for(var/i = 1, i <= rand(1, 3), i++)	//freaky shit here, 1-3 freaky portals
				var/mob/living/simple_animal/hostile/spawner/nether/bluespace_tap/portal = new(src)
				portal.forceMove(get_turf(src))
				for(var/j = 1, j <= rand(2, 4), j++)
					step(portal, pick(NORTH, WEST, SOUTH, EAST))


/obj/machinery/power/bluespace_tap/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["level"] = input_level
	data["points"] = points
	data["total_points"] = total_points
	data["power_use"] = actual_power_usage
	data["available_power"] = surplus()
	data["max_level"] = max_level
	data["emagged"] = emagged

	var/list/listed_items = list()//a list of lists, each inner list equals a datum
	for(var/key = 1 to length(product_list))
		var/datum/data/bluespace_tap_product/A = product_list[key]
		listed_items.Add(list(list(
				"key" = key,
				"name" = A.product_name,
				"price" = A.product_cost)))


	data["product"] = listed_items
	return data


/obj/machinery/power/bluespace_tap/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)


/obj/machinery/power/bluespace_tap/attack_ai(mob/user)
	ui_interact(user)

//produces and vends the product with the desired key
/obj/machinery/power/bluespace_tap/proc/produce(key)
	var/datum/data/bluespace_tap_product/A = product_list[key]
	if(!A)	//if called with a bogus key or something, just return
		message_admins("Yo you fucked up, no product for key [key]")	//debugging, weeeee
		return
	if(A.product_cost > points)
		return
	points -= A.product_cost
	A.product_cost *= 1.2
	playsound(src, 'sound/magic/blink.ogg', 50)
	new A.product_path(get_turf(src))	//creates product



//UI stuff below


//TODO: Do input/output here
/obj/machinery/power/bluespace_tap/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["decrease"])
		decrease_level()
	else if(href_list["increase"])
		increase_level()
	else if(href_list["set"])
		set_level(input(usr, "Enter new input level (0-[max_level])", "Bluespace Tap Input Control", input_level))
	else if(href_list["vend"])//it's not really vending as producing, but eh
		var/key = text2num(href_list["vend"])
		produce(key)



/obj/machinery/power/bluespace_tap/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	//stolen from SMES code
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "bluespace_tap.tmpi", "Bluespace Tap", 540, 380)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

//emaging allows anyone to use it. Might also add additional options that are unlocked via it.
/obj/machinery/power/bluespace_tap/emag_act(var/mob/living/user as mob)
	if(!emagged)
		emagged = 1
		if(user)
			user.visible_message("[user.name] emags the [src.name].","<span class='warning'>You short out the lock.</span>")

//a modifcation of the usual spawner for my purposes, spawns faster, has more health, spawns less total monsters
/mob/living/simple_animal/hostile/spawner/nether/bluespace_tap
	spawn_time = 300	//30 seconds, same as necropolis tendrils
	max_mobs = 5		//Dont' want them overrunning the station
	health = 150		//but also don't want them to be destroyed too easily
	maxHealth = 150
	pressure_resistance = 100	//pressure moving portals felt very silly
