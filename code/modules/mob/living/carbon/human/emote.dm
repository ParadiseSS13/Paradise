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
	var/list/species_whitelist = list()
	var/hands_needed = 0

/datum/emote/human/can_run_emote(mob/user, status_check = TRUE)
	if(!..())
		return FALSE

	if(status_check && hands_needed && (working_hands(user) < hands_needed))
		to_chat(user, "<span class='notice'>You do not have enough hands to [key].</span>")
		return FALSE
	 if(species_whitelist.len && !(user.get_species() in species_whitelist))
	 	unusable_message(user, status_check)
	return TRUE

/datum/emote/human/proc/working_hands(mob/living/carbon/human/user)
	var/obj/item/organ/external/L = user.get_organ("l_hand")
	var/obj/item/organ/external/R = user.get_organ("r_hand")

	var/left_hand_good = FALSE
	var/right_hand_good = FALSE
	if(L && (!(L.status & ORGAN_SPLINTED)) && (!(L.status & ORGAN_BROKEN)))
		left_hand_good = TRUE
	if(R && (!(R.status & ORGAN_SPLINTED)) && (!(R.status & ORGAN_BROKEN)))
		right_hand_good = TRUE

	return left_hand_good + right_hand_good

/datum/emote/human/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles"

/datum/emote/human/flip
	key = "flip"
	key_third_person = "flips"
	message = "does a flip"
	message_param = "flips in %t's general direction"
	punct = "!"
	cooldown = 20

/datum/emote/human/flip/create_emote_message(mob/living/carbon/human/user, params)
	if(user.lying || user.weakened)
		return "<b>[user]</b> flops and flails around on the floor."

	var/obj/item/grab/G = user.get_active_hand()

	if(istype(G, /obj/item/grab) && G.affecting)
		if(user.buckled || G.affecting.buckled)
			return ""

		var/turf/oldloc = user.loc
		var/turf/newloc = G.affecting.loc
		if(!isturf(oldloc) && isturf(newloc))
			return ""

		user.SpinAnimation(5,1)
		user.forceMove(newloc)
		G.affecting.forceMove(oldloc)
		return "<B>[user]</B> flips over [G.affecting]!"

	if(prob(5))
		user.SpinAnimation(5,1)
		sleep(3)
		user.Weaken(2)
		return "<b>[src]</b> attempts a flip and crashes to the floor!"

	user.SpinAnimation(5,1)
	return ..()

/datum/emote/human/slap
	key = "slap"
	key_third_person = "slaps"
	message = "slaps themself"
	message_param = "slaps %t across the face. Ouch"
	punct = "!"
	cooldown = 20 // Good times

/datum/emote/human/slap/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	// Must be next to target
	. = ..(user, target, FALSE, 1)

/datum/emote/human/slap/replace_pronoun(mob/living/carbon/human/user, msg)
	if(msg == message)
		// Slapping themselves
		user.adjustFireLoss(4)
	return ..()

/datum/emote/human/audible
	var/message_mime = ""
	var/message_mime_param = ""
	emote_type = EMOTE_AUDIBLE
	cooldown = 20

/datum/emote/human/audible/can_play_sound(mob/user)
	return ..() && (user.mind && !user.mind.miming)

/datum/emote/human/audible/select_message_type(mob/user)
	if(user.mind && user.mind.miming)
		return message_mime
	return ..()

/datum/emote/human/audible/run_emote(mob/user, params, type_override)
	if(user.mind && user.mind.miming)
		return ..(user, params, EMOTE_VISIBLE)
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

/datum/emote/human/audible/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps"
	message_mime = "claps silently"
	hands_needed = 2

/datum/emote/human/audible/clap/play_sound(mob/user)
	var/clap_sound = pick('sound/misc/clap1.ogg', 'sound/misc/clap2.ogg', 'sound/misc/clap3.ogg', 'sound/misc/clap4.ogg')
	playsound(user.loc, clap_sound, 50, 1, -1)

/datum/emote/human/audible/vox
	species_whitelist = list("Vox")

/datum/emote/human/audible/vox/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills"
	sound = 'sound/effects/voxrustle.ogg'
