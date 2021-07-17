// Base chemicals
GLOBAL_LIST_INIT(base_chemicals, list(/datum/reagent/water, /datum/reagent/oxygen, /datum/reagent/nitrogen, /datum/reagent/hydrogen, /datum/reagent/potassium, /datum/reagent/mercury, /datum/reagent/carbon,
							/datum/reagent/chlorine, /datum/reagent/fluorine, /datum/reagent/phosphorus, /datum/reagent/lithium, /datum/reagent/sulfur, /datum/reagent/acid, /datum/reagent/radium,
							/datum/reagent/iron, /datum/reagent/aluminum, /datum/reagent/silicon, /datum/reagent/consumable/sugar, /datum/reagent/consumable/ethanol))
// Standard chemicals
GLOBAL_LIST_INIT(standard_chemicals, list(/datum/reagent/slimejelly, /datum/reagent/blood, /datum/reagent/water, /datum/reagent/lube, /datum/reagent/medicine/charcoal, /datum/reagent/toxin, /datum/reagent/cyanide,
								/datum/reagent/medicine/morphine, /datum/reagent/medicine/epinephrine, /datum/reagent/space_drugs, /datum/reagent/oxygen, /datum/reagent/copper,
								/datum/reagent/nitrogen, /datum/reagent/hydrogen, /datum/reagent/potassium, /datum/reagent/mercury, /datum/reagent/sulfur, /datum/reagent/carbon, /datum/reagent/chlorine,
								/datum/reagent/fluorine, /datum/reagent/sodium, /datum/reagent/phosphorus, /datum/reagent/lithium, /datum/reagent/consumable/sugar, /datum/reagent/acid, /datum/reagent/acid/facid,
								/datum/reagent/glycerol, /datum/reagent/radium, /datum/reagent/medicine/mutadone, /datum/reagent/thermite, /datum/reagent/mutagen, /datum/reagent/consumable/virus_food, /datum/reagent/iron,
								/datum/reagent/gold, /datum/reagent/silver, /datum/reagent/uranium, /datum/reagent/aluminum, /datum/reagent/silicon, /datum/reagent/fuel, /datum/reagent/space_cleaner, /datum/reagent/glyphosate/atrazine,
								/datum/reagent/plasma, /datum/reagent/medicine/teporone, /datum/reagent/lexorin, /datum/reagent/medicine/silver_sulfadiazine, /datum/reagent/medicine/salbutamol,
								/datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/omnizine, /datum/reagent/medicine/synaptizine, /datum/reagent/medicine/haloperidol, /datum/reagent/medicine/potass_iodide,
								/datum/reagent/medicine/pen_acid, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/styptic_powder, /datum/reagent/methamphetamine,
								/datum/reagent/medicine/cryoxadone, /datum/reagent/medicine/spaceacillin, /datum/reagent/carpotoxin, /datum/reagent/lsd, /datum/reagent/fluorosurfactant,
								/datum/reagent/fluorosurfactant, /datum/reagent/consumable/ethanol, /datum/reagent/ammonia, /datum/reagent/diethylamine, /datum/reagent/medicine/antihol, /datum/reagent/pancuronium,
								/datum/reagent/lipolicide, /datum/reagent/consumable/condensedcapsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/amanitin, /datum/reagent/psilocybin,
								/datum/reagent/consumable/enzyme, /datum/reagent/consumable/drink/nothing, /datum/reagent/medicine/salglu_solution, /datum/reagent/consumable/ethanol/antifreeze, /datum/reagent/consumable/ethanol/neurotoxin, /datum/reagent/jestosterone))
// Rare chemicals
GLOBAL_LIST_INIT(rare_chemicals, list(/datum/reagent/minttoxin, /datum/reagent/medicine/syndicate_nanites, /datum/reagent/xenomicrobes))
// Standard medicines
GLOBAL_LIST_INIT(standard_medicines, list(/datum/reagent/medicine/charcoal, /datum/reagent/toxin, /datum/reagent/cyanide, /datum/reagent/medicine/morphine, /datum/reagent/medicine/epinephrine, /datum/reagent/space_drugs,
								/datum/reagent/medicine/mutadone, /datum/reagent/mutagen, /datum/reagent/medicine/teporone, /datum/reagent/lexorin, /datum/reagent/medicine/silver_sulfadiazine,
								/datum/reagent/medicine/salbutamol, /datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/omnizine, /datum/reagent/medicine/synaptizine, /datum/reagent/medicine/haloperidol,
								/datum/reagent/medicine/potass_iodide, /datum/reagent/medicine/pen_acid, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/styptic_powder,
								/datum/reagent/methamphetamine, /datum/reagent/medicine/spaceacillin, /datum/reagent/carpotoxin, /datum/reagent/lsd, /datum/reagent/consumable/ethanol, /datum/reagent/ammonia,
								/datum/reagent/diethylamine, /datum/reagent/medicine/antihol, /datum/reagent/pancuronium, /datum/reagent/lipolicide, /datum/reagent/consumable/condensedcapsaicin,
								/datum/reagent/consumable/frostoil, /datum/reagent/amanitin, /datum/reagent/psilocybin, /datum/reagent/consumable/drink/nothing, /datum/reagent/medicine/salglu_solution, /datum/reagent/consumable/ethanol/neurotoxin))
// Rare medicines
GLOBAL_LIST_INIT(rare_medicines, list(/datum/reagent/medicine/syndicate_nanites, /datum/reagent/minttoxin, /datum/reagent/blood, /datum/reagent/xenomicrobes))
// Drinks
GLOBAL_LIST_INIT(drinks, list(/datum/reagent/beer2, /datum/reagent/consumable/hot_coco, /datum/reagent/consumable/drink/orangejuice, /datum/reagent/consumable/drink/tomatojuice, /datum/reagent/consumable/drink/limejuice, /datum/reagent/consumable/drink/carrotjuice,
					/datum/reagent/consumable/drink/berryjuice, /datum/reagent/consumable/drink/poisonberryjuice, /datum/reagent/consumable/drink/watermelonjuice, /datum/reagent/consumable/drink/lemonjuice, /datum/reagent/consumable/drink/banana,
					/datum/reagent/consumable/drink/nothing, /datum/reagent/consumable/drink/potato_juice, /datum/reagent/consumable/drink/milk, /datum/reagent/consumable/drink/milk/soymilk, /datum/reagent/consumable/drink/milk/cream, /datum/reagent/consumable/drink/coffee, /datum/reagent/consumable/drink/tea, /datum/reagent/consumable/drink/coffee/icecoffee,
					/datum/reagent/consumable/drink/tea/icetea, /datum/reagent/consumable/drink/cold/space_cola, /datum/reagent/consumable/drink/cold/nuka_cola, /datum/reagent/consumable/drink/cold/spacemountainwind, /datum/reagent/consumable/ethanol/thirteenloko, /datum/reagent/consumable/drink/cold/dr_gibb,
					/datum/reagent/consumable/drink/cold/space_up, /datum/reagent/consumable/drink/cold/lemon_lime, /datum/reagent/consumable/ethanol/beer, /datum/reagent/consumable/ethanol/whiskey, /datum/reagent/consumable/ethanol/gin, /datum/reagent/consumable/ethanol/rum, /datum/reagent/consumable/ethanol/vodka, /datum/reagent/holywater,
					/datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/vermouth, /datum/reagent/consumable/ethanol/wine, /datum/reagent/consumable/drink/cold/tonic, /datum/reagent/consumable/ethanol/kahlua, /datum/reagent/consumable/ethanol/cognac, /datum/reagent/consumable/ethanol/ale, /datum/reagent/consumable/drink/cold/sodawater,
					/datum/reagent/consumable/drink/cold/ice, /datum/reagent/consumable/ethanol/bilk, /datum/reagent/consumable/ethanol/atomicbomb, /datum/reagent/consumable/ethanol/threemileisland, /datum/reagent/consumable/ethanol/goldschlager, /datum/reagent/consumable/ethanol/patron, /datum/reagent/consumable/ethanol/gintonic,
					/datum/reagent/consumable/ethanol/cuba_libre, /datum/reagent/consumable/ethanol/whiskey_cola, /datum/reagent/consumable/ethanol/martini, /datum/reagent/consumable/ethanol/vodkamartini, /datum/reagent/consumable/ethanol/white_russian, /datum/reagent/consumable/ethanol/screwdrivercocktail,
					/datum/reagent/consumable/ethanol/booger, /datum/reagent/consumable/ethanol/bloody_mary, /datum/reagent/consumable/ethanol/gargle_blaster, /datum/reagent/consumable/ethanol/brave_bull, /datum/reagent/consumable/ethanol/tequila_sunrise, /datum/reagent/consumable/ethanol/toxins_special,
					/datum/reagent/consumable/ethanol/beepsky_smash, /datum/reagent/medicine/salglu_solution, /datum/reagent/consumable/ethanol/irish_cream, /datum/reagent/consumable/ethanol/manly_dorf, /datum/reagent/consumable/ethanol/longislandicedtea,
					/datum/reagent/consumable/ethanol/moonshine, /datum/reagent/consumable/ethanol/b52, /datum/reagent/consumable/ethanol/irishcoffee, /datum/reagent/consumable/ethanol/margarita, /datum/reagent/consumable/ethanol/black_russian, /datum/reagent/consumable/ethanol/manhattan,
					/datum/reagent/consumable/ethanol/manhattan_proj, /datum/reagent/consumable/ethanol/whiskeysoda, /datum/reagent/consumable/ethanol/adminfreeze, /datum/reagent/consumable/ethanol/antifreeze, /datum/reagent/consumable/ethanol/barefoot, /datum/reagent/consumable/ethanol/snowwhite, /datum/reagent/consumable/ethanol/demonsblood,
					/datum/reagent/consumable/ethanol/vodkatonic, /datum/reagent/consumable/ethanol/ginfizz, /datum/reagent/consumable/ethanol/bahama_mama, /datum/reagent/consumable/ethanol/singulo, /datum/reagent/consumable/ethanol/sbiten, /datum/reagent/consumable/ethanol/devilskiss, /datum/reagent/consumable/ethanol/red_mead,
					/datum/reagent/consumable/ethanol/mead, /datum/reagent/consumable/ethanol/iced_beer, /datum/reagent/consumable/ethanol/grog, /datum/reagent/consumable/ethanol/aloe, /datum/reagent/consumable/ethanol/andalusia, /datum/reagent/consumable/ethanol/alliescocktail, /datum/reagent/consumable/drink/coffee/soy_latte,
					/datum/reagent/consumable/drink/coffee/cafe_latte, /datum/reagent/consumable/ethanol/acid_spit, /datum/reagent/consumable/ethanol/amasec, /datum/reagent/consumable/ethanol/neurotoxin, /datum/reagent/consumable/ethanol/hippies_delight, /datum/reagent/consumable/drink/bananahonk,
					/datum/reagent/consumable/drink/silencer, /datum/reagent/consumable/ethanol/changelingsting, /datum/reagent/consumable/ethanol/irishcarbomb, /datum/reagent/consumable/ethanol/syndicatebomb, /datum/reagent/consumable/ethanol/erikasurprise, /datum/reagent/consumable/ethanol/driestmartini, /datum/reagent/consumable/ethanol/flaming_homer))

//Liver Toxins list
GLOBAL_LIST_INIT(liver_toxins, list(/datum/reagent/toxin, /datum/reagent/plasma, /datum/reagent/acid, /datum/reagent/acid/facid, /datum/reagent/cyanide, /datum/reagent/amanitin, /datum/reagent/carpotoxin))

//Random chem blacklist
GLOBAL_LIST_INIT(blocked_chems, list(/datum/reagent/polonium, /datum/reagent/initropidril, /datum/reagent/concentrated_initro,
							/datum/reagent/sodium_thiopental, /datum/reagent/ketamine, /datum/reagent/coniine,
							/datum/reagent/medicine/adminordrazine, /datum/reagent/medicine/adminordrazine/nanites, /datum/reagent/hellwater,
							/datum/reagent/slimetoxin, /datum/reagent/aslimetoxin, /datum/reagent/venom,
							/datum/reagent/spore, /datum/reagent/medicine/stimulants, /datum/reagent/medicine/stimulative_agent,
							/datum/reagent/medicine/syndicate_nanites, /datum/reagent/blob/ripping_tendrils, /datum/reagent/blob/boiling_oil,
							/datum/reagent/blob/envenomed_filaments, /datum/reagent/blob/lexorin_jelly, /datum/reagent/blob/kinetic,
							/datum/reagent/blob/cryogenic_liquid, /datum/reagent/liquid_dark_matter, /datum/reagent/blob/b_sorium,
							/datum/reagent/blob, /datum/reagent/consumable/ethanol/dragons_breath, /datum/reagent/medicine/nanocalcium))

GLOBAL_LIST_INIT(safe_chem_list, list(/datum/reagent/medicine/antihol, /datum/reagent/medicine/charcoal, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/insulin, /datum/reagent/medicine/teporone, /datum/reagent/medicine/silver_sulfadiazine, /datum/reagent/medicine/salbutamol,
									  /datum/reagent/medicine/omnizine, /datum/reagent/medicine/stimulants, /datum/reagent/medicine/synaptizine, /datum/reagent/medicine/potass_iodide, /datum/reagent/medicine/oculine, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/styptic_powder,
									  /datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/cryoxadone, /datum/reagent/blood, /datum/reagent/medicine/synthflesh, /datum/reagent/medicine/hydrocodone,
									  /datum/reagent/medicine/mitocholide, /datum/reagent/medicine/rezadone, /datum/reagent/medicine/menthol))

GLOBAL_LIST_INIT(safe_chem_applicator_list, list(/datum/reagent/medicine/silver_sulfadiazine, /datum/reagent/medicine/styptic_powder, /datum/reagent/medicine/synthflesh))
