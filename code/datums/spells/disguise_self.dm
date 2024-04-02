/datum/spell/disguise_self
	name = "Disguise Self"
	desc = "Disguise yourself as a crewmember, based on your current location. Also changes your voice. \
		The disguise will not hold up to being examined directly, and will break if you're damaged."

	school = "illusion"
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	invocation = "Yutake Yutendes"
	invocation_type = "whisper"
	level_max = 0 //cannot be improved
	action_icon_state = "disguise_self"
	sound = null

/datum/spell/disguise_self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/disguise_self/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	H.apply_status_effect(STATUS_EFFECT_MAGIC_DISGUISE)
