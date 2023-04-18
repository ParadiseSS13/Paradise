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
	var/flavour_text = ""	//flavour/fluff about the role, optional.
	var/description = "A description for this has not been set. This is either an oversight or an admin-spawned spawner not in normal use."	//intended as OOC info about the role
	var/important_info = ""	//important info such as rules that apply to you, etc. Optional.
	var/id_job = null			//Such as "Clown" or "Chef." This just determines what the ID reads as, not their access
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

	//for mob_spawn/human
	var/allow_prefs_prompt = FALSE
	var/allow_species_pick = FALSE
	var/allow_gender_pick = FALSE
	var/allow_name_pick = FALSE
	var/mob_species = null

	var/assignedrole
	var/banType = ROLE_GHOST
	var/ghost_usable = TRUE
	var/offstation_role = TRUE // If set to true, the role of the user's mind will be set to offstation
	var/min_hours = 0 //Минимальное количество часов для игры на гост роли
	var/exp_type = EXP_TYPE_LIVING
	var/respawn_cooldown = 0

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
	var/deathtime = world.time - O.timeofdeath
	if(respawn_cooldown && deathtime < respawn_cooldown && O.started_as_observer == 0)
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		to_chat(usr, "<span class='warning'>You must wait [respawn_cooldown / 600] minutes to respawn as [mob_name]!</span>")
		return
	if(config.use_exp_restrictions && min_hours)
		if(user.client.get_exp_type_num(exp_type) < min_hours * 60 && !check_rights(R_ADMIN|R_MOD, 0, usr))
			to_chat(user, "<span class='warning'>У вас недостаточно часов для игры на этой роли. Требуется набрать [min_hours] часов типа [exp_type] для доступа к ней.</span>")
			return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No")
		return
	var/mob_use_prefs = FALSE
	var/_mob_species = FALSE
	var/_mob_gender = FALSE
	var/_mob_name = FALSE
	if(use_prefs_prompt(user))
		mob_use_prefs = TRUE
	else
		if(allow_prefs_prompt)
			var/randomize_alert = alert("Your character will be randomized for this role, continue?",,"Yes","No")
			if(randomize_alert == "No")
				return
		if(allow_species_pick)
			_mob_species = species_prompt()
		if(allow_gender_pick)
			_mob_gender = gender_prompt()
		if(allow_name_pick)
			var/m_gender = (_mob_gender)? _mob_gender : mob_gender
			var/m_species =(_mob_species)? _mob_species : mob_species
			_mob_name = name_prompt(m_gender, m_species)
		if(_mob_species)
			var/datum/species/S = GLOB.all_species[_mob_species]
			_mob_species = S.type
	if(!loc || !uses || QDELETED(src) || QDELETED(user))
		to_chat(user, "<span class='warning'>The [name] is no longer usable!</span>")
		return
	if(id_job == null)
		add_game_logs("[user.ckey] became [mob_name]", user)
	else
		add_game_logs("[user.ckey] became [mob_name]. Job: [id_job]", user)
	create(plr = user, prefs = mob_use_prefs, _mob_name = _mob_name, _mob_gender = _mob_gender, _mob_species = _mob_species)

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

/obj/effect/mob_spawn/proc/use_prefs_prompt(mob/user)
	return

/obj/effect/mob_spawn/proc/species_prompt()
	return TRUE

/obj/effect/mob_spawn/proc/gender_prompt()
	return

/obj/effect/mob_spawn/proc/name_prompt(_mob_gender, _mob_species)
	return

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M, use_prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	return

/obj/effect/mob_spawn/proc/create(mob/plr, flavour = TRUE, name, prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random)
		M.real_name = mob_name ? mob_name : M.name
		if(M.dna)
			M.dna.real_name = mob_name
		if(M.mind)
			M.mind.name = mob_name
		if(!mob_gender)
			mob_gender = pick(MALE, FEMALE)
		M.gender = mob_gender
	if(faction)
		M.faction = list(faction)
	if(disease)
		M.ForceContractDisease(new disease)
	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	M.adjustFireLoss(burn_damage)
	if(death)
		M.death() //Kills the new mob
	M.color = mob_color
	if(plr)
		if(prefs)
			plr.client?.prefs.copy_to(M)
	equip(M, use_prefs = prefs, _mob_name = _mob_name, _mob_gender = _mob_gender, _mob_species = _mob_species)

	if(plr)
		M.ckey = plr.ckey
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
		M.change_voice()
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)
	else
		M.tts_seed = SStts.get_random_seed(M)

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	mob_species = null		//Set species
	allow_species_pick = FALSE
	allow_prefs_prompt = FALSE
	allow_gender_pick = FALSE
	allow_name_pick = FALSE
	var/list/pickable_species = list("Human", "Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona")
	var/datum/outfit/outfit = /datum/outfit	//If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	var/disable_sensors = TRUE
	//All of these only affect the ID that the outfit has placed in the ID slot
	id_job = null			//Such as "Clown" or "Chef." This just determines what the ID reads as, not their access
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

	var/list/del_types = list(/obj/item/pda, /obj/item/radio/headset)

/obj/effect/mob_spawn/human/Initialize()
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	if(!mob_name)
		mob_name = id_job
	return ..()

/obj/effect/mob_spawn/human/use_prefs_prompt(mob/user)
	if(allow_prefs_prompt)
		if(!(user.client))
			return FALSE
		var/get_slot = alert("Would you like to play as the character you currently have selected in slot?",, "Yes","No")
		if(get_slot == "Yes")
			for(var/C in GLOB.human_names_list)
				var/char_name = user.client.prefs.real_name
				if(char_name == C)
					to_chat(user, "<span class='warning'>You have already entered the round with this name, choose another slot.</span>")
					return FALSE
			var/char_species = user.client.prefs.species
			if(!(char_species in pickable_species))
				to_chat(user, "<span class='warning'>Your character's current species is not suitable for this role.</span>")
				return FALSE
			return TRUE
	return FALSE

/obj/effect/mob_spawn/human/species_prompt()
	var/selected_species = input("Select a species", "Species Selection") as null|anything in pickable_species
	if(!selected_species)
		to_chat(usr, "<span class='warning'>Spawning stopped.</span>")
		return FALSE	// You didn't pick, abort
	skin_tone = rand(-25, 0)
	return selected_species

/obj/effect/mob_spawn/human/gender_prompt()
	var/new_gender = alert("Please select gender.",, "Male","Female")
	if(new_gender == "Male")
		return MALE
	else
		return FEMALE

/obj/effect/mob_spawn/human/name_prompt(_mob_gender, _mob_species)
	var/new_name = input("Enter your name:") as text
	if(!new_name)
		new_name = random_name(_mob_gender, _mob_species)
	return new_name

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H, use_prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	if(_mob_species && !use_prefs)
		H.set_species(_mob_species)
	else if(mob_species && !use_prefs)
		H.set_species(mob_species)

	if(husk)
		H.ChangeToHusk()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		H.mutations.Remove(HUSK)
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	var/obj/item/organ/external/head/D = H.get_organ("head")
	if(!use_prefs)
		if(!random)
			if(_mob_name)
				H.real_name = _mob_name
				if(H.dna)
					H.dna.real_name = _mob_name
				if(H.mind)
					H.mind.name = _mob_name
			else
				H.real_name = mob_name ? mob_name : H.name
				if(H.dna)
					H.dna.real_name = mob_name
				if(H.mind)
					H.mind.name = mob_name
			if(_mob_gender)
				H.gender = _mob_gender
			else
				if(!mob_gender)
					mob_gender = pick(MALE, FEMALE)
				H.gender = mob_gender
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

/obj/effect/mob_spawn/human/special(mob/living/carbon/human/H)
	if(!(NO_DNA in H.dna.species.species_traits))
		H.dna.blood_type = pick("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-") //Чтобы им всем подряд не требовалась кровь одного типа
		var/datum/dna/D = H.dna
		if(!D.species.is_small)
			H.change_dna(D, TRUE, TRUE)

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000


/obj/effect/mob_spawn/human/alive
	icon = 'icons/obj/machines/cryogenic2.dmi'
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
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "Squeak!"

/obj/effect/mob_spawn/cow
	name = "sleeper"
	mob_name = "space cow"
	mob_type = 	/mob/living/simple_animal/cow
	death = FALSE
	roundstart = FALSE
	mob_gender = FEMALE
	icon = 'icons/obj/machines/cryogenic2.dmi'
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

/obj/effect/mob_spawn/human/intern
	name = "Intern"
	mob_name = "Intern"
	id_job = "Intern"
	outfit = /datum/outfit/job/doctor/intern

/obj/effect/mob_spawn/human/doctor/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "sleeper"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a space doctor!"
	assignedrole = "Space Doctor"

/obj/effect/mob_spawn/human/doctor/alive/equip(mob/living/carbon/human/H, use_prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
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

/obj/effect/mob_spawn/human/trainee
	name = "Trainee Engineer"
	mob_name = "Trainee Engineer"
	id_job = "Trainee Engineer"
	outfit = /datum/outfit/job/engineer/trainee

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

/obj/effect/mob_spawn/human/student
	name = "Student Scientist"
	mob_name = "Student Scientist"
	id_job = "Student Scientist"
	outfit = /datum/outfit/job/scientist/student

/obj/effect/mob_spawn/human/securty
	name = "Security Officer"
	mob_name = "Security Officer"
	id_job = "Security Officer"
	outfit = /datum/outfit/job/officer

/obj/effect/mob_spawn/human/cadet
	name = "Security Cadet"
	mob_name = "Security Cadet"
	id_job = "Security Cadet"
	outfit = /datum/outfit/job/officer/cadet

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
	id_access_list = list(ACCESS_BAR)
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/human/bartender/alive
	death = FALSE
	roundstart = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	name = "bartender sleeper"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	description = "Stuck on Lavaland, you could try getting back to civilisation...or serve drinks to those that wander by."
	flavour_text = "You are a space bartender! Time to mix drinks and change lives. Wait, where did your bar just get transported to?"
	assignedrole = "Space Bartender"

/obj/effect/mob_spawn/human/bartender/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/obj/effect/mob_spawn/human/beach/alive/lifeguard
	flavour_text = "You're a spunky lifeguard! It's up to you to make sure nobody drowns or gets eaten by sharks and stuff. Then suddenly your entire beach was transported to this strange hell.\
	 You aren't trained for this, but you'll still keep your guests alive!"
	description = "Try to survive on lavaland with the pitiful equipment of a lifeguard. Or hide in your biodome."
	mob_gender = FEMALE
	name = "lifeguard sleeper"
	id_job = "Lifeguard"
	allow_gender_pick = FALSE
	outfit = /datum/outfit/beachbum/female

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
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	mob_name = "Beach Bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	flavour_text = "You are a beach bum! You think something just happened to the beach but you don't really pay too much attention."
	description = "Try to survive on lavaland or just enjoy the beach, waiting for visitors."
	assignedrole = "Beach Bum"

/obj/effect/mob_spawn/human/beach/alive/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()

/datum/outfit/beachbum
	name = "Beach Bum"
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/shorts/red

/datum/outfit/beachbum/female
	name = "Beach Bum (female)"
	glasses = /obj/item/clothing/glasses/sunglasses
	uniform = /obj/item/clothing/under/swimsuit/red

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
	description = "Be a spooky scary skeleton."	//not mapped in anywhere so admin spawner, who knows what they'll use this for.
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

//For dead simple mobs

/obj/effect/mob_spawn/carp
	mob_type = /mob/living/simple_animal/hostile/carp
	death = TRUE
	name = "Dead carp"
	icon = 'icons/mob/carp.dmi'
	icon_state = "base_dead"

//For black market packers gate

/obj/effect/mob_spawn/human/corpse/tacticool
	mob_type = /mob/living/carbon/human
	name = "Tacticool corpse"
	icon = 'icons/mob/uniform.dmi'
	icon_state = "tactifool_s"
	mob_name = "Unknown"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/packercorpse

/datum/outfit/packercorpse
	name = "Packer Corpse"

	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/tacticool/Initialize()
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader
	name = "Syndi trader corpse"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	random = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/syndicatetrader

/datum/outfit/syndicatetrader
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black/forensics
	belt = /obj/item/gun/projectile/automatic/pistol
	mask = /obj/item/clothing/mask/balaclava
	suit = /obj/item/clothing/suit/armor/vest/combat

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader/Initialize()
	brute_damage = rand(150, 500)
	burn_damage = rand(100, 300)
	return ..()
