/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose = sanitize(copytext(input(usr, "This is [src]. [p_they(TRUE)] [p_are()]...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()

/datum/emote/human
	var/list/species_restrictions = list()

/datum/emote/human/can_run_emote(mob/user, status_check = TRUE)
	return ..() && (!species_restrictions.len || user.get_species() in species_restrictions)

/datum/emote/human/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles"

/datum/emote/human/audible
	var/message_mime = ""
	var/message_mime_param = ""
	emote_type = EMOTE_AUDIBLE
	cooldown = 20

/datum/emote/human/audible/can_play_sound(mob/user)
	return ..() && (user.mind && !user.mind.miming)

/datum/emote/human/audible/select_param(mob/user, params)
	if(user.mind && user.mind.miming)
		if(!message_mime_param)
			return "[message_mime] at [params]"
		return replacetext(message_mime_param, "%t", params)
	return ..()

/datum/emote/human/audible/select_message_type(mob/user)
	if(user.mind && user.mind.miming)
		return message_mime
	return ..()

/datum/emote/human/audible/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	message_mime = "acts out a scream"
	cooldown = 50

/datum/emote/human/audible/scream/play_sound(mob/living/carbon/human/user)
	if(!can_play_sound(user))
		return

	var/scream_sound = (user.gender == FEMALE) ? user.species.female_scream_sound : user.species.male_scream_sound
	playsound(user.loc, "[scream_sound]", 80, 1, frequency = user.get_age_pitch())
