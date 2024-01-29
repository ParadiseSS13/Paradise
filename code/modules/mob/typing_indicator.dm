GLOBAL_LIST_EMPTY(typing_indicator)
GLOBAL_VAR(thinking_indicator)

/**
  * Toggles the floating chat bubble above a players head.
  *
  * Arguments:
  * * state - Should a chat bubble be shown or hidden
  * * me - Is the bubble being caused by the 'me' emote command
  */
/mob/proc/set_typing_indicator(state, me)
	if(!GLOB.typing_indicator[bubble_icon])
		GLOB.typing_indicator[bubble_icon] = image('icons/mob/talk.dmi', null, "[bubble_icon]typing", FLY_LAYER)
		var/image/I = GLOB.typing_indicator[bubble_icon]
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(ishuman(src) && !me)
		var/mob/living/carbon/human/H = src
		if(HAS_TRAIT(H, TRAIT_MUTE))
			overlays -= GLOB.typing_indicator[bubble_icon]
			typing = FALSE
			return FALSE

	if(!client)
		return FALSE

	if(stat != CONSCIOUS || is_muzzled() || (client.prefs.toggles & PREFTOGGLE_SHOW_TYPING) || (me && (client.prefs.toggles2 & PREFTOGGLE_2_EMOTE_BUBBLE)))
		overlays -= GLOB.typing_indicator[bubble_icon]
		typing = FALSE
		return FALSE

	if(state && !typing)
		overlays += GLOB.typing_indicator[bubble_icon]
		typing = TRUE

	if(!state && typing)
		overlays -= GLOB.typing_indicator[bubble_icon]
		typing = FALSE

	return state

/**
  * Toggles the floating thought bubble above a players head.
  *
  * Arguments:
  * * state - Should a thought bubble be shown or hidden
  */
/mob/proc/set_thinking_indicator(state)
	if(!GLOB.thinking_indicator)
		GLOB.thinking_indicator = image('icons/mob/talk.dmi', null, "defaultthinking", FLY_LAYER)
		var/image/I = GLOB.thinking_indicator
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(!client && !isliving(src))
		return FALSE

	if(stat != CONSCIOUS)
		overlays -= GLOB.thinking_indicator
		thinking = FALSE
		return FALSE

	if(!state && thinking)
		overlays -= GLOB.thinking_indicator
		thinking = FALSE

	if(state && !thinking)
		overlays += GLOB.thinking_indicator
		thinking = TRUE

	return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	set_typing_indicator(TRUE)
	typing = TRUE
	var/message = typing_input(src, "", "say (text)")
	typing = FALSE
	set_typing_indicator(FALSE)
	if(message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	set_typing_indicator(TRUE, TRUE)
	typing = TRUE
	var/message = typing_input(src, "", "me (text)")
	typing = FALSE
	set_typing_indicator(FALSE)
	if(message)
		me_verb(message)

/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing a message."
	prefs.toggles ^= PREFTOGGLE_SHOW_TYPING
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_SHOW_TYPING) ? "no longer" : "now"] display a typing indicator.")

	// Clear out any existing typing indicator.
	if(prefs.toggles & PREFTOGGLE_SHOW_TYPING)
		if(istype(mob))
			mob.set_typing_indicator(FALSE)

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Typing Indicator (Speech)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/emote_indicator()
	set name = "Show/Hide Emote Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing an emote."
	prefs.toggles2 ^= PREFTOGGLE_2_EMOTE_BUBBLE
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_EMOTE_BUBBLE) ? "no longer" : "now"] display a typing indicator for emotes.")

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Typing Indicator (Emote)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	// Clear out any existing emote typing indicator.
	if(prefs.toggles & PREFTOGGLE_2_EMOTE_BUBBLE)
		if(istype(mob))
			mob.set_typing_indicator(FALSE, TRUE)
