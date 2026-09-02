/datum/event_news/economic
	var/list/cheaper_goods
	var/list/pricier_goods

/datum/event_news/economic/riots/generate()
	title = "Riots on [topic.name]"
	body = "[pick("Riots have","Unrest has")] broken out on planet [topic.name]. Authorities call for calm, as [pick("various parties","rebellious elements","peacekeeping forces","\'REDACTED\'")] begin stockpiling weaponry and armour. Meanwhile, food and mineral prices are dropping as local industries attempt empty their stocks in expectation of looting."
	cheaper_goods = list(TRADE_GOOD_MINERALS, TRADE_GOOD_FOOD)
	pricier_goods = list(TRADE_GOOD_SECURITY)

/datum/event_news/economic/wild_animal_attack/generate()
	title = "Animal attack on [topic.name]"
	body = "Local [pick("wildlife","animal life","fauna")] on planet [topic.name] has been increasing in aggression and raiding outlying settlements for food. Big game hunters have been called in to help alleviate the problem, but numerous injuries have already occurred."
	cheaper_goods = list(TRADE_GOOD_ANIMALS)
	pricier_goods = list(TRADE_GOOD_FOOD, TRADE_GOOD_BIOMEDICAL)

/datum/event_news/economic/industrial_accident/generate()
	title = "Industrial accident on [topic.name]"
	body = "[pick("An industrial accident","A smelting accident","A malfunction","A malfunctioning piece of machinery","Negligent maintenance","A coolant leak","A ruptured conduit")] at a [pick("factory","installation","power plant","dockyards")] on [topic.name] resulted in severe structural damage and numerous injuries. Repairs are ongoing."
	pricier_goods = list(TRADE_GOOD_EMERGENCY, TRADE_GOOD_BIOMEDICAL, TRADE_GOOD_ROBOTICS)

/datum/event_news/economic/biohazard_outbreak/generate()
	title = "Viral outbreak on [topic.name]"
	body = "[pick("A \'REDACTED\'","A biohazard","An outbreak","A virus")] on [topic.name] has resulted in quarantine, stopping much shipping in the area. Although the quarantine is now lifted, authorities are calling for deliveries of medical supplies to treat the infected, and gas to replace contaminated stocks."
	pricier_goods = list(TRADE_GOOD_BIOMEDICAL, TRADE_GOOD_GAS)

/datum/event_news/economic/pirates/generate()
	title = "Attack on [topic.name]"
	body = "[pick("Pirates","Criminal elements","A [pick("Syndicate","Donk Co.","Waffle Co.","\'REDACTED\'")] strike force")] have [pick("raided","blockaded","attempted to blackmail","attacked")] [topic.name] today. Security has been tightened, but many valuable minerals were taken."
	pricier_goods = list(TRADE_GOOD_SECURITY, TRADE_GOOD_MINERALS)

/datum/event_news/economic/corporate_attack/generate()
	body = "A small [pick("pirate","Gorlex Marauders","Syndicate")] fleet has precise-jumped into proximity with [topic.name], [pick("for a smash-and-grab operation","in a hit and run attack","in an overt display of hostilities")]. Much damage was done, and security has been tightened since the incident."
	pricier_goods = list(TRADE_GOOD_SECURITY, TRADE_GOOD_MAINTENANCE)

/datum/event_news/economic/alien_raiders/generate()
	if(prob(20))
		title = "Raid on [topic.name]"
		body = "The Tiger Co-operative have raided [topic.name] today, no doubt on orders from their enigmatic masters. Stealing wildlife, farm animals, medical research materials and kidnapping civilians. Nanotrasen authorities are standing by to counter attempts at bio-terrorism."
	else
		title = "Alien raid on [topic.name]"
		body = "[pick("The alien species designated \'United Exolitics\'","The alien species designated \'REDACTED\'","An unknown alien species")] have raided [topic.name] today, stealing wildlife, farm animals, medical research materials and kidnapping civilians. It seems they desire to learn more about us, so the Navy will be standing by to accommodate them next time they try."

	pricier_goods = list(TRADE_GOOD_BIOMEDICAL, TRADE_GOOD_ANIMALS)
	cheaper_goods = list(TRADE_GOOD_GAS, TRADE_GOOD_MINERALS)

/datum/event_news/economic/ai_liberation/generate()
	title = "Technoterrorist attack on [topic.name]"
	body = "A [pick("\'REDACTED\' was detected on","S.E.L.F operative infiltrated","malignant computer virus was detected on","rogue [pick("slicer","hacker")] was apprehended on")] [topic.name] today, and managed to infect [pick("\'REDACTED\'","a sentient sub-system","a class one AI","a sentient defense installation")] before it could be stopped. Many lives were lost as it systematically begin murdering civilians, and considerable work must be done to repair the affected areas."
	pricier_goods = list(TRADE_GOOD_EMERGENCY, TRADE_GOOD_GAS, TRADE_GOOD_MAINTENANCE)

/datum/event_news/economic/mourning/generate()
	var/job = pick("professor","entertainer","singer","researcher","public servant","administrator","ship captain","\'REDACTED\'")
	var/age = rand(27, 100)
	title = "Famous [job] dies aged [age]"
	body = "[pick("The popular","The well-liked","The eminent","The well-known")] [job], [pick( random_name(pick(MALE,FEMALE)), 40; "\'REDACTED\'" )] has [pick("passed away","committed suicide","been murdered","died in a freakish accident")] on [topic.name] today. The entire planet is in mourning, and prices have dropped for industrial goods as worker morale drops."
	cheaper_goods = list(TRADE_GOOD_MINERALS, TRADE_GOOD_MAINTENANCE)

/datum/event_news/economic/cult_cell_revealed/generate()
	title = "Cult cell revealed on [topic.name]"
	body = "A [pick("dastardly","blood-thirsty","villainous","crazed")] cult of [pick("The Elder Gods","Nar'sie","an apocalyptic sect","\'REDACTED\'")] has [pick("been discovered","been revealed","revealed themselves","gone public")] on [topic.name] earlier today. Public morale has been shaken due to [pick("certain","several","one or two")] [pick("high-profile","well known","popular")] individuals [pick("performing \'REDACTED\' acts","claiming allegiance to the cult","swearing loyalty to the cult leader","promising to aid to the cult")] before those involved could be brought to justice. The editor reminds all personnel that supernatural myths will not be tolerated on Nanotrasen facilities."
	pricier_goods = list(TRADE_GOOD_SECURITY, TRADE_GOOD_BIOMEDICAL, TRADE_GOOD_MAINTENANCE)

/datum/event_news/economic/security_breach/generate()
	title = "Security breach on [topic.name]"
	body = "There was [pick("a security breach in","an unauthorized access in","an attempted theft in","an anarchist attack in","violent sabotage of")] a [pick("high-security","restricted access","classified","\'REDACTED\'")] [pick("\'REDACTED\'","section","zone","area")] this morning. Security was tightened on [topic.name] after the incident, and the editor reassures all Nanotrasen personnel that such lapses are rare."
	pricier_goods = list(TRADE_GOOD_SECURITY)

/datum/event_news/economic/animal_rights_raid/generate()
	title = "Animal rights raid on [topic.name]"
	body = "[pick("Militant animal rights activists","Members of the terrorist group Animal Rights Consortium","Members of the terrorist group \'REDACTED\'")] have [pick("launched a campaign of terror","unleashed a swathe of destruction","raided farms and pastures","forced entry to \'REDACTED\'")] on [topic.name] earlier today, freeing numerous [pick("farm animals","animals","\'REDACTED\'")]. Prices for tame and breeding animals have spiked as a result."
	pricier_goods = list(TRADE_GOOD_ANIMALS)

/datum/event_news/economic/festival/generate()
	title = "Festival on [topic.name]"
	body = "A [pick("festival","week long celebration","day of revelry","planet-wide holiday")] has been declared on [topic.name] by [pick("Governor","Commissioner","General","Commandant","Administrator")] [random_name(pick(MALE,FEMALE))] to celebrate [pick("the birth of their [pick("son","daughter")]","coming of age of their [pick("son","daughter")]","the pacification of rogue military cell","the apprehension of a violent criminal who had been terrorizing the planet")]. Massive stocks of food and meat have been bought driving up prices across the planet."
	pricier_goods = list(TRADE_GOOD_FOOD, TRADE_GOOD_ANIMALS)
