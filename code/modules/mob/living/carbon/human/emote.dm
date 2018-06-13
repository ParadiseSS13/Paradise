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
	var/list/species_blacklist = list()
	var/hands_needed = 0

/datum/emote/human/can_run_emote(mob/user, status_check = TRUE)
	if(!..())
		return FALSE

	if(status_check && hands_needed && (working_hands(user) < hands_needed))
		to_chat(user, "<span class='notice'>You do not have enough hands to [key].</span>")
		return FALSE

	if(LAZYLEN(species_whitelist) && !(user.get_species() in species_whitelist))
		unusable_message(user, status_check)
		return FALSE
	if(LAZYLEN(species_blacklist) && (user.get_species() in species_blacklist))
		unusable_message(user, status_check)
		return FALSE
	return TRUE

/datum/emote/human/run_emote(mob/user, params, type_override)
	. = ..()
	for(var/obj/item/implant/I in user)
		if(I.implanted)
			I.trigger(key, user)

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

/datum/emote/human/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"

/datum/emote/human/deathgasp/create_emote_message(mob/living/carbon/human/user, params)
	return replace_pronoun(user, "<b>[user]</b> [user.species.death_message]")

/datum/emote/human/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks"

/datum/emote/human/blink_r
	key = "blink_r"
	key_third_person = "blinks_r"
	message = "blinks rapidly"

/datum/emote/human/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles"

/datum/emote/human/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins"

/datum/emote/human/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns"

/datum/emote/human/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes"

/datum/emote/human/eyebrow
	key = "eyebrow"
	key_third_person = "eyebrowes"
	message = "raises an eyebrow"

/datum/emote/human/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves"
	restraint_check = TRUE

/datum/emote/human/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks"

/datum/emote/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs"

/datum/emote/human/pale
	key = "pale"
	key_third_person = "pales"
	message = "goes pale for a second"

/datum/emote/human/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints"

/datum/emote/human/faint/run_emote(mob/user, params, type_override)
	. = ..()
	if(.)
		user.AdjustSleeping(2)

/datum/emote/human/airguitar
	key = "airguitar"
	key_third_person = "airguitars"
	message = "is strumming the air and headbanging like a safari chimp"
	restraint_check = TRUE

/datum/emote/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes"
	message_param = "salutes to %t"
	restraint_check = TRUE

/datum/emote/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand"
	restraint_check = TRUE

/datum/emote/human/signal
	key = "signal"
	key_third_person = "signals"
	message = "raises a fist"
	restraint_check = TRUE
	hands_needed = 1

/datum/emote/human/signal/select_param(mob/living/carbon/human/user, params, msg)
	if(!params)
		return msg
	var/finger_count = round(text2num(params))
	if(finger_count > 10)
		return msg
	if(finger_count <= 5 && (user.r_hand && user.l_hand))
		return msg
	return "raises [finger_count] finger\s"

/datum/emote/human/point
	key = "point"
	key_third_person = "points"
	message = "points"
	restraint_check = TRUE

/datum/emote/human/point/select_param(mob/user, params, msg)
	var/M = handle_emote_param(user, params)
	if(!M)
		return msg
	user.pointed(M)
	return

/datum/emote/human/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers"
	hands_needed = 1
	restraint_check = TRUE
	cooldown = 20

/datum/emote/human/snap/create_emote_message(mob/user, params)
	if(prob(95))
		playsound(user.loc, 'sound/effects/fingersnap.ogg', 50, 1, -3)
		return ..()

	playsound(user.loc, 'sound/effects/snap.ogg', 50, 1)
	return "<span class='danger'><b>[user]</b> snaps [user.p_their()] fingers right off!</span>"

/datum/emote/human/flip
	key = "flip"
	key_third_person = "flips"
	message = "does a flip"
	message_param = "flips in %t's general direction"
	punct = "!"
	restraint_check = TRUE
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
		return "<b>[user]</b> attempts a flip and crashes to the floor!"

	user.SpinAnimation(5,1)
	return ..()

/datum/emote/human/slap
	key = "slap"
	key_third_person = "slaps"
	message = "slaps themself"
	message_param = "slaps %t across the face. Ouch"
	punct = "!"
	restraint_check = TRUE
	cooldown = 20 // Good times
	sound = 'sound/effects/snap.ogg'
	sound_volume = 50
	sound_vary = 1

/datum/emote/human/slap/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	// Must be next to target
	. = ..(user, target, FALSE, 1)

/datum/emote/human/slap/replace_pronoun(mob/living/carbon/human/user, msg)
	if(msg == message)
		// Slapping themselves
		user.adjustFireLoss(4)
	return ..()

/datum/emote/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself"
	message_param = "hugs %t"

/datum/emote/human/hug/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	. = ..(user, target, TRUE, TRUE)

/datum/emote/human/handshake
	key = "handshake"
	key_third_person = "handshakes"
	message_param = "shakes hands with %t"
	hands_needed = 1
	restraint_check = TRUE

/datum/emote/human/handshake/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	var/mob/M = ..(user, target, TRUE, TRUE)
	if(M && (!M.r_hand || !M.l_hand) && !M.restrained())
		return M

/datum/emote/human/handshake/create_emote_message(mob/user, params)
	if(!params)
		return
	var/msg = select_param(user, params)
	if(!msg)
		return
	return "<b>[user]</b> " + msg + punct

/datum/emote/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to gives daps to, and daps themself. Shameful"
	message_param = "gives daps to %t"
	restraint_check = TRUE

/datum/emote/human/dap/handle_emote_param(mob/user, var/target, var/not_self, var/vicinity, var/return_mob)
	return ..(user, target, FALSE, TRUE)

/datum/emote/human/highfive
	key = "highfive"
	key_third_person = "highfives"
	restraint_check = TRUE

/datum/emote/human/highfive/create_emote_message(mob/living/carbon/human/user, params)
	if(user.has_status_effect(STATUS_EFFECT_HIGHFIVE))
		to_chat(user, "You give up on the high five.")
		user.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
		return
	user.visible_message("<b>[user]</b> requests a highfive.", "You request a high five.")
	user.apply_status_effect(STATUS_EFFECT_HIGHFIVE)
	for(var/mob/living/L in orange(1, user))
		if(!L.has_status_effect(STATUS_EFFECT_HIGHFIVE))
			continue
		if((user.mind && user.mind.special_role == SPECIAL_ROLE_WIZARD) && (L.mind && L.mind.special_role == SPECIAL_ROLE_WIZARD))
			user.status_flags |= GODMODE
			L.status_flags |= GODMODE
			explosion(user.loc, 5, 2, 1, 3)
			user.status_flags &= ~GODMODE
			L.status_flags &= ~GODMODE
			return "<span class='danger'><b>[user]</b> and <b>[L.name]</b> high five EPICALLY!"
		user.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
		L.remove_status_effect(STATUS_EFFECT_HIGHFIVE)
		playsound('sound/effects/snap.ogg', 50)
		return "<b>[user]</b> and <b>[L.name]</b> high five!"

/datum/emote/human/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes"
	sound = 'sound/effects/slime_squish.ogg' // Credit to DrMinky (freesound.org) for the sound
	emote_type = EMOTE_AUDIBLE
	cooldown = 20

/datum/emote/human/squish/can_run_emote(mob/living/carbon/human/user, status_check = TRUE)
	if(!..())
		return FALSE
	if(user.get_species() == "Slime People")
		return TRUE
	for(var/obj/item/organ/external/L in user.bodyparts)
		if(L.dna.species in list("Slime People"))
			return TRUE
	unusable_message(user, status_check)
	return FALSE

/datum/emote/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "starts wagging their tail"

/datum/emote/human/wag/can_run_emote(mob/living/carbon/human/user, status_check = TRUE)
	if(user.body_accessory && user.body_accessory.try_restrictions(user))
		return TRUE
	if(user.species.bodyflags & TAIL_WAGGING)
		return !user.wear_suit || !(user.wear_suit.flags_inv & HIDETAIL) && !istype(user.wear_suit, /obj/item/clothing/suit/space)
	unusable_message(user, status_check)
	return FALSE

/datum/emote/human/wag/run_emote(mob/living/carbon/human/user, params, type_override)
	. = ..()
	if(.)
		user.start_tail_wagging(TRUE)

/datum/emote/human/swag
	key = "swag"
	key_third_person = "swags"
	message = "stops wagging their tail"

/datum/emote/human/swag/can_run_emote(mob/living/carbon/human/user, status_check = TRUE)
	if(user.species.bodyflags & TAIL_WAGGING || user.body_accessory)
		return TRUE
	unusable_message(user, status_check)
	return FALSE

/datum/emote/human/wag/run_emote(mob/living/carbon/human/user, params, type_override)
	. = ..()
	if(.)
		user.stop_tail_wagging(TRUE)

// Needed for M_TOXIC_FART
/datum/emote/human/fart
	key = "fart"
	key_third_person = "farts"
	species_blacklist = list("Machine")

/datum/emote/human/fart/create_emote_message(mob/living/carbon/human/user, params)
	if(user.reagents.has_reagent("simethicone"))
		return

	. = "<b>[user]</b> [pick("passes wind", "farts")]"

	if(TOXIC_FARTS in user.mutations)
		. = "<b>[user]</b> unleashes a [pick("horrible", "terrible", "foul", "disgusting", "awful")] fart"
		var/turf/location = get_turf(user)

		for(var/mob/living/carbon/C in range(location, 2))
			if(C.internal != null && C.wear_mask && (C.wear_mask.flags & AIRTIGHT))
				continue
			if(C == user)
				continue
			C.reagents.add_reagent("jenkem", 1)
	if(SUPER_FART in user.mutations)
		. = "<b>[user]</b> unleashes a [pick("loud","deafening")] fart"
		user.newtonian_move(user.dir)

	if(locate(/obj/item/storage/bible) in get_turf(user))
		var/image/cross = image('icons/obj/storage.dmi', "bible")
		var/adminbfmessage = "[bicon(cross)] <span class='danger'>Bible Fart:</span> [key_name(user, 1)] (<A HREF='?_src_=holder;adminmoreinfo=[UID()]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=[UID()]'>PP</A>) (<A HREF='?_src_=vars;Vars=[UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=[UID()]'>SM</A>) ([admin_jump_link(user)]) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;Smite=[UID()]'>SMITE</A>):</b>"
		for(var/client/X in admins)
			if(check_rights(R_EVENT, 0, X.mob))
				to_chat(X, adminbfmessage)
		return "<span class='danger'>[.] on the Bible!</span>"
	. += punct

// Human "audible" sounds handle alternative mime versions automatically
// Emotes who are primarily "spoken", and not side effects of a visual emote, go here (snap, for example, is a visual emote, but still makes a sound)
/datum/emote/human/audible
	var/message_mime = ""
	emote_type = EMOTE_AUDIBLE
	cooldown = 20

/datum/emote/human/audible/can_play_sound(mob/user)
	return ..() && (user.mind && !(user.mind.miming && message_mime))

/datum/emote/human/audible/select_message_type(mob/user)
	if(user.mind && user.mind.miming && message_mime)
		return message_mime
	return ..()

/datum/emote/human/audible/run_emote(mob/user, params, type_override)
	if(user.mind && user.mind.miming && message_mime)
		return ..(user, params, EMOTE_VISIBLE)
	return ..()

/datum/emote/human/audible/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries"
	message_mime = "cries"

/datum/emote/human/audible/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs"
	message_mime = "acts out a laugh"

/datum/emote/human/audible/hem
	key = "hem"
	key_third_person = "hems"
	message = "hems"
	message_mime = "appears thoughtful"

/datum/emote/human/audible/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles"
	message_mime = "appears to chuckle"

/datum/emote/human/audible/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles"
	message_mime = "giggles silently"

/datum/emote/human/audible/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes"
	message_mime = "clutches their throat desperately"
	punct = "!"

/datum/emote/human/audible/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles"
	message_mime = "grumbles"

/datum/emote/human/audible/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles"
	message_mime = "mumbles"
	punct = "!"

/datum/emote/human/audible/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans"
	message_mime = "appears to groan"
	punct = "!"

/datum/emote/human/audible/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans"
	message_mime = "appears to moan"
	punct = "!"

/datum/emote/human/audible/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps"
	message_mime = "appears to be gasping"
	punct = "!"

/datum/emote/human/audible/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs"
	message_mime = "sniffs"

/datum/emote/human/audible/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores"
	message_mime = "sleeps soundly"
	muzzled_noise = ""
	stat_allowed = UNCONSCIOUS

/datum/emote/human/audible/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers"
	message_mime = "appears hurt"
	muzzled_noise = "weak "

/datum/emote/human/audible/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns"
	message_mime = "yawns"

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

/datum/emote/human/audible/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs"
	message_mime = "appears to cough"
	muzzled_noise = "strong "
	punct = "!"
	sound_volume = 120

/datum/emote/human/audible/cough/play_sound(mob/living/carbon/human/user)
	if(!can_play_sound(user))
		return
	var/cough_sound = pick(user.gender == FEMALE ? user.species.female_cough_sounds : user.species.male_cough_sounds)
	playsound(user, cough_sound, sound_volume)

/datum/emote/human/audible/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes"
	message_mime = "appears to sneeze"
	muzzled_noise = "strange "
	punct = "!"
	sound_volume = 70

/datum/emote/human/audible/sneeze/play_sound(mob/living/carbon/human/user)
	if(!can_play_sound(user))
		return
	var/sneeze_sound = user.gender == FEMALE ? user.species.female_sneeze_sound : user.species.male_sneeze_sound
	playsound(user, sneeze_sound, sound_volume)

/datum/emote/human/audible/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps"
	message_mime = "claps silently"
	restraint_check = TRUE
	hands_needed = 2

/datum/emote/human/audible/clap/play_sound(mob/user)
	if(!can_play_sound(user))
		return
	var/clap_sound = pick('sound/misc/clap1.ogg', 'sound/misc/clap2.ogg', 'sound/misc/clap3.ogg', 'sound/misc/clap4.ogg')
	playsound(user.loc, clap_sound, 50, 1, -1)

// Species specific emotes
/datum/emote/human/audible/vox
	species_whitelist = list("Vox")

/datum/emote/human/audible/vox/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills"
	sound = 'sound/effects/voxrustle.ogg'

/datum/emote/human/audible/vulp
	species_whitelist = list("Vulpkanin")

/datum/emote/human/audible/vulp/howl
	key = "howl"
	key_third_person = "howls"
	message = "howls"
	message_mime = "tilts their head back as if to howl"
	sound = 'sound/goonstation/voice/howl.ogg'
	sound_volume = 100
	sound_frequency = 10
	cooldown = 100

/datum/emote/human/audible/vulp/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls"
	message_mime = "bares their teeth menacingly"
	sound = "growls"
	sound_volume = 80

/datum/emote/human/audible/drask
	species_whitelist = list("Drask")

/datum/emote/human/audible/drask/drone
	key = "drone"
	key_third_person = "drone"
	message = "drones"
	sound = 'sound/voice/DraskTalk.ogg'

/datum/emote/human/audible/drask/rumble
	key = "rumble"
	key_third_person = "rumble"
	message = "rumbles"
	sound = 'sound/voice/DraskTalk.ogg'

/datum/emote/human/audible/drask/hum
	key = "hum"
	key_third_person = "hum"
	message = "hums"
	sound = 'sound/voice/DraskTalk.ogg'

/datum/emote/human/audible/kidan
	species_whitelist = list("Kidan")

/datum/emote/human/audible/kidan/clack
	key = "clack"
	key_third_person = "clacks"
	message = "clacks their mandibles"
	sound = 'sound/effects/Kidanclack.ogg' // Credit to DrMinky (freesound.org) for the sound

/datum/emote/human/audible/kidan/click
	key = "click"
	key_third_person = "clicks"
	message = "clicks their mandibles"
	sound = 'sound/effects/Kidanclack2.ogg' // Credit to DrMinky (freesound.org) for the sound

/datum/emote/human/audible/diona
	species_whitelist = list("Diona")

/datum/emote/human/audible/diona/creak
	key = "creak"
	key_third_person = "creaks"
	message = "creaks"
	sound = 'sound/voice/dionatalk1.ogg'

/datum/emote/human/audible/unathi
	species_whitelist = list("Unathi")

/datum/emote/human/audible/unathi/hiss
	key = "hiss"
	message = "hiss"
	sound = 'sound/effects/unathihiss.ogg'
