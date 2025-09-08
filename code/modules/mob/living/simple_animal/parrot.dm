/* Parrots!
 * Contains
 * 		Defines
 *		Inventory (headset stuff)
 *		Attack responces
 *		AI
 *		Procs / Verbs (usable by players)
 *		Sub-types
 */

/*
 * Defines
 */

//Only a maximum of one action and one intent should be active at any given time.
//Actions
#define PARROT_PERCH (1<<0)		//Sitting/sleeping, not moving
#define PARROT_SWOOP (1<<1)		//Moving towards or away from a target
#define PARROT_WANDER (1<<2)		//Moving without a specific target in mind

//Intents
#define PARROT_STEAL (1<<3)		//Flying towards a target to steal it/from it
#define PARROT_ATTACK (1<<4)	//Flying towards a target to attack it
#define PARROT_RETURN (1<<5)	//Flying towards its perch
#define PARROT_FLEE (1<<6)		//Flying away from its attacker

/mob/living/simple_animal/parrot
	name = "parrot"
	desc = "The parrot squawks, \"It's a parrot! BAWWK!\""
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	icon_resting = "parrot_sit"
	pass_flags = PASSTABLE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	faction = list("neutral", "jungle")

	var/list/clean_speak = list(
		"Hi",
		"Hello!",
		"Cracker?",
		"BAWWWWK george mellons griffing me"
	)
	speak_emote = list("squawks", "says", "yells")
	emote_hear = list("squawks", "bawks")
	emote_see = list("flutters its wings")

	speak_chance = 1//1% (1 in 100) chance every tick; So about once per 150 seconds, assuming an average tick is 1.5s
	turns_per_move = 5
	butcher_results = list(/obj/item/food/cracker = 3)

	response_help = "pets"
	response_disarm = "gently moves aside"
	response_harm = "swats"
	stop_automated_movement = TRUE
	universal_speak = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_SMALL

	var/parrot_state = PARROT_WANDER //Hunt for a perch when created
	var/parrot_sleep_max = 25 //The time the parrot sits while perched before looking around. Mosly a way to avoid the parrot's AI in process_ai() being run every single tick.
	var/parrot_sleep_dur = 25 //Same as above, this is the var that physically counts down
	var/wander_probability = 90
	var/parrot_dam_zone = list("chest", "head", "l_arm", "l_leg", "r_arm", "r_leg") //For humans, select a bodypart to attack

	var/parrot_speed = 5 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	var/parrot_been_shot = 0 //Parrots get a speed bonus after being shot. This will deincrement every process_ai() and at 0 the parrot will return to regular speed.

	var/list/speech_buffer = list()
	var/list/available_channels = list()

	//Headset for Poly to yell at engineers :)
	var/obj/item/radio/headset/ears = null
	var/speech_probability = 10
	var/hear_probability = 50

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their pertch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/list/desired_perches
	var/leaving_perch_probability = 10

	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null
	initial_traits = list(TRAIT_FLYING)
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/parrot/Initialize(mapload)
	. = ..()

	GLOB.hear_radio_list += src
	update_speak()

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	verbs.Add(list(
		/mob/living/simple_animal/parrot/proc/steal_from_ground,
		/mob/living/simple_animal/parrot/proc/steal_from_mob,
		/mob/living/simple_animal/parrot/verb/drop_held_item_player,
		/mob/living/simple_animal/parrot/proc/perch_player
	))

	desired_perches = typecacheof(list(
		/obj/machinery/clonepod,
		/obj/machinery/computer,
		/obj/machinery/photocopier,
		/obj/machinery/nuclearbomb,
		/obj/machinery/particle_accelerator,
		/obj/machinery/atmospherics/portable,
		/obj/machinery/smartfridge/foodcart,
		/obj/machinery/message_server,
		/obj/machinery/tcomms/relay,
		/obj/machinery/teleport,
		/obj/structure/computerframe,
		/obj/structure/displaycase,
		/obj/structure/rack,
		/obj/structure/closet/crate
	)) - typecacheof(list(
		/obj/machinery/computer/security/telescreen,
		/obj/machinery/computer/cryopod,
		/obj/machinery/computer/guestpass
	))

	AddElement(/datum/element/wears_collar)

/mob/living/simple_animal/parrot/Destroy()
	GLOB.hear_radio_list -= src
	return ..()

/mob/living/simple_animal/parrot/get_strippable_items(datum/source, list/items)
	items |= GLOB.strippable_parrot_items

/mob/living/simple_animal/parrot/death(gibbed)
	if(can_die())
		if(held_item)
			custom_emote(EMOTE_VISIBLE, "lets go of [held_item]!")
			drop_held_item()
		walk(src, 0)
	return ..()

/mob/living/simple_animal/parrot/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Held Item:", "[held_item]")

/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M)
	..()
	if(client)
		return

	if(stat == CONSCIOUS && M.a_intent == "harm")
		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)

		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = M
		parrot_state = PARROT_SWOOP //The parrot just got hit, it WILL move, now to pick a direction..

		if(M.health < 50) //Weakened mob? Fight back!
			parrot_state |= PARROT_ATTACK
		else
			if(held_item)
				custom_emote(EMOTE_VISIBLE, "lets go of [held_item]!")

			parrot_state |= PARROT_FLEE		//Otherwise, fly like a bat out of hell!
			drop_held_item(FALSE)
	return

//Mobs with objects
/mob/living/simple_animal/parrot/attacked_by(obj/item/O, mob/living/user)
	if(..())
		return FINISH_ATTACK

	if(O.force)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = user
		parrot_state = PARROT_SWOOP|PARROT_FLEE
		icon_state = "parrot_fly"
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
		drop_held_item(FALSE)

//Bullets
/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/P)
	..()
	if(stat == CONSCIOUS && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER //OWFUCK, Been shot! RUN LIKE HELL!
		parrot_been_shot += 5
		icon_state = "parrot_fly"
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
		drop_held_item(FALSE)
	return

/mob/living/simple_animal/parrot/grabbedby(mob/living/carbon/user, supress_message)
	..()

	if(held_item && stat == CONSCIOUS)
		drop_held_item()

/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life(seconds, times_fired)
	..()

	if(held_item?.loc != src)
		held_item = null
		update_held_icon()

	//Sprite and AI update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"
		ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)

/mob/living/simple_animal/parrot/proc/update_available_channels()
	available_channels.Cut()
	if(!istype(ears) || QDELETED(ears))
		return

	for(var/ch in ears.channels)
		switch(ch)
			if("Engineering")
				available_channels.Add(":e")
			if("Command")
				available_channels.Add(":c")
			if("Security")
				available_channels.Add(":s")
			if("Science")
				available_channels.Add(":n")
			if("Medical")
				available_channels.Add(":m")
			if("Mining")
				available_channels.Add(":d")
			if("Cargo")
				available_channels.Add(":q")

	if(ears.translate_binary)
		available_channels.Add(":b")

/mob/living/simple_animal/parrot/proc/update_speak()
	speak.Cut()

	if(ears && length(available_channels))
		for(var/possible_phrase in clean_speak)
			//50/50 chance to not use the radio at all
			speak += "[prob(50) ? pick(available_channels) : ""][possible_phrase]"
		return
	//If we have no headset or channels to use, dont try to use any!
	speak = clean_speak.Copy()

/mob/living/simple_animal/parrot/handle_automated_movement()
	if(pulledby)
		parrot_state = PARROT_WANDER
		return

	if(!isturf(loc) || !(mobility_flags & MOBILITY_MOVE) || buckled)
		return //If it can't move, dont let it move.

//-----SPEECH
	/* Parrot speech mimickry!
	Phrases that the parrot hears in mob/living/say() get added to speach_buffer.
	Every once in a while, the parrot picks one of the lines from the buffer and replaces an element of the 'speech' list.
	Then it clears the buffer to make sure they dont magically remember something from hours ago. */
	if(length(speech_buffer) && prob(speech_probability))
		if(length(clean_speak))
			clean_speak -= pick(clean_speak)

		clean_speak += pick(speech_buffer)
		speech_buffer.Cut()

//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != loc) //Make sure someone hasnt moved our perch on us
			parrot_state = (parrot_perch in view(src)) ? (PARROT_SWOOP|PARROT_RETURN) : PARROT_WANDER
			icon_state = "parrot_fly"
			ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
			return

		if(--parrot_sleep_dur) //Zzz
			return
		else
			//This way we only call the stuff below once every [sleep_max] ticks.
			parrot_sleep_dur = parrot_sleep_max

			//Cycle through message modes for the headset
			update_speak()

			if(prob(leaving_perch_probability))
				// Parrot no longer likes this perch and will try to find another one
				parrot_perch = null
				parrot_state = PARROT_WANDER
				icon_state = "parrot_fly"
				ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
				return

			//Search for item to steal
			parrot_interest = search_for_perch_or_item()
			if(parrot_interest)
				custom_emote(EMOTE_VISIBLE, "looks in [parrot_interest]'s direction and takes flight.")
				parrot_state = PARROT_SWOOP|PARROT_STEAL
				icon_state = "parrot_fly"
				ADD_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
			return

//-----WANDERING - This is basically a 'I dont know what to do yet' state
	else if(parrot_state == PARROT_WANDER)
		//Stop movement, we'll set it later
		walk(src, 0)
		parrot_interest = null

		//Wander around aimlessly. This will help keep the loops from searches down
		//and possibly move the mob into a new are in view of something they can use
		if(prob(wander_probability))
			step(src, pick(GLOB.cardinal))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_or_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(isitem(AM) || isliving(AM))	//If stealable item
					parrot_interest = AM
					parrot_state = PARROT_SWOOP|PARROT_STEAL
					face_atom(AM)
					custom_emote(EMOTE_VISIBLE, "turns and flies towards [parrot_interest].")
					return
				else if(is_type_in_typecache(AM, desired_perches))	//Else if it's a perch
					parrot_perch = AM
					parrot_state = PARROT_SWOOP|PARROT_RETURN
					return
			return

		if(parrot_interest && (parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP|PARROT_STEAL
			return

		if(parrot_perch && (parrot_perch in view(src)))
			parrot_state = PARROT_SWOOP|PARROT_RETURN
			return

		else //Have an item but no perch? Find one!
			var/atom/movable/AM = search_for_perch_or_item()
			if(is_type_in_typecache(AM, desired_perches))
				parrot_perch = AM
				parrot_state = PARROT_SWOOP|PARROT_RETURN
				return
//-----STEALING
	else if(parrot_state == (PARROT_SWOOP|PARROT_STEAL))
		walk(src, 0)

		if(!parrot_interest || held_item || length(grabbed_by) || !(parrot_interest in view(src)))
			parrot_state = PARROT_SWOOP|PARROT_RETURN
			return

		if(Adjacent(parrot_interest))
			if(isliving(parrot_interest))
				steal_from_mob()
			else //This should ensure that we only grab the item we want, and make sure it's not already collected on our perch
				if(!parrot_perch || parrot_interest.loc != parrot_perch.loc)
					try_grab_item(parrot_interest)
					visible_message("<span class='notice'>[src] grabs [held_item]!</span>", "<span class='notice'>You grab [held_item]!</span>", "You hear the sounds of wings flapping furiously.")

			parrot_interest = null
			parrot_state = PARROT_SWOOP|PARROT_RETURN
			return

		var/list/path_to_take = get_path_to(src, parrot_interest, mintargetdist = 1)
		if(!length(path_to_take)) // The target is unachievable
			parrot_interest = null
			parrot_state = PARROT_SWOOP|PARROT_RETURN
			return

		walk_to(src, parrot_interest, 1, parrot_speed)
		return

//-----RETURNING TO PERCH
	else if(parrot_state == (PARROT_SWOOP|PARROT_RETURN))
		walk(src, 0)

		if(!parrot_perch || !isturf(parrot_perch.loc)) //Make sure the perch exists and somehow isnt inside of something else.
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		if(Adjacent(parrot_perch))
			forceMove(parrot_perch.loc)
			drop_held_item()
			parrot_state = PARROT_PERCH
			icon_state = "parrot_sit"
			REMOVE_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
			return

		var/list/path_to_take = get_path_to(src, parrot_perch, mintargetdist = 1)
		if(!length(path_to_take)) // The target is unachievable
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		walk_to(src, parrot_perch, 1, parrot_speed)
		return

//-----FLEEING
	else if(parrot_state == (PARROT_SWOOP|PARROT_FLEE))
		walk(src, 0)

		if(!parrot_interest || !isliving(parrot_interest) || !Adjacent(parrot_interest)) //Sanity
			parrot_state = PARROT_WANDER
			parrot_interest = null
			return

		walk_away(src, parrot_interest, 0, parrot_speed - parrot_been_shot)
		parrot_been_shot--
		return

//-----ATTACKING
	else if(parrot_state == (PARROT_SWOOP|PARROT_ATTACK))
		//If we're attacking a nothing, an object, a turf or a ghost for some stupid reason, switch to wander
		if(!parrot_interest || !isliving(parrot_interest))
			parrot_interest = null
			parrot_state = PARROT_WANDER
			return

		var/mob/living/L = parrot_interest

		//If the mob is close enough to interact with
		if(Adjacent(parrot_interest))
			//If the mob we've been chasing/attacking dies or falls into crit, check for loot!
			if(L.stat)
				parrot_interest = null
				if(!held_item)
					held_item = steal_from_ground()
					if(!held_item)
						held_item = steal_from_mob() //Apparently it's possible for dead mobs to hang onto items in certain circumstances.
					update_held_icon()
				if(parrot_perch in view(src)) //If we have a home nearby, go to it, otherwise find a new home
					parrot_state = PARROT_SWOOP|PARROT_RETURN
				else
					parrot_state = PARROT_WANDER
				return

			//Time for the hurt to begin!
			var/damage = rand(5, 10)

			if(ishuman(parrot_interest))
				var/mob/living/carbon/human/H = parrot_interest
				var/obj/item/organ/external/affecting = H.get_organ(ran_zone(pick(parrot_dam_zone)))

				H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, MELEE), sharp = TRUE)
				custom_emote(EMOTE_VISIBLE, pick("pecks [H]'s [affecting].", "cuts [H]'s [affecting] with its talons."))
			else
				L.adjustBruteLoss(damage)
				custom_emote(EMOTE_VISIBLE, pick("pecks at [L].", "claws [L]."))
			return
		//Otherwise, fly towards the mob!
		else
			// No AStar here because the parrot is pissed and isn't thinking rationally.
			walk_to(src, parrot_interest, 1, parrot_speed)
		return
//-----STATE MISHAP
	else //This should not happen. If it does lets reset everything and try again
		walk(src, 0)
		parrot_interest = null
		parrot_perch = null
		drop_held_item()
		parrot_state = PARROT_WANDER
		return

/*
 * Procs
 */

/mob/living/simple_animal/parrot/movement_delay()
	if(client && stat == CONSCIOUS && parrot_state != "parrot_fly")
		icon_state = "parrot_fly"
		//Because the most appropriate place to set icon_state is movement_delay(), clearly
	return ..()

/mob/living/simple_animal/parrot/proc/search_for_perch_or_item()
	var/turf/my_turf = get_turf(src)
	var/list/computed_paths = list()
	for(var/obj/O in shuffle(view(src)))
		var/is_eligible = FALSE
		if(!parrot_perch && is_type_in_typecache(O, desired_perches))
			is_eligible = TRUE
		else if(!held_item && O.loc != src && isitem(O))
			if(parrot_perch && get_turf(parrot_perch) == get_turf(O))
				continue
			var/obj/item/I = O
			is_eligible = (I.w_class <= WEIGHT_CLASS_SMALL)

		if(!is_eligible)
			continue

		// Can we find a path to it?
		var/turf/T = get_turf(O)
		if(my_turf != T)
			var/cache_id = "[my_turf.UID()]_[T.UID()]"
			var/list/path = computed_paths[cache_id] || get_path_to(src, T, mintargetdist = 1)
			computed_paths[cache_id] = path
			if(!length(path))
				continue
			var/turf/target_turf = path[length(path)]
			if(!target_turf.Adjacent(O))
				continue

		return O
	return null

/*
 * Verbs - These are actually procs, but can be used as verbs by player-controlled parrots.
 */
/mob/living/simple_animal/parrot/proc/steal_from_ground()
	set name = "Steal from ground"
	set category = "Parrot"
	set desc = "Grabs a nearby item."

	if(stat)
		return FALSE

	if(length(grabbed_by))
		to_chat(src, "<span class='warning'>You are being grabbed!</span>")
		return FALSE

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return TRUE

	if(istype(loc, /obj/machinery/disposal) || istype(loc, /obj/structure/disposalholder))
		to_chat(src, "<span class='warning'>You are inside a disposal chute!</span>")
		return TRUE

	for(var/obj/item/I in view(1, src))
		//Make sure we're not already holding it and it's small enough
		if(I.loc != src && I.w_class <= WEIGHT_CLASS_SMALL)
			//If we have a perch and the item is sitting on it, continue
			if(!client && parrot_perch && I.loc == parrot_perch.loc)
				continue

			try_grab_item(I)
			visible_message("<span class='notice'>[src] grabs [held_item]!</span>", "<span class='notice'>You grab [held_item]!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class = 'warning'>There is nothing of interest to take.</span>")
	return FALSE

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return FALSE

	if(length(grabbed_by))
		to_chat(src, "<span class='warning'>You are being grabbed!</span>")
		return FALSE

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return TRUE

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1, src))
		if(C.l_hand && C.l_hand.w_class <= WEIGHT_CLASS_SMALL)
			stolen_item = C.l_hand

		if(C.r_hand && C.r_hand.w_class <= WEIGHT_CLASS_SMALL)
			stolen_item = C.r_hand

		if(stolen_item && C.drop_item_to_ground(stolen_item))
			try_grab_item(stolen_item)
			visible_message("<span class='notice'>[src] grabs [held_item] out of [C]'s hand!</span>", "<span class='notice'>You snag [held_item] out of [C]'s hand!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return FALSE

/mob/living/simple_animal/parrot/verb/drop_held_item_player()
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	drop_held_item()
	return

/mob/living/simple_animal/parrot/proc/drop_held_item(drop_gently = TRUE)
	set name = "Drop held item"
	set category = "Parrot"
	set desc = "Drop the item you're holding."

	if(stat)
		return FALSE

	if(!held_item)
		to_chat(src, "<span class='warning'>You have nothing to drop!</span>")
		return FALSE

	if(!drop_gently)
		if(istype(held_item, /obj/item/grenade))
			var/obj/item/grenade/G = held_item
			G.forceMove(loc)
			G.prime()
			to_chat(src, "You let go of [held_item]!")
			held_item = null
			update_held_icon()
			return TRUE

	to_chat(src, "You drop [held_item].")

	held_item.forceMove(loc)
	held_item = null
	update_held_icon()
	return TRUE

/mob/living/simple_animal/parrot/proc/perch_player()
	set name = "Sit"
	set category = "Parrot"
	set desc = "Sit on a nice comfy perch."

	if(stat || !client)
		return

	if(icon_state == "parrot_fly")
		for(var/atom/movable/AM in view(src, 1))
			if(is_type_in_typecache(AM, desired_perches))
				forceMove(AM.loc)
				icon_state = "parrot_sit"
				REMOVE_TRAIT(src, TRAIT_FLYING, INNATE_TRAIT)
				return
	to_chat(src, "<span class='warning'>There is no perch nearby to sit on.</span>")
	return

/**
  * Attempts to pick up an adjacent item
  *
  * Arguments:
  * * I - The item to try and pick up
  */
/mob/living/simple_animal/parrot/proc/try_grab_item(obj/I)
	if(length(grabbed_by))
		return

	if(!Adjacent(I))
		return

	if(held_item)
		drop_held_item()

	held_item = I
	update_held_icon()
	I.forceMove(src)

/mob/living/simple_animal/parrot/npc_safe(mob/user)
	return TRUE

/*
 * Sub-types
 */
/mob/living/simple_animal/parrot/poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	clean_speak = list(
		"Poly wanna cracker!",
		"Check the crystal, you chucklefucks!",
		"STOP HOT-WIRING THE ENGINE, FUCKING CHRIST!",
		"Wire the solars, you lazy bums!",
		"WHO TOOK THE DAMN MODSUITS?",
		"WHO TOOK THE DAMN HARDSUITS?",
		"OH GOD ITS ABOUT TO DELAMINATE CALL THE SHUTTLE",
		"Why are there so many atmos alerts?",
		"OH GOD WHY WOULD YOU PUT PLASMA IN THE SM?",
		"Remember to lock the emitters!",
		"Stop goofing off and repair the goddam station!",
		"The supermatter is not your friend!",
		"What were the wires again?",
		"Goddam emaggers!",
		"Why is nobody watching the engine?",
		"Maybe the SM would produce more power if we fed it some clowns.",
		"Everyone else dusted when they touched the SM, but I am sure you will be different.",
		"I asked the mime if they turned off the scrubbers, but they didn't say a word.",
		"This engine setup meets all safety requirements.",
		"Chief Engineers are the SM's natural diet.",
		"Don't eat the forbidden nacho!",
		"Is the engine meant to be making that noise?",
		"THE TESLA IS LOOSE CALL THE SHUTTLE",
		"Go fix the chewed wires, you lazy bums!",
		"Go fix that breach, or we'll all suffocate!",
		"Why is the engine failing?",
		"Checked that everything is connected as it should be?",
		"If you push the SM too far we'll have to abandon station!",
		"SOS, save our supermatter!",
		"Is that a spider in the SM?",
		"Remember those mesons, or you'll be seeing spiders in the SM!",
		"Check the air alarm is set properly!",
		"Is the station goal done yet?",
		"WHO TOOK THE DAMN MODSUITS?",
		"Don't wire the Bluespace Harvester to the Grid, or the station will be powerless!",
		"THE BSH IS SPAWNING HORRIFIC THINGS, YOU PUT IT TOO HIGH!",
		"It's an excellent idea to aim the BSA at the shuttle.",
		"Nitrogen is an awful gas if you need to power a BSH!",
		"There's a hole in the shield coverage!",
		"The shields aren't up and meteors are inbound!",
		"The leading cause of death among engineers is due to deactivated magboots, whether that's due to unwrenching a pressurized pipe or being pulled into the embrace of the SM, it means turn on your magboots!",
		"BORGS BAD",
		"You're telling me a Kentucky fried this vox?",
		"AI OPEN",
		"BLUESHIELD TO ME!",
		"ITS LOOSE",
		"TESLA IN THE HALLS",
		"I deep fried the nuke disc",
		"SQUAWK!",
		"Honk.",
		"Bridge gone",
		"Someone set up telecomms",
		"TOXINS!",
		"ONI SOMA!",
		"GOLDEN BLAST",
		"Is there supposed to be this much plasma in the chamber??",,
		"Why are there so many borgs?",
		"Why're your eyes glowing red?"
		)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	available_channels = list(":e")

/mob/living/simple_animal/parrot/poly/Initialize(mapload)
	. = ..()

	ears = new /obj/item/radio/headset/headset_eng(src)
	clean_speak += "Danger! Crystal hyperstructure integrity faltering! Integrity: [rand(75, 99)]%" // Has to be here cause of the `rand()`.

/mob/living/simple_animal/parrot/poly/npc_safe(mob/user) // Hello yes, I have universal speak and I follow people around and shout out antags
	return FALSE

/mob/living/simple_animal/parrot/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(message_mode && istype(ears))
		ears.talk_into(src, message_pieces, message_mode, verb)
		used_radios += ears

/mob/living/simple_animal/parrot/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	if(speaker != src && prob(hear_probability))
		parrot_hear(html_decode(multilingual_to_message(message_pieces)))
	..()

/mob/living/simple_animal/parrot/hear_radio(list/message_pieces, verb = "says", part_a, part_b, mob/speaker = null, hard_to_hear = 0, atom/follow_target, check_name_against)
	if(speaker != src && prob(hear_probability))
		parrot_hear(html_decode(multilingual_to_message(message_pieces)))
	..()

/mob/living/simple_animal/parrot/proc/parrot_hear(message)
	if(!message || stat)
		return
	speech_buffer.Add(strip_html_tags(message))

/mob/living/simple_animal/parrot/proc/update_held_icon()
	underlays.Cut()

	if(!held_item)
		return

	var/matrix/m180 = matrix(held_item.transform)
	m180.Turn(180)

	var/held_item_icon = image(held_item, pixel_y = -8)
	animate(held_item_icon, transform = m180)
	underlays += held_item_icon

#undef PARROT_PERCH
#undef PARROT_SWOOP
#undef PARROT_WANDER
#undef PARROT_STEAL
#undef PARROT_ATTACK
#undef PARROT_RETURN
#undef PARROT_FLEE
