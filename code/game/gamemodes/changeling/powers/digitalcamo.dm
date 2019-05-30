/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill. However, humans looking at us will find us... uncanny."
	button_icon_state = "digital_camo"
	dna_cost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(var/mob/user)

	if(user.digitalcamo)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
	else
		to_chat(user, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	user.digitalcamo = !user.digitalcamo

	feedback_add_details("changeling_powers","CAM")
	return 1
