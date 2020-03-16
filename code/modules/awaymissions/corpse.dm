//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/mob_spawn
	name = "Unknown"
	density = TRUE
	anchored = TRUE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	var/mob_type = null
	var/mob_name = "unidentified entity"
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
	var/banType = ROLE_GHOST
	var/ghost_usable = TRUE
	var/offstation_role = TRUE // If set to true, the role of the user's mind will be set to offstation

/obj/effect/mob_spawn/attack_ghost(mob/user)
	var/mob/dead/observer/O = user
	if(SSticker.current_state != GAME_STATE_PLAYING || !loc || !ghost_usable)
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(jobban_isbanned(user, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(cannotPossess(user))
		to_chat(user, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(!O.can_reenter_corpse)
		to_chat(user, "<span class='warning'>You have forfeited the right to respawn.</span>")
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No")
		return
	if(!species_prompt())
		return
	if(!loc || !uses || QDELETED(src) || QDELETED(user))
		to_chat(user, "<span class='warning'>The [name] is no longer usable!</span>")
		return
	log_game("[user.ckey] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/mob_spawn/Initialize(mapload)
	. = ..()
	if(instant || roundstart)	//at some point we should probably re-introduce the (ticker && ticker.current_state > GAME_STATE_SETTING_UP) portion of this check, but for now it was preventing the corpses from spawning at roundstart and resulting in ghost role spawners that made dead bodies.
		create()
	else if(ghost_usable)
		GLOB.poi_list |= src
		LAZYADD(GLOB.mob_spawners[name], src)

/obj/effect/mob_spawn/Destroy()
	GLOB.poi_list -= src
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= name
	return ..()

/obj/effect/mob_spawn/proc/species_prompt()
	return TRUE

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey, flavour = TRUE, name)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	var/mob/living/carbon/human/H = M
	if(H && !H.dna)
		H.Initialize(null)
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
		M.death() //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	M.adjustFireLoss(burn_damage)
	M.color = mob_color
	equip(M, TRUE)

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
		M.mind.offstation_role = offstation_role
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
	var/mob_species = null		//Set species
	var/allow_species_pick = FALSE
	var/list/pickable_species = list("Human", "Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona")
	var/datum/outfit/outfit = /datum/outfit	//If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	var/disable_sensors = TRUE
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
	var/pda = -1
	var/backpack_contents = -1
	var/suit_store = -1

	var/hair_style
	var/facial_hair_style
	var/skin_tone


/obj/effect/mob_spawn/human/Initialize()
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	if(!mob_name)
		mob_name = id_job
	return ..()

/obj/effect/mob_spawn/human/species_prompt()
	if(allow_species_pick)
		var/selected_species = input("Select a species", "Species Selection") as null|anything in pickable_species
		if(!selected_species)
			return	TRUE	// You didn't pick, so just continue on with the spawning process as a human
		var/datum/species/S = GLOB.all_species[selected_species]
		mob_species = S.type
	return TRUE

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
	var/obj/item/organ/external/head/D = H.get_organ("head")
	if(istype(D))
		if(hair_style)
			D.h_style = hair_style
		else
			D.h_style = random_hair_style(gender, D.dna.species.name)
		D.hair_colour = rand_hex_color()
		if(facial_hair_style)
			D.f_style = facial_hair_style
		else
			D.f_style = random_facial_hair_style(gender, D.dna.species.name)
		D.facial_colour = rand_hex_color()
	if(skin_tone)
		H.change_skin_tone(skin_tone)
	else
		H.change_skin_tone(random_skin_tone())
		H.change_skin_color(rand_hex_color())
	H.update_hair()
	H.update_fhair()
	H.update_body()
	H.update_dna()
	H.regenerate_icons()
	if(outfit)
		var/static/list/slots = list("uniform", "r_hand", "l_hand", "suit", "shoes", "gloves", "ears", "glasses", "mask", "head", "belt", "r_pocket", "l_pocket", "back", "id", "neck", "backpack_contents", "suit_store")
		for(var/slot in slots)
			var/T = vars[slot]
			if(!isnum(T))
				outfit.vars[slot] = T
		H.equipOutfit(outfit)
		var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)
		for(var/del_type in del_types)
			var/obj/item/I = locate(del_type) in H
			qdel(I)

		if(disable_pda)
			// We don't want corpse PDAs to show up in the messenger list.
			var/obj/item/pda/PDA = locate(/obj/item/pda) in H
			if(PDA)
				var/datum/data/pda/app/messenger/M = PDA.find_program(/datum/data/pda/app/messenger)
				M.toff = 1
		if(disable_sensors)
			// Using crew monitors to find corpses while creative makes finding certain ruins too easy.
			var/obj/item/clothing/under/C = H.w_uniform
			if(istype(C))
				C.sensor_mode = SUIT_SENSOR_OFF

	var/obj/item/card/id/W = H.wear_id
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
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	death = FALSE
	roundstart = FALSE //you could use these for alive fake humans on roundstart but this is more common scenario


//Non-human spawners

/obj/effect/mob_spawn/mouse
	name = "sleeper"
	mob_name = "space mouse"
	mob_type = 	/mob/living/simple_animal/mouse
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "Squeak!"

/obj/effect/mob_spawn/cow
	name = "sleeper"
	mob_name = "space cow"
	mob_type = 	/mob/living/simple_animal/cow
	death = FALSE
	roundstart = FALSE
	mob_gender = FEMALE
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "Moo!"


///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/corpse/assistant
	name = "Assistant"
	mob_name = "Assistant"
	id_job = "Assistant"
	outfit = /datum/outfit/job/assistant

/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection
	disease = /datum/disease/beesease

/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection
	disease = /datum/disease/brainrot

/obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection
	disease = /datum/disease/fluspanish

/obj/effect/mob_spawn/human/cook
	name = "Cook"
	mob_name = "Chef"
	id_job = "Chef"
	outfit = /datum/outfit/job/chef

/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	mob_name = "Medical Doctor"
	id_job = "Medical Doctor"
	outfit = /datum/outfit/job/doctor

/obj/effect/mob_spawn/human/doctor/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "sleeper"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "<span class='big bold'>You are a space doctor!</span>"
	assignedrole = "Space Doctor"

/obj/effect/mob_spawn/human/doctor/alive/equip(mob/living/carbon/human/H)
	..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/I = locate(del_type) in H
		qdel(I)

/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	mob_name = "Engineer"
	id_job = "Engineer"
	outfit = /datum/outfit/job/engineer

/obj/effect/mob_spawn/human/engineer/hardsuit
	outfit = /datum/outfit/job/engineer/suit

/datum/outfit/job/engineer/suit
	name = "Station Engineer"

	uniform = /obj/item/clothing/under/rank/engineer
	belt = /obj/item/storage/belt/utility/full
	suit = /obj/item/clothing/suit/space/hardsuit/engine
	shoes = /obj/item/clothing/shoes/workboots
	mask = /obj/item/clothing/mask/breath
	id = /obj/item/card/id/engineering
	l_pocket = /obj/item/t_scanner

	backpack = /obj/item/storage/backpack/industrial


/obj/effect/mob_spawn/human/clown
	name = "Clown"
	mob_name = "Clown"
	id_job = "Clown"
	outfit = /datum/outfit/job/clown

/obj/effect/mob_spawn/human/clown/Initialize()
	mob_name = pick(GLOB.clown_names)
	return ..()

/obj/effect/mob_spawn/human/corpse/clownmili
	name = "Clown Soldier"
	outfit = /datum/outfit/clownsoldier

/obj/effect/mob_spawn/human/corpse/clownmili/Initialize()
	mob_name = "Officer [pick(GLOB.clown_names)]"
	return ..()

/obj/effect/mob_spawn/human/corpse/clownoff
	name = "Clown Officer"
	outfit = /datum/outfit/clownofficer

/obj/effect/mob_spawn/human/corpse/clownoff/Initialize()
	mob_name = "Honk Specialist [pick(GLOB.clown_names)]"
	return ..()


/datum/outfit/clownsoldier
	name = "Clown Soldier"
	uniform = /obj/item/clothing/under/soldieruniform
	suit = /obj/item/clothing/suit/soldiercoat
	shoes = /obj/item/clothing/shoes/clown_shoes
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	head = /obj/item/clothing/head/stalhelm

/datum/outfit/clownofficer
	name = "Clown Officer"
	uniform = /obj/item/clothing/under/officeruniform
	suit = /obj/item/clothing/suit/officercoat
	shoes = /obj/item/clothing/shoes/clown_shoes
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	head = /obj/item/clothing/head/naziofficer

/obj/effect/mob_spawn/human/mime
	name = "Mime"
	mob_name = "Mime"
	id_job = "Mime"
	outfit = /datum/outfit/job/mime

/obj/effect/mob_spawn/human/mime/Initialize()
	mob_name = pick(GLOB.mime_names)
	return ..()

/obj/effect/mob_spawn/human/scientist
	name = "Scientist"
	mob_name = "Scientist"
	id_job = "Scientist"
	outfit = /datum/outfit/job/scientist

/obj/effect/mob_spawn/human/miner
	name = "Shaft Miner"
	mob_name = "Shaft Miner"
	id_job = "Shaft Miner"
	outfit = /datum/outfit/job/mining/suit

/datum/outfit/job/mining/suit
	name = "Shaft Miner"
	suit = /obj/item/clothing/suit/space/hardsuit/mining
	uniform = /obj/item/clothing/under/rank/miner
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_cargo/mining
	id = /obj/item/card/id/supply
	l_pocket = /obj/item/reagent_containers/food/pill/patch/styptic
	r_pocket = /obj/item/flashlight/seclite

/obj/effect/mob_spawn/human/miner/explorer
	outfit = /datum/outfit/job/mining/equipped

/obj/effect/mob_spawn/human/bartender
	name = "Space Bartender"
	mob_name = "Bartender"
	id_job = "Bartender"
	id_access_list = list(access_bar)
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/human/bartender/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	allow_species_pick = TRUE
	name = "bartender sleeper"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "<span class='big bold'>You are a space bartender!</span><b> Time to mix drinks and change lives.</b>"
	assignedrole = "Space Bartender"

/obj/effect/mob_spawn/human/beach/alive/lifeguard
	flavour_text = "<span class='big bold'>You're a spunky lifeguard!</span><b> It's up to you to make sure nobody drowns or gets eaten by sharks and stuff.</b>"
	mob_gender = "female"
	name = "lifeguard sleeper"
	id_job = "Lifeguard"
	uniform = /obj/item/clothing/under/shorts/red

/datum/outfit/spacebartender
	name = "Space Bartender"
	uniform = /obj/item/clothing/under/rank/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/bandolier/full
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	id = /obj/item/card/id


/obj/effect/mob_spawn/human/beach
	outfit = /datum/outfit/beachbum

/obj/effect/mob_spawn/human/beach/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	allow_species_pick = TRUE
	mob_name = "Beach Bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/cryogenic2.dmi'
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
	mob_name = "Bridge Officer"
	id_job = "Bridge Officer"
	id_access = "Captain"
	outfit = /datum/outfit/nanotrasenbridgeofficercorpse

/datum/outfit/nanotrasenbridgeofficercorpse
	name = "Bridge Officer Corpse"
	l_ear = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom_officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id


/obj/effect/mob_spawn/human/commander
	name = "Commander"
	mob_name = "Commander"
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
	id = /obj/item/card/id/centcom



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
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
