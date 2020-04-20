/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name="DISABILITY"

	// Mutation to give (or 0)
	var/mutation=0

	// Disability to give (or 0)
	var/disability=0

	// Activation message
	var/activation_message=""

	// Yay, you're no longer growing 3 arms
	var/deactivation_message=""

/datum/dna/gene/disability/can_activate(var/mob/M,var/flags)
	return 1 // Always set!

/datum/dna/gene/disability/activate(var/mob/living/M, var/connected, var/flags)
	..()
	if(mutation && !(mutation in M.mutations))
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(activation_message)
		to_chat(M, "<span class='warning'>[activation_message]</span>")
	else
		testing("[name] has no activation message.")

/datum/dna/gene/disability/deactivate(var/mob/living/M, var/connected, var/flags)
	..()
	if(mutation && (mutation in M.mutations))
		M.mutations.Remove(mutation)
	if(disability)
		M.disabilities &= ~disability
	if(deactivation_message)
		to_chat(M, "<span class='warning'>[deactivation_message]</span>")
	else
		testing("[name] has no deactivation message.")

/datum/dna/gene/disability/hallucinate
	name="Hallucinate"
	activation_message="Tu mente dice 'Hola'."
	deactivation_message ="La cordura regresa. Lo hizo?"
	instability = -GENE_INSTABILITY_MODERATE
	mutation=HALLUCINATE

/datum/dna/gene/disability/hallucinate/New()
	block=GLOB.hallucinationblock

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_message="Te duele la cabeza."
	deactivation_message ="Tu dolor de cabeza se ha ido, por fin."
	instability = -GENE_INSTABILITY_MODERATE
	disability=EPILEPSY

/datum/dna/gene/disability/epilepsy/New()
	block=GLOB.epilepsyblock

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_message="Empiezas a toser."
	deactivation_message ="Tu garganta deja de picarte."
	instability = -GENE_INSTABILITY_MINOR
	disability=COUGHING

/datum/dna/gene/disability/cough/New()
	block=GLOB.coughblock

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_message="Te sientes mareado."
	deactivation_message ="Recuperas el control de tus movimientos"
	instability = -GENE_INSTABILITY_MINOR
	mutation=CLUMSY

/datum/dna/gene/disability/clumsy/New()
	block=GLOB.clumsyblock

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_message="Te sacudes"
	deactivation_message ="Tu boca sabe a jabon."
	instability = -GENE_INSTABILITY_MODERATE
	disability=TOURETTES

/datum/dna/gene/disability/tourettes/New()
	block=GLOB.twitchblock

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_message="Te sientes nervioso."
	deactivation_message ="Te sientes mucho mas calmado."
	disability=NERVOUS

/datum/dna/gene/disability/nervousness/New()
	block=GLOB.nervousblock


/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_message = "Parece que no puedes ver nada."
	deactivation_message = "Puedes ver ahora, en caso de que no te hayas dado cuenta..."
	instability = -GENE_INSTABILITY_MAJOR
	disability = BLIND

/datum/dna/gene/disability/blindness/New()
	block = GLOB.blindblock

/datum/dna/gene/disability/blindness/activate(mob/M, connected, flags)
	..()
	M.update_blind_effects()

/datum/dna/gene/disability/blindness/deactivate(mob/M, connected, flags)
	..()
	M.update_blind_effects()


/datum/dna/gene/disability/colourblindness
	name = "Colourblindness"
	activation_message = "Sientes un cosquilleo peculiar en tus ojos mientras tu percepcion del color cambia."
	deactivation_message ="Tus ojos tiemblan inquietantemente, aunque todo parece volverse mucho mas colorido."
	instability = -GENE_INSTABILITY_MODERATE
	disability = COLOURBLIND

/datum/dna/gene/disability/colourblindness/New()
	block=GLOB.colourblindblock

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
	activation_message="Todo esta algo tranquilo."
	deactivation_message ="Puedes escuchar de nuevo!"
	instability = -GENE_INSTABILITY_MAJOR
	disability=DEAF

/datum/dna/gene/disability/deaf/New()
	block=GLOB.deafblock

/datum/dna/gene/disability/deaf/activate(var/mob/M, var/connected, var/flags)
	..()
	M.MinimumDeafTicks(1)

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_message="Tus ojos se sienten raros ..."
	deactivation_message ="Puedes ver claramente ahora"
	instability = -GENE_INSTABILITY_MODERATE
	disability=NEARSIGHTED

/datum/dna/gene/disability/nearsighted/New()
	block=GLOB.glassesblock

/datum/dna/gene/disability/nearsighted/activate(mob/living/M, connected, flags)
	. = ..()
	M.update_nearsighted_effects()

/datum/dna/gene/disability/nearsighted/deactivate(mob/living/M, connected, flags)
	. = ..()
	M.update_nearsighted_effects()

/datum/dna/gene/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_message = "Thomething doethn't feel right."
	deactivation_message = "You now feel able to pronounce consonants."
	mutation = LISP

/datum/dna/gene/disability/lisp/New()
	..()
	block=GLOB.lispblock

/datum/dna/gene/disability/lisp/OnSay(var/mob/M, var/message)
	return replacetext(message,"s","th")

/datum/dna/gene/disability/comic
	name = "Comic"
	desc = "Esto solo traera muerte y destruccion."
	activation_message = "<span class='sans'>Uh oh!</span>"
	deactivation_message = "Bueno, gracias a Dios que termino."
	mutation=COMIC

/datum/dna/gene/disability/comic/New()
	block = GLOB.comicblock

/datum/dna/gene/disability/wingdings
	name = "Alien Voice"
	desc = "Confunde la voz del sujeto en un discurso incomprensible."
	activation_message = "<span class='wingdings'>Tus cuerdas vocales se sienten extrañas.</span>"
	deactivation_message = "Tus cuerdas vocales ya no se sienten extrañas."
	instability = -GENE_INSTABILITY_MINOR
	mutation = WINGDINGS

/datum/dna/gene/disability/wingdings/New()
	block = GLOB.wingdingsblock

/datum/dna/gene/disability/wingdings/OnSay(var/mob/M, var/message)
	var/list/chars = string2charlist(message)
	var/garbled_message = ""
	for(var/C in chars)
		if(C in GLOB.alphabet_uppercase)
			garbled_message += pick(GLOB.alphabet_uppercase)
		else if(C in GLOB.alphabet)
			garbled_message += pick(GLOB.alphabet)
		else
			garbled_message += C
	message = garbled_message
	return message
