// Attempts to offload processing for the spreading plants from the MC.
// Processes vines/spreading plants.

#define PLANTS_PER_TICK 500 // Cap on number of plant segments processed.
#define PLANT_TICK_TIME 75  // Number of ticks between the plant processor cycling.

// Debug for testing seed genes (less useful now that the obfuscation is gone, but still might be useful for the future.
/client/proc/show_plant_genes()
	set category = "Debug"
	set name = "Show Plant Genes"
	set desc = "Prints the round's plant gene tags."

	if(!holder)	return

	if(!plant_controller || !plant_controller.gene_tag_list)
		to_chat(usr, "Gene tags not set.")
		return

	for(var/gene_tag in plant_controller.gene_tag_list)
		to_chat(usr, "[gene_tag]")

var/global/datum/controller/plants/plant_controller // Set in New().

/datum/controller/plants

	var/plants_per_tick = PLANTS_PER_TICK
	var/plant_tick_time = PLANT_TICK_TIME
	var/list/product_descs = list()         // Stores generated fruit descs.
	var/list/plant_queue = list()           // All queued plants.
	var/list/seeds = list()                 // All seed data stored here.
	var/list/gene_tag_list = list()        	// List of gene tags for xenobotany fun
	var/list/plant_icon_cache = list()      // Stores images of growth, fruits and seeds.
	var/list/plant_sprites = list()         // List of all harvested product sprites.
	var/list/plant_product_sprites = list() // List of all growth sprites plus number of growth stages.
	//var/processing = 0                      // Off/on.

/datum/controller/plants/New()
	if(plant_controller && plant_controller != src)
		log_debug("Rebuilding plant controller.")
		qdel(plant_controller)
	plant_controller = src
	setup()
	process()

/datum/controller/plants/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

// Predefined/roundstart varieties use a string key to make it
// easier to grab the new variety when mutating. Post-roundstart
// and mutant varieties use their uid converted to a string instead.
// Looks like shit but it's sort of necessary.
/datum/controller/plants/proc/setup()

	// Build the icon lists.
	for(var/icostate in icon_states('icons/obj/hydroponics_growing.dmi'))
		var/split = findtext(icostate,"-")
		if(!split)
			// invalid icon_state
			continue

		var/ikey = copytext(icostate,(split+1))
		if(ikey == "dead")
			// don't count dead icons
			continue
		ikey = text2num(ikey)
		var/base = copytext(icostate,1,split)

		if(!(plant_sprites[base]) || (plant_sprites[base]<ikey))
			plant_sprites[base] = ikey

	for(var/icostate in icon_states('icons/obj/hydroponics_products.dmi'))
		var/split = findtext(icostate,"-")
		if(split)
			plant_product_sprites |= copytext(icostate,1,split)

	// Populate the global seed datum list.
	for(var/type in subtypesof(/datum/seed))
		var/datum/seed/S = new type
		seeds[S.name] = S
		S.uid = "[seeds.len]"
		S.roundstart = 1

	// Make sure any seed packets that were mapped in are updated
	// correctly (since the seed datums did not exist a tick ago).
	for(var/obj/item/seeds/S in world)
		S.update_seed()

	//Might as well mask the gene types while we're at it.
	var/list/plant_traits = ALL_GENES
	while(plant_traits && plant_traits.len)
		var/gene_tag = pick(plant_traits)
		plant_traits -= gene_tag
		gene_tag_list.Add(gene_tag)

// Proc for creating a random seed type.
/datum/controller/plants/proc/create_random_seed(var/survive_on_station)
	var/datum/seed/seed = new()
	seed.uid = plant_controller.seeds.len + 1
	seed.name = "[seed.uid]"
	seed.randomize()
	seeds[seed.name] = seed

	if(survive_on_station)
		if(seed.consume_gasses)
			seed.consume_gasses["plasma"] = null
			seed.consume_gasses["carbon_dioxide"] = null
		if(seed.chems && !isnull(seed.chems["pacid"]))
			seed.chems -= "pacid" // Eating through the hull will make these plants completely inviable, albeit very dangerous.
		seed.set_trait(TRAIT_IDEAL_HEAT,293)
		seed.set_trait(TRAIT_HEAT_TOLERANCE,20)
		seed.set_trait(TRAIT_IDEAL_LIGHT,8)
		seed.set_trait(TRAIT_LIGHT_TOLERANCE,5)
		seed.set_trait(TRAIT_LOWKPA_TOLERANCE,25)
		seed.set_trait(TRAIT_HIGHKPA_TOLERANCE,200)
	return seed

/datum/controller/plants/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		var/processed = 0
		while(1)
			if(!processing)
				sleep(plant_tick_time)
			else
				processed = 0
				if(plant_queue.len)
					var/target_to_process = min(plant_queue.len,plants_per_tick)
					for(var/x=0;x<target_to_process;x++)
						if(!plant_queue.len)
							break
						var/obj/effect/plant/plant = pick(plant_queue)
						plant_queue -= plant
						if(!istype(plant) || !isnull(plant.gcDestroyed))
							continue
						plant.process()
						processed++
						sleep(1) // Stagger processing out so previous tick can resolve (overlapping plant segments etc)
				sleep(max(1,(plant_tick_time-processed)))

/datum/controller/plants/proc/add_plant(var/obj/effect/plant/plant)
	plant_queue |= plant

/datum/controller/plants/proc/remove_plant(var/obj/effect/plant/plant)
	plant_queue -= plant

/client/proc/list_plant_sprites()
	if(!plant_controller || !plant_controller.plant_sprites || !plant_controller.plant_sprites.len)
		to_chat(world, "Cannot list plant sprites, plant controller or plant sprites list may not be initialized.")

	for(var/base in plant_controller.plant_sprites)
		to_chat(world, "[base] : [plant_controller.plant_sprites[base]] growth states")
