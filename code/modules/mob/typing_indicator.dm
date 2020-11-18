#define CHAT_BUBBLE_LIFETIME 3 SECONDS	//grace period after which typing indicator disappears regardless of text in chatbar

/mob/var/hud_typing = 0 //set when typing in an input window instead of chatline
/mob/var/typing
/mob/var/last_typed
/mob/var/last_typed_time

GLOBAL_LIST_EMPTY(typing_indicator)

/**
  * Toggles the floating chat bubble above a players head.
  *
  * Arguments:
  * * state - On or Off
  * * say - Is the bubble being caused by the 'say' command
  * * me - Is the bubble being caused by the 'me' command
  */
/mob/proc/set_typing_indicator(state, say, me)

	if(!GLOB.typing_indicator[bubble_icon])
		GLOB.typing_indicator[bubble_icon] = image('icons/mob/talk.dmi', null, "[bubble_icon]typing", FLY_LAYER)
		var/image/I = GLOB.typing_indicator[bubble_icon]
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if((MUTE in H.mutations) || H.silent)
			overlays -= GLOB.typing_indicator[bubble_icon]
			return

	if(client)
		if((!client.prefs.typing_indicator || stat != CONSCIOUS || is_muzzled()) || (me && (client.prefs.typing_indicator != TYPING_INDICATOR_ALL)))
			overlays -= GLOB.typing_indicator[bubble_icon]
		else
			if(state)
				if(!typing)
					overlays += GLOB.typing_indicator[bubble_icon]
					typing = 1
			else
				if(typing)
					overlays -= GLOB.typing_indicator[bubble_icon]
					typing = 0
			return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	set_typing_indicator(1, TRUE)
	hud_typing = 1
	var/message = typing_input(src, "", "say (text)")
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1


	set_typing_indicator(1, FALSE, TRUE)
	hud_typing = 1
	var/message = typing_input(src, "", "me (text)")
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		me_verb(message)

/mob/proc/handle_typing_indicator()
	if(client)
		if(!client.prefs.typing_indicator && !hud_typing)
			var/temp = winget(client, "input", "text")

			if(temp != last_typed)
				last_typed = temp
				last_typed_time = world.time

			if(world.time > last_typed_time + CHAT_BUBBLE_LIFETIME)
				set_typing_indicator(0)
				return
			if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
				set_typing_indicator(1, TRUE)
			else if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
				set_typing_indicator(1, FALSE, TRUE)

			else
				set_typing_indicator(0)

/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing an emote or say message."

	if(prefs.typing_indicator == TYPING_INDICATOR_ALL)
		prefs.typing_indicator = TYPING_INDICATOR_SAY
		to_chat(src, "You will no longer display a typing indicator for emotes.")
	
	else if(prefs.typing_indicator == TYPING_INDICATOR_SAY)
		prefs.typing_indicator = TYPING_INDICATOR_NONE
		to_chat(src, "You will no longer display a typing indicator.")

	else
		prefs.typing_indicator = TYPING_INDICATOR_ALL
		to_chat(src, "You will now display a typing indicator.")

	prefs.save_preferences(src)

	// Clear out any existing typing indicator.
	if(istype(mob))
		mob.set_typing_indicator(0)

	feedback_add_details("admin_verb","TID") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef CHAT_BUBBLE_LIFETIME
