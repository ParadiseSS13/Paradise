
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_message = "YOU FEEL LIKE YELLING!"
	deactivation_message = "You feel like being quiet.."

	New()
		..()
		block=LOUDBLOCK



	OnSay(var/mob/M, var/message)
		message = replacetext(message,".","!")
		message = replacetext(message,"?","?!")
		message = replacetext(message,"!","!!")
		return uppertext(message)

/* BROKEN WITH NEW SAYCODE
/datum/dna/gene/disability/speech/whisper
	name = "Quiet"
	desc = "Damages the subjects vocal cords"
	activation_message = "<i>Your throat feels sore..</i>"
	deactivation_message = "You feel fine again."

	New()
		..()
		block=WHISPERBLOCK

	can_activate(var/mob/M,var/flags)
		// No loud whispering.
		if(LOUD in M.mutations)
			return 0
		return ..(M,flags)

	OnSay(var/mob/M, var/message)
		M.whisper(message)
*/

/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_message = "You feel very dizzy..."
	deactivation_message = "You regain your balance."

	New()
		..()
		block=DIZZYBLOCK


	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if(DIZZY in M.mutations)
			M.Dizzy(300)
