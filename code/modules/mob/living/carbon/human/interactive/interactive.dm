/*
	NPC VAR EXPLANATIONS (for modules and other things)

		doing = their current action, SNPC_INTERACTING, SNPC_TRAVEL or SNPC_FIGHTING
		interest = how interested the NPC is in the situation, if they are idle, this drops
		timeout = this is internal
		TARGET = their current target
		LAST_TARGET = their last target
		nearby = a list of nearby mobs
		best_force = the highest force object, used for checking when to swap items
		retal = this is internal
		retal_target = this is internal
		update_hands = this is a bool (1/0) to determine if the NPC should update what is in his hands

		MYID = their ID card
		MYPDA = their PDA
		main_hand = what is in their "main" hand (chosen from left > right)
		TRAITS = the traits assigned to this npc
		mymjob = the job assigned to the npc

		robustness = the chance for the npc to hit something
		smartness = the inverse chance for an npc to do stupid things
		attitude = the chance for an npc to do rude or mean things
		slyness = the chance for an npc to do naughty things ie thieving

		functions = the list of procs that the npc will use for modules

		graytide = shitmin var to make them go psycho
*/
/mob/living/carbon/human/interactive
	name = "interactive station member"
	var/doing = 0
	var/interest = 10
	var/maxInterest = 10
	var/timeout = 0
	var/inactivity_period = 0
	var/atom/TARGET = null
	var/atom/LAST_TARGET = null
	var/list/nearby = list()
	var/best_force = 0
	var/retal = 0
	var/mob/retal_target = null
	var/update_hands = 0
	var/list/blacklistItems = list() // items we should be ignoring
	var/maxStepsTick = 6 // step as many times as we can per frame
	//Job and mind data
	var/obj/item/weapon/card/id/MYID
	var/obj/item/weapon/card/id/RPID // the "real" idea they use
	var/obj/item/device/pda/MYPDA
	var/obj/item/main_hand
	var/obj/item/other_hand
	var/TRAITS = 0
	var/obj/item/weapon/card/id/Path_ID
	var/default_job = /datum/job/civilian	// the type for the default job
	var/datum/job/myjob
	var/list/myPath = list()
	faction = list("synth")
	//trait vars
	var/robustness = 50
	var/smartness = 50
	var/attitude = 50
	var/slyness = 50
	var/graytide = 0
	var/list/favoured_types = list() // allow a mob to favour a type, and hold onto them
	var/chattyness = SNPC_CHANCE_TALK
	var/targetInterestShift = 5 // how much a good action should "reward" the npc
	//modules
	var/list/functions = list("nearbyscan","combat","shitcurity","chatter")
	var/restrictedJob = 0
	var/shouldUseDynamicProc = 0 // switch to make the AI control it's own proccessing
	var/alternateProcessing = 0
	var/forceProcess = 0
	var/processTime = 10
	var/speak_file = "npc_chatter.json"

	var/list/knownStrings = list()

	//snpc traitor variables

	var/isTraitor = 0
	var/traitorTarget
	var/traitorScale = 0 // our ability as a traitor
	var/traitorType = 0


/// SNPC voice handling

/mob/living/carbon/human/interactive/proc/loadVoice()
	var/savefile/S = new /savefile("data/npc_saves/snpc.sav")
	S["knownStrings"] >> knownStrings

	if(isnull(knownStrings))
		knownStrings = list()

/mob/living/carbon/human/interactive/proc/saveVoice()
	var/savefile/S = new /savefile("data/npc_saves/snpc.sav")
	S["knownStrings"] << knownStrings

//botPool funcs
/mob/living/carbon/human/interactive/proc/takeDelegate(mob/living/carbon/human/interactive/from,doReset=TRUE)
	change_eye_color(255, 0, 0)
	if(from == src)
		return FALSE
	TARGET = from.TARGET
	LAST_TARGET = from.LAST_TARGET
	retal = from.retal
	retal_target = from.retal_target
	doing = from.doing
	//
	timeout = 0
	inactivity_period = 0
	interest = maxInterest
	//
	update_icons()
	if(doReset)
		from.TARGET = null
		from.LAST_TARGET = null
		from.retal = 0
		from.retal_target = null
		from.doing = 0
	return TRUE

//end pool funcs

/mob/living/carbon/human/interactive/proc/random()
	//this is here because this has no client/prefs/brain whatever.
	age = rand(AGE_MIN, AGE_MAX)
	change_gender(pick("male", "female"))
	rename_character(real_name, species.get_random_name(gender))
	//job handling
	myjob = new default_job()
	job = myjob.title
	mind.assigned_role = job
	myjob.equip(src)
	myjob.apply_fingerprints(T)

/mob/living/carbon/human/interactive/proc/reset()
	walk(src, 0)
	timeout = 100
	retal = 0
	doing = 0
	inactivity_period = 0

/client/proc/resetSNPC(mob/living/carbon/human/interactive/T in npc_master.botPool_l)
	set name = "Reset SNPC"
	set desc = "Reset the SNPC"
	set category = "Debug"

	if(!holder)
		return

	if(istype(T))
		T.reset()

/client/proc/toggleSNPC(mob/living/carbon/human/interactive/T in npc_master.botPool_l)
	set name = "Toggle SNPC Proccessing Mode"
	set desc = "Toggle SNPC Proccessing Mode"
	set category = "Debug"

	if(!holder)
		return

	if(istype(T))
		T.alternateProcessing = !T.alternateProcessing
		T.forceProcess = 1
		to_chat(usr, "[T]'s processing has been switched to [T.alternateProcessing ? "High Profile" : "Low Profile"]")

/client/proc/customiseSNPC(mob/living/carbon/human/interactive/T in npc_master.botPool_l)
	set name = "Customize SNPC"
	set desc = "Customise the SNPC"
	set category = "Debug"

	if(!holder)
		return

	if(!istype(T))
		return

	var/list/jobs[0]
	for(var/datum/job/j in job_master.occupations)
		if(j.title != "AI" && j.title != "Cyborg")
			jobs[j.title] = j
	jobs = sortAssoc(jobs)
	var/job_name = input("Choose Job") as null|anything in jobs

	if(job_name)
		var/datum/job/cjob = jobs[job_name]
		var/alt_title = input("Choose Alt Title") in (list(job_name) + cjob.alt_titles)

		T.myjob = cjob
		T.job = cjob.title
		T.mind.assigned_role = cjob.title
		for(var/obj/item/W in T)
			qdel(W)
		T.myjob.equip(T)
		T.myjob.apply_fingerprints(T)
		T.doSetup(alt_title)

	var/shouldDoppel = input("Do you want the SNPC to disguise themself as a crewmember?") as anything in list("Yes", "No")
	if(shouldDoppel == "Yes")
		var/list/validchoices = list()
		for(var/mob/living/carbon/human/M in mob_list)
			validchoices += M

		var/mob/living/carbon/human/chosen = input("Which crewmember?") as null|anything in validchoices

		if(chosen)
			var/datum/dna/toDoppel = chosen.dna

			T.real_name = toDoppel.real_name
			T.set_species(chosen.species.name)
			T.body_accessory = chosen.body_accessory
			T.dna = toDoppel.Clone()
			T.UpdateAppearance()
			domutcheck(T)

	var/doTrait = input("Do you want the SNPC to be a traitor?") as anything in list("Yes", "No")
	if(doTrait == "Yes")
		var/list/tType = list("Brute" = SNPC_BRUTE, "Stealth" = SNPC_STEALTH, "Martyr" = SNPC_MARTYR, "Psycho" = SNPC_PSYCHO)
		var/cType = input("Choose the traitor personality.") as null|anything in tType
		if(cType)
			var/value = tType[cType]
			T.makeTraitor(value)

	var/doTele = input("Place the SNPC in their department?") as anything in list("Yes", "No")
	if(doTele == "Yes")
		T.loc = pick(get_area_turfs(T.job2area(T.myjob)))

	T.revive()

/mob/living/carbon/human/interactive/proc/doSetup(alt_title = null)
	Path_ID = new /obj/item/weapon/card/id(src)

	var/datum/job/captain/C = new/datum/job/captain
	Path_ID.access = C.get_access()

	if(!alt_title)
		alt_title = job

	MYID = new(src)
	MYID.name = "[real_name]'s ID Card ([alt_title])"
	MYID.assignment = "[alt_title]"
	MYID.rank = job
	MYID.sex = capitalize(gender)
	MYID.age = age
	MYID.registered_name = real_name
	MYID.photo = get_id_photo(src)
	MYID.access = Path_ID.access // Automatons have strange powers... strange indeed

	RPID = new(src)
	RPID.name = "[real_name]'s ID Card ([alt_title])"
	RPID.assignment = "[alt_title]"
	RPID.rank = job
	RPID.sex = capitalize(gender)
	RPID.age = age
	RPID.registered_name = real_name
	RPID.photo = get_id_photo(src)
	RPID.access = myjob.get_access()

	equip_to_slot_or_del(MYID, slot_wear_id)
	if(wear_pda)
		MYPDA = wear_pda
	else
		MYPDA = new(src)
		equip_to_slot_or_del(MYPDA, slot_wear_pda)
	MYPDA.owner = real_name
	MYPDA.ownjob = alt_title
	MYPDA.ownrank = job
	MYPDA.name = "PDA-[real_name] ([alt_title])"
	zone_sel.selecting = "chest"
	//arms
	if(prob((SNPC_FUZZY_CHANCE_LOW+SNPC_FUZZY_CHANCE_HIGH)/4))
		var/obj/item/organ/external/R = organs_by_name["r_arm"]
		if(R)
			R.robotize()
	else
		var/obj/item/organ/external/L = organs_by_name["l_arm"]
		if(L)
			L.robotize()
	//legs
	if(prob((SNPC_FUZZY_CHANCE_LOW+SNPC_FUZZY_CHANCE_HIGH)/4))
		var/obj/item/organ/external/R = organs_by_name["r_leg"]
		if(R)
			R.robotize()
	else
		var/obj/item/organ/external/L = organs_by_name["l_leg"]
		if(L)
			L.robotize()
	UpdateDamageIcon()
	regenerate_icons()

	hand = 0
	functions = list("nearbyscan", "combat", "shitcurity", "chatter") // stop customize adding multiple copies of a function
	setup_job(job)

	if(TRAITS & TRAIT_ROBUST)
		robustness = 75
	else if(TRAITS & TRAIT_UNROBUST)
		robustness = 25

	//modifiers are prob chances, lower = smarter
	if(TRAITS & TRAIT_SMART)
		smartness = 75
	else if(TRAITS & TRAIT_DUMB)
		disabilities |= CLUMSY
		smartness = 25

	if(TRAITS & TRAIT_MEAN)
		attitude = 75
	else if(TRAITS & TRAIT_FRIENDLY)
		attitude = 1

	if(TRAITS & TRAIT_THIEVING)
		slyness = 75

/mob/living/carbon/human/interactive/proc/setup_job(thejob)
	switch(thejob)
		if("Civilian")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon)
		if("Captain", "Head of Personnel")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/captain,/obj/item/weapon/disk/nuclear)
		if("Nanotrasen Representative")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/centcom, /obj/item/weapon/paper, /obj/item/weapon/melee/baton/loaded/ntcane)
			functions += "paperwork"
		if("Magistrate", "Internal Affairs Agent")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/law, /obj/item/weapon/paper)
			functions += "paperwork"
		if("Quartermaster", "Cargo Technician")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon/stamp/granted, /obj/item/weapon/stamp/denied, /obj/item/weapon/paper, /obj/item/weapon/clipboard)
			functions += "stamping"
		if("Chef")
			favoured_types = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/kitchen)
			functions += "souschef"
			restrictedJob = 1
		if("Bartender")
			favoured_types = list(/obj/item/weapon/reagent_containers/food, /obj/item/weapon/kitchen)
			functions += "bartend"
			restrictedJob = 1
		if("Station Engineer", "Chief Engineer", "Life Support Specialist", "Mechanic")
			favoured_types = list(/obj/item/stack, /obj/item/weapon, /obj/item/clothing)
		if("Chief Medical Officer", "Medical Doctor", "Chemist", "Virologist", "Geneticist", "Psychiatrist", "Paramedic", "Brig Physician")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/storage/firstaid, /obj/item/stack/medical, /obj/item/weapon/reagent_containers/syringe)
			functions += "healpeople"
		if("Research Director", "Scientist", "Roboticist")
			favoured_types = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/stack, /obj/item/weapon/reagent_containers)
		if("Head of Security", "Warden", "Security Officer", "Detective", "Security Pod Pilot", "Blueshield")
			favoured_types = list(/obj/item/clothing, /obj/item/weapon, /obj/item/weapon/restraints)
		if("Janitor")
			favoured_types = list(/obj/item/weapon/mop, /obj/item/weapon/reagent_containers/glass/bucket, /obj/item/weapon/reagent_containers/spray/cleaner, /obj/effect/decal/cleanable)
			functions += "dojanitor"
		if("Clown")
			favoured_types = list(/obj/item/weapon/soap, /obj/item/weapon/reagent_containers/food/snacks/grown/banana, /obj/item/weapon/bananapeel)
			functions += "clowning"
		if("Botanist")
			favoured_types = list(/obj/machinery/portable_atmospherics/hydroponics,  /obj/item/weapon/reagent_containers, /obj/item/weapon)
			functions += "botany"
			restrictedJob = 1
		else
			favoured_types = list(/obj/item/clothing)

/mob/living/carbon/human/interactive/proc/makeTraitor(var/inPers)
	isTraitor = 1
	traitorScale = (slyness + smartness) + rand(-10,10)
	traitorType = inPers

	ticker.mode.traitors += mind
	mind.special_role = "traitor"
	var/datum/mindslaves/slaved = new()
	slaved.masters += mind
	mind.som = slaved
	ticker.mode.update_traitor_icons_added(mind)

	switch(traitorType)
		if(SNPC_BRUTE) // SMASH KILL RAAARGH
			var/datum/objective/assassinate/A = new
			A.owner = mind
			A.find_target()
			mind.objectives += A
			traitorTarget = A.target.current
		if(SNPC_STEALTH) // Shhh we is sneekies
			var/datum/objective/steal/S = new
			S.owner = mind
			S.find_target()
			mind.objectives += S
			traitorTarget = locate(S.steal_target.typepath) in world
		if(SNPC_MARTYR) // MY LIFE FOR SPESZUL
			var/targetType = pick(/obj/structure/particle_accelerator, /obj/machinery/gravity_generator/main, /obj/machinery/power/smes)
			traitorTarget = locate(targetType) in world
			var/datum/objective/O = new("Destroy \the [traitorTarget].")
			O.owner = mind
			mind.objectives += O
		if(SNPC_PSYCHO) // YOU'RE LIKE A FLESH BICYLE AND I WANT TO DISMANTLE YOU
			var/datum/objective/hijack/H = new
			H.owner = mind
			mind.objectives += H
			traitorTarget = null

	functions += "traitor"
	faction -= "neutral"
	faction += "hostile"

/mob/living/carbon/human/interactive/create_mob_hud()
	if(!hud_used)
		hud_used = new /datum/hud/human(src)

/mob/living/carbon/human/interactive/New()
	..()
	snpc_list += src

	create_mob_hud()

	sync_mind()
	random()
	doSetup()
	npc_master.insertBot(src)
	loadVoice()
	hear_radio_list += src

	// a little bit of variation to make individuals more unique
	robustness += rand(-10, 10)
	smartness += rand(-10, 10)
	attitude += rand(-10, 10)
	slyness += rand(-10, 10)

	doProcess()

/mob/living/carbon/human/interactive/Destroy()
	hear_radio_list -= src
	snpc_list -= src
	return ..()

/mob/living/carbon/human/interactive/proc/retalTarget(mob/living/target)
	var/mob/living/M = target
	if(istype(M))
		if(health > 0)
			if(M.a_intent == "help" && !incapacitated())
				chatter()
				if(istype(target, /mob/living/carbon) && !retal && prob(SNPC_FUZZY_CHANCE_LOW))
					var/mob/living/carbon/C = target
					if(!Adjacent(target))
						tryWalk(target)
					else
						C.help_shake_act(src)
			if(M.a_intent == "harm")
				retal = 1
				retal_target = target

//Retaliation clauses

/mob/living/carbon/human/interactive/attacked_by(obj/item/I, mob/living/user, def_zone)
	..()
	retalTarget(user)

/mob/living/carbon/human/interactive/hitby(atom/movable/AM)
	..()
	var/mob/living/carbon/C = locate(/mob/living/carbon) in view(SNPC_MIN_RANGE_FIND, src)
	if(C)
		retalTarget(C)

/mob/living/carbon/human/interactive/bullet_act(obj/item/projectile/P)
	..()
	retalTarget(P.firer)

/mob/living/carbon/human/interactive/attack_hand(mob/living/carbon/human/M)
	..()
	retalTarget(M)

/mob/living/carbon/human/interactive/show_inv(mob/user)
	..()
	retalTarget(user)

/mob/living/carbon/human/interactive/can_inject(mob/user, error_msg, target_zone, var/penetrate_thick = 0)
	..()
	retalTarget(user)

//THESE EXIST FOR DEBUGGING OF THE DOING/INTEREST SYSTEM EASILY
/mob/living/carbon/human/interactive/proc/doing2string(doin)
	var/toReturn = ""
	if(!doin)
		toReturn = "not doing anything"
	if(doin & SNPC_INTERACTING)
		toReturn += "interacting with something, "
	if(doin & SNPC_FIGHTING)
		toReturn += "engaging in combat, "
	if(doin & SNPC_TRAVEL)
		toReturn += "and going somewhere"
	return toReturn

/mob/living/carbon/human/interactive/proc/interest2string(inter)
	var/toReturn = "Flatlined"
	if(inter >= 0 && inter <= 25)
		toReturn = "Very Bored"
	if(inter >= 26 && inter <= 50)
		toReturn = "Bored"
	if(inter >= 51 && inter <= 75)
		toReturn = "Content"
	if(inter >= 76)
		toReturn = "Excited"
	return toReturn
//END DEBUG

/mob/living/carbon/human/interactive/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!canmove)
		return 1
	if(health <= 0 && checkDead)
		return 1
	if(restrained())
		return 1
	if(paralysis)
		return 1
	if(stunned)
		return 1
	if(stat)
		return 1
	if(inactivity_period > 0)
		return 1
	return 0

/mob/living/carbon/human/interactive/proc/enforce_hands()
	if(main_hand)
		if(main_hand.loc != src)
			main_hand = null
	if(other_hand)
		if(other_hand.loc != src)
			other_hand = null
	if(hand)
		if(!l_hand)
			main_hand = null
			if(r_hand)
				swap_hands()
	else
		if(!r_hand)
			main_hand = null
			if(l_hand)
				swap_hands()

/mob/living/carbon/human/interactive/proc/swap_hands()
	hand = !hand
	var/obj/item/T = other_hand
	main_hand = other_hand
	other_hand = T
	update_hands = 1

/mob/living/carbon/human/interactive/proc/take_to_slot(obj/item/G, var/hands=0)
	var/list/slots = list("left pocket" = slot_l_store, "right pocket" = slot_r_store, "left hand" = slot_l_hand, "right hand" = slot_r_hand)
	if(hands)
		slots = list("left hand" = slot_l_hand, "right hand" = slot_r_hand)
	G.loc = src
	if(G.force && G.force > best_force)
		best_force = G.force
	equip_in_one_of_slots(G, slots)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/insert_into_backpack()
	var/list/slots = list(slot_l_store, slot_r_store, slot_l_hand, slot_r_hand)
	var/obj/item/I = get_item_by_slot(pick(slots))
	var/obj/item/weapon/storage/BP = get_item_by_slot(slot_back)
	if(back && BP && I)
		if(BP.can_be_inserted(I))
			BP.handle_item_insertion(I)
	else
		unEquip(I,TRUE)
	update_hands = 1

/mob/living/carbon/human/interactive/proc/targetRange(towhere)
	return get_dist(get_turf(towhere), get_turf(src))

/mob/living/carbon/human/interactive/death()
	saveVoice()
	..()

/mob/living/carbon/human/interactive/hear_say(message, verb = "says", datum/language/language = null, alt_name = "", italics = 0, mob/speaker = null, sound/speech_sound, sound_vol)
	if(!istype(speaker, /mob/living/carbon/human/interactive))
		knownStrings |= html_decode(message)
	..()

/mob/living/carbon/human/interactive/hear_radio(message, verb = "says", datum/language/language=null, part_a, part_b, mob/speaker = null, hard_to_hear = 0, vname = "", atom/follow_target)
	if(!istype(speaker, /mob/living/carbon/human/interactive))
		knownStrings |= html_decode(message)
	..()

/mob/living/carbon/human/interactive/proc/doProcess()
	forceProcess = 0

	if(shouldUseDynamicProc)
		var/isSeen = 0
		for(var/mob/living/carbon/human/A in orange(12, src))
			if(A.client)
				isSeen = 1
		alternateProcessing = isSeen
		if(alternateProcessing)
			forceProcess = 1

	if(IsDeadOrIncap())
		reset()
		return
	//---------------------------
	//---- interest flow control
	if(interest < 0 || inactivity_period < 0)
		if(interest < 0)
			interest = 0
		if(inactivity_period < 0)
			inactivity_period = 0
	if(interest > maxInterest)
		interest = maxInterest
	//---------------------------
	//VIEW FUNCTIONS

	//doorscan is now integrated into life and runs before all other procs
	var/mistake_chance = (100 - smartness) / 2
	spawn(0)
		for(var/dir in alldirs)
			var/turf/T = get_step(src, dir)
			if(T)
				for(var/obj/machinery/door/D in T.contents)
					if(!istype(D,/obj/machinery/door/poddoor) && D.density)
						spawn(0)
							if(istype(D,/obj/machinery/door/airlock))
								var/obj/machinery/door/airlock/AL = D
								if(!AL.CanAStarPass(RPID)) // only crack open doors we can't get through
									AL.p_open = 1
									AL.update_icon()
									AL.shock(src, mistake_chance)
									sleep(5)
									AL.unlock()
									if(prob(mistake_chance))
										if(!AL.wires.IsIndexCut(AIRLOCK_WIRE_DOOR_BOLTS))
											AL.wires.CutWireIndex(AIRLOCK_WIRE_DOOR_BOLTS)
									else
										if(AL.wires.IsIndexCut(AIRLOCK_WIRE_DOOR_BOLTS))
											AL.wires.CutWireIndex(AIRLOCK_WIRE_DOOR_BOLTS, 1)
									if(AL.locked)
										AL.wires.UpdatePulsed(AIRLOCK_WIRE_DOOR_BOLTS)
									if(!AL.wires.IsIndexCut(AIRLOCK_WIRE_MAIN_POWER1))
										AL.wires.CutWireIndex(AIRLOCK_WIRE_MAIN_POWER1)
									if(!AL.wires.IsIndexCut(AIRLOCK_WIRE_MAIN_POWER2))
										AL.wires.CutWireIndex(AIRLOCK_WIRE_MAIN_POWER2)
									if(prob(mistake_chance) && !AL.wires.IsIndexCut(AIRLOCK_WIRE_SAFETY))
										AL.wires.CutWireIndex(AIRLOCK_WIRE_SAFETY)
									if(prob(mistake_chance) && !AL.wires.IsIndexCut(AIRLOCK_WIRE_ELECTRIFY))
										AL.wires.CutWireIndex(AIRLOCK_WIRE_ELECTRIFY)
									sleep(5)
									AL.p_open = 0
									AL.update_icon()
							D.open()

	if(update_hands)
		if(l_hand || r_hand)
			if(l_hand)
				hand = 1
				main_hand = l_hand
				if(r_hand)
					other_hand = r_hand
			else if(r_hand)
				hand = 0
				main_hand = r_hand
				if(l_hand) //this technically shouldnt occur, but its a redundancy
					other_hand = l_hand
			update_icons()
		update_hands = 0

	if(grabbed_by.len > 0)
		for(var/obj/item/weapon/grab/G in grabbed_by)
			if(Adjacent(G))
				a_intent = "disarm"
				G.assailant.attack_hand(src)
				inactivity_period = 10

	if(buckled)
		resist()
		inactivity_period = 10

	//proc functions
	for(var/Proc in functions)
		if(!IsDeadOrIncap())
			callfunction(Proc)


	//target interaction stays hardcoded

	if(TARGET && (TARGET in blacklistItems)) // don't use blacklisted items
		TARGET = null

	if(TARGET && Adjacent(TARGET))
		doing |= SNPC_INTERACTING
		//--------DOORS
		if(istype(TARGET, /obj/machinery/door))
			var/obj/machinery/door/D = TARGET
			if(D.check_access(MYID) && !istype(D,/obj/machinery/door/poddoor))
				D.open()
				sleep(15)
				var/turf/T = get_step(get_step(D.loc, dir), dir) //recursion yo
				tryWalk(T)
		//THIEVING SKILLS
		insert_into_backpack() // dump random item into backpack to make space
		//---------ITEMS
		if(istype(TARGET, /obj/item))
			var/obj/item/I = TARGET
			if(I.anchored)
				TARGET = null
			else if(istype(TARGET, /obj/item/weapon))
				var/obj/item/weapon/W = TARGET
				if(W.force >= best_force || prob((SNPC_FUZZY_CHANCE_LOW + SNPC_FUZZY_CHANCE_HIGH) / 2) || favouredObjIn(list(W)))
					if(!l_hand || !r_hand)
						put_in_hands(W)
					else
						insert_into_backpack()
			else
				if(!l_hand || !r_hand)
					put_in_hands(TARGET)
				else
					insert_into_backpack()
		//---------FASHION
		if(istype(TARGET, /obj/item/clothing))
			var/obj/item/clothing/C = TARGET
			drop_item()
			spawn(5)
				take_to_slot(C,1)
				if(!equip_to_appropriate_slot(C))
					var/obj/item/I = get_item_by_slot(C)
					unEquip(I)
					spawn(5)
						equip_to_appropriate_slot(C)
			update_hands = 1
			if(MYPDA in loc)
				equip_to_appropriate_slot(MYPDA)
			if(MYID in loc)
				equip_to_appropriate_slot(MYID)
		//THIEVING SKILLS END
		//-------------TOUCH ME
		if(istype(TARGET, /obj/structure))
			var/obj/structure/STR = TARGET
			if(main_hand)
				var/obj/item/weapon/W = main_hand
				STR.attackby(W, src)
			else
				STR.attack_hand(src)
		interest += targetInterestShift
		doing = doing & ~SNPC_INTERACTING
		timeout = 0
		TARGET = null
	else
		if(TARGET)
			tryWalk(TARGET)
			timeout++

	if(doing == 0)
		interest--
	else
		interest++

	if(inactivity_period > 0)
		inactivity_period--

	if(interest <= 0 || timeout >= 10) // facilitate boredom functions
		TARGET = null
		doing = 0
		timeout = 0
		myPath = list()

	//this is boring, lets move
	if(!doing && !IsDeadOrIncap() && !TARGET)
		doing |= SNPC_TRAVEL
		if(!isTraitor || !traitorTarget || get_dist(src, traitorTarget) >= SNPC_MAX_RANGE_FIND || get_dist(src, traitorTarget) <= 1)
			var/choice = rand(1,50)
			switch(choice)
				if(1 to 30)
					//chance to chase an item
					TARGET = locate(/obj/item) in favouredObjIn(oview(SNPC_MIN_RANGE_FIND, src))
				if(31 to 40)
					TARGET = safepick(get_area_turfs(job2area(myjob)))
				if(41 to 45)
					TARGET = pick(target_filter(favouredObjIn(urange(SNPC_MAX_RANGE_FIND, src, 1))))
				if(46 to 50)
					TARGET = pick(target_filter(oview(SNPC_MIN_RANGE_FIND, src)))
		else
			TARGET = traitorTarget
		tryWalk(TARGET)
	LAST_TARGET = TARGET
	if(alternateProcessing)
		spawn(processTime)
			doProcess()

/mob/living/carbon/human/interactive/proc/favouredObjIn(list/inList)
	var/list/outList = list()
	for(var/i in inList)
		for(var/path in favoured_types)
			if(istype(i, path))
				outList += i
	if(!outList.len)
		outList = inList
	return outList

/mob/living/carbon/human/interactive/proc/callfunction(Proc)
	spawn(0)
		call(src, Proc)(src)

/mob/living/carbon/human/interactive/proc/tryWalk(turf/inTarget)
	if(restrictedJob) // we're a job that has to stay in our home
		if(!(get_turf(inTarget) in get_area_turfs(job2area(myjob))))
			TARGET = null
			return

	if(!IsDeadOrIncap())
		if(!walk2derpless(inTarget))
			timeout++
	else
		timeout++

/mob/living/carbon/human/interactive/proc/getGoodPath(target, maxtries=512)
	set background = 1
	var/turf/end = get_turf(target)

	var/turf/current = get_turf(src)

	var/list/path = list()
	var/tries = 0
	while(current != end && tries < maxtries)
		var/turf/shortest = current
		for(var/turf/T in view(current,1))
			var/foundDense = 0
			for(var/atom/A in T)
				if(A.density)
					foundDense = 1
			if(T.density == 0 && !foundDense)
				if(get_dist(T, target) < get_dist(shortest,target))
					shortest = T
				else
					tries++
			else
				tries++
		current = shortest
		path += shortest
	return path

/mob/living/carbon/human/interactive/proc/walk2derpless(target)
	set background = 1
	if(!target)
		return 0

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, SNPC_MAX_RANGE_FIND + 1, 250,1, id=Path_ID, simulated_only = 0)

	if(myPath)
		if(myPath.len > 0)
			doing = doing & ~SNPC_TRAVEL
			for(var/i = 0; i < maxStepsTick; ++i)
				if(!IsDeadOrIncap())
					if(myPath.len >= 1)
						walk_to(src,myPath[1],0,5)
						myPath -= myPath[1]
			return 1
	return 0

/mob/living/carbon/human/interactive/proc/job2area(target)
	var/datum/job/T = target
	switch(T.title)
		if("Civilian", "Paramedic")
			return /area/hallway/primary
		if("Captain", "Head of Personnel", "Blueshield")
			return /area/bridge
		if("Bartender")
			return /area/crew_quarters/bar
		if("Chef")
			return /area/crew_quarters/kitchen
		if("Station Engineer", "Chief Engineer", "Mechanic")
			return /area/engine
		if("Life Support Specialist")
			return /area/atmos
		if("Chief Medical Officer", "Medical Doctor", "Chemist", "Virologist", "Psychiatrist")
			return /area/medical
		if("Geneticist")
			return /area/medical/genetics
		if("Research Director", "Scientist")
			return /area/toxins
		if("Roboticist")
			return /area/assembly/robotics
		if("Head of Security", "Warden", "Security Officer", "Detective", "Security Pod Pilot", "Brig Physician", "Magistrate", "Internal Affairs Agent")
			return /area/security
		if("Botanist")
			return /area/hydroponics
		else
			return pick(/area/hallway, /area/crew_quarters)

/mob/living/carbon/human/interactive/proc/target_filter(target)
	var/list/filtered_targets = list(/area, /turf, /obj/machinery/door, /atom/movable/lighting_overlay, /obj/structure/cable, /obj/machinery/atmospherics, /obj/item/device/radio/intercom)
	var/list/L = target
	for(var/atom/A in target) // added a bunch of "junk" that clogs up the general find procs
		if(is_type_in_list(A,filtered_targets))
			L -= A
	return L

/mob/living/carbon/human/interactive/proc/shouldModulePass() // returns 1 if the npc is in anything "primary"
	if(doing & (SNPC_FIGHTING | SNPC_SPECIAL))
		return 1
	if(retal)
		return 1
	return 0

/mob/living/carbon/human/interactive/proc/getAllContents()
	var/list/allContents = list()
	for(var/atom/A in contents)
		allContents += A
		if(A.contents.len)
			for(var/atom/B in A)
				allContents += B
	return allContents

/mob/living/carbon/human/interactive/proc/enforceHome()
	var/list/validHome = get_area_turfs(job2area(myjob))

	if(TARGET)
		var/atom/tcheck = TARGET
		if(tcheck)
			if(!(get_turf(tcheck) in validHome))
				TARGET = null
				return 1

	if(!(get_turf(src) in validHome))
		tryWalk(pick(get_area_turfs(job2area(myjob))))
		return 1
	return 0

/mob/living/carbon/human/interactive/proc/npcDrop(obj/item/A, blacklist = 0)
	if(blacklist)
		blacklistItems += A
	unEquip(A)
	enforce_hands()
	update_icons()

/mob/living/carbon/human/interactive/proc/compareFaction(list/targetFactions)
	var/hasSame = 0

	for(var/A in targetFactions)
		if(A in faction)
			hasSame = 1

	return hasSame

/mob/living/carbon/human/interactive/proc/nearbyscan(obj)
	nearby = list()
	for(var/mob/living/M in view(4,src))
		if(M != src)
			nearby += M

/mob/living/carbon/human/interactive/rename_character(oldname, newname)
	if(!..())
		return 0

	if(oldname)
		if(MYID)
			MYID.registered_name = newname
			MYID.name = "[newname]'s ID Card ([MYID.assignment])"
		if(RPID)
			RPID.registered_name = MYID.registered_name
			RPID.name = MYID.name
	return 1