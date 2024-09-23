GLOBAL_LIST_EMPTY(typing_indicator)
GLOBAL_LIST_EMPTY(thinking_indicator)

/**
  * Toggles the floating chat bubble above a players head.
  *
  * Arguments:
  * * state - Should a chat bubble be shown or hidden
  * * me - Is the bubble being caused by the 'me' emote command
  */
/mob/proc/set_typing_indicator(state, me)
	if(!GLOB.typing_indicator[bubble_icon])
		GLOB.typing_indicator[bubble_icon] = image('icons/mob/talk.dmi', null, "[bubble_icon]_typing", ABOVE_HUD_LAYER)
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

	if(stat != CONSCIOUS || is_muzzled() || (client.prefs.toggles & PREFTOGGLE_SHOW_TYPING))
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
	if(!GLOB.thinking_indicator[bubble_icon])
		GLOB.thinking_indicator[bubble_icon] = image('icons/mob/talk.dmi', null, "[bubble_icon]_thinking", ABOVE_HUD_LAYER)
		var/image/I = GLOB.thinking_indicator[bubble_icon]
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(!client && !isliving(src))
		return FALSE

	if(stat != CONSCIOUS || (client.prefs.toggles & PREFTOGGLE_SHOW_TYPING))
		overlays -= GLOB.thinking_indicator[bubble_icon]
		thinking = FALSE
		return FALSE

	if(!state && thinking)
		overlays -= GLOB.thinking_indicator[bubble_icon]
		thinking = FALSE

	if(state && !thinking)
		overlays += GLOB.thinking_indicator[bubble_icon]
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
