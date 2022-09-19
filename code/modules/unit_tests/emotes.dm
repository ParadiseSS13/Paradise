
/datum/unit_test/emote/Run()
	// be aware that some of these values (like message, message_param) are subject to being set at runtime.
	for(var/emote_type in subtypesof(/datum/emote))
		var/datum/emote/cur_emote = new emote_type()
		if(cur_emote.message_param && !cur_emote.param_desc)
			Fail("emote [cur_emote] was given a message parameter without a description.")

		// Sanity checks, these emotes probably won't appear to a user but we should make sure they're cleaned up.
		if(!cur_emote.key)
			if(cur_emote.message || cur_emote.message_param)
				Fail("emote [cur_emote] is missing a key but has a message defined.")
			if(cur_emote.key_third_person)
				Fail("emote [cur_emote] has a third-person key defined, but no first-person key. Either first person, both, or neither should be defined.")

		// These are ones that might appear to a user, and so could use some special handling.
		else
			if(isnull(cur_emote.emote_type))
				Fail("emote [cur_emote] has a null target type.")

		if(isnum(cur_emote.max_stat_allowed) && cur_emote.max_stat_allowed < cur_emote.stat_allowed)
			Fail("emote [cur_emote]'s max_stat_allowed is greater than its stat_allowed, and would be unusable.")

		if(isnum(cur_emote.max_unintentional_stat_allowed) && cur_emote.max_unintentional_stat_allowed < cur_emote.unintentional_stat_allowed)
			Fail("emote [cur_emote]'s max_unintentional_stat_allowed is greater than its unintentional_stat_allowed, and would be unusable.")


/datum/unit_test/emote/proc/has_punctuation(datum/emote/E, msg)
	return E.remove_ending_punctuation(msg) == msg
