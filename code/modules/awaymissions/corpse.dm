//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/mob_spawn
	name = "Unknown"
	var/mob_type = null
	var/mob_name = ""
	var/mob_gender = null
	var/death = TRUE //Kill the mob
	var/roundstart = TRUE //fires on initialize
	var/instant = FALSE	//fires on New
	var/flavour_text = "The mapper forgot to set this!"
	var/faction = null
	var/permanent = FALSE	//If true, the spawner will not disappear upon running out of uses.
	var/random = FALSE		//Don't set a name or gender, just go random
	var/objectives = null
	var/uses = 1			//how many times can we spawn from it. set to -1 for infinite.
	var/brute_damage = 0
	var/oxy_damage = 0
	var/burn_damage = 0
	var/datum/disease/disease = null //Do they start with a pre-spawned disease?
	var/mob_color //Change the mob's color
	var/assignedrole
	density = TRUE
	anchored = TRUE
	var/banType = "lavaland"


/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING || !loc)
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(jobban_isbanned(user, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No" || !loc)
		return
	log_game("[user.ckey] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/mob_spawn/New()
	. = ..()
	if(ticker && ticker.current_state > GAME_STATE_PLAYING)
		create()
	else
		poi_list |= src
		LAZYADD(mob_spawners[name], src)

/obj/effect/mob_spawn/Destroy()
	poi_list -= src
	var/list/spawners = mob_spawners[name]
	LAZYREMOVE(spawners, src)
	return ..()

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey, flavour = TRUE, name)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random)
		M.real_name = mob_name ? mob_name : M.name
		if(!mob_gender)
			mob_gender = pick(MALE, FEMALE)
		M.gender = mob_gender
	if(faction)
		M.faction = list(faction)
	if(disease)
		M.ForceContractDisease(new disease)
	if(death)
		M.death(1) //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	M.adjustFireLoss(burn_damage)
	M.color = mob_color
	equip(M)

	if(ckey)
		M.ckey = ckey
		if(flavour)
			to_chat(M, "[flavour_text]")
		var/datum/mind/MM = M.mind
		if(objectives)
			for(var/objective in objectives)
				MM.objectives += new/datum/objective(objective)
		if(assignedrole)
			M.mind.assigned_role = assignedrole
		special(M, name)
		MM.name = M.real_name
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null		//Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/datum/outfit/outfit = /datum/outfit	//If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	//All of these only affect the ID that the outfit has placed in the ID slot
	var/id_job = null			//Such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null		//This is for access. See access.dm for which jobs give what access. Use "Captain" if you want it to be all access.
	var/id_access_list = null	//Allows you to manually add access to an ID card.
	assignedrole = "Ghost Role"

	var/husk = null
	//these vars are for lazy mappers to override parts of the outfit
	//these cannot be null by default, or mappers cannot set them to null if they want nothing in that slot
	var/uniform = -1
	var/r_hand = -1
	var/l_hand = -1
	var/suit = -1
	var/shoes = -1
	var/gloves = -1
	var/ears = -1
	var/glasses = -1
	var/mask = -1
	var/head = -1
	var/belt = -1
	var/r_pocket = -1
	var/l_pocket = -1
	var/back = -1
	var/id = -1
	var/neck = -1
	var/backpack_contents = -1
	var/suit_store = -1

/obj/effect/mob_spawn/human/New()
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	return ..()

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.ChangeToHusk()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		H.mutations.Remove(HUSK)
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	if(outfit)
		var/static/list/slots = list("uniform", "r_hand", "l_hand", "suit", "shoes", "gloves", "ears", "glasses", "mask", "head", "belt", "r_pocket", "l_pocket", "back", "id", "neck", "backpack_contents", "suit_store")
		for(var/slot in slots)
			var/T = vars[slot]
			if(!isnum(T))
				outfit.vars[slot] = T
		H.equipOutfit(outfit)
		//if(disable_pda) //FETHAS FIX THIS
			// We don't want corpse PDAs to show up in the messenger list.
		//	var/obj/item/device/pda/PDA = locate(/obj/item/device/pda) in H
		//	if(H.PDA)
		//		H.PDA.toff = 1
	var/obj/item/weapon/card/id/W = H.wear_id
	if(W)
		if(id_access)
			for(var/jobtype in typesof(/datum/job))
				var/datum/job/J = new jobtype
				if(J.title == id_access)
					W.access = J.get_access()
					break
		if(id_access_list)
			if(!islist(W.access))
				W.access = list()
			W.access |= id_access_list
		if(id_job)
			W.assignment = id_job
		W.registered_name = H.real_name
		W.update_label()

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000

/obj/effect/mob_spawn/human/alive
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	death = FALSE
	roundstart = FALSE //you could use these for alive fake humans on roundstart but this is more common scenario


//Non-human spawners

/obj/effect/mob_spawn/AICorpse/create() //Creates a corrupted AI
	var/A = locate(/mob/living/silicon/ai) in loc
	if(A)
		return
	var/mob/living/silicon/ai/M = new(loc) //spawn new AI at landmark as var M
	M.name = src.name
	M.real_name = src.name
	//M.aiPDA.toff = 1 //turns the AI's PDA messenger off, stopping it showing up on player PDAs
	M.death() //call the AI's death proc
	qdel(src)


/obj/effect/mob_spawn/human/facehugger/create() //Creates a squashed facehugger
	var/obj/item/clothing/mask/facehugger/O = new(src.loc) //variable O is a new facehugger at the location of the landmark
	O.name = src.name
	O.Die() //call the facehugger's death proc
	qdel(src)

/obj/effect/mob_spawn/mouse
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/mouse
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/cow
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/cow
	death = FALSE
	roundstart = FALSE
	mob_gender = FEMALE
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/corpse/assistant
	name = "Assistant"
	outfit = /datum/outfit/job/assistant

/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection
	disease = /datum/disease/beesease

/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection
	disease = /datum/disease/brainrot

/obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection
	disease = /datum/disease/fluspanish

/obj/effect/mob_spawn/human/cook
	name = "Cook"
	outfit = /datum/outfit/job/chef

/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	outfit = /datum/outfit/job/doctor

/obj/effect/mob_spawn/human/doctor/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space doctor!"
	assignedrole = "Space Doctor"

/obj/effect/mob_spawn/human/doctor/alive/equip(mob/living/carbon/human/H)
	..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/device/pda, /obj/item/device/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/I = locate(del_type) in H
		qdel(I)

/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	outfit = /datum/outfit/job/engineer

/obj/effect/mob_spawn/human/engineer/hardsuit
	outfit = /datum/outfit/job/engineer/suit

/datum/outfit/job/engineer/suit
	name = "Station Engineer"

	uniform = /obj/item/clothing/under/rank/engineer
	belt = /obj/item/weapon/storage/belt/utility/full
	suit = /obj/item/clothing/suit/space/hardsuit
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/helmet/space/hardsuit
	mask = /obj/item/clothing/mask/breath
	id = /obj/item/weapon/card/id/engineering
	l_pocket = /obj/item/device/t_scanner

	backpack = /obj/item/weapon/storage/backpack/industrial


/obj/effect/mob_spawn/human/clown
	name = "Clown"
	outfit = /datum/outfit/job/clown

/obj/effect/mob_spawn/human/corpse/clownmili/New()
	if(prob(10))
		name = "Clown Officer"
		outfit = /datum/outfit/clownofficer
	else
		name = "Clown Soldier"
		outfit = /datum/outfit/clownsoldier

/datum/outfit/clownsoldier
		uniform = /obj/item/clothing/under/soldieruniform
		suit = /obj/item/clothing/suit/soldiercoat
		shoes = /obj/item/clothing/shoes/clown_shoes
		l_ear = /obj/item/device/radio/headset
		mask = /obj/item/clothing/mask/gas/clown_hat
		l_pocket = /obj/item/weapon/bikehorn
		back = /obj/item/weapon/storage/backpack/clown
		head = /obj/item/clothing/head/stalhelm

/datum/outfit/clownofficer
		uniform = /obj/item/clothing/under/officeruniform
		suit = /obj/item/clothing/suit/officercoat
		shoes = /obj/item/clothing/shoes/clown_shoes
		l_ear = /obj/item/device/radio/headset
		mask = /obj/item/clothing/mask/gas/clown_hat
		l_pocket = /obj/item/weapon/bikehorn
		back = /obj/item/weapon/storage/backpack/clown
		head = /obj/item/clothing/head/naziofficer

/obj/effect/mob_spawn/human/mime
	name = "Mime"
	outfit = /datum/outfit/job/mime

/obj/effect/mob_spawn/human/scientist
	name = "Scientist"
	outfit = /datum/outfit/job/scientist

/obj/effect/mob_spawn/human/miner
	name = "Shaft Miner"
	outfit = /datum/outfit/job/mining

/obj/effect/mob_spawn/human/bartender
	name = "Space Bartender"
	id_job = "Bartender"
	id_access_list = list(access_bar)
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/human/bartender/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "bartender sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space bartender!"
	assignedrole = "Space Bartender"

/datum/outfit/spacebartender
	name = "Space Bartender"
	uniform = /obj/item/clothing/under/rank/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/weapon/storage/belt/bandolier/full
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	id = /obj/item/weapon/card/id


/obj/effect/mob_spawn/human/beach
	outfit = /datum/outfit/beachbum

/obj/effect/mob_spawn/human/beach/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	mob_name = "Beach Bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a beach bum!"
	assignedrole = "Beach Bum"

/datum/outfit/beachbum
	name = "Beach Bum"
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/shorts/red

/////////////////Spooky Undead//////////////////////

/obj/effect/mob_spawn/human/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton
	mob_gender = NEUTER

/obj/effect/mob_spawn/human/skeleton/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	flavour_text = "By unknown powers, your skeletal remains have been reanimated! Walk this mortal plain and terrorize all living adventurers who dare cross your path."
	assignedrole = "Skeleton"

/////////////////Officers//////////////////////

/obj/effect/mob_spawn/human/bridgeofficer
	name = "Bridge Officer"
	id_job = "Bridge Officer"
	id_access = "Captain"
	outfit = /datum/outfit/nanotrasenbridgeofficercorpse

/datum/outfit/nanotrasenbridgeofficercorpse
	name = "Bridge Officer Corpse"
	l_ear = /obj/item/device/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/weapon/card/id


/obj/effect/mob_spawn/human/commander
	name = "Commander"
	id_job = "Commander"
	id_access = "Captain"
	outfit = /datum/outfit/nanotrasencommandercorpse

/datum/outfit/nanotrasencommandercorpse
	name = "Commander Corpse"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	gloves =  /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/officer
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/weapon/card/id/centcom



/obj/effect/mob_spawn/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat

//For ghost bar.
/obj/effect/mob_spawn/human/alive/space_bar_patron
	name = "Bar cryogenics"
	mob_name = "Bar patron"
	random = TRUE
	permanent = TRUE
	uses = -1
	outfit = /datum/outfit/spacebartender
	assignedrole = "Space Bar Patron"

/obj/effect/mob_spawn/human/alive/space_bar_patron/attack_hand(mob/user)
	var/despawn = alert("Return to cryosleep? (Warning, Your mob will be deleted!)",,"Yes","No")
	if(despawn == "No" || !loc || !Adjacent(user))
		return
	user.visible_message("<span class='notice'>[user.name] climbs back into cryosleep...</span>")
	qdel(user)

/datum/outfit/cryobartender
	name = "Cryogenic Bartender"
	uniform = /obj/item/clothing/under/rank/bartender
	back = /obj/item/weapon/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent