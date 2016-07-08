
//////////////////////////////
//		Fish Tanks!			//
//////////////////////////////


/obj/machinery/fishtank
	name = "placeholder tank"
	desc = "So generic, it might as well have no description at all."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = 0
	anchored = 0
	throwpass = 0

	var/tank_type = ""			// Type of aquarium, used for icon updating
	var/water_capacity = 0		// Number of units the tank holds (varies with tank type)
	var/water_level = 0			// Number of units currently in the tank (new tanks start empty)
	var/light_switch = 0		// 0 = off, 1 = on (off by default)
	var/filth_level = 0.0		// How dirty the tank is (max 10)
	var/lid_switch = 0			// 0 = open, 1 = closed (open by default)
	var/max_fish = 0			// How many fish the tank can support (varies with tank type, 1 fish per 50 units sounds reasonable)
	var/food_level = 0			// Amount of fishfood floating in the tank (max 10)
	var/fish_count = 0			// Number of fish in the tank
	var/list/fish_list = null	// Tracks the current types of fish in the tank
	var/egg_count = 0			// How many fish eggs can be harvested from the tank (capped at the max_fish value)
	var/list/egg_list = null	// Tracks the current types of harvestable eggs in the tank

	var/has_lid = 0				// 0 if the tank doesn't have a lid/light, 1 if it does
	var/max_health = 0			// Can handle a couple hits
	var/cur_health = 0			// Current health, starts at max_health
	var/leaking = 0				// 0 if not leaking, 1 if minor leak, 2 if major leak (not leaking by default)
	var/shard_count = 0			// Number of glass shards to salvage when broken (1 less than the number of sheets to build the tank)

/obj/machinery/fishtank/bowl
	name = "fish bowl"
	desc = "A small bowl capable of housing a single fish, commonly found on desks. This one has a tiny treasure chest in it!"
	icon_state = "bowl1"
	density = 0					// Small enough to not block stuff
	anchored = 0				// Small enough to move even when filled
	throwpass = 1				// Just like at the county fair, you can't seem to throw the ball in to win the goldfish
	pass_flags = PASSTABLE		// Small enough to pull onto a table

	tank_type = "bowl"
	water_capacity = 50			// Not very big, therefore it can't hold much
	max_fish = 1				// What a lonely fish

	has_lid = 0
	max_health = 15				// Not very sturdy
	cur_health = 15
	shard_count = 0				// No salvageable shards

/obj/machinery/fishtank/tank
	name = "fish tank"
	desc = "A large glass tank designed to house aquatic creatures. Contains an integrated water circulation system."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = 1
	anchored = 1
	throwpass = 1				// You can throw objects over this, despite it's density, because it's short enough.

	tank_type = "tank"
	water_capacity = 200		// Decent sized, holds almost 2 full buckets
	max_fish = 4				// Room for a few fish

	has_lid = 1
	max_health = 50				// Average strength, will take a couple hits from a toolbox.
	cur_health = 50
	shard_count = 2


/obj/machinery/fishtank/wall
	name = "wall aquarium"
	desc = "This aquarium is massive! It completely occupies the same space as a wall, and looks very sturdy too!"
	icon_state = "wall1"
	density = 1
	anchored = 1
	throwpass = 0				// This thing is the size of a wall, you can't throw past it.

	tank_type = "wall"
	water_capacity = 500		// This thing fills an entire tile, it holds a lot.
	max_fish = 10				// Plenty of room for a lot of fish

	has_lid = 1
	max_health = 100			// This thing is a freaking wall, it can handle abuse.
	cur_health = 100
	shard_count = 3


//////////////////////////////
//		VERBS & PROCS		//
//////////////////////////////

/obj/machinery/fishtank/verb/toggle_lid_verb()
	set name = "Toggle Tank Lid"
	set category = "Object"
	set src in view(1)
	toggle_lid(usr)

/obj/machinery/fishtank/proc/toggle_lid(var/mob/living/user)
	lid_switch = !lid_switch
	update_icon()

/obj/machinery/fishtank/verb/toggle_light_verb()
	set name = "Toggle Tank Light"
	set category = "Object"
	set src in view(1)
	toggle_light(usr)

/obj/machinery/fishtank/proc/toggle_light(var/mob/living/user)
	light_switch = !light_switch
	if(light_switch)
		set_light(2,2,"#a0a080")
	else
		set_light(0)

//////////////////////////////
//		NEW() PROCS			//
//////////////////////////////

/obj/machinery/fishtank/New()
	..()
	fish_list = new/list()
	egg_list = new/list()
	if(!has_lid)				//Tank doesn't have a lid/light, remove the verbs for then
		verbs -= /obj/machinery/fishtank/verb/toggle_lid_verb
		verbs -= /obj/machinery/fishtank/verb/toggle_light_verb

/obj/machinery/fishtank/tank/New()
	..()
	if(prob(5))					//5% chance to get the castle decoration
		icon_state = "tank2"

//////////////////////////////
//		ICON PROCS			//
//////////////////////////////

/obj/machinery/fishtank/update_icon()
	overlays.Cut()

	//Update Alert Lights
	if(has_lid)											//Skip the alert lights for aquariums that don't have lids (fishbowls)
		if(egg_count > 0)								//There is at least 1 egg to harvest
			overlays += "over_egg"
		if(lid_switch == 1)								//Lid is closed, lid status light is red
			overlays += "over_lid_1"
		else											//Lid is open, lid status light is green
			overlays += "over_lid_0"
		if(food_level > 5)								//Food_level is high and isn't a concern yet
			overlays += "over_food_0"
		else if(food_level > 2)							//Food_level is starting to get low, but still above the breeding threshold
			overlays += "over_food_1"
		else											//Food_level is below breeding threshold, or fully consumed, feed the fish!
			overlays += "over_food_2"
		overlays += "over_leak_[leaking]"				//Green if we aren't leaking, light blue and slow blink if minor link, dark blue and rapid flashing for major leak

	//Update water overlay
	if(water_level == 0) return							//Skip the rest of this if there is no water in the aquarium
	var/water_type = "_clean"							//Default to clean water
	if(filth_level > 5)	water_type = "_dirty"			//Show dirty water above filth_level 5 (breeding threshold)
	if(water_level > (water_capacity * 0.85))			//Show full if the water_level is over 85% of water_capacity
		overlays += "over_[tank_type]_full[water_type]"
	else if(water_level > (water_capacity * 0.35))		//Show half-full if the water_level is over 35% of water_capacity
		overlays += "over_[tank_type]_half[water_type]"

	return

//////////////////////////////
//		PROCESS PROC		//
//////////////////////////////

//Stops atmos from passing wall tanks, since they are effectively full-windows.
/obj/machinery/fishtank/wall/CanAtmosPass(var/turf/T)
	return 0

/obj/machinery/fishtank/process()
	//Start by counting fish in the tank
	fish_count = 0
	for(var/fish in fish_list)
		if(fish)
			fish_count++

	//Check if the water level can support the current number of fish
	if((fish_count * 50) > water_level)
		if(prob(50))								//Not enough water for all the fish, chance to kill one
			kill_fish()								//Chance passed, kill a random fish
			filth_level += 2						//Dead fish raise the filth level quite a bit, reflect this

	//Check filth_level
	check_filth_level()
	if(filth_level == 10 && fish_count > 0)			//This tank is nasty and possibly unsuitable for fish if any are in it
		if(prob(30))								//Chance for a fish to die each cycle while the tank is this nasty
			kill_fish()								//Kill a random fish, don't raise filth level since we're at cap already

	//Check breeding conditions
	if(fish_count >=2 && egg_count < max_fish)		//Need at least 2 fish to breed, but won't breed if there are as many eggs as max_fish
		if(food_level > 2 && filth_level <=5)		//Breeding is going to use extra food, and the filth_level shouldn't be too high
			if(prob(((fish_count - 2) * 5)+10))		//Chances increase with each additional fish, 10% base + 5% per additional fish
				egg_count++						//A new set of eggs were laid, increase egg_count
				egg_list.Add(select_egg_type())		//Add the new egg to the egg_list for storage
				food_level -= 2						//Remove extra food for the breeding process

	//Handle standard food and filth adjustments
	check_food_level()
	var/ate_food = 0
	if(food_level > 0 && prob(50))					//Chance for the fish to eat some food
		if(food_level >= (fish_count * 0.1))		//If there is at least enough food to go around, feed all the fish
			food_level -= fish_count * 0.1
		else										//Use up the last of the food
			food_level = 0
		ate_food = 1
	check_food_level()

	if(water_level > 0)								//Don't dirty the tank if it has no water
		if(fish_count == 0)							//If the tank has no fish, algae growth can occur
			if(filth_level < 7.5 && prob(15))		//Algae growth is a low chance and cannot exceed filth_level of 7.5
				filth_level += 0.05					//Algae growth is slower than fish filth build-up
		else if(filth_level < 10 && prob(10))		//Chance for the tank to get dirtier if the filth_level isn't 10
			if(ate_food && prob(25))				//If they ate this cycle, there is an additional chance they make a bigger mess
				filth_level += fish_count * 0.1
			else									//If they didn't make the big mess, make a little one
				filth_level += 0.1
	check_filth_level()

	//Handle special interactions
	handle_special_interactions()

	//Handle water leakage from damage
	if(water_level > 0)								//Can't leak water if there is no water in the tank
		if(leaking == 2)							//At or below 25% health, the tank will lose 10 water_level per cycle (major leak)
			water_level -= 10
		else if(leaking == 1)						//At or below 50% health, the tank will lose 1 water_level per cycle (minor leak)
			water_level -= 1
	check_water_level()

//////////////////////////////
//		SUPPORT PROCS		//
//////////////////////////////

/obj/machinery/fishtank/proc/handle_special_interactions()
	var/glo_light = 0
	for(var/fish in fish_list)
		switch(fish)
			if("catfish")							//Catfish have a small chance of cleaning some filth since they are a bottom-feeder
				if((filth_level > 0) && prob(30))
					filth_level -= 0.1
			if("feederfish")						//Feeder fish have a small chance of sacrificing themselves to produce some food
				if(fish_count < 2)					//Don't sacrifice the last fish, there's nothing to eat it
					continue
				if(food_level <= 5 && prob(25))
					kill_fish("feederfish")			//Kill the fish to reflect it's sacrifice, but don't increase the filth_level
					food_level += 1					//The corpse became food for the other fish, ecology at it's finest
			if("glofish")
				glo_light++
	if(!light_switch && (glo_light > 0))
		set_light(2,glo_light,"#99FF66")
	check_food_level()
	check_filth_level()
	check_water_level()

/obj/machinery/fishtank/proc/check_water_level()
	if(water_level < 0)								//Water_level cannot be negative, set it to 0 if it is
		water_level = 0
	if(water_level > water_capacity)				//Water_level cannot exceed capacity, set it to capacity if it does
		water_level = water_capacity
	update_icon()

/obj/machinery/fishtank/proc/check_filth_level()
	if(filth_level < 0)								//Filth_level cannot be negative, set it to 0 if it is
		filth_level = 0
	if(filth_level > 10)							//Filth_level cannot exceed 10 (cap), set it to 10 if it does
		filth_level = 10

/obj/machinery/fishtank/proc/check_food_level()
	if(food_level < 0)								//Food_level cannot be negative, set it to 0 if it is
		food_level = 0
	if(food_level > 10)								//Food_level cannot exceed 10 (cap), set it to 10 if it does
		food_level = 10

/obj/machinery/fishtank/proc/check_health()
	//Max value check
	if(cur_health > max_health)						//Cur_health cannot exceed max_health, set it to max_health if it does
		cur_health = max_health
	//Leaking status check
	if(cur_health <= (max_health * 0.25))			//Major leak at or below 25% health (-10 water/cycle)
		leaking = 2
	else if(cur_health <= (max_health * 0.5))		//Minor leak at or below 50% health (-1 water/cycle)
		leaking = 1
	else											//Not leaking above 50% health
		leaking = 0
	//Destruction check
	if(cur_health <= 0)								//The tank is broken, destroy it
		destroy()

/obj/machinery/fishtank/proc/kill_fish(var/type = null)
	//Check if we were passed a fish to kill, otherwise kill a random one
	if(type)
		fish_list.Remove(type)						//Kill a fish of the specified type
		fish_count --								//Lower fish_count to reflect the death of a fish, so the everything else works fine
	else
		fish_list.Remove(pick(fish_list))			//Kill a random fish
		fish_count --								//Lower fish_count to reflect the death of a fish, so the everything else works fine

/obj/machinery/fishtank/proc/add_fish(var/type = null)
	//Check if we were passed a fish type
	if(type)
		fish_list.Add("[type]")						//Add a fish of the specified type
		fish_count++								//Increase fish_count to reflect the introduction of a fish, so the everything else works fine
		//Announce the new fish
		src.visible_message("A new [type] has hatched in \the [src]!")
	//Null type fish are dud eggs, give a message to inform the player
	else
		to_chat(usr, "The eggs disolve in the water. They were duds!")

/obj/machinery/fishtank/proc/select_egg_type()
	var/fish = pick(fish_list)						//Select a fish from the fish in the tank
	if(prob(25))									//25% chance to be a dud (blank) egg
		fish = "dud"
	var/obj/item/fish_eggs/egg_path	= null			//Create empty variable to receive the egg_path
	egg_path = fish_eggs_list[fish]					//Locate the corresponding path from fish_eggs_list that matches the fish
	if(!egg_path)									//The fish wasn't located in the fish_eggs_list, potentially due to a typo, so return a dud egg
		return /obj/item/fish_eggs
	else											//The fish was located in the fish_eggs_list, so return the proper egg
		return egg_path

/obj/machinery/fishtank/proc/harvest_eggs(var/mob/user)
	if(!egg_count)									//Can't harvest non-existant eggs
		return

	if(egg_count > max_fish)						//Make sure the number of eggs doesn't exceed the max_fish for the tank
		egg_count = max_fish						//If you somehow exceeded the cap, set the egg_count to max, destroy the excess later

	while(egg_count > 0)							//Loop until you've harvested all the eggs
		var/obj/item/fish_eggs/egg = pick(egg_list)	//Select an egg at random
		egg = new egg(get_turf(user))				//Spawn the egg at the user's feet
		egg_list.Remove(egg)						//Remove the egg from the egg_list
		egg_count --								//Decrease the egg_count and begin again

	egg_list.Cut()									//Destroy any excess eggs, clearing the egg_list

/obj/machinery/fishtank/proc/harvest_fish(var/mob/user)
	if(!fish_count)									//Can't catch non-existant fish!
		to_chat(usr, "There are no fish in \the [src] to catch!")
		return

	var/caught_fish
	caught_fish = input("Select a fish to catch.", "Fishing", caught_fish) in fish_list		//Select a fish from the tank
	if(caught_fish)
		var/dead_fish = null
		dead_fish = fish_items_list[caught_fish]	//Locate the appropriate fish_item for the caught fish
		if(!dead_fish)								//No fish_item found, possibly due to typo or not being listed. Do nothing.
			return
		kill_fish(caught_fish)						//Kill the caught fish from the tank
		user.visible_message("[user.name] harvests \a [caught_fish] from \the [src].", "You scoop \a [caught_fish] out of \the [src].")
		new dead_fish(get_turf(user))				//Spawn the appropriate fish_item at the user's feet.

/obj/machinery/fishtank/proc/destroy(var/deconstruct = 0)
	var/turf/T = get_turf(src)										//Store the tank's turf for atmos updating after deletion of tank
	if(!deconstruct)												//Check if we are deconstructing or breaking the tank
		var/shards_left = shard_count
		while(shards_left > 0)										//Produce the appropriate number of glass shards
			new /obj/item/weapon/shard(get_turf(src))
			shards_left --
		if(water_level)												//Spill any water that was left in the tank when it broke
			spill_water()
	else															//We are deconstructing, make glass sheets instead of shards
		var/sheets = shard_count + 1								//Deconstructing it salvages all the glass used to build the tank
		new /obj/item/stack/sheet/glass(get_turf(src), sheets)		//Produce the appropriate number of glass sheets, in a single stack
	qdel(src)														//qdel the tank and it's contents
	T.air_update_turf(1)											//Update the air for the turf, to avoid permanent atmos sealing with wall tanks

/obj/machinery/fishtank/proc/spill_water()
	switch(tank_type)
		if("bowl")										//Fishbowl: Wets it's own tile
			var/turf/T = get_turf(src)
			if(!istype(T, /turf/simulated)) return
			var/turf/simulated/S = T
			S.MakeSlippery()
		if("tank")										//Fishtank: Wets it's own tile and the 4 adjacent tiles (cardinal directions)
			var/turf/ST = get_turf(src)
			if(istype(ST, /turf/simulated))
				var/turf/simulated/ST2 = ST
				ST2.MakeSlippery()
			var/list/L = ST.CardinalTurfs()
			for(var/turf/T in L)
				if(!istype(T, /turf/simulated)) continue
				var/turf/simulated/S = T
				S.MakeSlippery()
		if("wall")										//Wall-tank: Wets it's own tile and the surrounding 8 tiles (3x3 square)
			for(var/turf/T in spiral_range_turfs(1, src.loc))
				if(!istype(T, /turf/simulated)) continue
				var/turf/simulated/S = T
				S.MakeSlippery()

//////////////////////////////		Note from FalseIncarnate:
//		EXAMINE PROC		//			This proc is massive, messy, and probably could be handled better.
//////////////////////////////			Feel free to try cleaning it up if you think of a better way to do it.

/obj/machinery/fishtank/examine(mob/user)
	..(user)
	var/examine_message = ""
	//Approximate water level

	examine_message += "Water level: "

	if(water_level == 0)
		examine_message += "\The [src] is empty! "
	else if(water_level < water_capacity * 0.1)
		examine_message += "\The [src] is nearly empty! "
	else if(water_level <= water_capacity * 0.25)
		examine_message += "\The [src] is about one-quarter filled. "
	else if(water_level <= water_capacity * 0.5)
		examine_message += "\The [src] is about half filled. "
	else if(water_level <= water_capacity * 0.75)
		examine_message += "\The [src] is about three-quarters filled. "
	else if(water_level < water_capacity)
		examine_message += "\The [src] is nearly full! "
	else if(water_level == water_capacity)
		examine_message += "\The [src] is full! "

	examine_message += "<br>Cleanliness level: "

	//Approximate filth level
	if(filth_level == 0)
		examine_message += "[src] is spotless! "
	else if(filth_level <= 2.5)
		examine_message += "[src] looks like the glass has been smudged. "
	else if(filth_level <= 5)					//This is the breeding threshold
		examine_message += "[src] has some algae growth in it. "
	else if(filth_level <= 7.5)
		examine_message += "[src] has a lot of algae growth in it. "
	else if(filth_level < 10)
		examine_message += "[src] is getting hard to see into! Someone should clean it soon! "
	else if(filth_level == 10)
		examine_message += "[src] is absolutely disgusting! Someone should clean it NOW! "

	examine_message += "<br>Food level: "

	//Approximate food level
	if(!fish_count)								//Check if there are fish in the tank
		if(food_level > 0)						//Don't report a tank that has neither fish nor food in it
			examine_message += "There's some food in [src], but no fish! "
	else										//We've got fish, report the food level
		if(food_level == 0)
			examine_message += "The fish look very hungry! "
		else if(food_level < 2)
			examine_message += "The fish are nibbling on the last of their food. "
		else if(food_level < 10)				//Breeding is possible
			examine_message += "The fish seem happy! "
		else if(food_level == 10)
			examine_message += "There is a solid layer of fish food at the top. "

	//Report the number of harvestable eggs
	if(egg_count)								//Don't bother if there isn't any eggs
		examine_message += "<br>There are [egg_count] eggs able to be harvested! "

	examine_message += "<br>"

	//Report the number and types of live fish if there is water in the tank
	if(fish_count == 0)
		examine_message += "\The [src] doesn't contain any live fish. "
	else
		//Build a message reporting the types of fish
		var/fish_num = fish_count
		var/message = "You spot "
		while(fish_num > 0)
			if(fish_count > 1 && fish_num == 1)	//If there were at least 2 fish, and this is the last one, add "and" to the message
				message += "and "
			message += "a [fish_list[fish_num]]"
			fish_num --
			if(fish_num > 0)					//There's more fish, add a comma to the message
				message +=", "
		message +="."							//No more fish, end the message with a period
		//Display the number of fish and previously constructed message
		examine_message += "\The [src] contains [fish_count] live fish. [message] "

	examine_message += "<br>"

	//Report lid state for tanks and wall-tanks
	if(has_lid)									//Only report if the tank actually has a lid
		//Report lid state
		if(lid_switch)
			examine_message += "The lid is closed. "
		else
			examine_message += "The lid is open. "

	examine_message += "<br>"

	//Report if the tank is leaking/cracked
	if(water_level > 0)							//Tank has water, so it's actually leaking
		if(leaking == 1) examine_message += "\The [src] is leaking."
		if(leaking == 2) examine_message += "\The [src] is leaking profusely!"
	else										//No water, report the cracks instead
		if(leaking == 1) examine_message += "\The [src] is cracked."
		if(leaking == 2) examine_message += "\The [src] is nearly shattered!"


	//Finally, report the full examine_message constructed from the above reports
	to_chat(user, "[examine_message]")
	return examine_message

//////////////////////////////
//		ATACK PROCS			//
//////////////////////////////

/obj/machinery/fishtank/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/pet/cat))
		if(M.a_intent == I_HELP)							//Cats can try to fish in open tanks on help intent
			if(lid_switch)									//Can't fish in a closed tank. Fishbowls are ALWAYS open.
				M.visible_message("[M.name] stares at into \the [src] while sitting perfectly still.", "The lid is closed, so you stare into \the [src] intently.")
			else
				if(fish_count)								//Tank must actually have fish to try catching one
					M.visible_message("[M.name] leaps up onto  \the[src] and attempts to fish through the opening!", "You jump up onto \the [src] and begin fishing through the opening!")
					spawn(10)
						if(water_level && prob(45))			//If there is water, there is a chance the cat will slip, Syndicat will spark like E-N when this happens
							M.visible_message("[M.name] slipped and got soaked!", "You slipped and got soaked!")
							if(istype(M, /mob/living/simple_animal/pet/cat/Syndi))
								var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
								s.set_up(3, 1, src)
								s.start()
						else								//No water or didn't slip, get that fish!
							M.visible_message("[M.name] catches and devours a live fish!", "You catch and devour a live fish, yum!")
							kill_fish()						//Kill a random fish
							M.health = M.maxHealth			//Eating fish heals the predator
				else
					to_chat(usr, "There are no fish in [src]!")
		else
			attack_generic(M, M.harm_intent_damage)
	else if(istype(M, /mob/living/simple_animal/hostile/bear))
		if(M.a_intent == I_HELP)							//Bears can try to fish in open tanks on help intent
			if(lid_switch)									//Can't fish in a closed tank. Fishbowls are ALWAYS open.
				M.visible_message("[M.name] scrapes it's claws along \the [src]'s lid.", "The lid is closed, so you scrape your claws against \the [src]'s lid.")
			else
				if(fish_count)								//Tank must actually have fish to try catching one
					M.visible_message("[M.name] reaches into  \the[src] and attempts to fish through the opening!", "You reach into \the [src] and begin fishing through the opening!")
					spawn(5)
						if(water_level && prob(5))			//Bears are good at catching fish, only a 5% chance to fail
							M.visible_message("[M.name] swipes at the water!", "You just barely missed that fish!")
						else								//No water or didn't slip, get that fish!
							M.visible_message("[M.name] catches and devours a live fish!", "You catch and devour a live fish, yum!")
							kill_fish()						//Kill a random fish
							M.health = M.maxHealth			//Eating fish heals the predator
				else
					to_chat(usr, "There are no fish in [src]!")
		else
			attack_generic(M, M.harm_intent_damage)
	else
		if(M.melee_damage_upper > 0)						//If the simple_animal has a melee_damage_upper defined, use that for the damage
			attack_generic(M, M.melee_damage_upper)
		else if(M.a_intent == I_HARM)						//Let any simple_animal try to break tanks when on harm intent
			if(M.harm_intent_damage <= 0) return			//If it doesn't do damage, don't bother with the attack
			attack_generic(M, M.harm_intent_damage)
	check_health()

/obj/machinery/fishtank/attack_alien(mob/living/user as mob)
	if(islarva(user)) return
	attack_generic(user, 15)

/obj/machinery/fishtank/attack_slime(mob/living/user as mob)
	var/mob/living/carbon/slime/S = user
	if(!S.is_adult)
		return
	attack_generic(user, rand(10, 15))

/obj/machinery/fishtank/attack_hand(mob/user as mob)
	if(HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes through [src]!</span>")
		destroy()
	else if(usr.a_intent == I_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 80, 1)
		usr.visible_message("<span class='danger'>[usr.name] bangs against the [src.name]!</span>", \
							"<span class='danger'>You bang against the [src.name]!</span>", \
							"You hear a banging sound.")
	else
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, 'sound/effects/glassknock.ogg', 80, 1)
		usr.visible_message("[usr.name] taps on the [src.name].", \
							"You tap on the [src.name].", \
							"You hear a knocking sound.")
	return

/obj/machinery/fishtank/proc/hit(var/damage, var/sound_effect = 1)
	cur_health = max(0, cur_health - damage)
	if(sound_effect)
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
	check_health()

/obj/machinery/fishtank/proc/attack_generic(mob/living/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	cur_health -= damage
	if(cur_health <= 0)
		user.visible_message("<span class='danger'>[user] smashes through \the [src]!</span>")
		destroy()
	else	//for nicer text~
		user.visible_message("<span class='danger'>[user] smashes into \the [src]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		check_health()

/obj/machinery/fishtank/attackby(var/obj/item/O, var/mob/user as mob)
	//Welders repair damaged tanks on help intent, damage on all others
	if(istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = O
		if(user.a_intent == I_HELP)
			if(W.isOn())
				if(cur_health < max_health)
					to_chat(usr, "You repair some of the cracks on \the [src].")
					cur_health += 20
					check_health()
				else
					to_chat(usr, "There is no damage to fix!")
			else
				if(cur_health < max_health)
					to_chat(usr, "[W.name] must on to repair this damage.")
		else
			user.changeNext_move(CLICK_CD_MELEE)
			hit(W.force)
		return
	//Open reagent containers add and remove water
	if(O.is_open_container())
		if(istype(O, /obj/item/weapon/reagent_containers/glass))
			if(lid_switch)
				to_chat(usr, "Open the lid on \the [src] first!")
				return
			var/obj/item/weapon/reagent_containers/glass/C = O
			//Containers with any reagents will get dumped in
			if(C.reagents.total_volume)
				var/water_value = 0
				water_value += C.reagents.get_reagent_amount("water")				//Water is full value
				water_value += C.reagents.get_reagent_amount("holywater") *1.1		//Holywater is (somehow) better. Who said religion had to make sense?
				water_value += C.reagents.get_reagent_amount("tonic") * 0.25		//Tonic water is 25% value
				water_value += C.reagents.get_reagent_amount("sodawater") * 0.50	//Sodawater is 50% value
				water_value += C.reagents.get_reagent_amount("fishwater") * 0.75	//Fishwater is 75% value, to account for the fish poo
				water_value += C.reagents.get_reagent_amount("ice") * 0.80			//Ice is 80% value
				var/message = ""
				if(!water_value)													//The container has no water value, clear everything in it
					message = "The filtration process removes everything, leaving the water level unchanged."
					C.reagents.clear_reagents()
				else
					if(water_level == water_capacity)
						to_chat(usr, "[src] is already full!")
						return
					else
						message = "The filtration process purifies the water, raising the water level."
						water_level += water_value
						if(water_level == water_capacity)
							message += " You filled \the [src] to the brim!"
						if(water_level > water_capacity)
							message += " You overfilled \the [src] and some water runs down the side, wasted."
						C.reagents.clear_reagents()
				check_water_level()
				user.visible_message("[user.name] pours the contents of [C.name] into \the [src].", "[message]")
				return
			//Empty containers will scoop out water, filling the container as much as possible from the water_level
			else
				if(water_level == 0)
					to_chat(usr, "[src] is empty!")
				else
					if(water_level >= C.volume)										//Enough to fill the container completely
						C.reagents.add_reagent("fishwater", C.volume)
						water_level -= C.volume
						user.visible_message("[user.name] scoops out some water from \the [src].", "You completely fill [C.name] from \the [src].")
					else															//Fill the container as much as possible with the water_level
						C.reagents.add_reagent("fishwater", water_level)
						water_level = 0
						user.visible_message("[user.name] scoops out some water from \the [src].", "You fill [C.name] with the last of the water in \the [src].")
					check_water_level()
			return
	//Wrenches can deconstruct empty tanks, but not tanks with any water. Kills any fish left inside and destroys any unharvested eggs in the process
	if(istype(O, /obj/item/weapon/wrench))
		if(water_level == 0)
			to_chat(usr, "<span class='notice'>Now disassembling [src].</span>")
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if(do_after(user,50, target = src))
				destroy(1)
		else
			to_chat(usr, "[src] must be empty before you disassemble it!")
		return
	//Fish eggs
	else if(istype(O, /obj/item/fish_eggs))
		var/obj/item/fish_eggs/egg = O
		//Don't add eggs if there is no water (they kinda need that to live)
		if(water_level == 0)
			to_chat(usr, "[src] has no water; [egg.name] won't hatch without water!")
		else
			//Don't add eggs if the tank already has the max number of fish
			if(fish_count >= max_fish)
				to_chat(usr, "[src] can't hold any more fish.")
			else
				add_fish(egg.fish_type)
				qdel(egg)
		return
	//Fish food
	else if(istype(O, /obj/item/weapon/fishfood))
		//Only add food if there is water and it isn't already full of food
		if(water_level)
			if(food_level < 10)
				if(fish_count == 0)
					user.visible_message("[user.name] shakes some fish food into the empty [src]... How sad.", "You shake some fish food into the empty [src]... If only it had fish.")
				else
					user.visible_message("[user.name] feeds the fish in \the [src]. The fish look excited!", "You feed the fish in \the [src]. They look excited!")
				food_level += 10
			else
				to_chat(usr, "[src] already has plenty of food in it. You decide to not add more.")
		else
			to_chat(usr, "[src] doesn't have any water in it. You should fill it with water first.")
		check_food_level()
		return
	//Fish egg scoop
	else if(istype(O, /obj/item/weapon/egg_scoop))
		if(egg_count)
			user.visible_message("[user.name] harvests some fish eggs from \the [src].", "You scoop the fish eggs out of \the [src].")
			harvest_eggs(user)
		else
			user.visible_message("[user.name] fails to harvest any fish eggs from \the [src].", "There are no fish eggs in \the [src] to scoop out.")
		return
	//Fish net
	if(istype(O, /obj/item/weapon/fish_net))
		harvest_fish(user)
		return
	//Tank brush
	if(istype(O, /obj/item/weapon/tank_brush))
		if(filth_level == 0)
			to_chat(usr, "[src] is already spotless!")
		else
			filth_level = 0
			user.visible_message("[user.name] scrubs the inside of \the [src], cleaning the filth.", "You scrub the inside of \the [src], cleaning the filth.")
	else if(O && O.force)
		user.visible_message("<span class='danger'>\The [src] has been attacked by [user.name] with \the [O]!</span>")
		hit(O.force)
	return
