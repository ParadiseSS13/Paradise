/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language" // Fluff name of language if any.
	var/desc = "A language."         // Short description for 'Check Languages'.
	var/speech_verb = "says"         // 'says', 'hisses', 'farts'.
	var/colour = "say_quote"         // CSS style to use for strings in this language.
	var/key = "x"                    // Character used to speak in language eg. :o for Unathi.
	var/flags = 0                    // Various language flags.
	var/native                       // If set, non-native speakers will have trouble speaking.

/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	colour = "soghun"
	key = "o"
	flags = WHITELISTED

/datum/language/tajaran
	name = "Siik'tajr"
	desc = "An expressive language that combines yowls and chirps with posture, tail and ears. Native to the Tajaran."
	speech_verb = "mrowls"
	colour = "tajaran"
	key = "j"
	flags = WHITELISTED

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	colour = "skrell"
	key = "k"
	flags = WHITELISTED

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	colour = "vox"
	key = "v"
	flags = RESTRICTED

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	colour = "soghun"
	key = "q"
	flags = RESTRICTED

/datum/language/kidan
	name = "Chittin"
	desc = "The noise made by rubbing it's antennae together is actually a complex form of communication for Kidan."
	speech_verb = "rubs it's antenna together"
	colour = "tajaran"
	key = "4"
	flags = RESTRICTED

/datum/language/slime
	name = "Bubblish"
	desc = "Languages of slimes, a mixture of bubbling noises and pops. Almost impossible to speak without mechanical aid for non slime people."
	speech_verb = "bubbles and pops"
	colour = "skrell"
	key = "f"
	flags = RESTRICTED

/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	key = "1"
	flags = RESTRICTED

/datum/language/trinary
	name = "Trinary"
	desc = "A modification of binary to allow fuzzy logic. 0 is no, 1 maybe, 2 yes. Credited with giving Machine People the ability to think creatively."
	key = "5"
	flags = RESTRICTED


// Galactic common languages (systemwide accepted standards).
/datum/language/trader
	name = "Tradeband"
	desc = "Maintained by the various trading cartels in major systems, this elegant, structured language is used for bartering and bargaining."
	speech_verb = "enunciates"
	key = "2"

/datum/language/gutter
	name = "Gutter"
	desc = "Much like Standard, this crude pidgin tongue descended from numerous languages and serves as Tradeband for criminal elements."
	speech_verb = "growls"
	key = "3"

// Language handling.
/mob/proc/add_language(var/language)

	for(var/datum/language/L in languages)
		if(L && L.name == language)
			return 0

	var/datum/language/new_language = all_languages[language]

	if(!istype(new_language,/datum/language))
		return 0

	languages += new_language
	return 1

/mob/proc/remove_language(var/rem_language)

	for(var/datum/language/L in languages)
		if(L && L.name == rem_language)
			languages -= L
			return 1

	return 0

//TBD
/mob/verb/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	for(var/datum/language/L in languages)
		dat += "<b>[L.name] (:[L.key])</b><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return