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

/datum/dna/gene/disability/activate(var/mob/M, var/connected, var/flags)
	..()
	if(mutation && !(mutation in M.mutations))
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(activation_message)
		to_chat(M, "<span class='warning'>[activation_message]</span>")
	else
		testing("[name] has no activation message.")

/datum/dna/gene/disability/deactivate(var/mob/M, var/connected, var/flags)
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
	activation_message="Your mind says 'Hello'."
	deactivation_message ="Sanity returns. Or does it?"
	instability = -GENE_INSTABILITY_MODERATE
	mutation=HALLUCINATE

/datum/dna/gene/disability/hallucinate/New()
	block=HALLUCINATIONBLOCK

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_message="You get a headache."
	deactivation_message ="Your headache is gone, at last."
	instability = -GENE_INSTABILITY_MODERATE
	disability=EPILEPSY

/datum/dna/gene/disability/epilepsy/New()
	block=EPILEPSYBLOCK

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_message="You start coughing."
	deactivation_message ="Your throat stops aching."
	instability = -GENE_INSTABILITY_MINOR
	disability=COUGHING

/datum/dna/gene/disability/cough/New()
	block=COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_message="You feel lightheaded."
	deactivation_message ="You regain some control of your movements"
	instability = -GENE_INSTABILITY_MINOR
	mutation=CLUMSY

/datum/dna/gene/disability/clumsy/New()
	block=CLUMSYBLOCK

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_message="You twitch."
	deactivation_message ="Your mouth tastes like soap."
	instability = -GENE_INSTABILITY_MODERATE
	disability=TOURETTES

/datum/dna/gene/disability/tourettes/New()
	block=TWITCHBLOCK

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_message="You feel nervous."
	deactivation_message ="You feel much calmer."
	disability=NERVOUS

/datum/dna/gene/disability/nervousness/New()
	block=NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_message="You can't seem to see anything."
	deactivation_message ="You can see now, in case you didn't notice..."
	instability = -GENE_INSTABILITY_MAJOR
	disability=BLIND

/datum/dna/gene/disability/blindness/New()
	block=BLINDBLOCK

/datum/dna/gene/disability/deaf
	name="Deafness"
	activation_message="It's kinda quiet."
	deactivation_message ="You can hear again!"
	instability = -GENE_INSTABILITY_MAJOR
	disability=DEAF

/datum/dna/gene/disability/deaf/New()
	block=DEAFBLOCK

/datum/dna/gene/disability/deaf/activate(var/mob/M, var/connected, var/flags)
	..(M,connected,flags)
	M.ear_deaf = 1

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_message="Your eyes feel weird..."
	deactivation_message ="You can see clearly now"
	instability = -GENE_INSTABILITY_MODERATE
	disability=NEARSIGHTED

/datum/dna/gene/disability/nearsighted/New()
	block=GLASSESBLOCK


/datum/dna/gene/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_message = "Thomething doethn't feel right."
	deactivation_message = "You now feel able to pronounce consonants."
	mutation = LISP

/datum/dna/gene/disability/lisp/New()
	..()
	block=LISPBLOCK

/datum/dna/gene/disability/lisp/OnSay(var/mob/M, var/message)
	return replacetext(message,"s","th")

/datum/dna/gene/disability/comic
	name = "Comic"
	desc = "This will only bring death and destruction."
	activation_message = "<span class='sans'>Uh oh!</span>"
	deactivation_message = "Well thank god that's over with."
	mutation=COMIC

/datum/dna/gene/disability/comic/New()
	block = COMICBLOCK
