// Standard medicines
GLOBAL_LIST_INIT(standard_medicines, list("charcoal","toxin","cyanide","morphine","epinephrine","space_drugs",
								"mutadone","mutagen","teporone","lexorin","silver_sulfadiazine",
								"salbutamol","perfluorodecalin","omnizine","synaptizine","haloperidol",
								"potass_iodide","pen_acid","mannitol","oculine","styptic_powder","happiness",
								"methamphetamine","spaceacillin","carpotoxin","lsd","ethanol","ammonia",
								"diethylamine","antihol","pancuronium","lipolicide","condensedcapsaicin",
								"frostoil","amanitin","psilocybin","nothing","salglu_solution","neurotoxin"))
// Rare medicines
GLOBAL_LIST_INIT(rare_medicines, list("syndicate_nanites","minttoxin","blood", "xenomicrobes"))
// Drinks
GLOBAL_LIST_EMPTY(alcoholic_drinks)
GLOBAL_LIST_EMPTY(soft_drinks)
GLOBAL_LIST_EMPTY(synthanolic_drinks)
GLOBAL_LIST_EMPTY(synthetic_soft_drinks)

/proc/populate_global_drink_lists()
	for(var/path in subtypesof(/datum/reagent/consumable))
		var/datum/reagent/consumable/beverage = path
		if(beverage.description == ABSTRACT_TYPE_DESC || beverage.id == "bacchus_blessing")
			// Skip abstract drinks that we shouldn't be spawning
			continue
		if(ispath(beverage, /datum/reagent/consumable/ethanol/synthanol))
			GLOB.synthanolic_drinks += beverage.id
			continue
		if(ispath(beverage, /datum/reagent/consumable/ethanol))
			GLOB.alcoholic_drinks += beverage.id
			continue
		if(beverage.taste_flag == SYNTHETIC)
			GLOB.synthetic_soft_drinks += beverage.id
			continue
		if(ispath(beverage, /datum/reagent/consumable/drink))
			GLOB.soft_drinks += beverage.id

//Liver Toxins list
GLOBAL_LIST_INIT(liver_toxins, list("toxin", "plasma", "sacid", "facid", "cyanide","amanitin", "carpotoxin"))

//General chem blacklist. This is for the really good stuff that we just want to restrict from things like bees and odysseus syringe gun duping
GLOBAL_LIST_INIT(blocked_chems, list("polonium", "initropidril", "concentrated_initro",
							"sodium_thiopental", "ketamine",
							"adminordrazine", "nanites", "hell_water",
							"mutationtoxin", "amutationtoxin", "venom",
							"spore", "stimulants", "stimulative_agent",
							"syndicate_nanites", "ripping_tendrils", "boiling_oil",
							"envenomed_filaments", "lexorin_jelly", "kinetic",
							"cryogenic_liquid", "liquid_dark_matter", "b_sorium",
							"reagent", "drink", "medicine", "plantnutrient", "consumable", "dragonsbreath",
							"nanocalcium", "xenomicrobes", "nanomachines", "gibbis", "prions",
							"spidereggs", "heartworms", "bacon_grease",
							"fungalspores", "jagged_crystals", "salmonella",
							"lavaland_extract", "stable_mutagen", "beer2",
							"curare", "gluttonytoxin", "smoke_powder", "stimulative_cling",
							"teslium_paste", "omnizine_no_addiction", "zombiecure1",
							"zombiecure2", "zombiecure3", "zombiecure4",
							"admincleaner_all", "admincleaner_item", "admincleaner_mob",
							"synthetic_omnizine_no_addiction", "surge_plus", "viral_eraser",
							))
