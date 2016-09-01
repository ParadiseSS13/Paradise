// Base chemicals
var/list/base_chemicals = list("water","oxygen","nitrogen","hydrogen","potassium","mercury","carbon",
							"chlorine","fluorine","phosphorus","lithium","sulfur","sacid","radium",
							"iron","aluminum","silicon","sugar","ethanol")
// Standard chemicals
var/list/standard_chemicals = list("slimejelly","blood","water","lube","charcoal","toxin","cyanide",
								"morphine","epinephrine","space_drugs","serotrotium","oxygen","copper",
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
								"enzyme","nothing","salglu_solution","antifreeze","neurotoxin")
// Rare chemicals
var/list/rare_chemicals = list("minttoxin","nanites","xenomicrobes","adminordrazine")
// Standard medicines
var/list/standard_medicines = list("charcoal","toxin","cyanide","morphine","epinephrine","space_drugs",
								"serotrotium","mutadone","mutagen","teporone","lexorin","silver_sulfadiazine",
								"salbutamol","perfluorodecalin","omnizine","synaptizine","haloperidol",
								"potass_iodide","pen_acid","mannitol","oculine","styptic_powder",
								"methamphetamine","spaceacillin","carpotoxin","lsd","ethanol","ammonia",
								"diethylamine","antihol","pancuronium","lipolicide","condensedcapsaicin",
								"frostoil","amanitin","psilocybin","nothing","salglu_solution","neurotoxin")
// Rare medicines
var/list/rare_medicines = list("nanites","xenomicrobes","minttoxin","adminordrazine","blood")
// Drinks
var/list/drinks = list("beer2","hot_coco","orangejuice","tomatojuice","limejuice","carrotjuice",
					"berryjuice","poisonberryjuice","watermelonjuice","lemonjuice","banana",
					"nothing","potato","milk","soymilk","cream","coffee","tea","icecoffee",
					"icetea","cola","nuka_cola","spacemountainwind","thirteenloko","dr_gibb",
					"space_up","lemon_lime","beer","whiskey","gin","rum","vodka","holywater",
					"tequila","vermouth","wine","tonic","kahlua","cognac","ale","sodawater",
					"ice","bilk","atomicbomb","threemileisland","goldschlager","patron","gintonic",
					"cubalibre","whiskeycola","martini","vodkamartini","whiterussian","screwdrivercocktail",
					"booger","bloodymary","gargleblaster","bravebull","tequilasunrise","toxinsspecial",
					"beepskysmash","salglu_solution","irishcream","manlydorf","longislandicedtea",
					"moonshine","b52","irishcoffee","margarita","blackrussian","manhattan",
					"manhattan_proj","whiskeysoda","antifreeze","barefoot","snowwhite","demonsblood",
					"vodkatonic","ginfizz","bahama_mama","singulo","sbiten","devilskiss","red_mead",
					"mead","iced_beer","grog","aloe","andalusia","alliescocktail","soy_latte",
					"cafe_latte","acidspit","amasec","neurotoxin","hippiesdelight","bananahonk",
					"silencer","changelingsting","irishcarbomb","syndicatebomb","erikasurprise","driestmartini")

//Random chem blacklist
var/global/list/blocked_chems = list("polonium", "initropidril", "concentrated_initro",
							"sodium_thiopental", "ketamine", "coniine",
							"adminordrazine", "nanites", "hellwater",
							"mutationtoxin", "amutationtoxin", "venom",
							"spore", "stimulants", "stimulative_agent",
							"syndicate_nanites", "ripping_tendrils", "boiling_oil",
							"envenomed_filaments", "lexorin_jelly", "kinetic",
							"cryogenic_liquid", "dark_matter", "b_sorium",
							"reagent", "life","dragonsbreath")

//List of chems/mixtures that can't grow in plants (in addition to the global random chem blacklist)
var/global/list/plant_blocked_chems = list()	//filled in /datum/reagents/New() with chems that have can_grow_in_plants = 0

var/global/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone","silver_sulfadiazine", "salbutamol",
									  "omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									  "spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									  "mitocholide", "rezadone")