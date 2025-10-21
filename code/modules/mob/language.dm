#define SCRAMBLE_CACHE_LEN 20

/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language"            // Fluff name of language if any.
	var/desc = "A language."                    // Short description for 'Check Languages'.
	var/speech_verb = "says"                    // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"                       // Used when sentence ends in a ?
	var/list/exclaim_verbs = list("exclaims")   // Used when sentence ends in a !
	var/whisper_verb                            // Optional. When not specified speech_verb + quietly/softly is used instead.
	var/colour = "body"                         // CSS style to use for strings in this language.
	var/key = "x"                               // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                               // Various language flags.
	var/native                                  // If set, non-native speakers will have trouble speaking.
	var/list/syllables                          // Used when scrambling text for a non-speaker.
	var/space_chance = 55                  // Likelihood of getting a space in the random scramble string.
	var/follow = 0                              // Applies to HIVEMIND languages - should a follow link be included for dead mobs?
	var/english_names = 0                       // Do we want English names by default, no matter what?
	var/list/scramble_cache = list()
	/// Do we want to override the word-join character for scrambled text? If null, defaults to " " or ". "
	var/join_override

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4)
	if(!syllables || !length(syllables) || english_names)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

	var/full_name = ""
	var/new_name = ""

	for(var/i = 0;i<name_count;i++)
		new_name = ""
		for(var/x = rand(FLOOR(syllable_count/2, 1),syllable_count);x>0;x--)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"

	return "[trim(full_name)]"

/datum/language/proc/scramble(input)

	if(!syllables || !length(syllables))
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = 1

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = 0
		scrambled_text += next
		var/chance = rand(100)
		if(!isnull(join_override))
			scrambled_text += join_override
		else if(chance <= 5)
			scrambled_text += ". "
			capitalize = 1
		else if(chance > 5 && chance <= space_chance)
			scrambled_text += " "

	scrambled_text = trim(scrambled_text)
	var/ending = copytext(scrambled_text, length(scrambled_text))
	if(ending == "." || ending == "-")
		scrambled_text = copytext(scrambled_text,1,length(scrambled_text)-1)
	var/input_ending = copytext(input, input_size)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(length(scramble_cache) > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, length(scramble_cache)-SCRAMBLE_CACHE_LEN-1)


	return scrambled_text

/datum/language/proc/format_message(message)
	return "<span class='message'><span class='[colour]'>[message]</span></span>"

/datum/language/proc/format_message_radio(message)
	return "<span class='[colour]'>[message]</span>"

/datum/language/proc/get_talkinto_msg_range(message)
	// if you yell, you'll be heard from two tiles over instead of one
	return (copytext(message, length(message)) == "!") ? 2 : 1

/datum/language/proc/broadcast(mob/living/speaker, message, speaker_mask)
	if(!check_can_speak(speaker))
		return FALSE

	var/log_message = "([name]-HIVE) [message]"
	log_say(log_message, speaker)
	speaker.create_log(SAY_LOG, log_message)

	if(!speaker_mask)
		speaker_mask = speaker.name
	var/msg = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> [get_spoken_verb(message)], [format_message(message)]</span></i>"

	for(var/mob/player in GLOB.player_list)
		if(istype(player, /mob/dead) && follow)
			var/msg_dead = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> ([ghost_follow_link(speaker, ghost=player)]) [get_spoken_verb(message)], [format_message(message)]</span></i>"
			to_chat(player, msg_dead)
			continue

		else if(istype(player, /mob/dead) || ((src in player.languages) && check_special_condition(player, speaker)))
			to_chat(player, msg)
			if((flags & HIVEMIND) && (flags & HIVEMIND_RUNECHAT) && player?.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
				player.create_chat_message(player, "[speaker_mask], [format_message(message)]")

/datum/language/proc/check_special_condition(mob/other, mob/living/speaker)
	return TRUE

/datum/language/proc/check_can_speak(mob/living/speaker)
	return TRUE

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return pick(exclaim_verbs)
		if("?")
			return ask_verb
	return speech_verb

// Noise "language", for audible emotes.
/datum/language/noise
	name = "Noise"
	desc = "Noises."
	key = ""
	flags = RESTRICTED|NONGLOBAL|INNATE|NO_TALK_MSG|NO_STUTTER

/datum/language/noise/format_message(message)
	return "<span class='message'><span class='[colour]'>[message]</span></span>"

/datum/language/noise/format_message_radio(message)
	return "<span class='[colour]'>[message]</span>"

/datum/language/noise/get_talkinto_msg_range(message)
	// if you make a loud noise (screams etc), you'll be heard from 4 tiles over instead of two
	return (copytext(message, length(message)) == "!") ? 4 : 2

/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes and the larger Unathi community. It's composed of sibilant hisses and rattles."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verbs = list("roars")
	colour = "soghun"
	key = "o"
	flags = RESTRICTED
	syllables = list("za","az","ze","ez","zi","iz","zo","oz","zu","uz","zs","sz","ha","ah","he","eh","hi","ih", \
	"ho","oh","hu","uh","hs","sh","la","al","le","el","li","il","lo","ol","lu","ul","ls","sl","ka","ak","ke","ek", \
	"ki","ik","ko","ok","ku","uk","ks","sk","sa","as","se","es","si","is","so","os","su","us","ss","ss","ra","ar", \
	"re","er","ri","ir","ro","or","ru","ur","rs","sr","a","a","e","e","i","i","o","o","u","u","s","s" )

/datum/language/unathi/get_random_name()

	var/new_name = ..()
	while(findtextEx(new_name,"sss",1,null))
		new_name = replacetext(new_name, "sss", "ss")
	return capitalize(new_name)

/datum/language/tajaran
	name = "Siik'tajr"
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. It is native to the Tajaran."
	speech_verb = "mrowls"
	ask_verb = "mrowls"
	exclaim_verbs = list("yowls")
	colour = "tajaran"
	key = "j"
	flags = RESTRICTED
	syllables = list("rr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr", \
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","thaa","dra","jurl","mah","sanu","dra","ii'r", \
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mak","hrar","nja","rir","khan","jun","dar","rik","kah", \
	"hal","ket","jurl","mah","tul","cresh","azu","ragh")

/datum/language/tajaran/get_random_name(gender)
	var/new_name = ..(gender,1)
	if(prob(80))
		new_name += " [pick("Hadii","Kaytam","Zhan-Khazan","Hharar","Njarir'Akhan")]"
	else
		new_name += " [..(gender,1)]"
	return new_name

/datum/language/vulpkanin
	name = "Canilunzt"
	desc = "A guttural language mainly spoken and utilized by the inhabitants of the Vazzend system. Its composition is primarily growls, barks, and yaps."
	speech_verb = "rawrs"
	ask_verb = "rurs"
	exclaim_verbs = list("barks")
	colour = "vulpkanin"
	key = "7"
	flags = RESTRICTED
	syllables = list("rur","ya","cen","rawr","bar","kuk","tek","qat","uk","wu","vuh","tah","tch","schz","auch", \
	"ist","ein","entch","zwichs","tut","mir","wo","bis","es","vor","nic","gro","lll","enem","zandt","tzch","noch", \
	"hel","ischt","far","wa","baram","iereng","tech","lach","sam","mak","lich","gen","or","ag","eck","gec","stag","onn", \
	"bin","ket","jarl","vulf","einech","cresthz","azunein","ghzth")

/datum/language/vulpkanin/get_random_name(gender)
	var/new_name
	if(gender == FEMALE)
		new_name = pick(GLOB.first_names_female_vulp)
	else
		new_name = pick(GLOB.first_names_male_vulp)
	new_name += " " + pick(GLOB.last_names_vulp)
	return new_name

/datum/language/skrell
	name = "Qurvolious"
	desc = "The state language of the Royal Domain of Qerballak, Qurvolious has a rich and melodious sound that flows like water."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verbs = list("warbles")
	colour = "skrell"
	key = "k"
	flags = RESTRICTED
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix","!","*")

/datum/language/vox
	name = "Vox-pidgin"
	desc = "Vox-pidgin is the primary language of Vox across the Orion arm. It is composed of chaotic shrieks, creels, and cawwing."
	speech_verb = "shrieks"
	ask_verb = "creels"
	exclaim_verbs = list("loudly skrees")
	colour = "vox"
	key = "v"
	flags = RESTRICTED | WHITELISTED
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya","yi","chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")

/datum/language/vox/get_random_name()
	var/sounds = rand(2, 8)
	var/i = 0
	var/newname = ""
	var/static/list/vox_name_syllables = list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah")
	while(i <= sounds)
		i++
		newname += pick(vox_name_syllables)
	return capitalize(newname)

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionae. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to multiple tens of individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verbs = list("rustles")
	colour = "diona"
	key = "q"
	flags = RESTRICTED
	syllables = list("hs","zt","kr","st","sh")

/datum/language/diona/get_random_name()
	var/new_name = "[pick("To Sleep Beneath", "Wind Over", "Embrace Of", "Dreams Of", "Witnessing", "To Walk Beneath", "Approaching The", "Glimmer Of", "The Ripple Of", "Colors Of", "The Still Of", "Silence Of", "Gentle Breeze Of", "Glistening Waters Under", "Child Of", "Blessed Plant-Ling Of", "Grass-Walker Of", "Element Of", "Spawn Of")]"
	new_name += " [pick("The Void", "The Sky", "Encroaching Night", "Planetsong", "Starsong", "The Wandering Star", "The Empty Day", "Daybreak", "Nightfall", "The Rain", "The Stars", "The Waves", "Dusk", "Night", "The Wind", "The Summer Wind", "The Blazing Sun", "The Scorching Sun", "Eternal Fields", "The Soothing Plains", "The Undying Fiona", "Mother Nature's Bousum")]"
	return new_name

/datum/language/trinary
	name = "Trinary"
	desc = @"A standard encoding framework used to communicate on a verbal level by robotic units. Its vocabulary consists of beeping that varies in tone and pitch. Additionally, the language features several honorifics: /[noun] for affection, \[noun] for distaste, +[noun] for speaking highly of someone, and -[noun] for speaking down on them."
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verbs = list("exclaims")
	colour = "trinary"
	key = "5"
	flags = RESTRICTED | WHITELISTED
	syllables = list("0", "1", "2")
	space_chance = 0
	join_override = ""

/datum/language/trinary/scramble(input)
	. = ..(copytext(input, 1, max(length(input) / 4, 2)))

/datum/language/trinary/get_random_name()
	var/new_name
	if(prob(70))
		new_name = "[pick("PBU","HIU","SINA","ARMA","OSI")]-[rand(100, 999)]"
	else
		new_name = pick(GLOB.ai_names)
	return new_name

/datum/language/kidan
	name = "Chittin"
	desc = "A complex form of communication, primary to the Kidan. Its sounds are formed by a combination of rubbing antennae together and expressive use of the mandibles."
	speech_verb = "rubs their antennae together"
	ask_verb = "rubs their antennae together"
	exclaim_verbs = list("rubs their antennae together")
	colour = "kidan"
	key = "4"
	flags = RESTRICTED | WHITELISTED
	syllables = list("click","clack")

/datum/language/kidan/get_random_name()
	var/new_name = "[pick("Vrax", "Krek", "Krekk", "Vriz", "Zrik", "Zarak", "Click", "Zerk", "Drax", "Zven", "Drexx", "Vrik", "Vrek", "Krax", "Varak", "Zavak", "Vrexx", "Drevk", "Krik", "Karak", "Krexx", "Zrax", "Zrexx", "Zrek", "Verk", "Drek", "Drikk", "Zvik", "Vzik", "Kviz", "Vrizk", "Vrizzk", "Krix", "Krixx", "Zark", "Xark", "Xarkk", "Xerx", "Xarak", "Karax", "Varak", "Vazak", "Vazzak", "Zirk", "Krak", "Xakk", "Zakk", "Vekk")]"
	if(prob(67))
		if(prob(50))
			new_name += ", "
			new_name += "[pick("Noble", "Worker", "Scout", "Carpenter", "Farmer", "Gatherer", "Soldier", "Guard", "Miner", "Priest", "Merchant", "Crafter", "Alchemist", "Historian", "Hunter", "Scholar", "Caretaker", "Artist", "Bard", "Blacksmith", "Brewer", "Mason", "Baker", "Prospector", "Laborer", "Hauler", "Servant")]"
			new_name += " of Clan "
		else
			new_name += " "
		new_name += "[pick("Tristan", "Zarlan", "Clack", "Kkraz", "Zramn", "Orlan", "Zrax", "Orax", "Oriz", "Tariz", "Kvestan")]"
	return new_name

/datum/language/slime
	name = "Bubblish"
	desc = "The primary language spoken by Slime People. Its vocabulary consists of bubbling, pops, and squishes."
	speech_verb = "burbles"
	ask_verb = "pops softly"
	exclaim_verbs = list("fizzes")
	colour = "slime"
	key = "f"
	flags = RESTRICTED | WHITELISTED
	syllables = list("zlu", "gl", "oo", "shl", "bl", "wob", "lur", "wh", "zz", "spl", "mur", "fl", "dro", "fru", "slu", "gle", "flo")

/datum/language/slime/get_random_name(gender)
	var/new_name
	if(gender == FEMALE)
		new_name = pick(GLOB.first_names_female_slime)
	else
		new_name = pick(GLOB.first_names_male_slime)
	new_name += " " + pick(GLOB.last_names_slime)
	return new_name

/datum/language/grey
	name = "Psionic Communication"
	desc = "The Grey's psionic communication, and a far less precise version of the telepathy of their distant cousin species. Speaks directly to other Greys within a limited radius."
	speech_verb = "expresses"
	ask_verb = "inquires"
	exclaim_verbs = list("imparts")
	colour = "abductor"
	key = "^"
	flags = RESTRICTED | HIVEMIND | NOLIBRARIAN | HIVEMIND_RUNECHAT
	follow = TRUE

/datum/language/grey/broadcast(mob/living/speaker, message, speaker_mask)
	..(speaker,message,speaker.real_name)

/datum/language/grey/check_can_speak(mob/living/speaker)
	if(speaker.mind?.miming) // Because its a hivemind, mimes would be able to speak otherwise
		to_chat(speaker,"<span class='warning'>You can't communicate without breaking your vow of silence.</span>")
		return FALSE
	if(ishuman(speaker))
		var/mob/living/carbon/human/S = speaker
		var/obj/item/organ/external/rhand = S.get_organ("r_hand")
		var/obj/item/organ/external/lhand = S.get_organ("l_hand")
		if((!rhand || !rhand.is_usable()) && (!lhand || !lhand.is_usable()))
			to_chat(speaker,"<span class='warning'>You can't communicate without the ability to use your hands!</span>")
			return FALSE
	if(HAS_TRAIT(speaker, TRAIT_HANDS_BLOCKED))
		to_chat(speaker,"<span class='warning'>You can't communicate while unable to move your hands to your head!</span>")
		return FALSE

	speaker.visible_message("<span class='notice'>[speaker] touches [speaker.p_their()] fingers to [speaker.p_their()] temple.</span>") //If placed in grey/broadcast, it will happen regardless of the success of the action.

	return TRUE

/datum/language/grey/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	if(atoms_share_level(other, speaker))
		return TRUE
	return FALSE

/datum/language/drask
	name = "Orluum"
	desc = "The droning, vibrous language of the Drask. It sounds similar to whalesong, being composed with a variety of low hums and drones."
	speech_verb = "drones"
	ask_verb = "hums"
	exclaim_verbs = list("rumbles")
	colour = "drask"
	key = "%"
	flags = RESTRICTED | WHITELISTED
	syllables = list("hoorb","vrrm","ooorm","urrrum","ooum","ee","ffm","hhh","mn","ongg")

/datum/language/drask/get_random_name()
	var/new_name = "[pick("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum")]"
	new_name += "-[pick("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum")]"
	new_name += "-[pick("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum")]"
	return new_name

/datum/language/moth
	name = "Tkachi"
	desc = "The nearly-unintelligible language of the Nian, originally native to the Garden system. Its vocabulary of buzzes and flapping make the language complex."
	speech_verb = "buzzes"
	ask_verb = "flaps"
	exclaim_verbs = list("chatters")
	colour = "moth"
	key = "#"
	flags = RESTRICTED | WHITELISTED
	join_override = "-"
	syllables = list("år", "i", "går", "sek", "mo", "ff", "ok", "gj", "ø", "gå", "la", "le",
					"lit", "ygg", "van", "dår", "næ", "møt", "idd", "hvo", "ja", "på", "han",
					"så", "ån", "det", "att", "nå", "gö", "bra", "int", "tyc", "om", "när", "två",
					"må", "dag", "sjä", "vii", "vuo", "eil", "tun", "käyt", "teh", "vä", "hei",
					"huo", "suo", "ää", "ten", "ja", "heu", "stu", "uhr", "kön", "we", "hön")

/datum/language/moth/get_random_name()
	var/new_name = "[pick("Abbot","Archer","Arkwright","Baker","Bard","Biologist","Broker","Caller","Chamberlain","Clerk","Cooper","Culinarian","Dean","Director","Duke","Energizer","Excavator","Explorer","Fletcher","Gatekeeper","Guardian","Guide","Healer","Horner","Keeper","Knight","Laidler","Mapper","Marshall","Mechanic","Miller","Navigator","Pilot","Prior","Seeker","Seer","Smith","Stargazer","Teacher","Tech Whisperer","Tender","Thatcher","Voidcrafter","Voidhunter","Voidwalker","Ward","Watcher","Weaver","Webster","Wright")]"
	new_name += "[pick(" of"," for"," in Service of",", Servant of"," for the Good of",", Student of"," to")]"
	new_name += " [pick("Alkaid","Andromeda","Antlia","Apus","Auriga","Caelum","Camelopardalis","Canes Venatici","Carinae","Cassiopeia","Centauri","Circinus","Cygnus","Dorado","Draco","Eridanus","Errakis","Fornax","Gliese","Grus","Horologium","Hydri","Lacerta","Leo Minor","Lupus","Lynx","Maffei","Megrez","Messier","Microscopium","Monocerotis","Muscae","Ophiuchi","Orion","Pegasi","Persei","Perseus","Polaris","Pyxis","Sculptor","Syrma","Telescopium","Tianyi","Triangulum","Trifid","Tucana","Tycho","Vir","Volans","Zavyava")]"
	return new_name

/datum/language/common
	name = "Galactic Common"
	desc = "Originally a carefully crafted fusion of various Human and Skrell dialects, Galactic Common is the most commonly spoken language in the Sector, and incorporates influences from nearly every known sapient species."
	exclaim_verbs = list("exclaims", "shouts", "yells")
	whisper_verb = "whispers"
	key = "9"
	flags = RESTRICTED
	syllables = list("blah","blah","blah","bleh","meh","neh","nah","wah")
	english_names = 1

/datum/language/human
	name = "Sol Common"
	desc = "An artifical language designed by the Trans-Solar Federation for ease of use and concise communication."
	exclaim_verbs = list("snaps", "shouts", "barks")
	whisper_verb = "whispers"
	colour = "solcom"
	key = "1"
	space_chance = 70
	flags = RESTRICTED
	syllables = list("ba","da","ka","ki","to","ta","sa","so","a","e","i","o","u","am","on","na","in",
					"ko",)

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	colour = "tradeband"
	key = "2"
	space_chance = 100
	syllables = list("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit",
					"sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore",
					"magna", "aliqua", "ut", "enim", "ad", "minim", "veniam", "quis", "nostrud",
					"exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo",
					"consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in",
					"voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla",
					"pariatur", "excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt",
					"in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum")

/datum/language/gutter
	name = "Gutter"
	desc = "Much like Galactic Common, this crude pidgin tongue descended from numerous languages, serving as Tradeband for criminal elements due to its ease of use and concise nature."
	speech_verb = "growls"
	ask_verb = "gnarls"
	exclaim_verbs = list("snarls")
	colour = "gutter"
	key = "3"
	syllables = list ("gra","ba","ba","breh","bra","rah","dur","ra","ro","gro","go","ber","bar","geh","heh","gra")

/datum/language/clown
	name = "Clownish"
	desc = "The language of Clown University. Mother tongue of clowns throughout the Orion arm."
	speech_verb = "honks"
	ask_verb = "honks"
	exclaim_verbs = list("toots", "wubs", "honks")
	colour = "clown"
	key = "0"
	syllables = list ("honk","squeak","bonk","toot","narf","zub","wee","wub","norf")

/datum/language/com_cygni
	name = "Cygni Standard"
	desc = "The language of revolution across the stars, initially formed as a hybrid of Russian and Mandarin Chinese by early Cygni settlers before incorporating additional influences from across Eurasia."
	speech_verb = "articulates"
	whisper_verb = "murmurs"
	exclaim_verbs = list("proclaims", "boasts", "accentuates")
	colour = "com_cygni"
	key = "?"
	space_chance = 50
	syllables = list("ai","bai","bian","che","chuang","e","fan","gan","huo","jian","jiao","ka","man","mu","nang","nuo","o","pang","pi",
					"pou","qian","qiu","rao","re","sa","sai","sheng","song","sui","tui","tu","wai","xi","xiu","xu","yan","yi","yuan","zao",
					"zei","zhang","zu","zun","a","be","ve","ge","de","ye","ka","el","em","pe","er","te","oo","kha","tse","sha","ă","â","ê",
					"ô","ơ","u","ư","th","tr","nh","yoo","eu","ya","pra","pre","pri","pro","pru","cla","cle","clo","bre","bru","ri","ca","ce",
					"po","kać","sza","sze","szo","dza","dze","dzo","tą","tę","cieć","sz","sia","sie","sio","siu","zna","zne","zno","lya","lyo",
					"lyu","lye","vna","vne","vno","ayat'","shcha","shche","mne","mno","mni","kam","tam","lam","kap","kop","sup","rip","kong",
					"tong","aan","aay","aam","klon","chorn")

/datum/language/xenocommon
	name = "Xenomorph"
	colour = "alien"
	desc = "The common tongue of the Xenomorphs, formed exclusively through hissing between speakers."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verbs = list("hisses")
	key = "6"
	flags = RESTRICTED | NOLIBRARIAN
	syllables = list("sss","sSs","SSS")

/datum/language/xenos
	name = "Hivemind"
	desc = "A psionic hivemind used for communication by Xenomorph hives over long distances."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verbs = list("hisses")
	colour = "alien"
	key = "a"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/xenos/broadcast(mob/living/speaker, message, speaker_mask)
	if(isalien(speaker))
		var/mob/living/carbon/alien/humanoid/alienspeaker = speaker
		if(alienspeaker.loudspeaker)
			return ..(speaker, "<font size=3><b>[message]</b></font>")
	return ..()

/datum/language/terrorspider
	name = "Spider Hivemind"
	desc = "Inherited from their partial Xenomorph origins, the Terror Spider hivemind functions as simple and efficient communication between members of the hive."
	speech_verb = "chitters"
	ask_verb = "chitters"
	exclaim_verbs = list("chitters")
	colour = "terrorspider"
	key = "ts"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/terrorspider/broadcast(mob/living/speaker, message, speaker_mask)
	if(isterrorspider(speaker))
		var/mob/living/simple_animal/hostile/poison/terror_spider/T = speaker
		if(T.loudspeaker)
			..(speaker, "<font size=3><b>[message]</b></font>")
			return
	..(speaker, message)

/datum/language/ling
	name = "Changeling"
	desc = "The hivemind language inherent to changelings. While its inner workings are unclear, the hivemind allows for anonymity and direct communication, similar to other hiveminds."
	colour = "changeling"
	key = "g"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/ling/broadcast(mob/living/speaker, message, speaker_mask)
	var/datum/antagonist/changeling/cling = speaker.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(cling)
		..(speaker, message, cling.changelingID)
	else
		..(speaker,message)


/datum/language/abductor
	name = "Abductor Mindlink"
	desc = "Serving as a replacement for the physical speech of Abductors, the mindlink creates a direct line of psionic communication between a scientist and their agent."
	speech_verb = "gibbers"
	ask_verb = "gibbers"
	exclaim_verbs = list("gibbers")
	colour = "abductor"
	key = "zw" //doesn't matter, this is their default and only language
	flags = RESTRICTED | HIVEMIND | NOBABEL | HIVEMIND_RUNECHAT
	follow = TRUE

/datum/language/abductor/broadcast(mob/living/speaker, message, speaker_mask)
	..(speaker,message,speaker.real_name)

/datum/language/abductor/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	if(isabductor(other) && isabductor(speaker))
		var/datum/species/abductor/A = speaker.dna.species
		var/datum/species/abductor/A2 = other.dna.species
		if(A.team == A2.team)
			return TRUE
	return FALSE

/datum/language/abductor/golem
	name = "Golem Mindlink"
	desc = "A psionic link nearly identical to that of Abductors, though showing more similarity to the Grey hivemind communication. Allows direct speech with other alien alloy golems."
	flags = RESTRICTED | HIVEMIND | NOBABEL

/datum/language/abductor/golem/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	return TRUE

/datum/language/binary
	name = "Robot Talk"
	desc = "A free-use communications protocol for synthetic use, supported by many stations through use of routing hubs built into cyborgs and AI units."
	colour = "say_quote"
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verbs = list("declares")
	key = "b"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE
	var/drone_only

/datum/language/binary/broadcast(mob/living/speaker, message, speaker_mask)
	if(!speaker.binarycheck())
		return

	if(!message)
		return

	if(HAS_TRAIT(speaker, TRAIT_MUTE))
		return

	var/log_message = "(ROBOT) [message]"
	log_say(log_message, speaker)
	speaker.create_log(SAY_LOG, log_message)

	var/list/message_start = list("<i><span class='game say'>[name], <span class='name'>[speaker.name]</span>") //Strings as lists lets you add blocks of text much easier
	var/list/message_body = list("<span class='message'>[speaker.say_quote(message)],</i><span class='robot'>\"[message]\"</span></span></span>")

	for(var/mob/M in GLOB.dead_mob_list)
		if(!isnewplayer(M) && !isbrain(M))
			var/list/message_start_dead = list("<i><span class='game say'>[name], <span class='name'>[speaker.name] ([ghost_follow_link(speaker, ghost=M)])</span>")
			var/list/dead_message = message_start_dead + message_body
			M.show_message(dead_message.Join(" "), 2)

	for(var/mob/living/S in GLOB.alive_mob_list)
		if(!S.binarycheck())
			continue
		else if(drone_only && !isdrone(S))
			continue
		else if(is_ai(S))
			message_start = list("<i><span class='game say'>[name], <a href='byond://?src=[S.UID()];track=\ref[speaker]'><span class='name'>[speaker.name]</span></a>")
		else if(isrobot(S))
			var/mob/living/silicon/robot/borg = S
			if(borg.connected_ai?.name == speaker.name)
				var/list/big_font_prefix = list("<font size=4>")
				var/list/big_font_suffix = list("</font>")
				message_start = big_font_prefix + message_start
				message_body = message_body + big_font_suffix
		var/list/final_message = message_start + message_body
		S.show_message(final_message.Join(" "), 2)

	var/list/listening = hearers(1, src)
	listening -= src

	for(var/mob/living/M in listening)
		if(issilicon(M) || M.binarycheck())
			continue
		M.show_message("<i><span class='game say'><span class='name'>synthesised voice</span> <span class='message'>beeps, \"beep beep beep\"</span></span></i>",2)

/datum/language/binary/drone
	name = "Drone Talk"
	desc = "A heavily encoded damage control coordination stream. Exclusively spoken by maintenance drones, and unable to be translated without heavy mechanical assistance."
	speech_verb = "transmits"
	ask_verb = "transmits"
	exclaim_verbs = list("transmits")
	key = "d"
	drone_only = TRUE

/datum/language/drone
	name = "Drone"
	desc = "An encrypted stream of data converted to speech patterns."
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verbs = list("declares")
	key = "]"
	flags = RESTRICTED | NOLIBRARIAN
	follow = TRUE
	syllables = list ("beep", "boop")

// Language handling.
/mob/proc/add_language(language, force)
	var/datum/language/new_language = GLOB.all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_LANGUAGE_LOCKED) && !force)
		return FALSE

	languages |= new_language
	return TRUE

/mob/proc/remove_language(rem_language, force)
	if(HAS_TRAIT(src, TRAIT_LANGUAGE_LOCKED) && !force)
		return FALSE
	var/datum/language/L = GLOB.all_languages[rem_language]
	. = (L in languages)
	languages.Remove(L)

/mob/living/remove_language(rem_language)
	. = ..()
	if(!.)
		return
	var/datum/language/L = GLOB.all_languages[rem_language]
	if(default_language == L)
		default_language = null

// Can we speak this language, as opposed to just understanding it?
/mob/proc/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking && speaking.flags & INNATE) || (speaking in languages)

//TBD
/mob/proc/check_lang_data()
	. = ""

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			. += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br><br>"

/mob/living/check_lang_data()
	. = ""

	if(default_language)
		. += "Current default language: [default_language] - <a href='byond://?src=[UID()];default_lang=reset'>reset</a><br><br>"

	for(var/datum/language/L in languages)
		if(!(L.flags & NONGLOBAL))
			if(L == default_language)
				. += "<b>[L.name] (:[L.key])</b> - default - <a href='byond://?src=[UID()];default_lang=reset'>reset</a><br>[L.desc]<br><br>"
			else
				. += "<b>[L.name] (:[L.key])</b> - <a href=\"byond://?src=[UID()];default_lang=[L]\">set default</a><br>[L.desc]<br><br>"

/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"

	var/datum/browser/popup = new(src, "checklanguage", "Known Languages", 420, 470)
	popup.set_content(check_lang_data())
	popup.open()

/mob/living/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = GLOB.all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return TRUE

/datum/language/human/monkey
	name = "Chimpanzee"
	desc = "A language of chimpering, monkey-like nonsense."
	speech_verb = "chimpers"
	ask_verb = "chimpers"
	exclaim_verbs = list("screeches")
	key = "mo"

/datum/language/skrell/monkey
	name = "Neara"
	desc = "The ancestor language to Qurvolious, with equally hard to pronounce syllables."
	key = "ne"

/datum/language/unathi/monkey
	name = "Stok"
	desc = "A language comprised of light hissing, comparable at most to Sinta'unathi."
	key = "st"

/datum/language/tajaran/monkey
	name = "Farwa"
	desc = "Simplistic and expressive in nature, the Farwa language is composed of chirps and meows."
	key = "fa"

/datum/language/vulpkanin/monkey
	name = "Wolpin"
	desc = "A guttural language with syllables of growls and barks, similar to Canilunzt."
	key = "vu"

/mob/proc/grant_all_babel_languages()
	for(var/la in GLOB.all_languages)
		var/datum/language/new_language = GLOB.all_languages[la]
		if(new_language.flags & NOBABEL)
			continue
		languages |= new_language

/datum/language/zombie
	name = "Zombie"
	desc = "The groaning language of flesh-hungry zombies. Braaaiiinsss..."
	speech_verb = "groans"
	ask_verb = "groans"
	exclaim_verbs = list("yells")
	colour = "zombie"
	key = "w"
	flags = RESTRICTED | NOLIBRARIAN
	syllables = list("Brains", "Brainssss", "Flesh", "Grrr", "Hnng", "Braaaains", "Braaiiiins")
	english_names = TRUE

/datum/language/zombie/scramble(input)
	var/terminator = "..."
	if(!length(input))
		return "[pick(syllables)][terminator]"

	var/last_letter = copytext(input, length(input))
	if(last_letter in list("?", "!"))
		terminator = last_letter

	if(prob(90) || !length(input))
		return "[pick(syllables)][terminator]"
	return "[copytext_char(input, 1, min(7, length(input)))][terminator]"

#undef SCRAMBLE_CACHE_LEN
