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

/datum/dna/gene/disability/colourblindness
	name="Colourblindness"
	activation_message="Your perception of colour warps and distorts."
	deactivation_message ="Your perception of colour returns to normal."
	instability = -GENE_INSTABILITY_MODERATE
	disability = COLOURBLIND
	flags = GENE_EYE_DEPENDENT
	update = 1

/datum/dna/gene/disability/colourblindness/New()
	block=COLOURBLINDBLOCK

/datum/dna/gene/disability/colourblindness/activate(var/mob/M, var/connected, var/flags)
	..(M,connected,flags)
	var/mob/living/carbon/human/H = M
	if(istype(M))
		var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(eyes && !eyes.robotic) //To avoid overriding the properties of cybernetic/mechassisted eyes, apply the colour matrix and darksight modifier only if the organ is organic. Robotic/mechassisted eyes currently do this, too, as is necessary.
			var/list/cblind_properties = (eyes.colourblind_special) ? eyes.colourblind_special : null //If the mob's species has its own colourblindness parameters, gather them.
			eyes.colourmatrix = (cblind_properties && cblind_properties["colour_matrix"]) ? cblind_properties["colour_matrix"] : MATRIX_GREYSCALE //If the mob's species has its own colourblindness colour matrix parameter, use it.
			eyes.dark_view = (cblind_properties && cblind_properties["darkview"]) ? cblind_properties["darkview"] : eyes.dark_view //If the mob's species has its own colourblindness dark view parameter, use it.
			H.update_client_colour()

/datum/dna/gene/disability/colourblindness/deactivate(var/mob/M, var/connected, var/flags)
	..(M,connected,flags)
	var/mob/living/carbon/human/H = M
	if(istype(M))
		var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(eyes && !eyes.robotic) //To avoid overriding the properties of cybernetic/mechassisted eyes, apply the colour matrix and darksight modifier only if the organ is organic. Robotic/mechassisted eyes currently do this, too, as is necessary.
			var/list/cblind_properties = (eyes.colourblind_special) ? eyes.colourblind_special : null //If the mob's species has its own colourblindness parameters, gather them.
			eyes.colourmatrix = null //The only time a mob will have this set is if they're colourblind, so it's fine to null this out.
			eyes.dark_view = (cblind_properties && cblind_properties["darkview"]) ? initial(eyes.dark_view) : eyes.dark_view //If the mob's species has its own colourblindness dark view parameter, set the mob's dark_view back to normal.
			H.update_client_colour()

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
	M.EarDeaf(1)

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
