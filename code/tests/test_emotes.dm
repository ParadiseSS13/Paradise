

/datum/game_test/emote/Run()

	// Special cases that shouldn't need keybinds.
	var/list/ignored_emote_types = list(
		/datum/emote/living/simple_animal/slime,  // The emotes are usable if you are a slime, but I don't think we need to flood the keybind list with them
		/datum/emote/help,
		/datum/emote/living/custom  // This one's handled by its own set of keybinds
	)

	var/list/keybound_emotes = get_emote_keybinds()

	// be aware that some of these values (like message, message_param) are subject to being set at runtime.
	for(var/emote_type in subtypesof(/datum/emote))
		var/datum/emote/cur_emote = new emote_type()
		if(cur_emote.message_param && !cur_emote.param_desc)
			TEST_FAIL("emote [cur_emote] was given a message parameter without a description.")

		// Sanity checks, these emotes probably won't appear to a user but we should make sure they're cleaned up.
		if(!cur_emote.key)
			if(cur_emote.message || cur_emote.message_param)
				TEST_FAIL("emote [cur_emote] is missing a key but has a message defined.")
			if(cur_emote.key_third_person)
				TEST_FAIL("emote [cur_emote] has a third-person key defined, but no first-person key. Either first person, both, or neither should be defined.")

		// These are ones that might appear to a user, and so could use some special handling.
		else
			TEST_ASSERT_NOTNULL(cur_emote.emote_type, "emote [cur_emote] has a null target type.")

			// If we're at this point, we're definitely an emote that a user could use, and therefore ought to make sure it's bound to a keybind if possible.
			if(!is_type_in_list(cur_emote, keybound_emotes) && !is_type_in_list(cur_emote, ignored_emote_types))
				TEST_FAIL("Emote [cur_emote] is usable, but not assigned a keybind.")

		if(isnum(cur_emote.max_stat_allowed) && cur_emote.max_stat_allowed < cur_emote.stat_allowed)
			TEST_FAIL("emote [cur_emote]'s max_stat_allowed is greater than its stat_allowed, and would be unusable.")

		if(isnum(cur_emote.max_unintentional_stat_allowed) && cur_emote.max_unintentional_stat_allowed < cur_emote.unintentional_stat_allowed)
			TEST_FAIL("emote [cur_emote]'s max_unintentional_stat_allowed is greater than its unintentional_stat_allowed, and would be unusable.")

/datum/game_test/emote/proc/get_emote_keybinds()
	var/list/bound_emotes = list()
	for(var/keybind in subtypesof(/datum/keybinding/emote))
		var/datum/keybinding/emote/E = new keybind()
		bound_emotes |= E.linked_emote

	return bound_emotes


