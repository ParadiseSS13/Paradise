
//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/makeDatumRefLists()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, hair_styles_list, hair_styles_male_list, hair_styles_female_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, facial_hair_styles_list, facial_hair_styles_male_list, facial_hair_styles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, underwear_list, underwear_m, underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, undershirt_list, undershirt_m, undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, socks_list, socks_m, socks_f)



	var/list/paths
	//Surgery Steps - Initialize all /datum/surgery_step into a list
	paths = subtypesof(/datum/surgery_step)
	for(var/T in paths)
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()

	//List of job. I can't believe this was calculated multiple times per tick!
	paths = subtypesof(/datum/job) -list(/datum/job/ai,/datum/job/cyborg)
	for(var/T in paths)
		var/datum/job/J = new T
		joblist[J.title] = J

	paths = subtypesof(/datum/superheroes)
	for(var/T in paths)
		var/datum/superheroes/S = new T
		all_superheroes[S.name] = S

	paths = subtypesof(/datum/nations)
	for(var/T in paths)
		var/datum/nations/N = new T
		all_nations[N.name] = N

	//Languages and species.
	paths = subtypesof(/datum/language)
	for(var/T in paths)
		var/datum/language/L = new T
		all_languages[L.name] = L

	for (var/language_name in all_languages)
		var/datum/language/L = all_languages[language_name]
		if(!(L.flags & NONGLOBAL))
			language_keys[":[lowertext(L.key)]"] = L
			language_keys[".[lowertext(L.key)]"] = L
			language_keys["#[lowertext(L.key)]"] = L

	var/rkey = 0
	paths = subtypesof(/datum/species)
	for(var/T in paths)
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S

		if(S.flags & IS_WHITELISTED)
			whitelisted_species += S.name

	init_subtypes(/datum/table_recipe, table_recipes)

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
