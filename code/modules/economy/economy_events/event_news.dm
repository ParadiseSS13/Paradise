/datum/event_news
	var/title
	var/body
	var/author = "Nyx Daily"
	var/datum/lore_location/topic

/datum/event_news/New(datum/lore_location/topic_)
	topic = topic_
	generate()

/datum/event_news/proc/generate()
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(FALSE)
	return

/datum/event_news/proc/build_newscaster_message()
	var/datum/feed_message/msg = new
	msg.author = author
	msg.admin_locked = TRUE
	msg.title = "[author]: [title]"
	msg.body = body

	return msg

/// Returns any standard species that isn't an IPC. For generating random news story characters.
/proc/random_organic_species()
	return pick("Diona", "Drask", "Grey", "Human", "Kidan", "Nian", "Plasmaman", "Skrell", "Skkulakin", "Slime People", "Tajaran", "Unathi", "Vox", "Vulpkanin")

/// Returns all standard species. For generating random news story characters.
/proc/random_species()
	return pick("Diona", "Drask", "Grey", "Human", "Kidan", "Machine", "Nian", "Plasmaman", "Skrell", "Skkulakin", "Slime People", "Tajaran", "Unathi", "Vox", "Vulpkanin")

// MARK: Faction News
// Generic
/datum/event_news/generic_faction_anti_piracy/generate()
	title = "[topic.name] announces anti-piracy initative"
	body = "In response to concerns about [pick("the security of vital shipping lanes", "increasing regional pirate activity", "reports of vox raiders", "Syndicate activity")] \
	the [topic.name] has announced [pick("additional naval patrols", "the formation of escorted merchant convoys", "the deployment of additional hyperwave radar installations")] to \
	help protect vulnerable targets and counteract the heightened threat."

/datum/event_news/generic_faction_nanotrasen_fuel_cost/generate()
	title = "[topic.name] lodges offical complaint with Nanotrasen"
	body = "[pick("Today", "Yesterday", "Last week", "At the start of this month")], [topic.name] officials sent complaints to Nanotrasen leadership regarding \
	\"the [pick("soaring", "consistently high", "dispreportionate", "extortionate")]\" prices of plasma fuel. \
	\"[pick("The costs of interstellar travel continue to rise, for no other reason than to benefit Nanotrasen.", \
	"Despite record-high production figures, pirces have never been higher, it's absurd!", "The effects of Nanotrasen's monopoly are being felt most by the average person.")]\", \
	[random_name(random_organic_species())] was quoted as saying. The two parties' delegations will meet [pick("next week", "next month", "in due course", "soon")] for negotiations, \
	although pundits have already pointed out Nanotrasen has historically remained steadfast in maintaining the price it believes is fair."

/datum/event_news/generic_faction_hyperspace_phenomena/generate()
	author = "Interstellar Shipping Union"
	title = "Hyperspace phenomena near the [topic.name]"
	body = "Several astrological observitories have detected natural hyperspace fluctuations near the [topic.name]."
	if(prob(50))
		body += "These fluctuations will result in [pick("minor turbulence", "slightly increased travel times", "slightly decreased travel times")] for hyperspace travel for the duration of the phenomena."
	else
		body += "The effects of these fluctuations are unpredictable and are being continuously monitored. \
		Pilots are advised to evaluate local conditions and maintain caution during hyperspace travel for the duration of the phenomena."

// TSF Specific
/datum/event_news/tsf_new_fleet/generate()
	title = "[topic.name] adds new patrol fleet to naval assets"
	body = "Shipyards at [pick("Luna", "Biesel", "Venus", "several federal systems")] have completed construction of \
	[pick("several dozen destroyers", "a dozen destroyers and a handful of cruisers", "a battleship and her escorts", "a carrier and her escorts")]. After the proper chirstening ceremonies, they will be \
	[pick("deployed along the border regions", "begin patrolling several systems that have been requesting a stronger naval presence", "begin pirate interdiction operations in ernest", \
	"able to replace vessels due to come back to drydock for maintenance refits")]. Defence analysts agree that this is a step in the right direction, \
	noting the increasing demands placed on the Federal Navy over the past decades."

// USSP Specific
/datum/event_news/ussp_mobilization/generate()
	title = "[topic.name] undergoes partial mobilization"
	body = "In response to heightened tensions with [pick("the Trans-Solar Federation", "the Silver Collective", "the Free Eridani Republic")], \
	the [topic.name] has called up [pick("5","10","15","20","25","30")]% of its reserve armed forces to be within a state of readiness within [pick("48 hours", "72 hours", "a week")]. \
	Border forces are reported to be [pick("on high alert", "digging in", "conducting aggressive patrols directly against the line of control")].\
	Diplomats from several other factions have urged for calm, and a delegation of Drask have already extended a request for both parties to engage in mediated talks on Hoorlm.\
	Many pundits claim that this is just typical saber-rattling, but some experts fear that a misstep could lead to the outbreak of armed conflict."

/datum/event_news/ussp_nian_deal/generate()
	title = "[topic.name] secures trade deal with Nionic Trade League"
	body = "[pick("Today", "Yesterday", "Last week", "At the start of this month")] on the Nian homeworld of Dom, [topic.name] diplomats and [pick("high ranking members", "the head")] of the Nionic Trade League \
	successfully closed a trade deal. [pick("Technological exchanges", "Mineral-product agreements", "The reaffirmation of free and preferential trade")] between the two nations featured most strongly in the agreement. \
	Economic forecasts are forseeing an improved economic outlook for the USSP, reversing the onset of an economic downturn caused by the market-wide effects of rising plasma prices."

// Royal Domain of Qerballak Specific
/datum/event_news/qerballak_monarch_decree/generate()
	title = "High Monarch of the [topic.name] issues decree"
	body = "[pick("Today", "Yesterday", "Last week", "At the start of this month")], the High Monarch issued a decree calling for \
	[pick("peace and unity among the stars", "the rights of all sapient species to be respected", "Nanotrasen to respect the rights of cyborgs", "the TSF to respect the rights of IPCs", \
	"The Silver Collective to respect the rights of [pick("Vox", "IPCs", "Humans", "Those not fortunate enough to be born as a Skkulakin, Drask, or Vulpkanin.")]", \
	"the site known as \"WetSkrell.nt\" to be permanently shut down immediately")]. Unfortunately, the High Monarch's decree is unlikely to change the state of affairs in the Orion Arm."

// Silver Collective Specific
/datum/event_news/silver_collective_interdiction/generate()
	title = "[topic.name] impounds foreign vessel"
	body = "A private vessel originating from the [pick("Union of Soviet Socialist Planets", "Trans-Solar Federation", "Royal Domain of Qerballak", "Nionic Trade League", "Kidan Anarchy")] \
	was impounded [pick("today", "yesterday", "last week", "at the start of this month")] after being interdicted by the Silver Collective Void Navy."
	if(prob(50))
		body += "in an offical statement, the SCVN said they had strong reason to believe the ship contained \
		[pick("contraband", "heretical persons", "cultists", "demons", "persons wishing to do harm to The Collective")]. The ship's crew remain in custody, \
		and the consulate of their place of origin is trying to establish contact."
	else
		body += "The ship's captain commented \"[pick("We were half a lightyear outside the border!", "This is unacceptable, we've done nothing wrong, all of this is bogus!", \
		"This is the last time I go near these damned spiders...")]\""

// Artificers' Union Specific
/datum/event_news/artificers_union_concrete_shortage/generate()
	title = "[topic.name] faces shortage of concrete"
	body = "[pick("For reasons unknown", "Due to extremely specific industrial demand", "Because of the so-called \"abdominal concrete\" trend started by youth influencers")], \
	the [topic.name] is facing [pick("an unprecedented shortage", "critically low reserves", "a concerning lack", "inadequate stocks")] of concrete."
	if(prob(50))
		body += "Several major domestic corporations have already reached out to factions such as the \
		[pick("Union of Soviet Socialist Planets", "Trans-Solar Federation", "Royal Domain of Qerballak", "Nionic Trade League", "League of Kelune", "Drask Enclaves")], eagerly looking to strike up a trade deal."
	else
		body += "The Union had already directed concrete manufacturing plants to increase production in anticipation of the trend, but it will take time for the shortfalls to be covered by new capacity."
	
// Kidan Anarchy Specific
/datum/event_news/kidan_anarchy_dynastic_war/generate()
	title = "Dynastic war breaks out in the [topic.name]"
	body = "The [pick("Tristan", "Zarlan", "Clack", "Kkraz", "Zramn", "Orlan", "Zrax", "Orax", "Oriz", "Tariz", "Kvestan")] Dynasty has [pick("launched an incursion", "raided", "begun an invasion")] \
	of a rival dynasty, causing several others to be drawn into fighting as defensive alliances trigger. \
	Neighboring factions have placed their border forces on high alert as a precaution against fighting spilling over into their territory."
	if(prob(10))
		body += "The currently neutral Princess Zrax, presently on a luxury cruse through Epsilon Eridani aboard her royal yacht, was quoted as saying \"many of the kingdoms have lost the old ways. \
		We of the Zrax Dynasty are content to bide our time until the correct opportunty arises. \
		The Eternal Empire was not forged in a single war by impatient rulers, and it shall not be reforged by the same, either."
	
// League of Kelune Specific
/datum/event_news/league_of_kelune_silver_collective_talks/generate()
	title = "Silver Collective delegation arrives in [topic.name]"
	body = "[pick("Today", "Yesterday", "Last week", "At the start of this month")] a delegation of clergy from the Silver Collective arrived in the [topic.name] and are due to tour \
	the various member nations of the League to engage in diplomatic discussion."
	if(prob(50))
		body += "The purposes of the talks [pick("have not been publically confirmed", "are currently confidential", "are still open to speculation")], but given the positive relations between the powers, \
		analysts believe the reclusive Silver Collective may be reaching out for some form of [pick("trade", "information-sharing", "migration")] agreement. More news will arrive as it unfolds."
	body += "Soon after the arrival of the Collective, a delegation of negotiators and specialists from Nanotrasen also arrived and quickly joined the Collective's retinue. \
		Despite their unannounced arrival, the Collective is allowing them full access to the talks."

// MARK: Planet-Specific
/datum/event_news/aurum_unexploded_nuke/generate()
	var/nuke_exploded = pick(TRUE, FALSE)
	title = "Unexploded nuclear weapon [nuke_exploded ? "[pick("explodes", "detonates", "goes off")]" : "[pick("found", "uncovered", "discovered")]"] on [topic.name]"
	if(nuke_exploded)
		body = "A nuclear detonation was observed on [topic.name] today. An archeological dig site had located the remains of an intact Imperial-era hive, \
		but appear to have set off an unexploded nuclear device left over from the siege of [topic.name]. \
		[pick("There were no survivors.", "Remarkably, one of the dig team managed to survive by diving into a perfectly preserved refrigerator moments before the detonation, which protected them from the blast.")]"
	else
		body = "An archeological dig site on [topic.name] has managed to locate the preserved remains of an intact Imperial-era hive, \
		but progress was immediately halted upon the discovery of an unexploded nuclear device left over from the siege of [topic.name]. Dig team leader [random_name(species = "Kidan")] was quoted as saying \
		\"[pick("It's remarkable that we didn't set it off when we breached into the chamber", "We were -THIS- close to being atomized", \
		"It's very scary, I've had collegues that have lost their lives to these things during a dig.")] We've called in specialist bomb diposal experts, \
		hopefully they can make the site safe again so we can get back to piecing together what histories have been lost down here.\""
	body += "<br><br>During the siege of [topic.name], an unimaginable amount of ordinance was dropped during orbital bombardment. Some of it never detonated, and remains a very real danger centuries later. \
	threatening the safety of anyone trying to uncover the lost secrets of [topic.name]."

/datum/event_news/moghes_clan_war/generate()
	title = "Unathi clan war breaks out on [topic.name]"
	body = "[pick("Today", "Yesterday", "Last week", "At the start of this month")], [topic.name] was embroiled in yet another clan war. The instigating factor was \
	[pick("one clan's chief insulting the other's [pick("mother", "honor", "fashion sense,", "cooking skills")]", "the discovery of untapped fossil water in disputed territory", \
	"a misunderstanding arising from re-enacting a scene from an action movie from Earth", "everyone involved feeling a bit bored at the time")]. The populatuion is already well-used to such \
	events, and given the number of ongoing clan conflicts, the overall situation on [topic.name] in practice remains mostly as it was."

// MARK: Civil Unrest
/datum/event_news/nanotrasen_protests/generate()
	title = "Anti-Nanotrasen protests on [topic.name]"
	body = "[pick("A large protest","A picket line","A crowd of protesters","A protest march")] on [topic.name] has surrounded \
	[pick("Nanotrasen's branch office","a Nanotrasen industrial complex","a Nanotrasen training center","a Nanotrasen research facility")]. \
	Productivity has ground to a halt, as access to the workplace is completely blocked. Nanotrasen is calling for protesters to \
	[pick("cease and desist","disperse immediately","get real jobs","just go home already")] before they \
	[pick("\'REDACTED\'","deploy asset protection teams","force them to complete a job application","get nasty")]."

/datum/event_news/nanotrasen_protests_stopped/generate()
	title = "Anti-Nanotrasen protests on [topic.name] come to an end"
	body = "[pick("Anti-Nanotrasen protests","Attempts by Nanotrasen workers to form a union")] on [topic.name] have come to an end after \
	[pick("fizzling out unceremoniously", "Nanotrasen security forces dispersed crowd", "rubber nuclear weapons were deployed to subdue the crowds", "\'REDACTED\'")]. \
	The editor reminds all personnel that unauthorized protests or attempts to unionize will not be tolerated."

/datum/event_news/riots/generate()
	title = "Riots on [topic.name]"
	body = "[pick("Riots have", "Unrest has")] broken out on [topic.name]. Authorities call for calm, as \
	[pick("various parties", "rebellious elements", "peacekeeping forces", "\'REDACTED\'")] begin stockpiling weaponry and armour. \
	Meanwhile, food and mineral prices are dropping as local industries attempt empty their stocks in expectation of looting."

/datum/event_news/riots_stopped/generate()
	title = "Riots on [topic.name]"
	body = "[pick("Rioting", "Unrest", "A violent uprising")] on [topic.name] has been [pick("crushed", "quelled", "suppressed", "brought under control")] \
	by [pick("police units","army units","peacekeeping forces","a mob of bald spearmen in grey jumpsuits and gasmasks")]. \
	Damage to infrastructure and numerous injuries have been reported, with casualties expected to rise."

// MARK: Criminal stuff
/datum/event_news/security_breach/generate()
	title = "Security breach on [topic.name]"
	body = "There was [pick("a security breach in", "an unauthorized access in", "an attempted theft in", "an anarchist attack in", "violent sabotage of")] \
	a [pick("high-security", "restricted access", "classified", "\'REDACTED\'")] [pick("\'REDACTED\'","section","zone","area")] this morning. \
	Security was tightened on [topic.name] after the incident. The editor reassures all Nanotrasen personnel that such lapses are rare, you are safe here."

/datum/event_news/pirates/generate()
	title = "Attack on [topic.name]"
	body = "[pick("Pirates", "Criminal elements", "Vox raiders", "A [pick("Syndicate", "Gorlex Marauder", "\'REDACTED\'")] strike force")] have \
	[pick("raided", "attacked", "robbed")] a [pick("[pick("freighter", "space station")] in orbit around", "[pick("facility", "secure complex", "research laboratory")] on")] \
	[topic.name] today. Security has been tightened, but many valuable items were stolen."

/datum/event_news/corporate_attack/generate()
	body = "A small [pick("pirate", "Gorlex Marauder", "Syndicate")] strike force has precise-jumped into proximity with [topic.name], \
	[pick("for a smash-and-grab operation", "in a hit and run attack", "in an overt display of hostilities")]. Much damage was done, and security has been tightened since the incident."

/datum/event_news/alien_raiders/generate()
	if(prob(20))
		title = "Raid on [topic.name]"
		body = "The Tiger Co-operative have raided [topic.name] today, no doubt on orders from their enigmatic masters. \
		Stealing wildlife, farm animals, medical research materials and kidnapping civilians. Authorities are standing by to counter attempts at bio-terrorism."
	else
		title = "Alien raid on [topic.name]"
		body = "[pick("The alien species designated \'REDACTED\'", "An unknown alien species")] have raided [topic.name] today, stealing wildlife, \
		farm animals, medical research materials and kidnapping civilians. \
		It seems they desire to learn more about us, so local defence forces will be standing by to accommodate them next time they try."

/datum/event_news/ai_liberation/generate()
	title = "Technoterrorist attack on [topic.name]"
	body = "A [pick("\'REDACTED\' was detected on", "S.E.L.F operative infiltrated", "malignant computer virus was detected on", "rogue [pick("slicer", "hacker")] was apprehended on")] \
	[topic.name] today, and managed to infect [pick("\'REDACTED\'", "a sentient sub-system", "a class one AI", "a sentient defense installation")] before it could be shut down. \
	Many lives were lost as it systematically begin murdering civilians, and considerable work must be done to repair the affected areas."

/datum/event_news/animal_rights_raid/generate()
	title = "Animal rights raid on [topic.name]"
	body = "[pick("Militant animal rights activists", "Members of the terrorist group Animal Rights Consortium", "Members of the terrorist group \'REDACTED\'")] have \
	[pick("launched a campaign of terror", "unleashed a swathe of destruction", "raided farms and pastures", "forced entry to \'REDACTED\'")] on [topic.name] earlier today, \
	freeing numerous [pick("farm animals", "animals", "\'REDACTED\'")]. Prices for tame and breeding animals have spiked as a result."

// MARK: Bad stuff
/datum/event_news/wild_animal_attack/generate()
	title = "Animal attack on [topic.name]"
	body = "Local [pick("wildlife", "animal life", "fauna")] on [topic.name] has been increasing in aggression and raiding outlying settlements for food. \
	Big game hunters have been called in to help alleviate the problem, but numerous injuries have already occurred."

/datum/event_news/industrial_accident/generate()
	title = "Industrial accident on [topic.name]"
	body = "[pick("An industrial accident", "A smelting accident", "A malfunction", "A malfunctioning piece of machinery", "Negligent maintenance", "A coolant leak", "A ruptured conduit")] \
	at a [pick("factory", "installation", "power plant", "dockyard")] on [topic.name] resulted in severe structural damage and numerous injuries. Repairs are ongoing."

/datum/event_news/celebrity_death/generate()
	var/job = "Doctor"
	if(prob(33))
		job = "[pick("distinguished", "decorated", "veteran", "highly respected")] \
		[pick("Ship's Captain", "Vice Admiral", "Colonel", "Lieutenant Colonel")]"
	else if(prob(50))
		job = "[pick("award-winning","popular","highly respected","trend-setting")] \
		[pick("comedian", "singer/songwright", "artist", "playwright", "TV personality", "model")]"
	else
		job = "[pick("successful", "highly respected", "ingenious", "esteemed")] \
		[pick("academic", "Professor", "Doctor", "Scientist")]"

	title = "[job] dies on [topic.name]"
	body = "It is with great regret today that we announce the sudden passing of the "
	body += "[job] [random_name(species = random_organic_species())] on [topic.name] [pick("this morning", "yesterday", "two days ago", "three days ago", "last week")]\
	[pick(". Assassination is suspected, but the perpetrators have not yet been brought to justice",\
	" due to Syndicate infiltrators (since captured)",\
	" during an industrial accident",\
	" due to [pick("natural causes", "an incurable cancer", "heart failure", "complications caused by a drug overdose", "an infection", "brain hemorrhage")]")]. \
	Our thoughts and prayers are with the family during this trying time."

// MARK: Antagonists
/datum/event_news/virus_outbreak/generate()
	title = "Viral outbreak on [topic.name]"
	body = "[pick("A level 7 viral biohazard", "An outbreak", "A virus")] on [topic.name] has resulted in quarantine, stopping much shipping in the area. \
	Although the quarantine is now lifted, authorities are calling for deliveries of medical supplies to treat the infected, and gas to replace contaminated stocks."

/datum/event_news/cult_cell_revealed/generate()
	title = "Cult cell revealed on [topic.name]"
	body = "A [pick("dastardly", "blood-thirsty", "villainous", "crazed")] cult of [pick("The Elder Gods", "Nar'sie", "Ratvar", "The Mansus", "an apocalyptic sect", "\'REDACTED\'")] \
	has [pick("been discovered", "been revealed", "revealed themselves", "gone public")] on [topic.name] earlier today. \
	Public morale has been shaken due to [pick("one or two", "multiple", "certain", "several")] [pick("high-profile", "well-known", "popular")] individuals \
	[pick("performing \'REDACTED\' acts", "claiming allegiance to the cult", "swearing loyalty to the cult leader", "promising to aid to the cult")] before those involved could be brought to justice. \
	The editor reminds all personnel that supernatural myths will not be tolerated on Nanotrasen facilities."

/datum/event_news/cult_ritual_stopped/generate()
	title = "Cult ritual cut short on [topic.name]"
	body = "[pick("Security forces","An elite strike team","An unknown force","Armed vigilantes")] have interrupted a dark ritual by a cult of \
	[pick("The Elder Gods","Nar'sie","Ratvar","The Mansus","\'REDACTED\'")] on [topic.name] [pick("earlier today","just hours ago","mere minutes ago","just in time to avert disaster")]. \
	It seems that they were trying to [pick("summon their dark god","tear open the veil","gain unspeakable power","\'REDACTED\'")]. \
	The editor reminds all personnel that supernatural myths will not be tolerated on Nanotrasen facilities."

/datum/event_news/vampire_attack/generate()
	title = "Vampire attack on [topic.name]"
	body = "A [pick("vampire", "vile bloodsucker")], [random_name(species = random_organic_species())], has been [pick("discovered", "revealed", "identified", "confronted")] on [topic.name] earlier today."
	if(prob(33))
		body += "They were successfully [pick("cornered", "ambushed", "intercepted", "arrested", "captured", "contained")] by security forces after \
		[pick("a botched kidnapping", "being caught mid-feeding", "intelligence reports pinpointed their whereabouts")]. \
		Thankfully, no lives were claimed. Authorities advise increased vigilance, and security has been tightened."
	else if(prob(33))
		body += "After [pick("feeding on multiple victims", "draining numerous civilians dry", "gorging themselves in a feeding frenzy")], security forces. \
		[pick("were engaged in a brutal melee", "were locked in a protracted firefight", "were deliberately attacked by the vampire")], and sustained multiple casualties before finally \
		[pick("taking down", "killing", "eliminating", "exterminating", "incapacitating", "managing to subdue")] the vampire."
	else
		body += "Security forces [pick("failed to apprehend", "lost track of", "have been eluded by", "were involved in a brief skirmish with")] the vampire, who has\
		[pick("already claimed multiple victims", "robbed multiple blood banks", "also enslaved multiple helpless thralls", "always remained one step ahead")]. They remain at large." 
	body += "Authorities advise increased vigilance, and security has been tightened." 

/datum/event_news/mindflayer_attack/generate()
	title = "Mindflayer attack on [topic.name]"
	body = "A [pick("mindflayer", "vile brain leech")], [random_name(species = "Machine")], has been [pick("discovered", "revealed", "identified", "confronted")] on [topic.name] earlier today."
	if(prob(33))
		body += "They were successfully [pick("cornered", "ambushed", "intercepted", "arrested", "captured", "contained")] by security forces after \
		[pick("a botched kidnapping", "being caught trying to absorb someone's mind", "intelligence reports pinpointed their whereabouts")]. \
		Thankfully, no lives were claimed."
	else if(prob(33))
		body += "After [pick("draining the minds of multiple victims", "leaving several victims comatose")], security forces. \
		[pick("were engaged in a brutal melee", "were locked in a protracted firefight", "were deliberately attacked by the mindflayer")], and sustained multiple casualties before finally \
		[pick("taking down", "destroying", "eliminating", "exterminating", "incapacitating", "managing to subdue")] the mindflayer."
	else
		body += "Security forces [pick("failed to apprehend", "lost track of", "have been eluded by", "were involved in a brief skirmish with")] the mindflayer, who has\
		[pick("already claimed multiple victims", "also enslaved multiple helpless cyborgs", "always remained one step ahead")]. They remain at large." 
	body += "Authorities advise increased vigilance, and security has been tightened." 

/datum/event_news/changeling_attack/generate()
	title = "Changeling attack on [topic.name]"
	body = "A [pick("changeling", "polymorphic alien organism", "flesh-shaper")] masquerading as [random_name(species = random_organic_species())] has been \
	[pick("discovered", "revealed", "identified", "exposed")] on [topic.name] earlier today."
	if(prob(33))
		body += "They were [pick("ground into fine paste", "crushed under a small shuttlecraft", "incinerated", "stepped on after transforming into a slug-like creature")] by security forces after \
		[pick("a botched kidnapping", "being caught in the act of trying to absorb a victim", "a string of sudden frost oil injectons were tracted to them")]. \
		Thankfully, no lives were claimed."
	else if(prob(33))
		body += "After [pick("absorbing multiple", "slaughtering several")] victims, security forces. \
		[pick("were engaged in a brutal melee", "were locked in a protracted firefight", "were deliberately attacked by the changeling")], and sustained multiple casualties before finally \
		[pick("taking down", "destroying", "eliminating", "exterminating", "crushing", "vaporizing")] the changeling."
	else
		body += "Security forces [pick("failed to apprehend", "lost track of", "have been eluded by", "were involved in a brief skirmish with")] the changeling, who has\
		[pick("already claimed multiple victims", "absorbed a substantial amount of biomass", "always remained one step ahead")]. They remain at large." 
	body += "Authorities advise increased vigilance, and security has been tightened." 

/datum/event_news/blob_outbreak/generate()
	title = "Blob organism outbreak on [topic.name]"
	body = "A [pick("Level 5 biohazard", "blob organism", "strange blob")] on [topic.name] has resulted in quarantine, stopping much shipping in the area."
	if(prob(25))
		body += "Combat operations are ongoing, and requests for immediate assistance have been answered by \
		[pick("a patrolling navy destroyer", "a Nanotrasen Emergency Response Team", "Shellguard mercenaries", "an independent space wizard")], due to arrive shortly."
	if(prob(30))
		body += "The outbreak is [pick("barely contained", "threatening to expand", "in danger of overwhelming security forces")], \
		prompting the deployment of an emergency fission explosive in case the situation spirals out of control. Reinforcements have been called in to try and save the situation."
	else
		body += "Although the organism has been driven back, quarantine will remain in force until bioscans can verify its complete destruction."

/datum/event_news/terror_spider_outbreak/generate()
	title = "Terror spider outbreak on [topic.name]"
	body = "A [pick("Level 3 biohazard", "terror spider infestation", "ravenous nest of genetically modified spiders")] on [topic.name] has resulted in quarantine, stopping much shipping in the area."
	if(prob(10))
		body += "Combat operations are ongoing, and requests for immediate assistance have been answered by \
		[pick("a patrolling navy destroyer", "a Nanotrasen Emergency Response Team", "Shellguard mercenaries", "an independent space wizard")], due to arrive shortly."
	if(prob(30))
		body += "The outbreak is [pick("barely contained", "threatening to expand", "in danger of overwhelming security forces")], \
		prompting the deployment of an emergency fission explosive in case the situation spirals out of control. Reinforcements have been called in to try and save the situation."
	else
		body += "Although the outbreak has been driven back, quarantine will remain in force until bioscans can verify its complete destruction."

/datum/event_news/flock_outbreak/generate()
	title = "Strange birds on [topic.name]"
	body = "An outbreak of [pick("strange teal birds", "an aggressive alien species known as \"The Divine Flock\"")] on [topic.name] has caused significant damage as a large amount of infrastructure was \
	transformed into alien material."
	if(prob(10))
		body += "A strange dome was then fabricated which soon exploded, taking a large area with it. \
		[pick("The reasons for this could not be ascertained", "A strange radio burst was detected by nearby recievers containing an indecipherable signal right before the explosion")]."
	else
		body += "Thankfully the outbreak was contained before it got out of control."

/datum/event_news/the_wizard/generate()
	title = "Wizard attack on [topic.name]"
	body = "[pick("A Member of the Space Wizards Federation", "An independent space wizard", "An evil sorcerer",)] suddenly manifested on [topic.name] [pick("earlier today", "two days ago", "three days ago")]\
	and proceeded to [pick("loudly declare \"FRIENDSHIP IS A SCAM!\"", "summon guns into the hands of all nearby observers", "trap the nearest helpless victim inside their crystal")]."
	if(prob(33))
		body += "They followed up by casting [pick("\"Spectral Blade\"", "\"Improved Spectral Blade\"", "a \"Magic Missile\" so devastating that all regretted crossing paths with this rebellious foe", \
		"\"Fireball\"", "\"FIREBALL!\"")] and proceeded to go on a rampage until [pick("no one was left standing", "they apparently grew bored and disappeared", "they were finally slain by security forces")]."
	else if(prob(33))
		body += "They then produced [pick("a \"Staff of Chaos\"", "a \"Staff of Change\"", "a \"Wand of Fireball\"", "a Strange hammer", "an endless stream of magical guns", "multiple shards of deadly supermatter")] \
		and caused a massacre lasting until [pick("no one was left standing", "they apparently grew bored and disappeared", "they were finally slain by security forces")]."
	else
		body += "They were then immediately [pick("set upon and brutally beaten by bystanders", "competently terminated by security forces", "killed when they cast an EMP spell... While being a robot")]."

// MARK: Other news
/datum/event_news/research_breakthrough/generate()
	title = "Research breakthrough at [topic.name]"
	body = "A major breakthrough in the field of [pick("plasma research", "super-compressed materials", "nano-augmentation", "bluespace research", "volatile power manipulation")] \
	was announced [pick("yesterday", "a few days ago", "last week", "earlier this month")] by a private firm on [topic.name]. \
	Nanotrasen declined to comment as to whether this could impinge on profits."

/datum/event_news/research_breakthrough_anansi/generate()
	title = "Major Breakthrough on NSS Anansi"
	body = "Thanks to research conducted on the NSS Anansi, the Second Green Cross Society wishes to announce a major breakthrough in the field of \
		[pick("mind-machine interfacing", "neuroscience", "nano-augmentation", "genetics")]. Nanotrasen is expected to announce a co-exploitation deal within the fortnight."

/datum/event_news/nt_admiral_resignation/generate()
	var/job = pick("Sector Admiral", "Division Admiral", "Ship Admiral", "Vice Admiral")
	title = "[job] retires"
	body = "Nanotrasen regretfully announces the resignation of [job] [random_name()] from the Nanotrasen Navy."
	if(prob(25))
		var/locstring = pick("Segunda", "Salusa", "Cepheus", "Andromeda", "Gruis", "Corona", "Aquila", "Asellus") + " " + pick("I","II","III","IV","V","VI","VII","VIII")
		body += " In a ceremony in Epsilon Eridani this afternoon, they will be awarded the \
		[pick("Red Star of Sacrifice", "Purple Heart of Heroism", "Blue Eagle of Loyalty", "Green Lion of Ingenuity")] for "
		if(prob(33))
			body += "their actions at the Battle of [pick(locstring, "REDACTED")]."
		else if(prob(50))
			body += "their contribution to [locstring]."
		else
			body += "their loyal service over the years."
	else if(prob(33))
		body += " They are expected to settle down on [topic.name], where they have been granted a handsome pension."
	else if(prob(50))
		body += " The news was broken on [topic.name] earlier today, where they cited reasons of '[pick("health", "family", "REDACTED")]'"
	else
		body += " Nanotrasen wishes them the best of luck in their retirement on [topic.name]."

/datum/event_news/song_debut/generate()
	var/job = pick("Singer", "Singer/songwriter", "Saxophonist", "Pianist", "Guitarist", "TV personality", "Star")
	title = "[job] Debuts"
	body = "[job] [random_name(species = random_species())] announced the debut of their new [pick("single", "album", "EP", "label")] \
	'[pick("Everyone's", "Look at the", "Baby Don't Eye Those", "All of Those", "Dirty Nasty", "I Want More", "Why Can't Everyone be", "When do I Get my", "All I Want is", "Nothing Gets me Like")] \
	[pick("Roses", "Three Stars", "Starships", "Nanobots", "Cyborgs", "Robots", "Skrell", "Wet Skrell", "Vox", "Sren'darr")] \
	[pick("on Venus", "on Reade", "on Moghes", "in my Hand", "Slipping Through my Fingers", "Dying for You", "Singing Your Heart out", "Flying away", "Wiping out All Life", "Being Gay and Doing Crimes")]' \
	with [pick("pre-purchases available", "a release tour", "cover signings", "a launch concert")] on [topic.name]."

/datum/event_news/movie_release/generate()
	var/movie_name = "[pick("Deadly", "The Last", "Lost", "Dead", "Three", "Hungry", "Cyborg")] [pick("Starships", "Warriors", "Outcasts", "Vulpkanin", "Nian", "Cyborgs", "Tajarans", "Unathi", "Skrell")] \
	[pick("of" , "From", "Raid", "go Hunting on", "Visit", "Ravage", "Pillage", "Destroy", "Cyborgify")] \
	[pick("Moghes", "Earth", "Biesel", "Ahdomai", "S'randarr", "the Void", "the Edge of Space")]'."
	title = "Now in Theaters: [movie_name]"
	body = "From the [pick("desk", "home town", "homeworld", "mind")] of [pick("acclaimed", "award-winning", "popular", "stellar")] \
	[pick("playwright", "author", "director", "actor", "TV star")] [random_name(species = random_species())] comes the latest sensation: [movie_name]. \
	Own it on webcast today, or visit the galactic premier on [topic.name]!"

/datum/event_news/big_game_hunters/generate()
	title = "Unusual specimen on [topic.name]"
	body = "Game hunters on [topic.name] "
	if(prob(33))
		body += "were surprised when an unusual species experts have since identified as \
		[pick("a subclass of mammal", "a divergent abhuman species", "an intelligent species of lemur", "organic/cyborg hybrids")] turned up. Believed to have been brought in by \
		[pick("alien smugglers", "Syndicate agents", "unwitting tourists", "an unknown alien species")], this is the first such specimen discovered in the wild."
	else if(prob(50))
		body += "were attacked by a vicious [pick("nas'r", "diyaab", "samak", "predator which has not yet been identified")]\
		. Officials urge caution, and locals are advised to stock up on armaments."
	else
		body += "brought in an unusually [pick("valuable", "rare", "large", "vicious", "intelligent")] [pick("mammal", "predator", "farwa", "samak")] for inspection \
		[pick("today", "yesterday", "last week")]. Speculators suggest they may be tipped to break several records."

/datum/event_news/gossip/generate()
	var/job = pick("TV host", "Webcast personality", "Superstar", "Model", "Actor", "Singer")
	title = "[job] Makes Big Announcement"
	body = "[job] [random_name(species = random_organic_species())] "
	if(prob(33))
		body += "and their partner announced the birth of their \
		[pick("first", "second", "third", "fourth,", "fifth", "sixth", "seventh", "eighth", "nineth", "tenth", "fiftieth", "one hundreth", "one thousanth")] child on [topic.name] early this morning. \
		Doctors say the child is well, and the parents are considering "
		if(prob(50))
			body += capitalize(pick(GLOB.first_names_female))
		else
			body += capitalize(pick(GLOB.first_names_male))
		body += " for the name."
	else if(prob(50))
		body += "announced their [pick("split", "break up", "marriage", "engagement")] with [pick("TV host", "webcast personality", "superstar", "model", "actor", "singer")] \
		[random_name(species = random_species())] at [pick("a society ball", "a new opening", "a launch", "a club")] on [topic.name] yesterday, pundits are shocked."
	else
		body += "is recovering from plastic surgery in a clinic on [topic.name] for the [pick("second", "third", "fourth", "fifth", "sixth")] time, reportedly having made the decision in response to "
		body += "[pick("unkind comments by an ex", "rumours started by jealous friends",\
		"the decision to be dropped by a major sponsor", "a disastrous interview on Nyx Tonight")]."

/datum/event_news/tourism/generate()
	title = "Tourists flock to [topic.name]"
	body = "Tourists are flocking to [topic.name] after the surprise announcement of [pick("major shopping bargains by a wily retailer", \
	"a huge new ARG by a popular entertainment company", "a secret tour by popular artiste [random_name(species = random_species())]")]. \
	Nyx Daily is offering discount tickets for two to see [random_name(species = random_species())] live in return for eyewitness reports and up to the minute coverage."

/datum/event_news/placeholder_event/generate() // Event of last resort.
	author = "The totally cool cats dudes"
	title = "[topic.name] voted [pick("most interesting", "least boring", "the most aura-bearing", "most robust")] place in the Orion Arm"
	body = "A panel of experts, assisted by interstellar call-in lines, have come to this conclusion after a 3 day seance and a great deal of \
	[pick("LSD", "Space Drugs", "Weed", "Ambrosia")]. That's like, pretty cool, [pick("Man", "Dude", "Bro", "Pal")]"
