// Would be nice to make this a permanent admin pref so we don't need to click it each time
USER_VERB(enable_debug_verbs, R_DEBUG, "Debug verbs", "Enable all debug verbs.", VERB_CATEGORY_DEBUG)
	SSuser_verbs.update_visibility_flag(client, VERB_VISIBILITY_FLAG_MOREDEBUG, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB_VISIBILITY(disable_debug_verbs, VERB_VISIBILITY_FLAG_MOREDEBUG)
USER_VERB(disable_debug_verbs, R_DEBUG, "Debug verbs", "Disable all debug verbs.", VERB_CATEGORY_DEBUG)
	SSuser_verbs.update_visibility_flag(client, VERB_VISIBILITY_FLAG_MOREDEBUG, FALSE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Debug Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
