/datum/emote/carbon
	mob_type_blacklist_typecache = list(/mob/living/carbon/slime)

/datum/emote/carbon/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers"
	emote_type = EMOTE_AUDIBLE

/datum/emote/carbon/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps"
	emote_type = EMOTE_AUDIBLE

/datum/emote/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches"
	restraint_check = TRUE

/datum/emote/carbon/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools"

/datum/emote/carbon/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods"

/datum/emote/carbon/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head"

/datum/emote/carbon/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down"
	mob_type_blacklist_typecache = list(/mob/living/carbon/alien/larva)

/datum/emote/carbon/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks sadly"

/datum/emote/carbon/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes"

/datum/emote/carbon/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses"
	punct = "!"

/datum/emote/carbon/collapse/run_emote(mob/user, params, type_override)
	. = ..()
	if(.)
		user.Paralyse(2)

/datum/emote/carbon/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps"
	punct = "!"

/datum/emote/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans"
	punct = "!"
