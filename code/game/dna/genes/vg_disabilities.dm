
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_messages = list("YOU FEEL LIKE YELLING!")
	deactivation_messages = list("You feel like being quiet..")
	trait = TRAIT_LOUD

/datum/dna/gene/disability/speech/loud/New()
	..()
	block=LOUDBLOCK



/datum/dna/gene/disability/speech/loud/OnSay(var/mob/M, var/message)
	message = replacetext(message,".","!")
	message = replacetext(message,"?","?!")
	message = replacetext(message,"!","!!")
	return uppertext(message)

/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_messages = list("You feel very dizzy...")
	deactivation_messages = list("You regain your balance.")
	instability = -GENE_INSTABILITY_MINOR
	trait = TRAIT_DIZZY

/datum/dna/gene/disability/dizzy/New()
	..()
	block=DIZZYBLOCK


/datum/dna/gene/disability/dizzy/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(M.has_trait(TRAIT_DIZZY))
		M.Dizzy(300)
