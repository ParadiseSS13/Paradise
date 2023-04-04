// Base chemicals
GLOBAL_LIST_INIT(base_chemicals, list("water","oxygen","nitrogen","hydrogen","potassium","mercury","carbon",
							"chlorine","fluorine","phosphorus","lithium","sulfur","sacid","radium",
							"iron","aluminum","silicon","sugar","ethanol"))
// Standard chemicals
GLOBAL_LIST_INIT(standard_chemicals, list("slimejelly","blood","water","lube","charcoal","toxin","cyanide",
								"morphine","syntmorphine","epinephrine","space_drugs","oxygen","copper",
								"nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine",
								"fluorine","sodium","phosphorus","lithium","sugar","sacid","facid",
								"glycerol","radium","mutadone","thermite","mutagen","virusfood","iron",
								"gold","silver","uranium","aluminum","silicon","fuel","cleaner","atrazine",
								"plasma","teporone","lexorin","silver_sulfadiazine","salbutamol",
								"perfluorodecalin","omnizine","synaptizine","haloperidol","potass_iodide",
								"pen_acid","mannitol","oculine","styptic_powder","methamphetamine",
								"cryoxadone","spaceacillin","carpotoxin","lsd","fluorosurfactant",
								"fluorosurfactant","ethanol","ammonia","diethylamine","antihol","pancuronium",
								"lipolicide","condensedcapsaicin","frostoil","amanitin","psilocybin",
								"enzyme","nothing","salglu_solution","antifreeze","neurotoxin", "jestosterone"))
// Rare chemicals
GLOBAL_LIST_INIT(rare_chemicals, list("minttoxin","syndicate_nanites", "xenomicrobes"))
// Standard medicines
GLOBAL_LIST_INIT(standard_medicines, list("charcoal","toxin","cyanide","morphine","syntmorphine","epinephrine","space_drugs",
								"mutadone","mutagen","teporone","lexorin","silver_sulfadiazine",
								"salbutamol","perfluorodecalin","omnizine","synaptizine","haloperidol",
								"potass_iodide","pen_acid","mannitol","oculine","styptic_powder",
								"methamphetamine","spaceacillin","carpotoxin","lsd","ethanol","ammonia",
								"diethylamine","antihol","pancuronium","lipolicide","condensedcapsaicin",
								"frostoil","amanitin","psilocybin","nothing","salglu_solution","neurotoxin"))
// Rare medicines
GLOBAL_LIST_INIT(rare_medicines, list("syndicate_nanites","minttoxin","blood", "xenomicrobes"))
// Drinks
GLOBAL_LIST_INIT(drinks, subtypesof(/datum/reagent/consumable/drink/)\
						+ subtypesof(/datum/reagent/consumable/ethanol)\
						+ /datum/reagent/consumable/ethanol \
						+ /datum/reagent/beer2)

//Liver Toxins list
GLOBAL_LIST_INIT(liver_toxins, list("toxin", "plasma", "sacid", "facid", "cyanide","amanitin", "carpotoxin"))

//Random chem blacklist
GLOBAL_LIST_INIT(blocked_chems, list("polonium", "initropidril", "concentrated_initro",
							"sodium_thiopental", "ketamine", "coniine",
							"adminordrazine", "nanites", "hellwater",
							"mutationtoxin", "amutationtoxin", "venom",
							"spore", "stimulants", "stimulative_agent",
							"syndicate_nanites", "ripping_tendrils", "boiling_oil",
							"envenomed_filaments", "lexorin_jelly", "kinetic",
							"cryogenic_liquid", "dark_matter", "b_sorium",
							"reagent", "life","dragonsbreath", "nanocalcium", "bungotoxin", "fruit_wine"))

GLOBAL_LIST_INIT(safe_chem_list, list("antihol", "charcoal", "epinephrine", "insulin", "teporone","silver_sulfadiazine", "salbutamol",
									  "omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									  "spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									  "mitocholide", "rezadone"))

GLOBAL_LIST_INIT(safe_chem_applicator_list, list("silver_sulfadiazine", "styptic_powder", "synthflesh"))
