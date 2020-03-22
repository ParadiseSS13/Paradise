
//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/makeDatumRefLists()
	//markings
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.marking_styles_list)
	//head accessory
	init_sprite_accessory_subtypes(/datum/sprite_accessory/head_accessory, GLOB.head_accessory_styles_list)
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_public_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list, GLOB.hair_styles_full_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list, GLOB.socks_m, GLOB.socks_f)
	//alt heads
	init_sprite_accessory_subtypes(/datum/sprite_accessory/alt_heads, GLOB.alt_heads_list)

	init_subtypes(/datum/surgery_step, GLOB.surgery_steps)

	for(var/path in (subtypesof(/datum/surgery)))
		GLOB.surgeries_list += new path()

	init_datum_subtypes(/datum/job, GLOB.joblist, list(/datum/job/ai, /datum/job/cyborg), "title")
	init_datum_subtypes(/datum/superheroes, GLOB.all_superheroes, null, "name")
	init_datum_subtypes(/datum/language, GLOB.all_languages, null, "name")

	for(var/language_name in GLOB.all_languages)
		var/datum/language/L = GLOB.all_languages[language_name]
		if(!(L.flags & NONGLOBAL))
			GLOB.language_keys[":[lowertext(L.key)]"] = L
			GLOB.language_keys[".[lowertext(L.key)]"] = L
			GLOB.language_keys["#[lowertext(L.key)]"] = L

	var/rkey = 0
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		S.race_key = ++rkey //Used in mob icon caching.
		GLOB.all_species[S.name] = S

		if(IS_WHITELISTED in S.species_traits)
			GLOB.whitelisted_species += S.name

	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

	//Pipe list building
	init_subtypes(/datum/pipes, GLOB.construction_pipe_list)
	for(var/D in GLOB.construction_pipe_list)
		var/datum/pipes/P = D
		if(P.rpd_dispensable)
			GLOB.rpd_pipe_list += list(list("pipe_name" = P.pipe_name, "pipe_id" = P.pipe_id, "pipe_type" = P.pipe_type, "pipe_category" = P.pipe_category, "orientations" = P.orientations, "pipe_icon" = P.pipe_icon, "bendy" = P.bendy))
	return 1

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for(var/reaction in GLOB.chemical_reactions_list)
		. += "GLOB.chemical_reactions_list\[\"[reaction]\"\] = \"[GLOB.chemical_reactions_list[reaction]]\"\n"
		if(islist(GLOB.chemical_reactions_list[reaction]))
			var/list/L = GLOB.chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_chat(world, .)
*/


//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))	L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

/proc/init_datum_subtypes(prototype, list/L, list/pexempt, assocvar)
	if(!istype(L))	L = list()
	for(var/path in subtypesof(prototype) - pexempt)
		var/datum/D = new path()
		if(istype(D))
			var/assoc
			if(D.vars["[assocvar]"]) //has the var
				assoc = D.vars["[assocvar]"] //access value of var
			if(assoc) //value gotten
				L["[assoc]"] = D //put in association
	return L
