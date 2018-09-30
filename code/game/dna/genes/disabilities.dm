/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name="DISABILITY"

/datum/dna/gene/disability/can_activate(var/mob/M,var/flags)
	return 1 // Always set!

/datum/dna/gene/disability/hallucinate
	name="Hallucinate"
	activation_messages = list("Your mind says 'Hello'.")
	deactivation_messages = list("Sanity returns. Or does it?")
	instability = -GENE_INSTABILITY_MODERATE
	trait = TRAIT_HALLUCINATE

/datum/dna/gene/disability/hallucinate/New()
	block=HALLUCINATIONBLOCK

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_messages = list("You get a headache.")
	deactivation_messages = list("Your headache is gone, at last.")
	instability = -GENE_INSTABILITY_MODERATE
	trait = TRAIT_EPILEPSY

/datum/dna/gene/disability/epilepsy/New()
	block=EPILEPSYBLOCK

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_messages = list("You start coughing.")
	deactivation_messages = list("Your throat stops aching.")
	instability = -GENE_INSTABILITY_MINOR
	trait = TRAIT_COUGHING

/datum/dna/gene/disability/cough/New()
	block=COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_messages = list("You feel lightheaded.")
	deactivation_messages = list("You regain some control of your movements")
	instability = -GENE_INSTABILITY_MINOR
	trait = TRAIT_CLUMSY

/datum/dna/gene/disability/clumsy/New()
	block=CLUMSYBLOCK

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_messages = list("You twitch.")
	deactivation_messages = list("Your mouth tastes like soap.")
	instability = -GENE_INSTABILITY_MODERATE
	trait = TRAIT_TOURETTES

/datum/dna/gene/disability/tourettes/New()
	block=TWITCHBLOCK

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_messages = list("You feel nervous.")
	deactivation_messages = list("You feel much calmer.")
	trait = TRAIT_NERVOUS

/datum/dna/gene/disability/nervousness/New()
	block=NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_messages = list("You can't seem to see anything.")
	deactivation_messages = list("You can see now, in case you didn't notice...")
	instability = -GENE_INSTABILITY_MAJOR
	trait = TRAIT_BLIND

/datum/dna/gene/disability/blindness/New()
	block=BLINDBLOCK

/datum/dna/gene/disability/colourblindness
	name = "Colourblindness"
	activation_messages = list("You feel a peculiar prickling in your eyes while your perception of colour changes.")
	deactivation_messages = list("Your eyes tingle unsettlingly, though everything seems to become alot more colourful.")
	instability = -GENE_INSTABILITY_MODERATE
	trait = TRAIT_COLOURBLIND

/datum/dna/gene/disability/colourblindness/New()
	block=COLOURBLINDBLOCK

/datum/dna/gene/disability/colourblindness/activate(var/mob/M, var/connected, var/flags)
	..()
	M.update_client_colour() //Handle the activation of the colourblindness on the mob.
	M.update_icons() //Apply eyeshine as needed.

/datum/dna/gene/disability/colourblindness/deactivate(var/mob/M, var/connected, var/flags)
	..()
	M.update_client_colour() //Handle the deactivation of the colourblindness on the mob.
	M.update_icons() //Remove eyeshine as needed.

/datum/dna/gene/disability/deaf
	name="Deafness"
	activation_messages = list("It's kinda quiet.")
	deactivation_messages = list("You can hear again!")
	instability = -GENE_INSTABILITY_MAJOR
	trait = TRAIT_DEAF

/datum/dna/gene/disability/deaf/New()
	block=DEAFBLOCK

/datum/dna/gene/disability/deaf/activate(var/mob/M, var/connected, var/flags)
	..()
	M.EarDeaf(1)

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_messages = list("Your eyes feel weird...")
	deactivation_messages = list("You can see clearly now")
	instability = -GENE_INSTABILITY_MODERATE
	trait = TRAIT_NEARSIGHT

/datum/dna/gene/disability/nearsighted/New()
	block=GLASSESBLOCK

/datum/dna/gene/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_messages = list("Thomething doethn't feel right.")
	deactivation_messages = list("You now feel able to pronounce consonants.")
	trait = TRAIT_LISP

/datum/dna/gene/disability/lisp/New()
	..()
	block=LISPBLOCK

/datum/dna/gene/disability/lisp/OnSay(var/mob/M, var/message)
	return replacetext(message,"s","th")

/datum/dna/gene/disability/comic
	name = "Comic"
	desc = "This will only bring death and destruction."
	activation_messages = list("<span class='sans'>Uh oh!</span>")
	deactivation_messages = list("Well thank god that's over with.")
	trait = TRAIT_COMIC

/datum/dna/gene/disability/comic/New()
	block = COMICBLOCK
