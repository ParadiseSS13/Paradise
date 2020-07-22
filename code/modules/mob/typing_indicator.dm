#define TYPING_INDICATOR_LIFETIME 30 * 10	//grace period after which typing indicator disappears regardless of text in chatbar

mob/var/hud_typing = 0 //set when typing in an input window instead of chatline
mob/var/typing
mob/var/last_typed
mob/var/last_typed_time

var/global/image/typing_indicator

/mob/proc/set_typing_indicator(var/state)

	if(!typing_indicator)
		typing_indicator = image('icons/mob/talk.dmi', null, "typing", MOB_LAYER + 1)
		typing_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.disabilities & MUTE || H.silent)
			overlays -= typing_indicator
			return

	if(client)
		if((client.prefs.toggles & SHOW_TYPING) || stat != CONSCIOUS || is_muzzled())
			overlays -= typing_indicator
		else
			if(state)
				if(!typing)
					overlays += typing_indicator
					typing = 1
			else
				if(typing)
					overlays -= typing_indicator
					typing = 0
			return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	set_typing_indicator(1)
	hud_typing = 1
	var/message = typing_input(src, "", "say (text)")
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		say_verb(message)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

	
	set_typing_indicator(1)
	hud_typing = 1
	var/message = typing_input(src, "", "me (text)")
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		me_verb(message)

/mob/proc/handle_typing_indicator()
	if(client)
		if(!(client.prefs.toggles & SHOW_TYPING) && !hud_typing)
			var/temp = winget(client, "input", "text")

			if(temp != last_typed)
				last_typed = temp
				last_typed_time = world.time

			if(world.time > last_typed_time + TYPING_INDICATOR_LIFETIME)
				set_typing_indicator(0)
				return
			if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
				set_typing_indicator(1)
			else if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
				set_typing_indicator(1)

			else
				set_typing_indicator(0)

/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing emote or say message."
	prefs.toggles ^= SHOW_TYPING
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & SHOW_TYPING) ? "no longer" : "now"] display a typing indicator.")

	// Clear out any existing typing indicator.
	if(prefs.toggles & SHOW_TYPING)
		if(istype(mob)) mob.set_typing_indicator(0)

	feedback_add_details("admin_verb","TID") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!