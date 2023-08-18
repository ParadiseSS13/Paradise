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
	icon = 'icons/mob/animal.dmi'
	icon_state = "parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	icon_resting = "parrot_sit"
	pass_flags = PASSTABLE
	can_collar = TRUE
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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/cracker = 3)

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
	var/parrot_dam_zone = list("chest", "head", "l_arm", "l_leg", "r_arm", "r_leg") //For humans, select a bodypart to attack

	var/parrot_speed = 5 //"Delay in world ticks between movement." according to byond. Yeah, that's BS but it does directly affect movement. Higher number = slower.
	var/parrot_been_shot = 0 //Parrots get a speed bonus after being shot. This will deincrement every process_ai() and at 0 the parrot will return to regular speed.

	var/list/speech_buffer
	var/list/available_channels

	//Headset for Poly to yell at engineers :)
	var/obj/item/radio/headset/ears = null

	//The thing the parrot is currently interested in. This gets used for items the parrot wants to pick up, mobs it wants to steal from,
	//mobs it wants to attack or mobs that have attacked it
	var/atom/movable/parrot_interest = null

	//Parrots will generally sit on their pertch unless something catches their eye.
	//These vars store their preffered perch and if they dont have one, what they can use as a perch
	var/obj/parrot_perch = null
	var/obj/desired_perches = null

	//Parrots are kleptomaniacs. This variable ... stores the item a parrot is holding.
	var/obj/item/held_item = null
	flying = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/parrot/New()
	..()
	speech_buffer = list()
	available_channels = list()
	GLOB.hear_radio_list += src
	update_speak()

	parrot_sleep_dur = parrot_sleep_max //In case someone decides to change the max without changing the duration var

	verbs.Add(/mob/living/simple_animal/parrot/proc/steal_from_ground, \
			/mob/living/simple_animal/parrot/proc/steal_from_mob, \
			/mob/living/simple_animal/parrot/verb/drop_held_item_player, \
			/mob/living/simple_animal/parrot/proc/perch_player)

	desired_perches = typecacheof(list(/obj/structure/computerframe, 	/obj/structure/displaycase, \
									/obj/structure/filingcabinet,	/obj/machinery/teleport, \
									/obj/machinery/suit_storage_unit,/obj/machinery/clonepod, \
									/obj/machinery/dna_scannernew,	/obj/machinery/tcomms, \
									/obj/machinery/nuclearbomb,		/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/computer))

/mob/living/simple_animal/parrot/Destroy()
	GLOB.hear_radio_list -= src
	return ..()

/mob/living/simple_animal/parrot/death(gibbed)
	if(can_die())
		if(held_item)
			custom_emote(EMOTE_VISIBLE, "lets go of [held_item]!")
			drop_held_item()
		walk(src, 0)
	return ..()

/mob/living/simple_animal/parrot/Stat()
	..()
	stat("Held Item", held_item)

/*
 * Inventory
 */
/mob/living/simple_animal/parrot/show_inv(mob/user)
	user.set_machine(src)

	var/dat = {"<table>"}

	dat += "<tr><td><B>Headset:</B></td><td><A href='?src=[UID()];[ears?"remove_inv":"add_inv"]=ears'>[(ears && !(ears.flags&ABSTRACT)) ? html_encode(ears) : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(can_collar)
		dat += "<tr><td>&nbsp;</td></tr>"
		dat += "<tr><td><B>Collar:</B></td><td><A href='?src=[UID()];[pcollar ? "remove_inv" : "add_inv"]=collar'>[(pcollar && !(pcollar.flags&ABSTRACT)) ? html_encode(pcollar) : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/parrot/Topic(href, href_list)
	//Can the usr physically do this?
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.stat || usr.restrained() || !usr.Adjacent(src))
		return

	//Is the usr's mob type able to do this?
	if(ishuman(usr) || isrobot(usr))
		if(href_list["remove_inv"])
			var/remove_from = href_list["remove_inv"]
			switch(remove_from)
				if("ears")
					if(ears)
						if(stat == CONSCIOUS) //DEAD PARROTS SHOULD NOT SPEAK (i hate that this is done in topic)
							if(length(available_channels))
								say("[pick(available_channels)]BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
							else
								say("BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")
						ears.forceMove(loc)
						ears = null
						update_speak()
					else
						to_chat(usr, "<span class='warning'>There is nothing to remove from its [remove_from].</span>")
						return
			show_inv(usr)
		else if(href_list["add_inv"])
			var/add_to = href_list["add_inv"]
			if(!usr.get_active_hand())
				to_chat(usr, "<span class='warning'>You have nothing in your hand to put on its [add_to].</span>")
				return
			switch(add_to)
				if("ears")
					if(ears)
						to_chat(usr, "<span class='warning'>It's already wearing something.</span>")
						return
					else
						var/obj/item/item_to_add = usr.get_active_hand()
						if(!item_to_add)
							return

						if(!istype(item_to_add, /obj/item/radio/headset))
							to_chat(usr, "<span class='warning'>This object won't fit.</span>")
							return

						var/obj/item/radio/headset/headset_to_add = item_to_add

						usr.drop_item()
						headset_to_add.forceMove(src)
						ears = headset_to_add
						to_chat(usr, "You fit the headset onto [src].")

						available_channels.Cut()
						for(var/ch in headset_to_add.channels)
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

						if(headset_to_add.translate_binary)
							available_channels.Add(":b")
						update_speak()
			show_inv(usr)
		else
			..()

/*
 * Attack responces
 */
//Humans, monkeys, aliens
/mob/living/simple_animal/parrot/attack_hand(mob/living/carbon/M)
	..()
	if(client)
		return

	if(!stat && M.a_intent == "harm")
		icon_state = "parrot_fly" //It is going to be flying regardless of whether it flees or attacks

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
/mob/living/simple_animal/parrot/attackby(obj/item/O, mob/user, params)
	..()
	if(!stat && !client && !istype(O, /obj/item/stack/medical))
		if(O.force)
			if(parrot_state == PARROT_PERCH)
				parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

			parrot_interest = user
			parrot_state = PARROT_SWOOP|PARROT_FLEE
			icon_state = "parrot_fly"
			drop_held_item(FALSE)
	return

//Bullets
/mob/living/simple_animal/parrot/bullet_act(obj/item/projectile/P)
	..()
	if(!stat && !client)
		if(parrot_state == PARROT_PERCH)
			parrot_sleep_dur = parrot_sleep_max //Reset it's sleep timer if it was perched

		parrot_interest = null
		parrot_state = PARROT_WANDER //OWFUCK, Been shot! RUN LIKE HELL!
		parrot_been_shot += 5
		icon_state = "parrot_fly"
		drop_held_item(FALSE)
	return

/*
 * AI - Not really intelligent, but I'm calling it AI anyway.
 */
/mob/living/simple_animal/parrot/Life(seconds, times_fired)
	..()

	//Sprite and AI update for when a parrot gets pulled
	if(pulledby && stat == CONSCIOUS)
		icon_state = "parrot_fly"

/mob/living/simple_animal/parrot/proc/update_speak()
	speak.Cut()

	if(available_channels.len && ears)
		for(var/possible_phrase in clean_speak)
			//50/50 chance to not use the radio at all
			speak += "[prob(50) ? pick(available_channels) : ""][possible_phrase]"

	else //If we have no headset or channels to use, dont try to use any!
		for(var/possible_phrase in clean_speak)
			speak += possible_phrase

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
	if(speech_buffer.len && prob(10))
		if(clean_speak.len)
			clean_speak -= pick(clean_speak)

		clean_speak += pick(speech_buffer)
		speech_buffer.Cut()

//-----SLEEPING
	if(parrot_state == PARROT_PERCH)
		if(parrot_perch && parrot_perch.loc != loc) //Make sure someone hasnt moved our perch on us
			if(parrot_perch in view(src))
				parrot_state = PARROT_SWOOP|PARROT_RETURN
				icon_state = "parrot_fly"
				return
			else
				parrot_state = PARROT_WANDER
				icon_state = "parrot_fly"
				return

		if(--parrot_sleep_dur) //Zzz
			return
		else
			//This way we only call the stuff below once every [sleep_max] ticks.
			parrot_sleep_dur = parrot_sleep_max

			//Cycle through message modes for the headset
			update_speak()

			//Search for item to steal
			parrot_interest = search_for_perch_and_item()
			if(parrot_interest)
				custom_emote(EMOTE_VISIBLE, "looks in [parrot_interest]'s direction and takes flight.")
				parrot_state = PARROT_SWOOP|PARROT_STEAL
				icon_state = "parrot_fly"
			return

//-----WANDERING - This is basically a 'I dont know what to do yet' state
	else if(parrot_state == PARROT_WANDER)
		//Stop movement, we'll set it later
		walk(src, 0)
		parrot_interest = null

		//Wander around aimlessly. This will help keep the loops from searches down
		//and possibly move the mob into a new are in view of something they can use
		if(prob(90))
			step(src, pick(GLOB.cardinal))
			return

		if(!held_item && !parrot_perch) //If we've got nothing to do.. look for something to do.
			var/atom/movable/AM = search_for_perch_and_item() //This handles checking through lists so we know it's either a perch or stealable item
			if(AM)
				if(isitem(AM) || isliving(AM))	//If stealable item
					parrot_interest = AM
					parrot_state = PARROT_SWOOP|PARROT_STEAL
					face_atom(AM)
					custom_emote(EMOTE_VISIBLE, "turns and flies towards [parrot_interest].")
					return
				else	//Else it's a perch
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
			parrot_perch = search_for_perch_and_item()
			if(parrot_perch)
				parrot_state = PARROT_SWOOP|PARROT_RETURN
				return
//-----STEALING
	else if(parrot_state == (PARROT_SWOOP|PARROT_STEAL))
		walk(src, 0)

		if(!parrot_interest || held_item || !(parrot_interest in view(src)))
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

		var/list/path_to_take = get_path_to(src, parrot_interest)
		if(length(path_to_take) <= 1) // The target is below us
			parrot_interest = null
			parrot_state = PARROT_SWOOP|PARROT_RETURN
			return

		walk_to(src, path_to_take[2], 0, parrot_speed)
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
			return

		var/list/path_to_take = get_path_to(src, parrot_perch)
		if(length(path_to_take) <= 1) // The target is below us
			parrot_perch = null
			parrot_state = PARROT_WANDER
			return

		walk_to(src, path_to_take[2], 0, parrot_speed)
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

/mob/living/simple_animal/parrot/proc/search_for_perch_and_item(list/stuff)
	var/turf/my_turf = get_turf(src)
	var/list/computed_paths = list()
	for(var/obj/O in view(src))
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
			computed_paths[cache_id] = computed_paths[cache_id] || get_path_to(src, T)
			if(!length(computed_paths[cache_id]))
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
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return 1
	if(istype(loc, /obj/machinery/disposal) || istype(loc, /obj/structure/disposalholder))
		to_chat(src, "<span class='warning'>You are inside a disposal chute!</span>")
		return 1
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
	return 0

/mob/living/simple_animal/parrot/proc/steal_from_mob()
	set name = "Steal from mob"
	set category = "Parrot"
	set desc = "Steals an item right out of a person's hand!"

	if(stat)
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding [held_item]</span>")
		return 1

	var/obj/item/stolen_item = null

	for(var/mob/living/carbon/C in view(1, src))
		if(C.l_hand && C.l_hand.w_class <= WEIGHT_CLASS_SMALL)
			stolen_item = C.l_hand

		if(C.r_hand && C.r_hand.w_class <= WEIGHT_CLASS_SMALL)
			stolen_item = C.r_hand

		if(stolen_item && C.unEquip(stolen_item))
			try_grab_item(stolen_item)
			visible_message("<span class='notice'>[src] grabs [held_item] out of [C]'s hand!</span>", "<span class='notice'>You snag [held_item] out of [C]'s hand!</span>", "You hear the sounds of wings flapping furiously.")
			return held_item

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

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
		return -1

	if(!held_item)
		to_chat(src, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	if(!drop_gently)
		if(istype(held_item, /obj/item/grenade))
			var/obj/item/grenade/G = held_item
			G.forceMove(loc)
			G.prime()
			to_chat(src, "You let go of [held_item]!")
			held_item = null
			update_held_icon()
			return 1

	to_chat(src, "You drop [held_item].")

	held_item.forceMove(loc)
	held_item = null
	update_held_icon()
	return 1

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
/mob/living/simple_animal/parrot/Poly
	name = "Poly"
	desc = "Poly the Parrot. An expert on quantum cracker theory."
	clean_speak = list(
		"Poly wanna cracker!",
		"Check the crystal, you chucklefucks!",
		"STOP HOT-WIRING THE ENGINE, FUCKING CHRIST!",
		"Wire the solars, you lazy bums!",
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
		)
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/parrot/Poly/New()
	ears = new /obj/item/radio/headset/headset_eng(src)
	available_channels = list(":e")
	clean_speak += "Danger! Crystal hyperstructure integrity faltering! Integrity: [rand(75, 99)]%" // Has to be here cause of the `rand()`.
	..()

/mob/living/simple_animal/parrot/Poly/npc_safe(mob/user) // Hello yes, I have universal speak and I follow people around and shout out antags
	return FALSE

/mob/living/simple_animal/parrot/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(message_mode && istype(ears))
		ears.talk_into(src, message_pieces, message_mode, verb)
		used_radios += ears

/mob/living/simple_animal/parrot/hear_say(list/message_pieces, verb = "says", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	if(speaker != src && prob(50))
		parrot_hear(html_decode(multilingual_to_message(message_pieces)))
	..()

/mob/living/simple_animal/parrot/hear_radio(list/message_pieces, verb = "says", part_a, part_b, mob/speaker = null, hard_to_hear = 0, atom/follow_target)
	if(speaker != src && prob(50))
		parrot_hear(html_decode(multilingual_to_message(message_pieces)))
	..()

/mob/living/simple_animal/parrot/proc/parrot_hear(message)
	if(!message || stat)
		return
	speech_buffer.Add(message)

/mob/living/simple_animal/parrot/proc/update_held_icon()
	underlays.Cut()

	if(!held_item)
		return

	var/matrix/m180 = matrix(held_item.transform)
	m180.Turn(180)

	var/held_item_icon = image(held_item, pixel_y = -8)
	animate(held_item_icon, transform = m180)
	underlays += held_item_icon

/mob/living/simple_animal/parrot/CanPathfindPassTo(ID, dir, obj/destination)
	return is_type_in_typecache(destination, desired_perches)
