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
	var/list/space_chance = 55                  // Likelihood of getting a space in the random scramble string.
	var/follow = 0                              // Applies to HIVEMIND languages - should a follow link be included for dead mobs?
	var/english_names = 0                       // Do we want English names by default, no matter what?
	var/list/scramble_cache = list()
	/// Do we want to override the word-join character for scrambled text? If null, defaults to " " or ". "
	var/join_override
	var/list/partial_understanding              // List of languages that can /somehwat/ understand it, format is: name = chance of understanding a word
	var/culture                                 // List of cultural languages, these are restricted to species

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4)
	if(!syllables || !syllables.len || english_names)
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

/datum/language/proc/scramble(input, list/known_languages = list())

	var/understand_chance = 0
	for(var/datum/language/L in known_languages)
		if(LAZYACCESS(partial_understanding, L.type))
			understand_chance += partial_understanding[L.type]
		if(LAZYACCESS(L.partial_understanding, src.type))
			understand_chance += L.partial_understanding[type] * 0.5

	var/scrambled_text = ""
	var/list/words = splittext(input, " ")
	for(var/w in words)
		if(prob(understand_chance))
			scrambled_text += " [w] "
		else
			var/nword = scramble_word(w)
			var/ending = copytext(scrambled_text, length(scrambled_text) - 1)
			if(findtext(ending, "."))
				nword = capitalize(nword)
			scrambled_text += nword
	scrambled_text = replacetext(scrambled_text, "  ", " ")

	scrambled_text = capitalize(scrambled_text)
	scrambled_text = trim(scrambled_text)
	var/ending = copytext(scrambled_text, length(scrambled_text))
	if(ending == ".")
		scrambled_text = copytext(scrambled_text, 1, length(scrambled_text) - 1)

	var/input_ending = copytext(input, length(input))
	if(input_ending in list("!", "?", "."))
		scrambled_text += input_ending

	return scrambled_text

/datum/language/proc/scramble_word(input)
	if(!length(syllables))
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	if(input in scramble_cache)
		var/n = scramble_cache[input]
		scramble_cache -= input
		scramble_cache[input] = n
		return n

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = TRUE

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = FALSE
		scrambled_text += next
		var/chance = rand(100)
		if(!isnull(join_override))
			scrambled_text += join_override
		else if(chance <= 5)
			scrambled_text += ". "
			capitalize = TRUE
		else if(chance > 5 && chance <= space_chance)
			scrambled_text += " "

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len-SCRAMBLE_CACHE_LEN-1)


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
		if(istype(player,/mob/dead) && follow)
			var/msg_dead = "<i><span class='game say'>[name], <span class='name'>[speaker_mask]</span> ([ghost_follow_link(speaker, ghost=player)]) [get_spoken_verb(message)], [format_message(message)]</span></i>"
			to_chat(player, msg_dead)
			continue

		else if(istype(player,/mob/dead) || ((src in player.languages) && check_special_condition(player, speaker)))
			to_chat(player, msg)

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
	desc = "Noises"
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
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
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
	desc = "The traditionally employed tongue of Ahdomai, composed of expressive yowls and chirps. Native to the Tajaran."
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
		new_name += " [pick(list("Hadii","Kaytam","Zhan-Khazan","Hharar","Njarir'Akhan"))]"
	else
		new_name += " [..(gender,1)]"
	return new_name

/datum/language/vulpkanin
	name = "Canilunzt"
	desc = "The guttural language spoken and utilized by the inhabitants of Vazzend system, composed of growls, barks, yaps, and heavy utilization of ears and tail movements.Vulpkanin speak this language with ease."
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
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verbs = list("warbles")
	colour = "skrell"
	key = "k"
	flags = RESTRICTED
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix","*","!")
	partial_understanding = list(/datum/language/common = 30)

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
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
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verbs = list("rustles")
	colour = "diona"
	key = "q"
	flags = RESTRICTED
	syllables = list("hs","zt","kr","st","sh")

/datum/language/diona/get_random_name()
	var/new_name = "[pick(list("To Sleep Beneath", "Wind Over", "Embrace Of", "Dreams Of", "Witnessing", "To Walk Beneath", "Approaching The", "Glimmer Of", "The Ripple Of", "Colors Of", "The Still Of", "Silence Of", "Gentle Breeze Of", "Glistening Waters Under", "Child Of", "Blessed Plant-Ling Of", "Grass-Walker Of", "Element Of", "Spawn Of"))]"
	new_name += " [pick(list("The Void", "The Sky", "Encroaching Night", "Planetsong", "Starsong", "The Wandering Star", "The Empty Day", "Daybreak", "Nightfall", "The Rain", "The Stars", "The Waves", "Dusk", "Night", "The Wind", "The Summer Wind", "The Blazing Sun", "The Scorching Sun", "Eternal Fields", "The Soothing Plains", "The Undying Fiona", "Mother Nature's Bousum"))]"
	return new_name

/datum/language/trinary
	name = "Trinary"
	desc = "A modification of binary to allow fuzzy logic. 0 is no, 1 is maybe, 2 is yes. Credited with giving Machine People the ability to think creatively."
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
		new_name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	else
		new_name = pick(GLOB.ai_names)
	return new_name

/datum/language/kidan
	name = "Chittin"
	desc = "The noise made by rubbing its antennae together is actually a complex form of communication for Kidan."
	speech_verb = "rubs their antennae together"
	ask_verb = "rubs their antennae together"
	exclaim_verbs = list("rubs their antennae together")
	colour = "kidan"
	key = "4"
	flags = RESTRICTED | WHITELISTED
	syllables = list("click","clack")

/datum/language/kidan/get_random_name()
	var/new_name = "[pick(list("Vrax", "Krek", "Krekk", "Vriz", "Zrik", "Zarak", "Click", "Zerk", "Drax", "Zven", "Drexx", "Vrik", "Vrek", "Krax", "Varak", "Zavak", "Vrexx", "Drevk", "Krik", "Karak", "Krexx", "Zrax", "Zrexx", "Zrek", "Verk", "Drek", "Drikk", "Zvik", "Vzik", "Kviz", "Vrizk", "Vrizzk", "Krix", "Krixx", "Zark", "Xark", "Xarkk", "Xerx", "Xarak", "Karax", "Varak", "Vazak", "Vazzak", "Zirk", "Krak", "Xakk", "Zakk", "Vekk"))]"
	if(prob(67))
		if(prob(50))
			new_name += ", "
			new_name += "[pick(list("Noble", "Worker", "Scout", "Carpenter", "Farmer", "Gatherer", "Soldier", "Guard", "Miner", "Priest", "Merchant", "Crafter", "Alchemist", "Historian", "Hunter", "Scholar", "Caretaker", "Artist", "Bard", "Blacksmith", "Brewer", "Mason", "Baker", "Prospector", "Laborer", "Hauler", "Servant"))]"
			new_name += " of Clan "
		else
			new_name += " "
		new_name += "[pick(list("Tristan", "Zarlan", "Clack", "Kkraz", "Zramn", "Orlan", "Zrax", "Orax", "Oriz", "Tariz", "Kvestan"))]"
	return new_name


/datum/language/slime
	name = "Bubblish"
	desc = "The language of slimes. It's a mixture of bubbling noises and pops. Very difficult to speak without mechanical aid for humans."
	speech_verb = "bubbles and pops"
	ask_verb = "bubbles and pops"
	exclaim_verbs = list("bubbles and pops")
	colour = "slime"
	key = "f"
	flags = RESTRICTED | WHITELISTED
	syllables = list("blob","plop","pop","bop","boop")

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
	desc = "The grey's psionic communication, less potent version of their distant cousin's telepathy. Talk to other greys within a limited radius."
	speech_verb = "expresses"
	ask_verb = "inquires"
	exclaim_verbs = list("imparts")
	colour = "abductor"
	key = "^"
	flags = RESTRICTED | HIVEMIND | NOLIBRARIAN
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
	desc = "The droning, vibrous language of the Drask. It sounds somewhat like whalesong."
	speech_verb = "drones"
	ask_verb = "hums"
	exclaim_verbs = list("rumbles")
	colour = "drask"
	key = "%"
	flags = RESTRICTED | WHITELISTED
	syllables = list("hoorb","vrrm","ooorm","urrrum","ooum","ee","ffm","hhh","mn","ongg")

/datum/language/drask/get_random_name()
	var/new_name = "[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	new_name += "-[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	new_name += "-[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	return new_name

/datum/language/moth
	name = "Tkachi"
	desc = "The language of the Nianae mothpeople borders on complete unintelligibility."
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
	var/new_name = "[pick(list("Abbot","Archer","Arkwright","Baker","Bard","Biologist","Broker","Caller","Chamberlain","Clerk","Cooper","Culinarian","Dean","Director","Duke","Energizer","Excavator","Explorer","Fletcher","Gatekeeper","Guardian","Guide","Healer","Horner","Keeper","Knight","Laidler","Mapper","Marshall","Mechanic","Miller","Navigator","Pilot","Prior","Seeker","Seer","Smith","Stargazer","Teacher","Tech Whisperer","Tender","Thatcher","Voidcrafter","Voidhunter","Voidwalker","Ward","Watcher","Weaver","Webster","Wright"))]"
	new_name += "[pick(list(" of"," for"," in Service of",", Servant of"," for the Good of",", Student of"," to"))]"
	new_name += " [pick(list("Alkaid","Andromeda","Antlia","Apus","Auriga","Caelum","Camelopardalis","Canes Venatici","Carinae","Cassiopeia","Centauri","Circinus","Cygnus","Dorado","Draco","Eridanus","Errakis","Fornax","Gliese","Grus","Horologium","Hydri","Lacerta","Leo Minor","Lupus","Lynx","Maffei","Megrez","Messier","Microscopium","Monocerotis","Muscae","Ophiuchi","Orion","Pegasi","Persei","Perseus","Polaris","Pyxis","Sculptor","Syrma","Telescopium","Tianyi","Triangulum","Trifid","Tucana","Tycho","Vir","Volans","Zavyava"))]"
	return new_name


///Human misc langauges, able to be learnt by every species, however are some origin from Humans
/datum/language/common //This is the default language everyone should obviously start with, so its always going to be given to crew members unless something something admins
	name = "Galactic Common"
	desc = "A fusion of Human and Skrellian dialects, it stands as one of the most universally comprehended languages throughout the Orion Sector. It has gained immense popularity, particularly within the Trans-Solar Federation, where it serves as a common tongue understood by virtually all its inhabitants, whether they hail from the planets or the stars. Proficiency in Galactic Common has become almost mandatory for securing employment or prospects within Human or Skrell territory. Its widespread usage and long history have contributed to making Galactic Common one of the easiest and most straightforward languages to learn."
	speech_verb = "says"
	exclaim_verbs = list("exclaims", "shouts", "yells")
	whisper_verb = "whispers"
	key = "9"
	flags = RESTRICTED
	syllables = list("blah","blah","blah","bleh","meh","neh","nah","wah")
	english_names = 1
	partial_understanding = list(/datum/language/skrell = 30, /datum/language/sol = 30)

/datum/language/spacer
	name = "Spacer"
	desc = "One of the earliest human languages devised during the pioneering days of space exploration, it was originally crafted to facilitate communication during diplomatic exchanges between the Solar-Central Compact and various alien species. Over time, it was eventually superseded by the simpler and more widespread Galactic Common, which gained prominence due to its ease of use. However, Spacer retained its popularity, particularly among spacefaring nomads, explorers, and those with a strong connection to space. It has endured as a language associated with those of Spacer heritage and remains in common use among individuals dwelling long-term on space stations and starships."
	colour = "spacer"
	key = "s"
	partial_understanding = list(
		/datum/language/euro = 25,
		/datum/language/yangyu = 25,
		/datum/language/iberian = 25,
		/datum/language/com_srus = 25,
		/datum/language/trader = 25,
		/datum/language/gutter = 35,
		/datum/language/skrell = 10
	)
	syllables = list(
		"ada", "zir", "bian", "ach", "usk", "ado", "ich", "cuan", "iga", "qing", "le", "que", "ki", "qaf", "dei", "eta"
	)

// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "With its origins dating back to Mars during the period of rapid corporate expansion into other Trans-Solar Federation colonies, particularly within Skrell space, it has earned widespread popularity among corporations and commerce enthusiasts. Originally developed to streamline the process of bargaining and negotiations, Tradeband's frequency became associated with affluent individuals. Over time, it evolved into a distinct language among the sector's aristocrats and traders, reflecting its prominent role in the realm of interstellar business and corporate prestige. It sounds posh and snappy when heard, with occasional wavy tones mixed in."
	speech_verb = "enunciates"
	colour = "say_quote"
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
	partial_understanding = list(
		/datum/language/euro = 30,
		/datum/language/skrell = 40,
		/datum/language/spacer = 20
	)

/datum/language/gutter
	name = "Gutter"
	desc = "Originating on Pluto due to its unusual pronunciation and dissonant sounds, Gutter quickly gained notoriety as a language used primarily in seedy and criminal circles across space. Over time, it expanded far beyond Pluto's borders, becoming synonymous with nefarious activities and adding layers of complexity to covert communication. Gutter is prevalent in regions where poverty and criminality are rife, with most speakers acquiring the language through their upbringing in such environments or by associating closely with shady, often unlawful, associates."
	speech_verb = "growls"
	ask_verb = "gnarls"
	exclaim_verbs = list("snarls")
	colour = "gutter"
	key = "3"
	syllables = list ("gra","ba","ba","breh","bra","rah","dur","ra","ro","gro","go","ber","bar","geh","heh","gra")
	partial_understanding = list(
		/datum/language/euro = 5,
		/datum/language/gutter = 10,
		/datum/language/spacer = 20
	)

/datum/language/clown
	name = "Clownish"
	desc = "The language derived from the fervent worship of the Honk Mother has its origins in an ancient circus performer from the 21st century. This performer's acts and eccentric shows captivated audiences worldwide, leading to the creation of a cult of personality around her. Over time, this following evolved into a legally recognized religious group dedicated to the teachings and gospel of the Honk Mother. Within this religious community, Clownish developed as an internal language spoken by those devoted to the arts of entertainment and the venerable traditions associated with the clown arts."
	speech_verb = "honks"
	ask_verb = "honks"
	exclaim_verbs = list("toots", "wubs", "honks")
	colour = "clown"
	key = "0"
	syllables = list ("honk","squeak","bonk","toot","narf","zub","wee","wub","norf")

/datum/language/sol
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	speech_verb = "says"
	exclaim_verbs = list("exclaims", "shouts", "yells")
	whisper_verb = "whispers"
	colour = "solcom"
	key = "1"
	culture = LANGUAGE_HUMAN
	syllables = list("tao", "shi", "tzu", "yi", "com", "be", "is", "i", "op", "vi", "ed", "lec", "mo", "cle", "te", "dis", "e")
	english_names = 1

/datum/language/com_srus
	name = "Neo-Russkiya"
	desc = "Derived from Old Slavic and various European dialects, Neo-Russkiya is the linguistic offspring of ancient tongues that now follow Northern Eurasian culture, particularly under the USSP government. The sheer scale of the USSP's dominion and the migration of its populace have propelled Neo-Russkiya to the forefront, making it the primary language. It sounds blunt and harsh when heard and composed of mostly consonants and vowels."
	speech_verb = "articulates"
	whisper_verb = "mutters"
	exclaim_verbs = list("exaggerates")
	colour = "com_srus"
	key = "?"
	space_chance = 65
	english_names = 1
	syllables = list("dyen","bar","bota","vyek","tvo","slov","slav","syen","doup","vah","laz","gloz","yet",
					"nyet","da","sky","glav","glaz","netz","doomat","zat","moch","boz",
					"comy","vrad","vrade","tay","bli","ay","nov","livn","tolv","glaz","gliz",
					"ouy","zet","yevt","dat","botat","nev","novy","vzy","nov","sho","obsh","dasky",
					"key","skey","ovsky","skaya","bib","kiev","studen","var","bul","vyan",
					"tzion","vaya","myak","gino","volo","olam","miti","nino","menov","perov",
					"odasky","trov","niki","ivano","dostov","sokol","oupa","pervom","schel",
					"tizan","chka","tagan","dobry","okt","boda","veta","idi","cyk","blyt","hui","na",
					"udi","litchki","casa","linka","toly","anatov","vich","vech","vuch","toi","ka","vod")

/datum/language/iberian
	name = "Iberian Mix"
	desc = "A dialect that emerges from the fusion of Spanish and Northern African languages. Its popularity took root in the Iberian Peninsula and Northern Africa. Over time, Iberian would gradually supersede traditional Spanish and North African languages due to its linguistic simplicity and its ability to harmoniously blend different cultural vowels. Its words tend to flow seamlessly and have a natural rhythm."
	colour = "iberian"
	key = "i"
	culture = LANGUAGE_HUMAN
	partial_understanding = list(
		/datum/language/euro = 30,
		/datum/language/trader = 15,
		/datum/language/spacer = 20
	)
	syllables = list(
		"ad", "al", "an", "ar", "as", "ci", "co", "de", "do", "el", "en", "er", "es",
		"ie", "ue", "la", "ra", "os", "nt", "te", "ar", "qu", "el", "ta", "do", "co",
		"re", "as", "on", "aci", "ada", "ado", "ant", "ara", "cio", "com", "con", "des",
		"dos", "ent", "era", "ero", "que", "ent", "nte", "est", "ado", "par", "los", "ien",
		"sta", "una", "ion", "tra", "men", "ele", "nao", "uma", "ame", "dos", "uno", "mas",
		"ndo", "nha", "ver", "voc", "uma"
	)

/datum/language/iberian/get_random_name()
	var/new_name = "[pick(list("Diego", "Isabella", "Carlos", "Sofia", "Mateo", "Lucia", "Javier", "Elena", "Miguel", "Carmen", "Rafael", "Ana", "Luis", "Maria", "Fernando", "Clara", "Alejandro", "Teresa", "Juan", "Rosa", "Pedro", "Patricia", "Francisco", "Lorena", "Sergio", "Alicia", "Antonio", "Marisol", "Jorge", "Consuelo", "Raul", "Pilar", "Pablo", "Esperanza", "Alberto", "Natalia", "Enrique", "Gabriela", "Manuel", "Raquel", "Ricardo", "Beatriz", "Adrian", "Sonia", "Alvaro", "Silvia", "Oscar", "Cristina", "Victor", "Marta", "Angel", "Yolanda", "José", "Carla", "Eduardo", "Dolores", "Gonzalo", "Irene", "Roberto", "Ana María", "David", "Eva María", "Samuel", "Luisa", "César", "Inés", "Marcos", "Rocío", "Esteban", "Elsa", "Andrés", "Amalia", "Domingo", "Elisa", "Ramón", "Fátima", "José Luis", "Blanca", "Felipe", "Lidia", "Hugo", "Noelia"))]"
	new_name += " "
	new_name += "[pick(list("Garcia", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Perez", "Sanchez", "Ramirez", "Torres", "Flores", "Rivera", "Gomez", "Diaz", "Reyes", "Morales", "Cruz", "Ortiz", "Gutierrez", "Ramos", "Ruiz", "Alvarez", "Vasquez", "Castillo", "Santos", "Mendez", "Guerrero", "Ortega", "Castro", "Vargas", "Fernandez", "Garcia", "Jimenez", "Moreno", "Romero", "Herrera", "Medina", "Aguilar", "Alvarado", "Rojas", "Soto", "Delgado", "Pena", "Rios", "Alonso", "Vega", "Suarez", "Dominguez", "Luna", "Navarro", "Campos", "Bautista", "Vazquez", "Molina", "Iglesias", "Silva", "Ortiz", "Nunez", "Aguirre", "Paredes", "Arroyo", "Cordero", "Salazar", "Mora", "Rivas", "Benitez", "Reyes", "Hidalgo", "Merino", "Cano", "Araujo", "Vidal", "Andrade", "Gallegos", "Cuenca", "Montoya", "Calderon", "Esteban", "Cabrera", "Lemos", "Serrano", "Rosales", "Oliveira", "Teixeira", "Correia", "Mendes", "Barros", "Ferreira", "Sousa", "Machado", "Azevedo", "Figueiredo", "Lourenço", "Gomes", "Carvalho", "Costa", "Martins", "Jesus", "Pinto", "Afonso", "Rocha", "Ribeiro", "Dias", "Almeida", "Simões", "Duarte", "Baptista", "Barbosa", "Magalhães", "Leite", "Lima", "Marques", "Nascimento", "Oliveira", "Pereira", "Santos", "Silva", "Soares", "Vieira", "Borges", "Cardoso", "Carneiro", "Cruz", "Domingues", "Fernandes", "Fonseca", "Freitas", "Henriques", "Leal", "Macedo", "Melo", "Mendes", "Miranda", "Monteiro", "Morais", "Moreira", "Moura", "Neves", "Nobre", "Nunes", "Paiva", "Pinheiro", "Quintas", "Ramos", "Reis", "Sampaio", "Santana", "Saraiva", "Serra", "Tavares", "Valente", "Valentim", "Vasconcelos", "Vaz", "Vicente"))]"
	return new_name

/datum/language/euro
	name = "Euro Accord"
	desc = "A language that draws its roots from French, Germania, and English dialects, combining the linguistic and cultural traditions of old Western Europe. With its distinctive speech patterns, Euro Accord stands as one of the most anciently evolved languages in human history, being the predecessor of the English language. It sounds nasally and very congested when spoken, but compact enough to be short and to the point."
	colour = "euro"
	speech_verb = "says"
	whisper_verb = "whispers"
	key = "e"
	culture = LANGUAGE_HUMAN
	partial_understanding = list(
		/datum/language/yangyu = 5,
		/datum/language/iberian = 30,
		/datum/language/com_srus = 5,
		/datum/language/trader = 85,
		/datum/language/spacer = 20
	)
	syllables = list(
		"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
		"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
		"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
		"ch", "de", "ge", "be", "ach", "abe", "ich", "ein", "die", "sch", "auf", "aus", "ber", "che", "ent", "que",
		"ait", "les", "lle", "men", "ais", "ans", "ait", "ave", "con", "com", "des", "tre", "eta", "eur", "est",
		"ing", "the", "ver", "was", "ith", "hin"
	)

/datum/language/euro/get_random_name()
	var/new_name = "[pick(list("Emile", "Annette", "Gustav", "Sophie", "Henrik", "Charlotte", "Franz", "Louise", "Maximilian", "Helene", "Wolfgang", "Marie", "Klaus", "Elisabeth", "Otto", "Mathilde", "Rudolf", "Giselle", "Dieter", "Brigitte", "Hans", "Nadine", "Johann", "Klara", "Siegfried", "Hanna", "Gunther", "Margot", "Gerhard", "Ingrid", "Alfred", "Anneliese", "Friedrich", "Ursula", "Ludwig", "Renate", "Erik", "Isabelle", "Martin", "Eva", "Peter", "Liselotte", "Bernd", "Susanne", "Christian", "Caroline", "Paul", "Heike", "Georg", "Sabine", "Alexander", "Birgit", "Thomas", "Daniela", "Andreas", "Petra", "Michael", "Silke", "Stefan", "Monika", "Karl", "Julia", "Rainer", "Katrin", "Oliver", "Kristin", "Manfred", "Sarah", "Norbert", "Laura", "Joachim", "Nicole", "Werner", "Barbara", "Uwe", "Sandra", "Kurt", "Angelika"))]"
	new_name += " "
	new_name += "[pick(list("Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit", "Durand", "Leroy", "Moreau", "Simon", "Laurent", "Lefebvre", "Michel", "Garcia", "David", "Bertrand", "Roux", "Vincent", "Fournier", "Morel", "Girard", "Andre", "Lefevre", "Mercier", "Dupont", "Lambert", "Bonnet", "Francois", "Martinez", "Legrand", "Garnier", "Faure", "Rousseau", "Blanc", "Guerin", "Muller", "Henry", "Roussel", "Nicolas", "Perrin", "Morin", "Mathieu", "Clement", "Gauthier", "Dumont", "Lopez", "Fontaine", "Chevalier", "Robin", "Masson", "Sanchez", "Gerard", "Monnier", "Meyer", "Martel", "Marechal", "Deschamps", "Perrot", "Daniel", "Cousin", "Richardson", "Schmidt", "Weber", "Hoffmann", "Klein", "Wagner", "Schneider", "Fischer", "Schmidt", "Schultz", "Werner", "Koch", "Bauer", "Richter", "Klein", "Wolf", "Schröder", "Neumann", "Schwarz", "Zimmermann", "Braun", "Krüger", "Hofmann", "Hartmann", "Lange", "Schmitt", "Werner", "Schmid", "Weiss", "Lang", "Jung", "Hahn", "Schubert", "Vogel", "Friedrich", "Keller", "Günther", "Frank", "Berger", "Winkler", "Roth", "Becker", "Köhler", "Ziegler", "Krause", "Kramer", "Mohr", "Fuchs", "Scholz", "Voigt", "Spencer", "Murray", "Freeman", "Carroll", "Duncan", "Hogan", "McKenna", "Hopkins", "Hawkins", "Willis", "Graham", "Sullivan", "Wallace", "Woods", "Cole", "West", "Jordan", "Owens", "Reynolds", "Fisher", "Ellis", "Harrison", "Gibson", "McDonald", "Cruz", "Marshall", "Ortiz", "Gomez", "Murray", "Freeman", "Wells", "Webb", "Simpson", "Stevens", "Tucker", "Porter", "Hunter", "Hicks", "Crawford", "Henry", "Boyd", "Mason", "Morales", "Kennedy", "Warren", "Dixon", "Ramos", "Reyes", "Burns", "Gordon", "Shaw", "Holmes", "Rice", "Robertson", "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant", "Knight", "Ferguson", "Rose", "Stone", "Hawkins", "Dunn", "Perkins", "Hudson", "Spencer", "Gardner", "Stephens", "Payne", "Pierce", "Berry", "Matthews", "Arnold", "Wagner", "Willis", "Ray", "Watkins", "Olson", "Carroll", "Duncan", "Snyder", "Hart", "Cunningham", "Bradley", "Lane", "Andrews", "Ruiz", "Harper", "Fox", "Riley", "Armstrong", "Carpenter", "Weaver", "Greene", "Lawrence", "Elliott", "Chavez", "Sims", "Austin", "Peters", "Kelley", "Franklin", "Lawson"))]"
	return new_name

/datum/language/yangyu
	name = "Yangyu"
	desc = "A simplified version of Mandarin Chinese adapted to the Latin script, is the predominant language spoken across Asia on Earth. Its influence has extended beyond Earth's borders, making it the modern choice for many Asian communities, both on their home planets and in space. It sounds bouncy and lively when heard, having many upward and downward audio cues within it."
	colour = "yangyu"
	key = "c"
	culture = LANGUAGE_HUMAN
	space_chance = 30
	partial_understanding = list(
		/datum/language/euro = 5,
		/datum/language/trader = 10,
		/datum/language/spacer = 20
	)
	syllables = list(
		"a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao",
		"bie", "bin", "bing", "bo", "bu", "ca", "cai", "can", "cang", "cao", "ce", "cei", "cen", "ceng", "cha", "chai",
		"chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chua", "chuai", "chuan", "chuang", "chui", "chun",
		"chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei",
		"den", "deng", "di", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e",
		"ei", "en", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu", "ga", "gai", "gan", "gang",
		"gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha",
		"hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hm", "hng", "hong", "hou", "hu", "hua", "huai", "huan",
		"huang", "hui", "hun", "huo", "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan",
		"jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "kei", "ken", "keng", "kong", "kou", "ku", "kua", "kuai",
		"kuan", "kuang", "kui", "kun", "kuo", "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian",
		"liang", "liao", "lie", "lin", "ling", "liu", "long", "lou", "lu", "luan", "lun", "luo", "ma", "mai", "man", "mang",
		"mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu", "na",
		"nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ng", "ni", "nian", "niang", "niao", "nie", "nin", "ning",
		"niu", "nong", "nou", "nu", "nuan", "nuo", "o", "ou", "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng",
		"pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin",
		"qing", "qiong", "qiu", "qu", "quan", "que", "qun", "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou",
		"ru", "rua", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sei", "sen", "seng", "sha",
		"shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui",
		"shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo", "ta", "tai", "tan", "tang", "tao", "te",
		"teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan",
		"wang", "wei", "wen", "weng", "wo", "wu", "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu",
		"xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yong", "you", "yu", "yuan",
		"yue", "yun", "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao",
		"zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi",
		"zong", "zou", "zuan", "zui", "zun", "zuo", "zu"
	)

/datum/language/yangyu/get_random_name()
	var/new_name = "[pick(list("Akira", "Aiko", "Haruki", "Emi", "Hiroshi", "Yuki", "Sakura", "Kenzo", "Ayumi", "Riku", "Sora", "Miyuki", "Ren", "Kai", "Naomi", "Rin", "Yuna", "Takashi", "Asuka", "Haru", "Keiko", "Kazuki", "Satsuki", "Toshiro", "Mei", "Daichi", "Amaya", "Hikaru", "Eriko", "Kaito", "Misaki", "Haruka", "Kazumi", "Shin", "Yoko", "Noboru", "Hana", "Taiki", "Mika", "Hiroko", "Yoshiro", "Natsuki", "Tsubasa", "Yumi", "Akari", "Ryota", "Rika", "Tatsu", "Megumi", "Yukio", "Mao", "Kazuhiro", "Hinata", "Eiji", "Hanae", "Kenshin", "Yoshiko", "Daisuke", "Yoshimi", "Kazuo", "Natsumi", "Shiori", "Yasuo", "Yui", "Itsuki", "Mitsuki", "Ryo", "Yoshida", "Rei", "Nariko", "Takumi", "Izumi", "Akio", "Mizuki", "Kiyomi", "Satoshi", "Ayane", "Kanako", "Hideki", "Chiyo", "Nori", "Kaori", "Tomo", "Aimi", "Kiyoshi", "Haruko", "Taiga", "Eiko", "Kenji", "Sakiko", "Yoshio", "Maki", "Takako", "Kaito", "Miyako"))]"
	new_name += " "
	new_name += "[pick(list("Tanaka" , "Suzuki", "Yamamoto", "Nakamura", "Kobayashi", "Kato", "Sato", "Ito", "Yoshida", "Yamada", "Sasaki", "Yamaguchi", "Matsumoto", "Inoue", "Kimura", "Shimizu", "Hayashi", "Shin", "Sakamoto", "Ishikawa", "Mori", "Hashimoto", "Maeda", "Murakami", "Fujita", "Okada", "Takahashi", "Nakajima", "Tamura", "Abe", "Kaneko", "Ishii", "Hasegawa", "Ogawa", "Arai", "Ono", "Mizuno", "Kojima", "Fujii", "Kawamura", "Itoh", "Shibata", "Kudo", "Yano", "Eto", "Noguchi", "Shibuya", "Imai", "Takada", "Matsui", "Hara", "Hosokawa", "Murata", "Komatsu", "Fukuda", "Iwasaki", "Otsuka", "Shoji", "Kawakami", "Sugiyama", "Ogata", "Maruyama", "Ueno", "Ota", "Takeda", "Taniguchi", "Tamura", "Morita", "Yonezawa", "Uchida", "Kubo", "Yamashita", "Ueda", "Kawashima", "Morikawa", "Iwata", "Sasaki", "Fujimoto", "Nakano", "Saito", "Kudo", "Iwamoto", "Nishimura", "Ikeuchi", "Yoshimura", "Akiyama", "Nishida", "Higuchi", "Kojima", "Igarashi", "Aoki", "Higashiyama"))]"
	return new_name

/datum/language/xenocommon
	name = "Xenomorph"
	colour = "alien"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verbs = list("hisses")
	key = "6"
	flags = RESTRICTED | NOLIBRARIAN
	syllables = list("sss","sSs","SSS")

/datum/language/xenos
	name = "Hivemind"
	desc = "Xenomorphs have the strange ability to commune over a psychic hivemind."
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
	desc = "Terror spiders have a limited ability to commune over a psychic hivemind, similar to xenomorphs."
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
	desc = "Although they are normally wary and suspicious of each other, changelings can commune over a distance."
	speech_verb = "says"
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
	desc = "Abductors are incapable of speech, but have a psychic link attuned to their own team."
	speech_verb = "gibbers"
	ask_verb = "gibbers"
	exclaim_verbs = list("gibbers")
	colour = "abductor"
	key = "zw" //doesn't matter, this is their default and only language
	flags = RESTRICTED | HIVEMIND | NOBABEL
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
	desc = "Communicate with other alien alloy golems through a psychic link."

/datum/language/abductor/golem/check_special_condition(mob/living/carbon/human/other, mob/living/carbon/human/speaker)
	return TRUE

/datum/language/binary
	name = "Robot Talk"
	desc = "Most human stations support free-use communications protocols and routing hubs for synthetic use."
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
		else if(isAI(S))
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
	desc = "A heavily encoded damage control coordination stream."
	speech_verb = "transmits"
	ask_verb = "transmits"
	exclaim_verbs = list("transmits")
	colour = "say_quote"
	key = "d"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	drone_only = TRUE
	follow = TRUE

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
/mob/proc/add_language(language)
	var/datum/language/new_language = GLOB.all_languages[language]

	if(!istype(new_language) || (new_language in languages))
		return FALSE

	languages |= new_language
	return TRUE

/mob/proc/remove_language(rem_language)
	var/datum/language/L = GLOB.all_languages[rem_language]
	. = (L in languages)
	languages.Remove(L)

/mob/living/remove_language(rem_language)
	var/datum/language/L = GLOB.all_languages[rem_language]
	if(default_language == L)
		default_language = null
	return ..()

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
	set src = usr

	var/datum/browser/popup = new(src, "checklanguage", "Known Languages", 420, 470)
	popup.set_content(check_lang_data())
	popup.open()

/mob/living/Topic(href, href_list)
	if(href_list["default_lang"])
		if(href_list["default_lang"] == "reset")
			set_default_language(null)
		else
			var/datum/language/L = GLOB.all_languages[href_list["default_lang"]]
			if(L)
				set_default_language(L)
		check_languages()
		return TRUE
	else
		return ..()

/datum/language/monkey
	name = "Chimpanzee"
	desc = "Ook ook ook."
	speech_verb = "chimpers"
	ask_verb = "chimpers"
	exclaim_verbs = list("screeches")
	flags = RESTRICTED
	key = "mo"

/datum/language/skrell/monkey
	name = "Neara"
	desc = "Squik squik squik."
	flags = RESTRICTED
	key = "ne"

/datum/language/unathi/monkey
	name = "Stok"
	desc = "Hiss hiss hiss."
	flags = RESTRICTED
	key = "st"

/datum/language/tajaran/monkey
	name = "Farwa"
	desc = "Meow meow meow."
	flags = RESTRICTED
	key = "fa"

/datum/language/vulpkanin/monkey
	name = "Wolpin"
	desc = "Bark bark bark."
	flags = RESTRICTED
	key = "vu"

/mob/proc/grant_all_babel_languages()
	for(var/la in GLOB.all_languages)
		var/datum/language/new_language = GLOB.all_languages[la]
		if(new_language.flags & NOBABEL)
			continue
		languages |= new_language

#undef SCRAMBLE_CACHE_LEN
