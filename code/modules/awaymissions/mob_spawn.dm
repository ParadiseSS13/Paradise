//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

// To do: Allow customizing the bodies appearance (they're all bald and white right now).

/// this mob spawn creates the corpse instantly
#define CORPSE_INSTANT 1
/// this mob spawn creates the corpse during GAME_STATE_PLAYING
#define CORPSE_ROUNDSTART 2

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
	var/flavour_text = ""	//flavour/fluff about the role, optional.
	var/description = "A description for this has not been set. This is either an oversight or an admin-spawned spawner not in normal use."	//intended as OOC info about the role
	var/important_info = ""	//important info such as rules that apply to you, etc. Optional.
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
	var/death_cooldown = 0 // How long you have to wait after dying before using it again, in deciseconds. People that join as observers are not included.
	///If antagbanned people are prevented from using it, only false for the ghost bar spawner.
	var/restrict_antagban = TRUE

/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(!valid_to_spawn(user))
		return
	var/ghost_role = tgui_alert(user, "Become [mob_name]? (Warning, You can no longer be cloned!)", "Respawn", list("Yes", "No"))
	if(ghost_role != "Yes")
		return
	if(!species_prompt(user))
		return
	if(!loc || !uses && !permanent || QDELETED(src) || QDELETED(user))
		to_chat(user, "<span class='warning'>The [name] is no longer usable!</span>")
		return
	create(ckey = user.ckey, user = user)

	return TRUE

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

/obj/effect/mob_spawn/proc/valid_to_spawn(mob/user)
	if(SSticker.current_state != GAME_STATE_PLAYING || !loc || !ghost_usable)
		return FALSE
	if(!uses && !permanent)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return FALSE
	if((jobban_isbanned(user, banType) || (restrict_antagban && jobban_isbanned(user, ROLE_SYNDICATE))))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return FALSE
	if(!HAS_TRAIT(user, TRAIT_RESPAWNABLE))
		to_chat(user, "<span class='warning'>You currently do not have respawnability!</span>")
		return FALSE
	if(isobserver(user))
		var/mob/dead/observer/O = user
		if(!O.check_ahud_rejoin_eligibility())
			to_chat(user, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return FALSE
	if(time_check(user))
		return FALSE
	return TRUE

/obj/effect/mob_spawn/proc/time_check(mob/user)
	var/deathtime = world.time - user.timeofdeath
	var/joinedasobserver = FALSE
	if(isobserver(user))
		var/mob/dead/observer/G = user
		if(G.started_as_observer)
			joinedasobserver = TRUE

	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "minute"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes == 1)
		pluralcheck = " [deathtimeminutes] minute and"
	else if(deathtimeminutes > 1)
		pluralcheck = " [deathtimeminutes] minutes and"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10, 1)

	if(deathtime <= death_cooldown && !joinedasobserver)
		to_chat(user, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		to_chat(user, "<span class='warning'>You must wait [death_cooldown / 600] minutes to respawn!</span>")
		return TRUE
	return FALSE

/obj/effect/mob_spawn/proc/create(ckey, flavour = TRUE, name, mob/user = usr)
	log_game("[ckey] became [mob_name]")
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
				M.mind.add_mind_objective(new /datum/objective(objective))
		if(assignedrole)
			M.mind.assigned_role = assignedrole
		M.mind.offstation_role = offstation_role
		special(M, name)
		MM.name = M.real_name
	else
		special(M)
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)

	return M

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null		//Set species
	var/allow_species_pick = FALSE
	var/list/pickable_species = list("Human", "Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona", "Nian")
	var/datum/outfit/outfit = /datum/outfit	//If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	var/disable_sensors = TRUE
	//All of these only affect the ID that the outfit has placed in the ID slot
	var/id_job = null			//Such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null		//This is for access. See access.dm for which jobs give what access. Use "Captain" if you want it to be all access.
	var/id_access_list = null	//Allows you to manually add access to an ID card.
	assignedrole = "Ghost Role"

	var/husk = null
	/// Should we fully dna-scramble these humans?
	var/dna_scrambled = FALSE
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

	var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)

/obj/effect/mob_spawn/human/Initialize()
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	if(!mob_name)
		mob_name = id_job
	return ..()

/obj/effect/mob_spawn/human/species_prompt(mob/user)
	if(allow_species_pick)
		var/selected_species = tgui_input_list(user, "Select a species", "Species Selection", pickable_species)
		if(!selected_species)
			return	TRUE	// You didn't pick, so just continue on with the spawning process as a human
		var/datum/species/S = GLOB.all_species[selected_species]
		mob_species = S.type
	return TRUE

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(random)
		H.real_name = random_name(H.gender, H.dna.species)

	if(husk)
		H.Drain()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		H.cure_husk()
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
		H.s_tone = skin_tone
	else
		H.s_tone = random_skin_tone()
		H.skin_colour = rand_hex_color()

	if(dna_scrambled)
		H.get_dna_scrambled()

	H.update_body(rebuild_base = TRUE)

	if(outfit)
		var/static/list/slots = list("uniform", "r_hand", "l_hand", "suit", "shoes", "gloves", "ears", "glasses", "mask", "head", "belt", "r_pocket", "l_pocket", "back", "id", "neck", "backpack_contents", "suit_store")
		for(var/slot in slots)
			var/T = vars[slot]
			if(!isnum(T))
				outfit.vars[slot] = T
		H.equipOutfit(outfit)
		for(var/del_type in del_types)
			var/obj/item/I = locate(del_type) in H
			if(I)
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


//////////Alive ones, used as "core" for ghost roles now and in future.//////////

//Space(?) Bar Patron (ghost role).
/obj/effect/mob_spawn/human/alive/space_bar_patron
	name = "Bar cryogenics"
	mob_name = "Bar patron"
	random = TRUE
	permanent = TRUE
	uses = -1
	outfit = /datum/outfit/spacebartender
	assignedrole = "Space Bar Patron"

/obj/effect/mob_spawn/human/alive/space_bar_patron/attack_hand(mob/user)
	var/despawn = tgui_alert(user, "Return to cryosleep? (Warning, Your mob will be deleted!)", "Leave Bar", list("Yes", "No"))
	if(despawn != "Yes" || !loc || !Adjacent(user))
		return
	user.visible_message("<span class='notice'>[user.name] climbs back into cryosleep...</span>")
	qdel(user)

/datum/outfit/cryobartender
	name = "Cryogenic Bartender"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/reagent

//Lavaland Animal Doctor (ghost role).
/obj/effect/mob_spawn/human/alive/doctor
	random = TRUE
	name = "sleeper"
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space doctor!"
	assignedrole = "Space Doctor"
	outfit = /datum/outfit/job/doctor

/obj/effect/mob_spawn/human/alive/doctor/equip(mob/living/carbon/human/H)
	..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/I = locate(del_type) in H
		qdel(I)

//Spooky Scary Skeleton...
/obj/effect/mob_spawn/human/alive/skeleton
	icon = 'icons/mob/simple_human.dmi'
	mob_species = /datum/species/skeleton
	icon_state = "skeleton"
	description = "Be a spooky scary skeleton."	//not mapped in anywhere so admin spawner, who knows what they'll use this for.
	flavour_text = "By unknown powers, your skeletal remains have been reanimated! Walk this mortal plain and terrorize all living adventurers who dare cross your path."
	assignedrole = "Skeleton"

/obj/effect/mob_spawn/human/corpse/skeleton/security_officer
	outfit = /datum/outfit/job/officer
	id_access = "Assistant" //no brig access for explorers

/obj/effect/mob_spawn/human/corpse/skeleton/prisoner
	uniform = /obj/item/clothing/under/color/orange/prison
	shoes = /obj/item/clothing/shoes/orange

/obj/effect/mob_spawn/human/corpse/skeleton/prisoner/equip(mob/living/carbon/human/prisoner) //put cuffs on the corpse
	. = ..()
	var/obj/item/restraints/handcuffs/cuffs = new(prisoner)
	prisoner.handcuffed = cuffs
	prisoner.update_handcuffed()

//////////Corpses, they can be used for "decoration" purpose.//////////

//Default Abductor corpse.
/obj/effect/mob_spawn/human/corpse/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat

//Assistant Corpse
/obj/effect/mob_spawn/human/corpse/assistant
	name = "Assistant"
	mob_name = "Assistant"
	id_job = "Assistant"
	outfit = /datum/outfit/job/assistant

//Yes you guess it, they have disease in corpse.
/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection
	disease = /datum/disease/beesease

/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection
	disease = /datum/disease/brainrot

/obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection
	disease = /datum/disease/fluspanish

//Bartender corpse.
/obj/effect/mob_spawn/human/corpse/bartender
	name = "Space Bartender"
	mob_name = "Bartender"
	id_job = "Bartender"
	id_access_list = list(ACCESS_BAR)
	outfit = /datum/outfit/spacebartender

/datum/outfit/spacebartender
	name = "Space Bartender"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/storage/belt/bandolier/full
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	id = /obj/item/card/id

//Lavaland Beach Turist (?) corpse.
/obj/effect/mob_spawn/human/corpse/beach
	outfit = /datum/outfit/beachbum

/datum/outfit/beachbum
	name = "Beach Bum"
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/pants/shorts/red

//Bridge Officer corpse.
/obj/effect/mob_spawn/human/corpse/bridgeofficer
	name = "Bridge Officer"
	mob_name = "Bridge Officer"
	id_job = "Bridge Officer"
	id_access = "Captain"
	outfit = /datum/outfit/nanotrasenbridgeofficercorpse

/datum/outfit/nanotrasenbridgeofficercorpse
	name = "Bridge Officer Corpse"
	l_ear = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id

//Clown corpse.
/obj/effect/mob_spawn/human/corpse/clown
	name = "Clown"
	mob_name = "Clown"
	id_job = "Clown"
	outfit = /datum/outfit/job/clown

/obj/effect/mob_spawn/human/corpse/clown/Initialize()
	mob_name = pick(GLOB.clown_names)
	return ..()

//Clown Officer corpse.
/obj/effect/mob_spawn/human/corpse/clown/officer
	name = "Clown Officer"
	outfit = /datum/outfit/clownofficer

/obj/effect/mob_spawn/human/corpse/clown/officer/Initialize()
	mob_name = "Honk Specialist [pick(GLOB.clown_names)]"
	return ..()
/datum/outfit/clownofficer
	name = "Clown Officer"
	uniform = /obj/item/clothing/under/costume/officeruniform
	suit = /obj/item/clothing/suit/officercoat
	shoes = /obj/item/clothing/shoes/clown_shoes
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	head = /obj/item/clothing/head/armyofficer

//Clown Soldier corpse
/obj/effect/mob_spawn/human/corpse/clown/soldier
	name = "Clown Soldier"
	outfit = /datum/outfit/clownsoldier

/obj/effect/mob_spawn/human/corpse/clown/soldier/Initialize()
	mob_name = "Officer [pick(GLOB.clown_names)]"
	return ..()

/datum/outfit/clownsoldier
	name = "Clown Soldier"
	uniform = /obj/item/clothing/under/costume/soldieruniform
	suit = /obj/item/clothing/suit/soldiercoat
	shoes = /obj/item/clothing/shoes/clown_shoes
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	head = /obj/item/clothing/head/stalhelm

//Commander (?) corpse.
/obj/effect/mob_spawn/human/corpse/commander
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

//Chef corpse
/obj/effect/mob_spawn/human/corpse/cook
	name = "Cook"
	mob_name = "Chef"
	id_job = "Chef"
	outfit = /datum/outfit/job/chef

//Medical Doctor corpse.
/obj/effect/mob_spawn/human/corpse/doctor
	name = "Doctor"
	mob_name = "Medical Doctor"
	id_job = "Medical Doctor"
	outfit = /datum/outfit/job/doctor

//Engineer corpse.
/obj/effect/mob_spawn/human/corpse/engineer
	name = "Engineer"
	mob_name = "Engineer"
	id_job = "Engineer"
	outfit = /datum/outfit/job/engineer

//Mime corpse.
/obj/effect/mob_spawn/human/corpse/mime
	name = "Mime"
	mob_name = "Mime"
	id_job = "Mime"
	outfit = /datum/outfit/job/mime

/obj/effect/mob_spawn/human/corpse/mime/Initialize()
	mob_name = pick(GLOB.mime_names)
	return ..()

//Normal Miner corpse.
/obj/effect/mob_spawn/human/corpse/miner
	name = "Shaft Miner"
	mob_name = "Shaft Miner"
	id_job = "Shaft Miner"
	outfit = /datum/outfit/job/mining/equipped

//Hardsuit Miner corpse.
/obj/effect/mob_spawn/human/corpse/miner/explorer
	outfit = /datum/outfit/job/mining/suit

/datum/outfit/job/mining/suit
	name = "Shaft Miner"
	back = /obj/item/mod/control/pre_equipped/mining/asteroid
	uniform = /obj/item/clothing/under/rank/cargo/miner
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/workboots
	l_ear = /obj/item/radio/headset/headset_cargo/mining
	id = /obj/item/card/id/shaftminer
	l_pocket = /obj/item/reagent_containers/patch/styptic
	r_pocket = /obj/item/flashlight/seclite

//Scientist corpse.
/obj/effect/mob_spawn/human/corpse/scientist
	name = "Scientist"
	mob_name = "Scientist"
	id_job = "Scientist"
	outfit = /datum/outfit/job/scientist

/obj/effect/mob_spawn/human/corpse/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton/brittle
	mob_gender = NEUTER

/datum/outfit/randomizer
	name = "randomizer"

/datum/outfit/randomizer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	// Add picks for more slots as necessary for your needs
	if(islist(uniform))
		uniform = pick(uniform)
	if(islist(shoes))
		shoes = pick(shoes)

/datum/outfit/randomizer/gambler
	name = "gambler"
	shoes = list(
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/shoes/leather
	)
	uniform = list(
		/obj/item/clothing/under/suit/navy,
		/obj/item/clothing/under/suit/really_black,
		/obj/item/clothing/under/suit/checkered,
	)

/obj/effect/mob_spawn/human/corpse/random_species/Initialize(mapload)
	mob_species = pick(
		/datum/species/human,
		/datum/species/unathi,
		/datum/species/moth,
		/datum/species/skrell,
		/datum/species/vox,
		/datum/species/vulpkanin,
		/datum/species/tajaran,
		/datum/species/slime,
		/datum/species/kidan,
		/datum/species/drask,
		/datum/species/grey,
		/datum/species/diona,
	)

	return ..()

/obj/effect/mob_spawn/human/corpse/random_species/gambler
	name = "Gambler"
	mob_name = "Gambler"
	outfit = /datum/outfit/randomizer/gambler

/obj/effect/mob_spawn/human/alive/zombie
	name = "NPC Zombie (Infectious)"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	roundstart = TRUE
	dna_scrambled = TRUE

/obj/effect/mob_spawn/human/alive/zombie/equip(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_NPC_ZOMBIE, ROUNDSTART_TRAIT)
	H.ForceContractDisease(new /datum/disease/zombie)
	for(var/datum/disease/zombie/zomb in H.viruses)
		zomb.stage = 8

	return ..()

/obj/effect/mob_spawn/human/alive/zombie/non_infectious
	name = "NPC Zombie (Non-infectious)"

/obj/effect/mob_spawn/human/alive/zombie/non_infectious/equip(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_NON_INFECTIOUS_ZOMBIE, ROUNDSTART_TRAIT)
	return ..()

////////Non-human spawners////////

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

/// these mob spawn subtypes trigger immediately (New or Initialize) and are not player controlled... since they're dead, you know?
/obj/effect/mob_spawn/corpse
	/// when this mob spawn should auto trigger.
	var/spawn_when = CORPSE_INSTANT

	/// what environmental storytelling script should this corpse have
	var/corpse_description = ""
	/// optionally different text to display if the target is a clown
	var/naive_corpse_description = ""

/obj/effect/mob_spawn/corpse/Initialize(mapload, no_spawn)
	. = ..()
	if(no_spawn)
		return
	switch(spawn_when)
		if(CORPSE_INSTANT)
			INVOKE_ASYNC(src, PROC_REF(create))
		if(CORPSE_ROUNDSTART)
			if(mapload || (SSticker && SSticker.current_state > GAME_STATE_SETTING_UP))
				INVOKE_ASYNC(src, PROC_REF(create))

/obj/effect/mob_spawn/corpse/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.death(TRUE)
	if(corpse_description)
		spawned_mob.AddComponent(/datum/component/corpse_description, corpse_description, naive_corpse_description)

/obj/effect/mob_spawn/corpse/create(ckey, flavour, name, user)
	. = ..()
	qdel(src)

/obj/effect/mob_spawn/corpse/watcher
	mob_type = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher_dead"
	pixel_x = -12

/obj/effect/mob_spawn/corpse/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_dead"
	pixel_x = -12


#undef CORPSE_INSTANT
#undef CORPSE_ROUNDSTART
