/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "hydrotray3"
	density = 1
	anchored = 1
	flags = OPENCONTAINER
	volume = 100

	var/mechanical = 1         // Set to 0 to stop it from drawing the alert lights.
	var/base_name = "tray"

	// Plant maintenance vars.
	var/waterlevel = 100       // Water level (max 100)
	var/maxwater = 100
	var/nutrilevel = 10        // Nutrient level (max 10)
	var/maxnutri = 10
	var/pestlevel = 0          // Pests (max 10)
	var/weedlevel = 0          // Weeds (max 10)

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have we taken a sample?

	// Harvest/mutation mods.
	var/yield_mod = 0          // Modifier to yield
	var/mutation_mod = 0       // Modifier to mutation chance
	var/toxins = 0             // Toxicity in the tray?
	var/tray_light = 1         // Supplied lighting.

	// Mechanical concerns.
	var/health = 0             // Plant health.
	var/lastproduce = 0        // Last time tray was harvested
	var/current_cycle = 0	   // Used for tracking number of cycles for aging
	var/lastcycle = 0          // Cycle timing/tracking var.
	var/cycledelay = 150       // Delay per cycle.
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/obj/temp_chem_holder   // Something to hold reagents during process_reagents()
	var/labelled

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

	// Construction
	var/unwrenchable = 1

	var/last_plant_ikey		//This is for debugging reference, and is otherwise useless. --FalseIncarnate

	var/recent_bee_visit = FALSE //Have we been visited by a bee recently, so bees dont overpolinate one plant

/*
*	process() can be found in \code\modules\hydroponics\tray\tray_process.dm
*	reagent handling can be found in \code\modules\hydroponics\tray\tray_reagents.dm
*	icon handling can be found in \code\modules\hydroponics\tray\tray_update_icons.dm
*/

/obj/machinery/portable_atmospherics/hydroponics/AltClick()
	if(mechanical && !usr.stat && !usr.lying && Adjacent(usr))
		close_lid(usr)
		return
	return ..()

/obj/machinery/portable_atmospherics/hydroponics/proc/attack_generic(var/mob/user)
	if(istype(user,/mob/living/simple_animal/diona))
		var/mob/living/simple_animal/diona/nymph = user

		if(nymph.stat == DEAD || nymph.paralysis || nymph.weakened || nymph.stunned || nymph.restrained())
			return

		if(weedlevel > 0)
			nymph.reagents.add_reagent("nutriment", weedlevel)
			weedlevel = 0
			nymph.visible_message("<font color='blue'><b>[nymph]</b> begins rooting through [src], ripping out weeds and eating them noisily.</font>","<font color='blue'>You begin rooting through [src], ripping out weeds and eating them noisily.</font>")
		else if(nymph.nutrition > 100 && nutrilevel < 10)
			nymph.nutrition -= ((10-nutrilevel)*5)
			nutrilevel = 10
			nymph.visible_message("<font color='blue'><b>[nymph]</b> secretes a trickle of green liquid, refilling [src].</font>","<font color='blue'>You secrete a trickle of green liquid, refilling [src].</font>")
		else
			nymph.visible_message("<font color='blue'><b>[nymph]</b> rolls around in [src] for a bit.</font>","<font color='blue'>You roll around in [src] for a bit.</font>")
		return

/obj/machinery/portable_atmospherics/hydroponics/New()
	..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/hydroponics(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

	temp_chem_holder = new()
	temp_chem_holder.create_reagents(10)

	create_reagents(200)
	connect()
	update_icon()
	if(closed_system)
		flags &= ~OPENCONTAINER

/obj/machinery/portable_atmospherics/hydroponics/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/hydroponics(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	RefreshParts()

/obj/machinery/portable_atmospherics/hydroponics/RefreshParts()
	var/tmp_capacity = 0
	for (var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		tmp_capacity += M.rating
	maxwater = tmp_capacity * 50 // Up to 300
	maxnutri = tmp_capacity * 5 // Up to 30
	//waterlevel = maxwater
	//nutrilevel = 3

/obj/machinery/portable_atmospherics/hydroponics/bullet_act(var/obj/item/projectile/Proj)

	//Don't act on seeds like dionaea that shouldn't change.
	if(seed && seed.get_trait(TRAIT_IMMUTABLE) > 0)
		return

	//--FalseIncarnate
	//Override for somatoray projectiles, updated to work with new mutation rework
	if(istype(Proj ,/obj/item/projectile/energy/floramut))
		mutate("F1")
		return
	else if(istype(Proj ,/obj/item/projectile/energy/florayield))
		mutate("F2")
		return
	//--FalseIncarnate

	..()

/obj/machinery/portable_atmospherics/hydroponics/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/hydroponics/proc/check_health()
	if(seed && !dead && health <= 0)
		die()
	check_level_sanity()
	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/proc/die()
	dead = 1
	harvest = 0
	weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
	pestlevel = 0

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(var/mob/user)

	//Harvest the product of the plant,
	if(!seed || !harvest)
		return

	if(closed_system)
		if(user)
			to_chat(user, "You can't harvest from the plant while the lid is shut.")
		return

	if(user)
		seed.harvest(user,yield_mod)
	else
		seed.harvest(get_turf(src),yield_mod)
	//Increases harvest count for round-end score
	//Currently per-plant (not per-item) harvested
	// --FalseIncarnate
	score_stuffharvested++

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.get_trait(TRAIT_HARVEST_REPEAT))
		yield_mod = 0
		seed = null
		dead = 0
		age = 0
		lastproduce = 0
		sampled = 0
		mutation_mod = 0

	check_health()
	return

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(var/mob/user)
	if(!user || !dead) return

	if(closed_system)
		to_chat(user, "You can't remove the dead plant while the lid is shut.")
		return

	seed = null
	dead = 0

	sampled = 0
	age = 0
	lastproduce = 0
	yield_mod = 0
	mutation_mod = 0

	to_chat(user, "You remove the dead plant.")
	check_health()
	return

// If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()

	//Remove the seed if something is already planted.
	if(seed) seed = null
	seed = plant_controller.seeds[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","weeds"))]
	if(!seed) return //Weed does not exist, someone fucked up.

	dead = 0
	age = 0
	health = seed.get_trait(TRAIT_ENDURANCE)
	lastcycle = world.time
	harvest = 0
	lastproduce = 0
	weedlevel = 0
	pestlevel = 0
	sampled = 0
	update_icon()
	visible_message("<span class='notice'>[src] has been overtaken by [seed.display_name].</span>")

	return

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(var/severity)

	// No seed, no mutations.
	if(!seed)
		return

	/*
	--FalseIncarnate
	New mutation system, now uses "Mutation Tiers" to adjust the chances of mutations
		Tier 1 has a low chance of causing a stat mutation
		Tier 2 has a higher chance of causing a stat mutation
		Tier 3 has a low chance of causing a species shift (if possible), and will ALWAYS cause a stat mutation if it does not shift species
		Tier 4 has a higher chance of causing a species shift (if possible), and will ALWAYS cause a stat mutation if it does not shift species
			Tier 4 also has a low chance to cause a SECOND stat mutation when it does not shift species
	All mutation chances are increased by the mutation_mod value. Mutation_mod is not transferred into seeds/harvests, and is reset when the plant dies
	*/

	switch(severity)
		//Reagent Tiers
		if(1)		//Tier 1
			if(prob(20+mutation_mod))							//Low chance of stat mutation
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				seed.mutate(1,get_turf(src))
				return
		if(2)		//Tier 2
			if(prob(60+mutation_mod))							//Higher chance of stat mutation
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				seed.mutate(1,get_turf(src))
				return
		if(3)		//Tier 3
			if(prob(20+mutation_mod))							//Low chance of species shift mutation
				if(seed.mutants. && seed.mutants.len)			//Check if current seed/plant has mutant species
					mutate_species()
				else											//No mutant species, mutate stats instead
					if(!isnull(plant_controller.seeds[seed.name]))
						seed = seed.diverge()
					else
						seed.update_name_prefixes()
					seed.mutate(1,get_turf(src))
				return
			else												//Failed to shift, mutate stats instead
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				seed.mutate(1,get_turf(src))
				return
		if(4)		//Tier 4
			if(prob(60+mutation_mod))							//Higher chance of species shift mutation
				if(seed.mutants. && seed.mutants.len)			//Check if current seed/plant has mutant species
					mutate_species()
				else											//No mutant species, mutate stats instead
					if(!isnull(plant_controller.seeds[seed.name]))
						seed = seed.diverge()
					else
						seed.update_name_prefixes()
					seed.mutate(1,get_turf(src))
					if(prob(20+mutation_mod))					//Low chance for second stat mutation
						if(!isnull(plant_controller.seeds[seed.name]))
							seed = seed.diverge()
						else
							seed.update_name_prefixes()
						seed.mutate(1,get_turf(src))
				return
			else												//Failed to shift, mutate stats instead
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				seed.mutate(1,get_turf(src))
				if(prob(20+mutation_mod))						//Low chance for second stat mutation
					if(!isnull(plant_controller.seeds[seed.name]))
						seed = seed.diverge()
					else
						seed.update_name_prefixes()
					seed.mutate(1,get_turf(src))
				return
		//Floral Somatoray Tiers
		if("F1")	//Random Stat Tier
			if(prob(80+mutation_mod))							//EVEN Higher chance of stat mutation
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				seed.mutate(1,get_turf(src))
				return
		if("F2")	//Yield Tier
			if(prob(40+mutation_mod))							//Medium chance of Yield stat mutation
				if(!isnull(plant_controller.seeds[seed.name]))
					seed = seed.diverge()
				else
					seed.update_name_prefixes()
				if(seed.get_trait(TRAIT_IMMUTABLE) <= 0 && seed.get_trait(TRAIT_YIELD) != -1)		//Check if the plant can be mutated and has a yield to mutate
					seed.set_trait(TRAIT_YIELD, (seed.get_trait(TRAIT_YIELD) + rand(-2, 2)))		//Randomly adjust yield
					if(seed.get_trait(TRAIT_YIELD) < 0)							//If yield would drop below 0 after adjustment, set to 0 to allow further attempts
						seed.set_trait(TRAIT_YIELD, 0)
				return

	/* code references
	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(seed_types[seed.name]))
		seed = seed.diverge()
	seed.mutate(severity,get_turf(src))
	*/

	//--FalseIncarnate

/obj/machinery/portable_atmospherics/hydroponics/verb/remove_label()

	set name = "Remove Label"
	set category = "Object"
	set src in view(1)

	if(labelled)
		to_chat(usr, "You remove the label.")
		labelled = null
		update_icon()
	else
		to_chat(usr, "There is no label to remove.")
	return

/obj/machinery/portable_atmospherics/hydroponics/verb/setlight()
	set name = "Set Light"
	set category = "Object"
	set src in view(1)

	var/new_light = input("Specify a light level.") as null|anything in list(0,1,2,3,4,5,6,7,8,9,10)
	if(new_light)
		tray_light = new_light
		to_chat(usr, "You set the tray to a light level of [tray_light] lumens.")

/obj/machinery/portable_atmospherics/hydroponics/proc/check_level_sanity()
	//Make sure various values are sane.
	if(seed)
		health =     max(0,min(seed.get_trait(TRAIT_ENDURANCE),health))
	else
		health = 0
		dead = 0

	nutrilevel =	max(0,min(nutrilevel,maxnutri))
	waterlevel =	max(0,min(waterlevel,maxwater))
	pestlevel =		max(0,min(pestlevel,10))
	weedlevel =		max(0,min(weedlevel,10))
	toxins =		max(0,min(toxins,10))
	yield_mod =		min(100, yield_mod)

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()

	var/previous_plant = seed.display_name
	var/newseed = seed.get_mutant_variant()
	if(newseed in plant_controller.seeds)
		seed = plant_controller.seeds[newseed]
	else
		return

	dead = 0
	//mutate(1)
	age = 0
	health = seed.get_trait(TRAIT_ENDURANCE)
	lastcycle = world.time
	lastproduce = 0
	harvest = 0
	weedlevel = 0

	update_icon()
	visible_message("\red The \blue [previous_plant] \red has suddenly mutated into \blue [seed.display_name]!")

	return


/obj/machinery/portable_atmospherics/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(exchange_parts(user, O))
		return

	if(istype(O, /obj/item/weapon/crowbar))
		if(anchored==2)
			to_chat(user, "Unscrew the hoses first!")
			return
		default_deconstruction_crowbar(O, 1)

	//--FalseIncarnate
	//Check if held item is an open container
	if (O.is_open_container())
		//Check if container is of the "glass" subtype (includes buckets, beakers, vials)
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			var/obj/item/weapon/reagent_containers/glass/C = O
			//Check if container is empty
			if(!C.reagents.total_volume)
				to_chat(user, "\red [C] is empty.")
				return
			//Container not empty, transfer contents to tray
			var/trans = C.reagents.trans_to(src, C.amount_per_transfer_from_this)
			to_chat(user, "\blue You transfer [trans] units of the solution to [src].")

			check_level_sanity()
			process_reagents()
			update_icon()

		//Check if container is one of the plantsprays (defined in tray_reagents.dm)
		else if(istype(O, /obj/item/weapon/plantspray))
			var/obj/item/weapon/plantspray/P = O
			user.drop_item(O)
			toxins += P.toxicity
			pestlevel -= P.pest_kill_str
			weedlevel -= P.weed_kill_str
			to_chat(user, "You spray [src] with [O].")
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			qdel(O)

			check_level_sanity()
			update_icon()

		//Check if spray is weedkiller (defined in tray_reagents.dm, un-obtainable currently)
		else if(istype(O, /obj/item/weedkiller))
			var/obj/item/weedkiller/W = O
			user.drop_item(O)
			toxins += W.toxicity
			weedlevel -= W.weed_kill_str
			to_chat(user, "You spray [src] with [O].")
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			qdel(O)

			check_level_sanity()
			update_icon()

		//Check if container is any spray container
		else if (istype(O, /obj/item/weapon/reagent_containers/spray))
			var/obj/item/weapon/reagent_containers/spray/S = O
			//Check if there is a plant in the tray
			if(seed)
				if(!S.reagents.total_volume)
					to_chat(user, "\red [S] is empty.")
					return
				//Container not empty, transfer contents to tray
				S.reagents.trans_to(src, S.amount_per_transfer_from_this)
				visible_message("\red <B>\The [src] has been sprayed with \the [O][(user ? " by [user]." : ".")]")
				playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
				check_level_sanity()
				update_icon()
			else
				to_chat(user, "There's nothing in [src] to spray!")

		else if(istype(O, /obj/item/weapon/screwdriver) && unwrenchable) //THIS NEED TO BE DONE DIFFERENTLY, SOMEONE REFACTOR THE TRAY CODE ALREADY
			if(anchored)
				if(anchored == 2)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					anchored = 1
					to_chat(user, "You unscrew the [src]'s hoses.")
					panel_open = 0

				else if(anchored == 1)
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
					anchored = 2
					to_chat(user, "You screw in the [src]'s hoses.")
					panel_open = 1

				for(var/obj/machinery/portable_atmospherics/hydroponics/h in range(1,src))
					spawn()
						h.update_icon()

	if(istype(O, /obj/item/weapon/wirecutters) || istype(O, /obj/item/weapon/scalpel))

		if(!seed)
			to_chat(user, "There is nothing to take a sample from in \the [src].")
			return

		if(sampled)
			to_chat(user, "You have already sampled from this plant.")
			return

		if(dead)
			to_chat(user, "The plant is dead.")
			return

		// Create a sample.
		seed.harvest(user,yield_mod,1)
		health -= (rand(3,5)*10)

		if(prob(30))
			sampled = 1

		// Bookkeeping.
		check_health()
		force_update = 1
		process()

		return

	else if(istype(O, /obj/item/weapon/reagent_containers/syringe))

		var/obj/item/weapon/reagent_containers/syringe/S = O

		if (S.mode == 1)
			if(seed)
				return ..()
			else
				to_chat(user, "There's no plant to inject.")
				return 1
		else
			if(seed)
				//Leaving this in in case we want to extract from plants later.
				to_chat(user, "You can't get any extract out of this plant.")
			else
				to_chat(user, "There's nothing to draw something from.")
			return 1

	else if (istype(O, /obj/item/seeds))

		if(!seed)

			var/obj/item/seeds/S = O
			user.drop_item(O)

			if(!S.seed)
				to_chat(user, "The packet seems to be empty. You throw it away.")
				qdel(O)
				return

			to_chat(user, "You plant the [S.seed.seed_name] [S.seed.seed_noun].")
			seed = S.seed //Grab the seed datum.
			dead = 0
			age = 1
			lastproduce = 0
			//Snowflakey, maybe move this to the seed datum
			health = (istype(S, /obj/item/seeds/cutting) ? round(seed.get_trait(TRAIT_ENDURANCE)/rand(2,5)) : seed.get_trait(TRAIT_ENDURANCE))
			lastcycle = world.time

			qdel(O)

			check_health()

		else
			to_chat(user, "<span class='danger'>\The [src] already has seeds in it!</span>")

	else if (istype(O, /obj/item/weapon/minihoe))  // The minihoe

		if(weedlevel > 0)
			user.visible_message("<span class='danger'>[user] starts uprooting the weeds.</span>", "<span class='danger'>You remove the weeds from the [src].</span>")
			weedlevel = 0
			update_icon()
		else
			to_chat(user, "<span class='danger'>This plot is completely devoid of weeds. It doesn't need uprooting.</span>")

	else if (istype(O, /obj/item/weapon/storage/bag/plants))

		attack_hand(user)

		var/obj/item/weapon/storage/bag/plants/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)

	else if(mechanical && istype(O, /obj/item/weapon/wrench))

		//If there's a connector here, the portable_atmospherics setup can handle it.
		if(locate(/obj/machinery/atmospherics/unary/portables_connector) in loc)
			return ..()

		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		to_chat(user, "You [anchored ? "wrench" : "unwrench"] \the [src].")

	else if ((istype(O, /obj/item/weapon/tank) && !( src.destroyed )))
		if (src.holding)
			to_chat(user, "\blue There is alreadu a tank loaded into the [src].")
			return
		var/obj/item/weapon/tank/T = O
		user.drop_item()
		T.loc = src
		src.holding = T
		update_icon()
		return
	else if(O && O.force && seed)
		user.visible_message("<span class='danger'>\The [seed.display_name] has been attacked by [user] with \the [O]!</span>")
		if(!dead)
			health -= O.force
			check_health()
	return

/obj/machinery/portable_atmospherics/hydroponics/attack_tk(mob/user as mob)
	if(dead)
		remove_dead(user)
	else if(harvest)
		harvest(user)

/obj/machinery/portable_atmospherics/hydroponics/attack_hand(mob/user as mob)

	if(istype(usr,/mob/living/silicon))
		return

	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

/obj/machinery/portable_atmospherics/hydroponics/examine(mob/user)
	..(user)

	if(!seed)
		to_chat(user, "[src] is empty.")
		return

	to_chat(user, "<span class='notice'>[seed.display_name]</span> are growing here.</span>")

	if(!Adjacent(user))
		return

	to_chat(user, "Water: [round(waterlevel,0.1)]/[maxwater]")
	to_chat(user, "Nutrient: [round(nutrilevel,0.1)]/[maxnutri]")

	if(weedlevel >= 5)
		to_chat(user, "\The [src] is <span class='danger'>infested with weeds</span>!")
	if(pestlevel >= 5)
		to_chat(user, "\The [src] is <span class='danger'>infested with tiny worms</span>!")

	if(dead)
		to_chat(user, "<span class='danger'>The plant is dead.</span>")
	else if(health <= (seed.get_trait(TRAIT_ENDURANCE)/ 2))
		to_chat(user, "The plant looks <span class='danger'>unhealthy</span>.")

	if(mechanical)
		var/turf/T = loc
		var/datum/gas_mixture/environment

		if(closed_system && (connected_port || holding))
			environment = air_contents

		if(!environment)
			if(istype(T))
				environment = T.return_air()

		if(!environment) //We're in a crate or nullspace, bail out.
			return

		var/light_string
		if(closed_system && mechanical)
			light_string = "that the internal lights are set to [tray_light] lumens"
		else
			var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
			var/light_available
			if(L)
				light_available = L.get_clamped_lum()*10
			else
				light_available =  5
			light_string = "a light level of [light_available] lumens"

		to_chat(user, "The tray's sensor suite is reporting [light_string] and a temperature of [environment.temperature]K.")

/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid_verb()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)
	close_lid(usr)

/obj/machinery/portable_atmospherics/hydroponics/proc/close_lid(var/mob/living/user)
	if(!user || user.stat || user.restrained())
		return

	closed_system = !closed_system
	to_chat(user, "You [closed_system ? "close" : "open"] the tray's lid.")
	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/verb/eject_tank_verb()
	set name = "Eject Internal Tank"
	set category = "Object"
	set src in view(1)
	eject_tank(usr)

/obj/machinery/portable_atmospherics/hydroponics/proc/eject_tank(var/mob/living/user)
	if(!user || user.stat || user.restrained())
		return

	if(!holding)
		to_chat(usr, "\red There is no tank loaded into [src] to eject.")

	if(istype(holding, /obj/item/weapon/tank))
		to_chat(usr, "\blue You eject [holding.name] from [src].")
		holding.loc = loc
		holding = null
