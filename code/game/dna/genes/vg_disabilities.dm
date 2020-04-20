
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Obliga al centro de conversacion del cerebro del sujeto a gritar cada oracion."
	activation_message = "SIENTES QUE GRITAS!"
	deactivation_message = "Te sientes callado..."
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
	desc = "Hace que el cerebelo se cierre en algunos lugares."
	activation_message = "Te sientes muy mareado..."
	deactivation_message = "Recuperas el equilibrio."
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
