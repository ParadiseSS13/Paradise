var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/spirits = list()					//List of all the spirits, including Masks
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player
var/global/list/respawnable_list = list()				//List of all mobs, dead or in mindless creatures that still be respawned.

var/global/list/portals = list()					//for use by portals
var/global/list/cable_list = list()					//Index for all cables, so that powernets don't have to look through the entire world all the time
var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//list of all landmarks created
var/global/list/surgery_steps = list()				//list of all surgery steps  |BS12
var/global/list/side_effects = list()				//list of all medical sideeffects types by thier names |BS12
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.
var/global/list/joblist = list()					//list of all jobstypes, minus borg and AI
var/global/list/flag_list = list()					//list of flags during Nations gamemode
var/global/list/airlocks = list()					//list of all airlocks

//Languages/species/whitelist.
var/global/list/all_species[0]
var/global/list/all_languages[0]
var/global/list/all_nations[0]
var/global/list/whitelisted_species = list()

// Posters
var/global/list/datum/poster/poster_designs = typesof(/datum/poster) - /datum/poster

//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()
var/global/list/hair_styles_female_list = list()
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()
var/global/list/facial_hair_styles_female_list = list()
var/global/list/skin_styles_female_list = list()		//unused
	//Underwear
var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "None") 
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "None")
var/global/list/underwear_list = underwear_m + underwear_f
	//undershirt
var/global/list/undershirt_t = list("White Shirt", "White Tank top", "Black shirt", "Black Tank top", "Grey Shirt", "Grey tank top", "Lover Shirt", "Blue Ian Shirt", "UK Shirt","I Love NT Shirt", "Peace Shirt", "Band Shirt", "PogoMan Shirt", "Matroska Shirt", "White Short-sleeved shirt", "Purple Short-sleeved shirt", "Blue Short-sleeved shirt", "Green Short-sleeved shirt", "Black Short-Sleeved shirt", "Blue T-Shirt", "Red T-Shirt", "Yellow T-Shirt", "Green T-Shirt", "Blue Polo Shirt", "Red Polo Shirt", "White Polo Shirt", "Gray-Yellow Polo Shirt", "Green Sports Shirt", "Red Sports Shirt", "Blue Sports Shirt", "SS13 Shirt", "Fire Tank Top", "Question Shirt", "Skull Shirt", "Commie Shirt", "Nanotrasen Shirt", "Striped Shirt", "Blue Shirt", "Red Shirt", "Green Shirt", "Meat Shirt", "Tie-Dye Shirt", "Red Jersey", "Blue Jersey", "None")
var/global/list/undershirt_list = undershirt_t
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt")

//////////////////////////
/////Initial Building/////
//////////////////////////

/hook/startup/proc/makeDatumRefLists()
	var/list/paths

	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	paths = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	for(var/path in paths)
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)	hair_styles_male_list += H.name
			if(FEMALE)	hair_styles_female_list += H.name
			else
				hair_styles_male_list += H.name
				hair_styles_female_list += H.name

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	paths = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	for(var/path in paths)
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H
		switch(H.gender)
			if(MALE)	facial_hair_styles_male_list += H.name
			if(FEMALE)	facial_hair_styles_female_list += H.name
			else
				facial_hair_styles_male_list += H.name
				facial_hair_styles_female_list += H.name

	//Surgery Steps - Initialize all /datum/surgery_step into a list
	paths = typesof(/datum/surgery_step)-/datum/surgery_step
	for(var/T in paths)
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()

	//Medical side effects. List all effects by their names
	paths = typesof(/datum/medical_effect)-/datum/medical_effect
	for(var/T in paths)
		var/datum/medical_effect/M = new T
		side_effects[M.name] = T

	//List of job. I can't believe this was calculated multiple times per tick!
	paths = typesof(/datum/job) -list(/datum/job,/datum/job/ai,/datum/job/cyborg)
	for(var/T in paths)
		var/datum/job/J = new T
		joblist[J.title] = J

	paths = typesof(/datum/nations)-/datum/nations
	for(var/T in paths)
		var/datum/nations/N = new T
		all_nations[N.name] = N

	//Languages and species.
	paths = typesof(/datum/language)-/datum/language
	for(var/T in paths)
		var/datum/language/L = new T
		all_languages[L.name] = L

	var/rkey = 0
	paths = typesof(/datum/species)-/datum/species
	for(var/T in paths)
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S

		if(S.flags & IS_WHITELISTED)
			whitelisted_species += S.name

	return 1

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	world << .
*/


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
        if(!istype(L))        L = list()
        for(var/path in typesof(prototype))
                if(path == prototype)        continue
                L += new path()
        return L
