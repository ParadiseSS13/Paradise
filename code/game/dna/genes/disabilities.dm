/////////////////////
// DISABILITY GENES
//
// These activate either a mutation, disability, or sdisability.
//
// Gene is always activated.
/////////////////////

/datum/dna/gene/disability
	name="DISABILITY"

	// Mutation to give (or 0)
	var/mutation=0

	// Disability to give (or 0)
	var/disability=0

	// SDisability to give (or 0)
	var/sdisability=0

	// Activation message
	var/activation_message=""

	// Yay, you're no longer growing 3 arms
	var/deactivation_message=""

/datum/dna/gene/disability/can_activate(var/mob/M,var/flags)
	return 1 // Always set!

/datum/dna/gene/disability/activate(var/mob/M, var/connected, var/flags)
	if(mutation && !(mutation in M.mutations))
		M.mutations.Add(mutation)
	if(disability)
		M.disabilities|=disability
	if(sdisability)
		M.sdisabilities|=sdisability
	if(activation_message)
		M << "\red [activation_message]"
	else
		testing("[name] has no activation message.")

/datum/dna/gene/disability/deactivate(var/mob/M, var/connected, var/flags)
	if(mutation && (mutation in M.mutations))
		M.mutations.Remove(mutation)
	if(disability)
		M.disabilities &= ~disability
	if(sdisability)
		M.sdisabilities &= ~sdisability
	if(deactivation_message)
		M << "\red [deactivation_message]"
	else
		testing("[name] has no deactivation message.")

/datum/dna/gene/disability/hallucinate
	name="Hallucinate"
	activation_message="Your mind says 'Hello'."
	deactivation_message ="Sanity returns. Or does it?"
	mutation=HALLUCINATE

	New()
		block=HALLUCINATIONBLOCK

/datum/dna/gene/disability/epilepsy
	name="Epilepsy"
	activation_message="You get a headache."
	deactivation_message ="Your headache is gone, at last."
	disability=EPILEPSY

	New()
		block=EPILEPSYBLOCK

/datum/dna/gene/disability/cough
	name="Coughing"
	activation_message="You start coughing."
	deactivation_message ="Your throat stops aching."
	disability=COUGHING

	New()
		block=COUGHBLOCK

/datum/dna/gene/disability/clumsy
	name="Clumsiness"
	activation_message="You feel lightheaded."
	deactivation_message ="You regain some control of your movements"
	mutation=CLUMSY

	New()
		block=CLUMSYBLOCK

/datum/dna/gene/disability/tourettes
	name="Tourettes"
	activation_message="You twitch."
	deactivation_message ="Your mouth tastes like soap."
	disability=TOURETTES

	New()
		block=TWITCHBLOCK

/datum/dna/gene/disability/nervousness
	name="Nervousness"
	activation_message="You feel nervous."
	deactivation_message ="You feel much calmer."
	disability=NERVOUS

	New()
		block=NERVOUSBLOCK

/datum/dna/gene/disability/blindness
	name="Blindness"
	activation_message="You can't seem to see anything."
	deactivation_message ="You can see now, in case you didn't notice..."
	sdisability=BLIND

	New()
		block=BLINDBLOCK

/datum/dna/gene/disability/deaf
	name="Deafness"
	activation_message="It's kinda quiet."
	deactivation_message ="You can hear again!"
	sdisability=DEAF

	New()
		block=DEAFBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.ear_deaf = 1

/datum/dna/gene/disability/nearsighted
	name="Nearsightedness"
	activation_message="Your eyes feel weird..."
	deactivation_message ="You can see clearly now"
	disability=NEARSIGHTED

	New()
		block=GLASSESBLOCK


/datum/dna/gene/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_message = "Thomething doethn't feel right."
	deactivation_message = "You now feel able to pronounce consonants."

	New()
		..()
		block=LISPBLOCK

	OnSay(var/mob/M, var/message)
		return replacetext(message,"s","th")

/datum/dna/gene/disability/comic
	name = "Comic"
	desc = "This will only bring death and destruction."
	activation_message = "<span class='sans'>Uh oh!</span>"
	deactivation_message = "Well thank god that's over with."
	mutation=COMIC

	New()
		block = COMICBLOCK
