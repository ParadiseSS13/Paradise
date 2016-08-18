/datum/language/xenocommon
	name = "Xenomorph"
	colour = "alien"
	desc = "The common tongue of the xenomorphs."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	key = "6"
	flags = RESTRICTED
	syllables = list("sss","sSs","SSS")

/datum/language/xenos
	name = "Hivemind"
	desc = "Xenomorphs have the strange ability to commune over a psychic hivemind."
	speech_verb = "hisses"
	ask_verb = "hisses"
	exclaim_verb = "hisses"
	colour = "alien"
	key = "a"
	flags = RESTRICTED | HIVEMIND
	follow = 1

/datum/language/ling
	name = "Changeling"
	desc = "Although they are normally wary and suspicious of each other, changelings can commune over a distance."
	speech_verb = "says"
	colour = "changeling"
	key = "g"
	flags = RESTRICTED | HIVEMIND

/datum/language/shadowling
	name = "Shadowling Hivemind"
	desc = "Shadowlings and their thralls are capable of communicating over a psychic hivemind."
	speech_verb = "says"
	colour = "shadowling"
	key = "8"
	flags = RESTRICTED | HIVEMIND


/datum/language/shadowling/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	if(speaker.mind && speaker.mind.special_role)
		..(speaker, message, "([speaker.mind.special_role]) [speaker]")
	else
		..(speaker, message)

/datum/language/ling/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	if(speaker.mind && speaker.mind.changeling)
		..(speaker,message,speaker.mind.changeling.changelingID)
	else
		..(speaker,message)

/datum/language/abductor
	name = "Abductor Mindlink"
	desc = "Abductors are incapable of speech, but have a psychic link attuned to their own team."
	speech_verb = "gibbers"
	ask_verb = "gibbers"
	exclaim_verb = "gibbers"
	colour = "abductor"
	key = "zw" //doesn't matter, this is their default and only language
	flags = RESTRICTED | HIVEMIND

/datum/language/abductor/broadcast(var/mob/living/speaker, var/message, var/speaker_mask)
	..(speaker, message, speaker.real_name)

/datum/language/abductor/check_special_condition(var/mob/living/carbon/human/other, var/mob/living/carbon/human/speaker)
	if(other.mind && other.mind.abductor)
		if(other.mind.abductor.team == speaker.mind.abductor.team)
			return 1
	return 0

/datum/language/corticalborer
	name = "Cortical Link"
	desc = "Cortical borers possess a strange link between their tiny minds."
	speech_verb = "sings"
	ask_verb = "sings"
	exclaim_verb = "sings"
	colour = "alien"
	key = "x"
	flags = RESTRICTED | HIVEMIND

/datum/language/corticalborer/broadcast(var/mob/living/speaker,var/message,var/speaker_mask)
	var/mob/living/simple_animal/borer/B

	if(iscarbon(speaker))
		var/mob/living/carbon/M = speaker
		B = M.has_brain_worms()
	else if(istype(speaker,/mob/living/simple_animal/borer))
		B = speaker

	if(B)
		speaker_mask = B.truename
	..(speaker, message, speaker_mask)


/datum/language/swarmer
	name = "Swarmer"
	desc = "A heavily encoded alien binary pattern."
	speech_verb = "tones"
	ask_verb = "tones"
	exclaim_verb = "tones"
	colour = "say_quote"
	key = "z"//Zwarmer...Or Zerg!
	flags = RESTRICTED | HIVEMIND
	follow = 1


/datum/language/wryn
	name = "Wryn Hivemind"
	desc = "Wryn have the strange ability to commune over a psychic hivemind."
	speech_verb = "chitters"
	ask_verb = "chitters"
	exclaim_verb = "chitters"
	colour = "alien"
	key = "y"
	flags = RESTRICTED | HIVEMIND

/datum/language/wryn/check_special_condition(var/mob/other)
	var/mob/living/carbon/M = other
	if(!istype(M))
		return 1
	if(locate(/obj/item/organ/internal/wryn/hivenode) in M.internal_organs)
		return 1

	return 0