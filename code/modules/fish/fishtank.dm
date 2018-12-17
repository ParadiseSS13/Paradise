
//////////////////////////////
//		Fish Tanks			//
//////////////////////////////


/obj/machinery/fishtank
	name = "placeholder tank"
	desc = "So generic, it might as well have no description at all."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = FALSE
	anchored = FALSE
	pass_flags = 0

	var/tank_type = ""			// Type of aquarium, used for icon updating
	var/water_capacity = 0		// Number of units the tank holds (varies with tank type)
	var/water_level = 0			// Number of units currently in the tank (new tanks start empty)
	var/light_switch = 0		// 0 = off, 1 = on (off by default)
	var/filth_level = 0		// How dirty the tank is (max 10)
	var/lid_switch = 0			// 0 = open, 1 = closed (open by default)
	var/max_fish = 0			// How many fish the tank can support (varies with tank type, 1 fish per 50 units sounds reasonable)
	var/food_level = 0			// Amount of fishfood floating in the tank (max 10)
	var/fish_count = 0			// Number of fish in the tank
	var/list/fish_list = list()	// Tracks the current types of fish in the tank
	var/egg_count = 0			// How many fish eggs can be harvested from the tank (capped at the max_fish value)
	var/list/egg_list = list()	// Tracks the current types of harvestable eggs in the tank

	var/has_lid = FALSE			// 0 if the tank doesn't have a lid/light, 1 if it does
	var/leaking = FALSE			// 0 if not leaking, 1 if minor leak, 2 if major leak (not leaking by default)
	var/shard_count = 0			// Number of glass shards to salvage when broken (1 less than the number of sheets to build the tank)

/obj/machinery/fishtank/bowl
	name = "fish bowl"
	desc = "A small bowl capable of housing a single fish, commonly found on desks. This one has a tiny treasure chest in it!"
	icon_state = "bowl1"
	density = FALSE				// Small enough to not block stuff
	anchored = FALSE			// Small enough to move even when filled
	pass_flags = PASSTABLE | LETPASSTHROW // Just like at the county fair, you can't seem to throw the ball in to win the goldfish, and it's small enough to pull onto a table

	tank_type = "bowl"
	water_capacity = 50			// Not very big, therefore it can't hold much
	max_fish = 1				// What a lonely fish

	has_lid = FALSE
	max_integrity = 15				// Not very sturdy
	shard_count = 0				// No salvageable shards

/obj/machinery/fishtank/tank
	name = "fish tank"
	desc = "A large glass tank designed to house aquatic creatures. Contains an integrated water circulation system."
	icon = 'icons/obj/fish_items.dmi'
	icon_state = "tank1"
	density = TRUE
	anchored = TRUE
	pass_flags = LETPASSTHROW

	tank_type = "tank"
	water_capacity = 200		// Decent sized, holds almost 2 full buckets
	max_fish = 4				// Room for a few fish

	has_lid = TRUE
	max_integrity = 50				// Average strength, will take a couple hits from a toolbox.
	shard_count = 2


/obj/machinery/fishtank/wall
	name = "wall aquarium"
	desc = "This aquarium is massive! It completely occupies the same space as a wall, and looks very sturdy too!"
	icon_state = "wall1"
	density = TRUE
	anchored = TRUE
	pass_flags = 0				// This thing is the size of a wall, you can't throw past it.

	tank_type = "wall"
	water_capacity = 500		// This thing fills an entire tile, it holds a lot.
	max_fish = 10				// Plenty of room for a lot of fish

	has_lid = TRUE
	max_integrity = 100			// This thing is a freaking wall, it can handle abuse.
	shard_count = 3


//////////////////////////////
//		VERBS & PROCS		//
//////////////////////////////

/obj/machinery/fishtank/verb/toggle_lid_verb()
	set name = "Toggle Tank Lid"
	set category = "Object"
	set src in view(1)

	toggle_lid()

/obj/machinery/fishtank/proc/toggle_lid()
	lid_switch = !lid_switch
	update_icon()

/obj/machinery/fishtank/verb/toggle_light_verb()
	set name = "Toggle Tank Light"
	set category = "Object"
	set src in view(1)

	toggle_light()

/obj/machinery/fishtank/proc/toggle_light()
	light_switch = !light_switch
	if(light_switch)
		set_light(2, 2, "#a0a080")
	else
		adjust_tank_light()

//////////////////////////////
//		NEW() PROCS			//
//////////////////////////////

/obj/machinery/fishtank/New()
	..()
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
	if(!water_level)
		return							//Skip the rest of this if there is no water in the aquarium
	var/water_type = "_clean"							//Default to clean water
	if(filth_level > 5)	water_type = "_dirty"			//Show dirty water above filth_level 5 (breeding threshold)
	if(water_level > (water_capacity * 0.85))			//Show full if the water_level is over 85% of water_capacity
		overlays += "over_[tank_type]_full[water_type]"
	else if(water_level > (water_capacity * 0.35))		//Show half-full if the water_level is over 35% of water_capacity
		overlays += "over_[tank_type]_half[water_type]"

//////////////////////////////
//		PROCESS PROC		//
//////////////////////////////

//Stops atmos from passing wall tanks, since they are effectively full-windows.
/obj/machinery/fishtank/wall/CanAtmosPass(turf/T)
	return FALSE

/obj/machinery/fishtank/process()
	//Start by counting fish in the tank
	fish_count = 0
	var/ate_food = 0
	for(var/fish in fish_list)
		if(fish)
			fish_count++

	//Check if the water level can support the current number of fish
	if((fish_count * 50) > water_level)
		if(prob(50))								//Not enough water for all the fish, chance to kill one
			kill_fish()								//Chance passed, kill a random fish
			adjust_filth_level(2)					//Dead fish raise the filth level quite a bit, reflect this

	//Check filth_level
	if(filth_level == 10 && fish_count > 0)			//This tank is nasty and possibly unsuitable for fish if any are in it
		if(prob(30))								//Chance for a fish to die each cycle while the tank is this nasty
			kill_fish()								//Kill a random fish, don't raise filth level since we're at cap already

	//Check breeding conditions
	if(fish_count >=2 && egg_count < max_fish)		//Need at least 2 fish to breed, but won't breed if there are as many eggs as max_fish
		if(food_level >= 0.2 && filth_level <=5)	//Breeding is going to use extra food, and the filth_level shouldn't be too high
			if(prob(((fish_count - 2) * 5)+10))		//Chances increase with each additional fish, 10% base + 5% per additional fish
				breed_fish()
				adjust_food_level(-0.2)				//Remove extra food for the breeding process
				ate_food = 1

	//Handle standard food and filth adjustments
	if(food_level > 0 && prob(50))					//Chance for the fish to eat some food
		if(food_level >= (fish_count * 0.1))		//If there is at least enough food to go around, feed all the fish
			adjust_food_level(fish_count * -0.1)
		else										//Use up the last of the food
			adjust_food_level(-food_level)
		ate_food = 1

	if(water_level > 0)								//Don't dirty the tank if it has no water
		if(fish_count == 0)							//If the tank has no fish, algae growth can occur
			if(filth_level < 7.5 && prob(15))		//Algae growth is a low chance and cannot exceed filth_level of 7.5
				adjust_filth_level(0.05)			//Algae growth is slower than fish filth build-up
		else if(filth_level < 10 && prob(10))		//Chance for the tank to get dirtier if the filth_level isn't 10
			if(ate_food && prob(25))				//If they ate this cycle, there is an additional chance they make a bigger mess
				adjust_filth_level(fish_count * 0.1)
			else									//If they didn't make the big mess, make a little one
				adjust_filth_level(0.1)

	//Handle special interactions
	handle_special_interactions()

	//Handle water leakage from damage
	if(water_level > 0)								//Can't leak water if there is no water in the tank
		if(leaking == 2)							//At or below 25% health, the tank will lose 10 water_level per cycle (major leak)
			adjust_water_level(-10)
		else if(leaking == 1)						//At or below 50% health, the tank will lose 1 water_level per cycle (minor leak)
			adjust_water_level(-1)
	update_icon()

//////////////////////////////
//		SUPPORT PROCS		//
//////////////////////////////

/obj/machinery/fishtank/proc/handle_special_interactions()
	for(var/datum/fish/fish in fish_list)
		fish.special_interact(src)
	adjust_tank_light()

/obj/machinery/fishtank/proc/adjust_tank_light()
	if(!light_switch)								//tank light overrides fish lights
		var/glo_light = 0
		for(var/datum/fish/fish in fish_list)
			if(istype(fish, /datum/fish/glofish))
				glo_light ++
		if(glo_light)
			set_light(2, glo_light, "#99FF66")
		else
			set_light(0, 0)

/obj/machinery/fishtank/proc/adjust_water_level(amount = 0)
	water_level = min(water_capacity, max(0, water_level + amount))
	update_icon()

/obj/machinery/fishtank/proc/adjust_filth_level(amount = 0)
	filth_level = min(10, max(0, filth_level + amount))

/obj/machinery/fishtank/proc/adjust_food_level(amount = 0)
	food_level = min(10, max(0, food_level + amount))

/obj/machinery/fishtank/proc/check_health()
	//Leaking status check
	if(obj_integrity <= (max_integrity * 0.25))			//Major leak at or below 25% health (-10 water/cycle)
		leaking = 2
	else if(obj_integrity <= (max_integrity * 0.5))		//Minor leak at or below 50% health (-1 water/cycle)
		leaking = 1
	else											//Not leaking above 50% health
		leaking = 0

/obj/machinery/fishtank/proc/kill_fish(datum/fish/fish_type = null)
	//Check if we were passed a fish to kill, otherwise kill a random one
	if(!fish_type)
		fish_type = pick(fish_list)
	fish_list.Remove(fish_type)						//Kill a fish of the specified type
	fish_count --									//Lower fish_count to reflect the death of a fish, so the everything else works fine
	if(istype(fish_type, /datum/fish/glofish))
		adjust_tank_light()
	qdel(fish_type)

/obj/machinery/fishtank/proc/add_fish(datum/fish/fish_type = null)
	//Check if we were passed a fish type
	if(fish_type)
		fish_type = new fish_type
		fish_list.Add(fish_type)					//Add a fish of the specified type
		fish_count++								//Increase fish_count to reflect the introduction of a fish, so the everything else works fine
		//Announce the new fish
		visible_message("A new [fish_type.fish_name] has hatched in [src]!")
	//Null type fish are dud eggs, give a message to inform the player
	else
		to_chat(usr, "The eggs disolve in the water. They were duds!")

/obj/machinery/fishtank/proc/harvest_eggs(mob/user)
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

/obj/machinery/fishtank/proc/harvest_fish(mob/user)
	if(fish_count <= 0)									//Can't catch non-existant fish!
		to_chat(user, "There are no fish in [src] to catch!")
		return
	var/list/fish_names_list = list()
	for(var/datum/fish/fish_type in fish_list)
		fish_names_list += list("[fish_type.fish_name]" = fish_type)
	var/caught_fish = input("Select a fish to catch.", "Fishing") as null|anything in fish_names_list		//Select a fish from the tank
	if(fish_count <= 0)
		to_chat(user, "There are no fish in [src] to catch!")
		return
	else if(caught_fish)
		user.visible_message("[user.name] harvests \a [caught_fish] from [src].", "You scoop \a [caught_fish] out of [src].")
		var/datum/fish/fish_type = fish_names_list[caught_fish]
		var/fish_item = fish_type.fish_item
		if(fish_item)
			new fish_item(get_turf(user))			//Spawn the appropriate fish_item at the user's feet.
		kill_fish(fish_type)						//Kill the caught fish from the tank
													//Update the air for the turf, to avoid permanent atmos sealing with wall tanks
/obj/machinery/fishtank/proc/spill_water()
	var/turf/simulated/T = get_turf(src)
	switch(tank_type)
		if("bowl")										//Fishbowl: Wets it's own tile
			if(istype(T))
				T.MakeSlippery()
		if("tank")										//Fishtank: Wets it's own tile and the 4 adjacent tiles (cardinal directions)
			if(istype(T))
				T.MakeSlippery()
				for(var/turf/simulated/ST in T.CardinalTurfs())
					ST.MakeSlippery()
		if("wall")										//Wall-tank: Wets it's own tile and the surrounding 8 tiles (3x3 square)
			for(var/turf/simulated/ST in spiral_range_turfs(1, loc))
				ST.MakeSlippery()

/obj/machinery/fishtank/proc/breed_fish()
	var/list/breed_candidates = fish_list.Copy()
	var/datum/fish/parent1 = pick_n_take(breed_candidates)
	if(!parent1.crossbreeder)							//fish with crossbreed = 0 will only breed with their own species, and only leave duds if they can't breed
		var/match_found = 0
		for(var/datum/fish/possible in breed_candidates)
			if(parent1.type == possible.type)
				match_found = 1
				break
		if(match_found)
			egg_list.Add(parent1.egg_item)
		else
			egg_list.Add(/obj/item/fish_eggs)
	else
		var/datum/fish/parent2 = pick(breed_candidates)
		if(!parent2.crossbreeder)						//second fish refuses to crossbreed, spawn a dud
			egg_list.Add(/obj/item/fish_eggs)
		else if(parent1.type == parent2.type)						//both fish are the same type
			if(prob(90))									//90% chance to get that type of egg
				egg_list.Add(parent1.egg_item)
			else											//10% chance to get a dud
				egg_list.Add(/obj/item/fish_eggs)
		else											//different types of fish
			if(prob(30))									//30% chance to get dud
				egg_list.Add(/obj/item/fish_eggs)
			else
				if(prob(50))								//chance to get egg for either parent type (50/50 for either parent, 35% overall each)
					egg_list.Add(parent1.egg_item)
				else
					egg_list.Add(parent2.egg_item)
	egg_count++

//////////////////////////////		Note from FalseIncarnate:
//		EXAMINE PROC		//			This proc is massive, messy, and probably could be handled better.
//////////////////////////////			Feel free to try cleaning it up if you think of a better way to do it.

/obj/machinery/fishtank/examine(mob/user)
	..(user)
	var/examine_message = ""
	//Approximate water level

	examine_message += "Water level: "

	if(!water_level)
		examine_message += "[src] is empty! "
	else if(water_level < water_capacity * 0.1)
		examine_message += "[src] is nearly empty! "
	else if(water_level <= water_capacity * 0.25)
		examine_message += "[src] is about one-quarter filled. "
	else if(water_level <= water_capacity * 0.5)
		examine_message += "[src] is about half filled. "
	else if(water_level <= water_capacity * 0.75)
		examine_message += "[src] is about three-quarters filled. "
	else if(water_level < water_capacity)
		examine_message += "[src] is nearly full! "
	else if(water_level == water_capacity)
		examine_message += "[src] is full! "

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
		examine_message += "[src] doesn't contain any live fish. "
	else
		//Build a message reporting the types of fish
		var/fish_num = fish_count
		var/message = "You spot "
		while(fish_num > 0)
			var/datum/fish/fish_type = fish_list[fish_num]
			var/fish_name = fish_type.fish_name
			if(fish_count > 1 && fish_num == 1)	//If there were at least 2 fish, and this is the last one, add "and" to the message
				message += "and "
			message += "\an [fish_name]"
			fish_num --
			if(fish_num > 0)					//There's more fish, add a comma to the message
				message +=", "
		message +="."							//No more fish, end the message with a period
		//Display the number of fish and previously constructed message
		examine_message += "[src] contains [fish_count] live fish. [message] "

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
	if(water_level)							//Tank has water, so it's actually leaking
		if(leaking == 1)
			examine_message += "[src] is leaking."
		if(leaking == 2)
			examine_message += "[src] is leaking profusely!"
	else										//No water, report the cracks instead
		if(leaking == 1)
			examine_message += "[src] is cracked."
		if(leaking == 2)
			examine_message += "[src] is nearly shattered!"


	//Finally, report the full examine_message constructed from the above reports
	to_chat(user, "<span class='notice'>[examine_message]</span>")
	return examine_message

//////////////////////////////
//		ATACK PROCS			//
//////////////////////////////

/obj/machinery/fishtank/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/pet/cat))
		if(M.a_intent == INTENT_HELP)							//Cats can try to fish in open tanks on help intent
			if(lid_switch)									//Can't fish in a closed tank. Fishbowls are ALWAYS open.
				M.visible_message("<span class='notice'>[M.name] stares at into [src] while sitting perfectly still.</span>", "<span class='notice'>The lid is closed, so you stare into [src] intently.</span>")
			else
				if(fish_count)								//Tank must actually have fish to try catching one
					M.visible_message("<span class='warning'>[M.name] leaps up onto [src] and attempts to fish through the opening!</span>", "<span class='notice'>You jump up onto [src] and begin fishing through the opening!</span>")
					if(water_level && prob(45))			//If there is water, there is a chance the cat will slip, Syndicat will spark like E-N when this happens
						M.visible_message("<span class='notice'>[M.name] slipped and got soaked!</span>", "<span class='notice'>You slipped and got soaked!</span>")
						if(istype(M, /mob/living/simple_animal/pet/cat/Syndi))
							do_sparks(3, 1, src)
					else								//No water or didn't slip, get that fish!
						M.visible_message("<span class='warning'>[M.name] catches and devours a live fish!</span>", "<span class='notice'>You catch and devour a live fish, yum!</span>")
						kill_fish()						//Kill a random fish
						M.health = M.maxHealth			//Eating fish heals the predator
				else
					to_chat(M, "<span class='warning'>There are no fish in [src]!</span>")
		else
			return ..()
	else if(istype(M, /mob/living/simple_animal/hostile/bear))
		if(M.a_intent == INTENT_HELP)							//Bears can try to fish in open tanks on help intent
			if(lid_switch)									//Can't fish in a closed tank. Fishbowls are ALWAYS open.
				M.visible_message("<span class='notice'>[M.name] scrapes it's claws along [src]'s lid.</span>", "<span class='notice'>The lid is closed, so you scrape your claws against [src]'s lid.</span>")
			else
				if(fish_count)								//Tank must actually have fish to try catching one
					M.visible_message("<span class='warning'>[M.name] reaches into [src] and attempts to fish through the opening!</span>", "<span class='warning'>You reach into [src] and begin fishing through the opening!</span>")
					if(water_level && prob(5))			//Bears are good at catching fish, only a 5% chance to fail
						M.visible_message("<span class='warning'>[M.name] swipes at the water!</span>", "<span class='notice'>You just barely missed that fish!</span>")
					else								//No water or didn't slip, get that fish!
						M.visible_message("<span class='warning'>[M.name] catches and devours a live fish!</span>", "<span class='notice'>You catch and devour a live fish, yum!</span>")
						kill_fish()						//Kill a random fish
						M.health = M.maxHealth			//Eating fish heals the predator
				else
					to_chat(M, "<span class='warning'>There are no fish in [src]!</span>")
		else
			return ..()
	else
		return ..()

/obj/machinery/fishtank/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent == INTENT_HARM)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='danger'>[user.name] bangs against the [name]!</span>", \
							"<span class='danger'>You bang against the [name]!</span>", \
							"You hear a banging sound.")
	else
		playsound(loc, 'sound/effects/glassknock.ogg', 80, 1)
		user.visible_message("<span class='notice'>[user.name] taps on the [name].</span>", \
							"<span class='notice'>You tap on the [name].</span>", \
							"You hear a knocking sound.")

/obj/machinery/fishtank/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		check_health()

/obj/machinery/fishtank/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/Glasshit.ogg', 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/fishtank/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, "shatter", 70, 1)
		for(var/i in 1 to shard_count)	//Produce the appropriate number of glass shards
			var/obj/item/shard/S = new /obj/item/shard(get_turf(src))
			transfer_fingerprints_to(S)
		if(water_level)												//Spill any water that was left in the tank when it broke
			spill_water()
	else															//We are deconstructing, make glass sheets instead of shards
		new /obj/item/stack/sheet/glass(get_turf(src), shard_count + 1)		//Produce the appropriate number of glass sheets, in a single stack
	qdel(src)

/obj/machinery/fishtank/attackby(obj/item/O, mob/user)
	//Welders repair damaged tanks on help intent, damage on all others
	if(iswelder(O))
		var/obj/item/weldingtool/W = O
		if(user.a_intent == INTENT_HELP)
			if(W.isOn())
				if(obj_integrity < max_integrity)
					playsound(loc, W.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You repair some of the cracks on [src].</span>")
					obj_integrity = min(obj_integrity + 20, max_integrity)
					check_health()
				else
					to_chat(user, "<span class='notice'>There is no damage to fix!</span>")
			else
				if(obj_integrity < max_integrity)
					to_chat(user, "<span class='notice'>[W] must be on to repair this damage.</span>")
		else
			return ..()
	//Open reagent containers add and remove water
	else if(O.is_drainable())
		//Containers with any reagents will get dumped in
		if(O.reagents.total_volume)
			var/water_value = 0
			water_value += O.reagents.get_reagent_amount("water")				//Water is full value
			water_value += O.reagents.get_reagent_amount("holywater") *1.1		//Holywater is (somehow) better. Who said religion had to make sense?
			water_value += O.reagents.get_reagent_amount("tonic") * 0.25		//Tonic water is 25% value
			water_value += O.reagents.get_reagent_amount("sodawater") * 0.50	//Sodawater is 50% value
			water_value += O.reagents.get_reagent_amount("fishwater") * 0.75	//Fishwater is 75% value, to account for the fish poo
			water_value += O.reagents.get_reagent_amount("ice") * 0.80			//Ice is 80% value
			var/message = ""
			if(!water_value)													//The container has no water value, clear everything in it
				message = "The filtration process removes everything, leaving the water level unchanged."
				O.reagents.clear_reagents()
			else
				if(water_level == water_capacity)
					to_chat(user, "<span class='notice'>[src] is already full!</span>")
				else
					message = "The filtration process purifies the water, raising the water level."

					if((water_level + water_value) == water_capacity)
						message += " You filled [src] to the brim!"
					if((water_level + water_value) > water_capacity)
						message += " You overfilled [src] and some water runs down the side, wasted."
					O.reagents.clear_reagents()
					adjust_water_level(water_value)
			user.visible_message("<span class='notice'>[user.name] pours the contents of [O.name] into [src].</span>", "<span class='notice'>[message]</span>")
		//Empty containers will scoop out water, filling the container as much as possible from the water_level
		else if(O.is_refillable())
			if(!water_level)
				to_chat(user, "<span class='notice'>[src] is empty!</span>")
			else
				if(water_level >= O.reagents.maximum_volume) //Enough to fill the container completely
					O.reagents.add_reagent("fishwater", O.reagents.maximum_volume)
					adjust_water_level(-O.reagents.maximum_volume)
					user.visible_message("<span class='notice'>[user.name] scoops out some water from [src].</span>", "<span class='notice'>You completely fill [O.name] from [src].</span>")
				else															//Fill the container as much as possible with the water_level
					O.reagents.add_reagent("fishwater", water_level)
					adjust_water_level(-water_level)
					user.visible_message("<span class='notice'>[user.name] scoops out some water from [src].</span>", "<span class='notice'>You fill [O.name] with the last of the water in [src].</span>")
	//Wrenches can deconstruct empty tanks, but not tanks with any water. Kills any fish left inside and destroys any unharvested eggs in the process
	else if(iswrench(O))
		if(!water_level)
			to_chat(user, "<span class='notice'>Now disassembling [src].</span>")
			playsound(loc, O.usesound, 50, 1)
			if(do_after(user, 50 * O.toolspeed, target = src))
				deconstruct(TRUE)
		else
			to_chat(user, "<span class='warning'>[src] must be empty before you disassemble it!</span>")
	//Fish eggs
	else if(istype(O, /obj/item/fish_eggs))
		var/obj/item/fish_eggs/egg = O
		//Don't add eggs if there is no water (they kinda need that to live)
		if(!water_level)
			to_chat(user, "<span class='warning'>[src] has no water; [egg.name] won't hatch without water!</span>")
		else
			//Don't add eggs if the tank already has the max number of fish
			if(fish_count >= max_fish)
				to_chat(user, "<span class='notice'>[src] can't hold any more fish.</span>")
			else
				add_fish(egg.fish_type)
				qdel(egg)
	//Fish food
	else if(istype(O, /obj/item/fishfood))
		//Only add food if there is water and it isn't already full of food
		if(water_level)
			if(food_level < 10)
				if(fish_count == 0)
					user.visible_message("<span class='notice'>[user.name] shakes some fish food into the empty [src]... How sad.</span>", "<span class='notice'>You shake some fish food into the empty [src]... If only it had fish.</span>")
				else
					user.visible_message("<span class='notice'>[user.name] feeds the fish in [src]. The fish look excited!</span>", "<span class='notice'>You feed the fish in [src]. They look excited!</span>")
				adjust_food_level(10)
			else
				to_chat(user, "<span class='notice'>[src] already has plenty of food in it. You decide to not add more.</span>")
		else
			to_chat(user, "<span class='notice'>[src] doesn't have any water in it. You should fill it with water first.</span>")
	//Fish egg scoop
	else if(istype(O, /obj/item/egg_scoop))
		if(egg_count)
			user.visible_message("<span class='notice'>[user.name] harvests some fish eggs from [src].</span>", "<span class='notice'>You scoop the fish eggs out of [src].</span>")
			harvest_eggs(user)
		else
			user.visible_message("<span class='notice'>[user.name] fails to harvest any fish eggs from [src].</span>", "<span class='notice'>There are no fish eggs in [src] to scoop out.</span>")
	//Fish net
	else if(istype(O, /obj/item/fish_net))
		harvest_fish(user)
	//Tank brush
	else if(istype(O, /obj/item/tank_brush))
		if(filth_level == 0)
			to_chat(user, "<span class='warning'>[src] is already spotless!</span>")
		else
			adjust_filth_level(-filth_level)
			user.visible_message("<span class='notice'>[user.name] scrubs the inside of [src], cleaning the filth.</span>", "<span class='notice'>You scrub the inside of [src], cleaning the filth.</span>")
	else
		return ..()