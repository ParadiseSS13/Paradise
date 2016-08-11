/datum/language/unathi
	name = "Sinta'unathi"
	desc = "The common language of Moghes, composed of sibilant hisses and rattles. Spoken natively by Unathi."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "roars"
	colour = "soghun"
	key = "o"
	syllables = list("ss","ss","ss","ss","skak","seeki","resh","las","esi","kor","sh")

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
	exclaim_verb = "yowls"
	colour = "tajaran"
	key = "j"
	syllables = list("rr","rr","tajr","kir","raj","kii","mir","kra","ahk","nal","vah","khaz","jri","ran","darr", \
	"mi","jri","dynh","manq","rhe","zar","rrhaz","kal","chur","eech","thaa","dra","jurl","mah","sanu","dra","ii'r", \
	"ka","aasi","far","wa","baq","ara","qara","zir","sam","mak","hrar","nja","rir","khan","jun","dar","rik","kah", \
	"hal","ket","jurl","mah","tul","cresh","azu","ragh")

/datum/language/tajaran/get_random_name(var/gender)
	var/new_name = ..(gender, 1)
	if(prob(80))
		new_name += " [pick(list("Hadii","Kaytam","Zhan-Khazan","Hharar","Njarir'Akhan"))]"
	else
		new_name += ..(gender,1)
	return new_name

/datum/language/vulpkanin
	name = "Canilunzt"
	desc = "The guttural language spoken and utilized by the inhabitants of Vazzend system, composed of growls, barks, yaps, and heavy utilization of ears and tail movements.Vulpkanin speak this language with ease."
	speech_verb = "rawrs"
	ask_verb = "rurs"
	exclaim_verb = "barks"
	colour = "vulpkanin"
	key = "7"
	syllables = list("rur","ya","cen","rawr","bar","kuk","tek","qat","uk","wu","vuh","tah","tch","schz","auch", \
	"ist","ein","entch","zwichs","tut","mir","wo","bis","es","vor","nic","gro","lll","enem","zandt","tzch","noch", \
	"hel","ischt","far","wa","baram","iereng","tech","lach","sam","mak","lich","gen","or","ag","eck","gec","stag","onn", \
	"bin","ket","jarl","vulf","einech","cresthz","azunein","ghzth")

/datum/language/skrell
	name = "Skrellian"
	desc = "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the notes are inaudible to humans."
	speech_verb = "warbles"
	ask_verb = "warbles"
	exclaim_verb = "warbles"
	colour = "skrell"
	key = "k"
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix","*","!")

/datum/language/vox
	name = "Vox-pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	speech_verb = "shrieks"
	ask_verb = "creels"
	exclaim_verb = "SHRIEKS"
	colour = "vox"
	key = "v"
	flags = RESTRICTED | WHITELISTED
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya", "yi", "chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")

/datum/language/vox/get_random_name()
	return ..(FEMALE,1,6)

/datum/language/diona
	name = "Rootspeak"
	desc = "A creaking, subvocal language spoken instinctively by the Dionaea. Due to the unique makeup of the average Diona, a phrase of Rootspeak can be a combination of anywhere from one to twelve individual voices and notes."
	speech_verb = "creaks and rustles"
	ask_verb = "creaks"
	exclaim_verb = "rustles"
	colour = "diona"
	key = "q"
	flags = RESTRICTED
	syllables = list("hs","zt","kr","st","sh")

/datum/language/diona/get_random_name()
	var/new_name = "[pick(list("To Sleep Beneath","Wind Over","Embrace of","Dreams of","Witnessing","To Walk Beneath","Approaching the"))]"
	new_name += " [pick(list("the Void","the Sky","Encroaching Night","Planetsong","Starsong","the Wandering Star","the Empty Day","Daybreak","Nightfall","the Rain"))]"
	return new_name

/datum/language/trinary
	name = "Trinary"
	desc = "A modification of binary to allow fuzzy logic. 0 is no, 1 is maybe, 2 is yes. Credited with giving Machine People the ability to think creatively."
	speech_verb = "states"
	ask_verb = "queries"
	exclaim_verb = "exclaims"
	colour = "trinary"
	key = "5"
	flags = RESTRICTED | WHITELISTED
	syllables = list("02011","01222","10100","10210","21012","02011","21200","1002","2001","0002","0012","0012","000","120","121","201","220","10","11","0")

/datum/language/trinary/get_random_name()
	var/new_name
	if(prob(70))
		new_name = "[pick(list("PBU","HIU","SINA","ARMA","OSI"))]-[rand(100, 999)]"
	else
		new_name = pick(ai_names)
	return new_name

/datum/language/kidan
	name = "Chittin"
	desc = "The noise made by rubbing its antennae together is actually a complex form of communication for Kidan."
	speech_verb = "rubs its antennae together"
	ask_verb = "rubs its antennae together"
	exclaim_verb = "rubs its antennae together"
	colour = "kidan"
	key = "4"
	flags = RESTRICTED | WHITELISTED
	syllables = list("click","clack")

/datum/language/slime
	name = "Bubblish"
	desc = "The language of slimes. It's a mixture of bubbling noises and pops. Very difficult to speak without mechanical aid for humans."
	speech_verb = "bubbles and pops"
	ask_verb = "bubbles and pops"
	exclaim_verb = "bubbles and pops"
	colour = "slime"
	key = "f"
	flags = RESTRICTED | WHITELISTED
	syllables = list("blob","plop","pop","bop","boop")

/datum/language/grey
	name = "Psionic Communication"
	desc = "The grey's psionic communication, less potent version of their distant cousin's telepathy. Talk to other greys within a limited radius."
	speech_verb = "expresses"
	ask_verb = "inquires"
	exclaim_verb = "imparts"
	colour = "abductor"
	key = "^"
	flags = RESTRICTED | HIVEMIND

/datum/language/grey/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)
	..(speaker, message, speaker.real_name)

/datum/language/grey/check_special_condition(var/mob/living/carbon/human/other, var/mob/living/carbon/human/speaker)
	if(other in range(7, speaker))
		return 1
	return 0

/datum/language/drask
	name = "Orluum"
	desc = "The droning, vibrous language of the Drask. It sounds somewhat like whalesong."
	speech_verb = "drones"
	ask_verb = "hums"
	exclaim_verb = "rumbles"
	colour = "drask"
	key = "%"
	flags = RESTRICTED | WHITELISTED
	syllables = list("hoorb","vrrm","ooorm","urrrum","ooum","ee","ffm","hhh","mn","ongg")

/datum/language/drask/get_random_name()
	var/new_name = "[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	new_name += "-[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	new_name += "-[pick(list("Hoorm","Viisk","Saar","Mnoo","Oumn","Fmong","Gnii","Vrrm","Oorm","Dromnn","Ssooumn","Ovv", "Hoorb","Vaar","Gaar","Goom","Ruum","Rumum"))]"
	return new_name

/datum/language/human
	name = "Sol Common"
	desc = "A bastardized hybrid of informal English and elements of Mandarin Chinese; the common language of the Sol system."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = "solcom"
	key = "1"
	syllables = list("tao","shi","tzu","yi","com","be","is","i","op","vi","ed","lec","mo","cle","te","dis","e")
	english_names = 1

/datum/language/human/get_spoken_verb(var/msg_end)
	switch(msg_end)
		if("!")
			return pick("exclaims","shouts","yells") //TODO: make the basic proc handle lists of verbs.
		if("?")
			return ask_verb
	return speech_verb
