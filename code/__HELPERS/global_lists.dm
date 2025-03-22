
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
	//hair gradients
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair_gradient, GLOB.hair_gradients_list)
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

	// Different bodies
	__init_body_accessory(/datum/body_accessory/body)
	// Different tails
	__init_body_accessory(/datum/body_accessory/tail)
	// Different wings
	__init_body_accessory(/datum/body_accessory/wing)

	// Setup species:accessory relations
	initialize_body_accessory_by_species()

	for(var/path in (subtypesof(/datum/surgery)))
		GLOB.surgeries_list += new path()

	init_datum_subtypes(/datum/job, GLOB.joblist, list(/datum/job/ai, /datum/job/cyborg), "title")
	init_datum_subtypes(/datum/superheroes, GLOB.all_superheroes, null, "name")
	init_datum_subtypes(/datum/language, GLOB.all_languages, null, "name")

	// Setup languages
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

	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

	//Pipe list building
	init_subtypes(/datum/pipes, GLOB.construction_pipe_list)
	for(var/D in GLOB.construction_pipe_list)
		var/datum/pipes/P = D
		if(P.rpd_dispensable)
			GLOB.rpd_pipe_list += list(list("pipe_name" = P.pipe_name, "pipe_id" = P.pipe_id, "pipe_type" = P.pipe_type, "pipe_category" = P.pipe_category, "orientations" = P.orientations, "pipe_icon" = P.pipe_icon, "bendy" = P.bendy))

	// Setup PAI software
	for(var/type in subtypesof(/datum/pai_software))
		var/datum/pai_software/P = new type()
		if(GLOB.pai_software_by_key[P.id])
			var/datum/pai_software/O = GLOB.pai_software_by_key[P.id]
			to_chat(world, "<span class='warning'>pAI software module [P.name] has the same key as [O.name]!</span>")
			continue
		GLOB.pai_software_by_key[P.id] = P

	// Setup loadout gear
	for(var/gear_type in subtypesof(/datum/gear))
		var/datum/gear/gear = gear_type

		if(gear == initial(gear.main_typepath))
			continue

		if(!initial(gear.display_name))
			stack_trace("Loadout - Missing display name: [gear]")
			continue
		if(!initial(gear.cost))
			stack_trace("Loadout - Missing cost: [gear]")
			continue
		if(!initial(gear.path))
			stack_trace("Loadout - Missing path definition: [gear]")
			continue

		gear = new gear_type
		var/obj/gear_item = gear.path
		var/list/tweaks = list()
		for(var/datum/gear_tweak/tweak as anything in gear.gear_tweaks)
			tweaks[tweak.type] += list(list(
				"name" = tweak.display_type,
				"icon" = tweak.fa_icon,
				"tooltip" = tweak.info,
			))

		GLOB.gear_tgui_info[gear.sort_category] += list(
			"[gear_type]" = list(
				"name" = gear.display_name,
				"desc" = gear.description,
				"icon" = gear_item.icon,
				"icon_state" = gear_item.icon_state,
				"cost" = gear.cost,
				"gear_tier" = gear.donator_tier,
				"allowed_roles" = gear.allowed_roles,
				"tweaks" = tweaks,
			)
		)

		GLOB.gear_datums[gear_type] = gear

	// Setup a list of robolimbs
	GLOB.basic_robolimb = new()
	for(var/limb_type in typesof(/datum/robolimb))
		var/datum/robolimb/R = new limb_type()
		GLOB.all_robolimbs[R.company] = R
		if(R.selectable)
			GLOB.selectable_robolimbs[R.company] = R

	// Setup world topic handlers
	for(var/topic_handler_type in subtypesof(/datum/world_topic_handler))
		var/datum/world_topic_handler/wth = new topic_handler_type()
		if(!wth.topic_key)
			stack_trace("[wth.type] has no topic key!")
			continue
		if(GLOB.world_topic_handlers[wth.topic_key])
			stack_trace("[wth.type] has the same topic key as [GLOB.world_topic_handlers[wth.topic_key]]! ([wth.topic_key])")
			continue
		GLOB.world_topic_handlers[wth.topic_key] = topic_handler_type

	// Setup client login processors.
	for(var/processor_type in subtypesof(/datum/client_login_processor))
		var/datum/client_login_processor/CLP = new processor_type
		GLOB.client_login_processors += CLP
	// Sort them by priority, lowest first
	sortTim(GLOB.client_login_processors, GLOBAL_PROC_REF(cmp_login_processor_priority))

	GLOB.emote_list = init_emote_list()

	// Set up PCWJ recipes
	initialize_cooking_recipes()

	// Keybindings
	for(var/path in subtypesof(/datum/keybinding))
		var/datum/keybinding/D = path
		if(initial(D.name))
			GLOB.keybindings += new path()

	for(var/path in subtypesof(/datum/preference_toggle))
		var/datum/preference_toggle/pref_toggle = path
		if(initial(pref_toggle.name))
			GLOB.preference_toggles[path] = new path()

	for(var/path in subtypesof(/datum/objective))
		var/datum/objective/O = path
		if(isnull(initial(O.name)))
			continue // These are not valid objectives to add.
		GLOB.admin_objective_list[initial(O.name)] = path

	for(var/path in subtypesof(/datum/tilt_crit))
		var/datum/tilt_crit/crit = path
		if(isnull(initial(crit.name)))
			continue
		crit = new path()
		GLOB.tilt_crits[path] = crit

	for(var/path in subtypesof(/datum/tech))
		var/datum/tech/T = path
		GLOB.rnd_tech_id_to_name[initial(T.id)] = initial(T.name)

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


/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			if(!.[E.key])
				.[E.key] = list(E)
			else
				.[E.key] += E
		else if(E.message) //Assuming all non-base emotes have this
			stack_trace("Keyless emote: [E.type]")

		if(E.key_third_person) //This one is optional
			if(!.[E.key_third_person])
				.[E.key_third_person] = list(E)
			else
				.[E.key_third_person] |= E
