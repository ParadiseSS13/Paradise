/datum/language/
	var/no_tts = FALSE

/datum/language/serpentid
	name = "Nabberian"
	desc = "Звук, издаваемый этим языком похоже на кононаду из скрежета мандибул, лезвий, стука конечностей, трения антенн и утробного рева"
	speech_verb = "стучит клинками и жестикулирует конечностями"
	ask_verb = "стучит жвалами и жестикулирует конечностями"
	exclaim_verbs = list("издает гремящие щелчки")
	colour = "serpentid"
	key = "g"
	flags = RESTRICTED | WHITELISTED
	syllables = list("click","clack","cling","clang","cland","clog")
	no_tts = TRUE

/datum/language/serpentid/get_random_name(gender)
	var/new_name = ""
	if(gender == FEMALE)
		new_name = capitalize(pick(GLOB.first_names_female))
	else
		new_name = capitalize(pick(GLOB.first_names_male))
	return new_name
