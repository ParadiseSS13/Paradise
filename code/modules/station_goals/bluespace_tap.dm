//Station goal stuff goes here
/datum/station_goal/bluespace_tap
	name = "Bluespace Harvester"
	var/goal = 500000

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
	var/datum/supply_packs/misc/station_goal/bluespace_tap/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bluespace_tap]"]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_tap/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/power/bluespace_tap/T in GLOB.machines)
		to_chat(world, "<b>Bluespace Harvester Highscore</b> : <span class='greenannounce'>[T.total_points]</span>")
		if(T.total_points >= goal)
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

//circuit board for building it
/obj/item/circuitboard/machine/bluespace_tap
	name = "Bluespace Harvester (Machine Board)"
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
		/obj/item/twohanded/dualsaber/toy = 5,
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
		/obj/item/clothing/gloves/combat = 5
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
		/obj/item/dnainjector/midgit = 5,
		/obj/item/dnainjector/morph = 5,
		/obj/item/dnainjector/regenerate = 5,
		/mob/living/simple_animal/pet/dog/corgi/ = 5,
		/mob/living/simple_animal/pet/cat = 5,
		/mob/living/simple_animal/pet/dog/fox/ = 5,
		/mob/living/simple_animal/pet/penguin = 5,
		/mob/living/simple_animal/pig = 5,
		/obj/item/slimepotion/sentience = 5,
		/obj/item/clothing/mask/cigarette/cigar/havana = 3,	//TODO add more neat stuff to replace xray mutation
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
		/obj/item/reagent_containers/food/snacks/wingfangchu,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/sliceable/turkey,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/appletart,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake,
		/obj/item/reagent_containers/food/snacks/sliceable/bananacake,
		/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake,
		/obj/item/reagent_containers/food/snacks/meatballsoup,
		/obj/item/reagent_containers/food/snacks/mysterysoup,
		/obj/item/reagent_containers/food/snacks/stew,
		/obj/item/reagent_containers/food/snacks/hotchili,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/fishburger,
		/obj/item/reagent_containers/food/snacks/cubancarp,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/meatpie,
		/obj/item/pizzabox/hawaiian, //it ONLY gives hawaiian. MUHAHAHA
		/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread //maybe add some dangerous/special food here, ie robobuger?
	)




//machine that consumes enormous amounts of power
/obj/machinery/power/bluespace_tap
	name = "Bluespace harvester"
	icon = 'icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"	//sprites by Ionward
	max_integrity = 300	//it's a pretty big machine.
	pixel_x = -32	//shamelessly stolen off of dna vault code, hope this works
	pixel_y = -64
	var/list/obj/structure/fillers = list()
	use_power = NO_POWER_USE	//don't pull automatic power
	active_power_usage = 500//value that will be multiplied with mining level to generate actual power use
	var/input_level = 0	//the level the machine is set to mine at. 0 means off
	var/points = 0	//mining points
	var/actual_power_usage = 500
	var/total_points = 0	//total amount of points ever earned, for tracking station goal
	density = TRUE
	interact_offline = 1
	luminosity = 1
	var/max_level = 20	//max power input level, I don't expect this to be ever reached
	var/base_value = 5	//used for power consumption, higher = more power
	var/base_points = 4	//tweaks amount of points given
	var/safe_levels = 7	//how high you can run the machine before it starts having a chance for dimension breaches
	var/static/product_list = list(	//list of items the bluespace harvester can produce
	new /datum/data/bluespace_tap_product("Unknown Exotic Hat", /obj/effect/spawner/lootdrop/bluespace_tap/hat, 10000),
	new /datum/data/bluespace_tap_product("Unknown Snack", /obj/effect/spawner/lootdrop/bluespace_tap/food, 12000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/cultural, 15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/organic, 20000)
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
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/bluespace_tap(null)
	for(var/i = 0 to 4)	//five of each
		component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
		component_parts += new /obj/item/stack/ore/bluespace_crystal(null)
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
	actual_power_usage = (base_value ** input_level) * active_power_usage	//each level takes one order of magnitude more power than the previous one
	if(surplus() < actual_power_usage)
		decrease_level()	//turn down a level when lacking power, don't want to suck the powernet dry
		return
	else
		add_load(actual_power_usage)
		var/points_to_add = (input_level + emagged) * base_points
		points += points_to_add	//point generation, emagging gets you 'free' points at the cost of higher anomaly chance
		total_points += points_to_add
		if(prob(input_level - safe_levels + (emagged * 5)))	//at dangerous levels, start doing freaky shit. prob with values less than 0 treat it as 0, so only occurs if input level > 7
			GLOB.event_announcement.Announce("Unexpected power spike during Bluespace Harvester Operation. Extra-dimensional intruder alert. Expected location: [get_area(src).name].", "Bluespace Harvester Malfunction")
			if(!emagged)
				input_level = 0	//as hilarious as it would be for the tap to spawn in even more nasties because you can't get to it to turn it off, that might be too much for now. Unless sabotage is involved
			for(var/i = 1, i <= rand(1, 3), i++)	//freaky shit here, 1-3 freaky portals
				var/turf/location = locate(x + rand(-5,5), y + rand(-5,5), z)
				new /obj/structure/spawner/nether/bluespace_tap(location)



/obj/machinery/power/bluespace_tap/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
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
		return
	if(A.product_cost > points)
		return
	points -= A.product_cost
	A.product_cost *= 1.2
	playsound(src, 'sound/magic/blink.ogg', 50)
	new A.product_path(get_turf(src))	//creates product



//UI stuff below


/obj/machinery/power/bluespace_tap/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["decrease"])
		decrease_level()
	else if(href_list["increase"])
		increase_level()
	else if(href_list["set"])
		set_level(input(usr, "Enter new input level (0-[max_level])", "Bluespace Harvester Input Control", input_level))
	else if(href_list["vend"])//it's not really vending as producing, but eh
		var/key = text2num(href_list["vend"])
		produce(key)



/obj/machinery/power/bluespace_tap/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	//stolen from SMES code
	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "bluespace_tap.tmpl", "Bluespace Harvester", 540, 380)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

//emaging provides slightly more points but at much greater risk
/obj/machinery/power/bluespace_tap/emag_act(mob/living/user as mob)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("[user] emags [src].","<span class='warning'>You override the safety protocols.</span>")

//a modifcation of the usual spawner for my purposes, spawns faster, has more health, spawns less total monsters
/obj/structure/spawner/nether/bluespace_tap
	spawn_time = 300	//30 seconds, same as necropolis tendrils
	max_mobs = 5		//Dont' want them overrunning the station
	max_integrity = 250 //same as necropolis tendrils
