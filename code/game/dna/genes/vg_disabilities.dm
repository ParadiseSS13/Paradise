
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_message = "YOU FEEL LIKE YELLING!"
	deactivation_message = "You feel like being quiet.."
	mutation = LOUD

/datum/dna/gene/disability/speech/loud/New()
	..()
	block=GLOB.loudblock



/datum/dna/gene/disability/speech/loud/OnSay(var/mob/M, var/message)
	message = replacetext(message,".","!")
	message = replacetext(message,"?","?!")
	message = replacetext(message,"!","!!")
	return uppertext(message)

/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_message = "You feel very dizzy..."
	deactivation_message = "You regain your balance."
	instability = -GENE_INSTABILITY_MINOR
	mutation = DIZZY

/datum/dna/gene/disability/dizzy/New()
	..()
	block=GLOB.dizzyblock


/datum/dna/gene/disability/dizzy/OnMobLife(var/mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(DIZZY in M.mutations)
		M.Dizzy(300)

/datum/dna/gene/disability/dizzy/deactivate(mob/living/M, connected, flags)
	. = ..()
	M.SetDizzy(0)
