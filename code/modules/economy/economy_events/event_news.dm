/datum/event_news
	var/title
	var/body
	var/author = "Nyx Daily"
	var/datum/trade_destination/topic

/datum/event_news/New(datum/trade_destination/topic_)
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

/datum/event_news/research_breakthrough/generate()
	title = "Research breakthrough at [topic.name]"
	body = "A major breakthrough in the field of [pick("plasma research","super-compressed materials","nano-augmentation","bluespace research","volatile power manipulation")] \
	was announced [pick("yesterday","a few days ago","last week","earlier this month")] by a private firm on [topic.name]. \
	Nanotrasen declined to comment as to whether this could impinge on profits."

/datum/event_news/election/generate()
	title = "Election on [topic.name]"
	body = "The pre-selection of an additional candidates was announced for the upcoming [pick("supervisors council","advisory board","governorship","board of inquisitors")] \
	election on [topic.name] was announced earlier today, \
	[pick("media mogul","web celebrity", "industry titan", "superstar", "famed chef", "popular gardener", "ex-army officer", "multi-billionaire")] \
	[random_name(pick(MALE,FEMALE))]. In a statement to the media they said '[pick("My only goal is to help the [pick("sick","poor","children")]",\
	"I will maintain Nanotrasen's record profits","I believe in our future","We must return to our moral core","Just like... chill out dudes")]'."

/datum/event_news/resignation/generate()
	var/job = pick("Sector Admiral","Division Admiral","Ship Admiral","Vice Admiral")
	title = "[job] retires"
	body = "Nanotrasen regretfully announces the resignation of [job] [random_name(pick(MALE,FEMALE))]."
	if(prob(25))
		var/locstring = pick("Segunda","Salusa","Cepheus","Andromeda","Gruis","Corona","Aquila","Asellus") + " " + pick("I","II","III","IV","V","VI","VII","VIII")
		body += " In a ceremony on [topic.name] this afternoon, they will be awarded the \
		[pick("Red Star of Sacrifice","Purple Heart of Heroism","Blue Eagle of Loyalty","Green Lion of Ingenuity")] for "
		if(prob(33))
			body += "their actions at the Battle of [pick(locstring,"REDACTED")]."
		else if(prob(50))
			body += "their contribution to the colony of [locstring]."
		else
			body += "their loyal service over the years."
	else if(prob(33))
		body += " They are expected to settle down in [topic.name], where they have been granted a handsome pension."
	else if(prob(50))
		body += " The news was broken on [topic.name] earlier today, where they cited reasons of '[pick("health","family","REDACTED")]'"
	else
		body += " Administration Aerospace wishes them the best of luck in their retirement ceremony on [topic.name]."

/datum/event_news/celebrity_death/generate()
	var/job = "Doctor"
	if(prob(33))
		job = "[pick("distinguished","decorated","veteran","highly respected")] \
		[pick("Ship's Captain","Vice Admiral","Colonel","Lieutenant Colonel")] "
	else if(prob(50))
		job = "[pick("award-winning","popular","highly respected","trend-setting")] \
		[pick("comedian","singer/songwright","artist","playwright","TV personality","model")] "
	else
		job = "[pick("successful","highly respected","ingenious","esteemed")] \
		[pick("academic","Professor","Doctor","Scientist")] "

	title = "Famous [job] dies on [topic.name]"
	body = "It is with regret today that we announce the sudden passing of the "
	body += "[job] [random_name(pick(MALE,FEMALE))] on [topic.name] [pick("last week","yesterday","this morning","two days ago","three days ago")]\
	[pick(". Assassination is suspected, but the perpetrators have not yet been brought to justice",\
	" due to Syndicate infiltrators (since captured)",\
	" during an industrial accident",\
	" due to [pick("heart failure","kidney failure","liver failure","brain hemorrhage")]")]"

/datum/event_news/bargains/generate()
	title = "Bargains"
	body = "Commerce Control on [topic.name] wants you to know that everything must go! Across all retail centres, \
	all goods are being slashed, and all retailors are onboard - so come on over for the \[shopping\] time of your life."

/datum/event_news/song_debut/generate()
	var/job = pick("Singer","Singer/songwriter","Saxophonist","Pianist","Guitarist","TV personality","Star")
	title = "[job] Debuts"
	body = "[job] [random_name(pick(MALE,FEMALE))] \
	announced the debut of their new [pick("single","album","EP","label")] '[pick("Everyone's","Look at the","Baby don't eye those","All of those","Dirty nasty")] \
	[pick("roses","three stars","starships","nanobots","cyborgs","Skrell","Sren'darr")] \
	[pick("on Venus","on Reade","on Moghes","in my hand","slip through my fingers","die for you","sing your heart out","fly away")]' \
	with [pick("pre-purchases available","a release tour","cover signings","a launch concert")] on [topic.name]."

/datum/event_news/movie_release/generate()
	var/movie_name = "[pick("Deadly","The last","Lost","Dead")] [pick("Starships","Warriors","outcasts","Tajarans","Unathi","Skrell")] \
	[pick("of","from","raid","go hunting on","visit","ravage","pillage","destroy")] \
	[pick("Moghes","Earth","Biesel","Ahdomai","S'randarr","the Void","the Edge of Space")]'."
	title = "Now in Theaters: [movie_name]"
	body = "From the [pick("desk","home town","homeworld","mind")] of [pick("acclaimed","award-winning","popular","stellar")] \
	[pick("playwright","author","director","actor","TV star")] [random_name(pick(MALE,FEMALE))] comes the latest sensation: [movie_name]. \
	Own it on webcast today, or visit the galactic premier on [topic.name]!"

/datum/event_news/big_game_hunters/generate()
	title = "Unusual specimen on [topic.name]"
	body = "Game hunters on [topic.name] "
	if(prob(33))
		body += "were surprised when an unusual species experts have since identified as \
		[pick("a subclass of mammal","a divergent abhuman species","an intelligent species of lemur","organic/cyborg hybrids")] turned up. Believed to have been brought in by \
		[pick("alien smugglers","early colonists","Syndicate raiders","unwitting tourists")], this is the first such specimen discovered in the wild."
	else if(prob(50))
		body += "were attacked by a vicious [pick("nas'r","diyaab","samak","predator which has not yet been identified")]\
		. Officials urge caution, and locals are advised to stock up on armaments."
	else
		body += "brought in an unusually [pick("valuable","rare","large","vicious","intelligent")] [pick("mammal","predator","farwa","samak")] for inspection \
		[pick("today","yesterday","last week")]. Speculators suggest they may be tipped to break several records."

/datum/event_news/gossip/generate()
	var/job = pick("TV host","Webcast personality","Superstar","Model","Actor","Singer")
	title = "[job] Makes Big Announcement"
	body = "[job] [random_name(pick(MALE,FEMALE))] "
	if(prob(33))
		body += "and their partner announced the birth of their [pick("first","second","third")] child on [topic.name] early this morning. \
		Doctors say the child is well, and the parents are considering "
		if(prob(50))
			body += capitalize(pick(GLOB.first_names_female))
		else
			body += capitalize(pick(GLOB.first_names_male))
		body += " for the name."
	else if(prob(50))
		body += "announced their [pick("split","break up","marriage","engagement")] with [pick("TV host","webcast personality","superstar","model","actor","singer")] \
		[random_name(pick(MALE,FEMALE))] at [pick("a society ball","a new opening","a launch","a club")] on [topic.name] yesterday, pundits are shocked."
	else
		body += "is recovering from plastic surgery in a clinic on [topic.name] for the [pick("second","third","fourth")] time, reportedly having made the decision in response to "
		body += "[pick("unkind comments by an ex","rumours started by jealous friends",\
		"the decision to be dropped by a major sponsor","a disastrous interview on Nyx Tonight")]."

/datum/event_news/tourism/generate()
	title = "Tourists flock to [topic.name]"
	body = "Tourists are flocking to [topic.name] after the surprise announcement of [pick("major shopping bargains by a wily retailer",\
	"a huge new ARG by a popular entertainment company","a secret tour by popular artiste [random_name(pick(MALE,FEMALE))]")]. \
	Nyx Daily is offering discount tickets for two to see [random_name(pick(MALE,FEMALE))] live in return for eyewitness reports and up to the minute coverage."
