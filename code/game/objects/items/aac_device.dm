#define BUTTON_GREEN "Green Button"
#define BUTTON_RED "Red Button"
#define BUTTON_BLUE "Blue Button"
#define BUTTON_YELLOW "Yellow Button"
#define BUTTON_PURPLE "Purple Button"

/obj/item/aac_device
	name = "\improper AAC device"
	desc = "A small device with a number of buttons and a speaker. It can unfold to reveal a keyboard and screen used to configure what each button says when pressed."
	icon = 'icons/obj/device.dmi' // Temp
	icon_state = "enginepicker" // Temp
	w_class = WEIGHT_CLASS_SMALL
	new_attack_chain = TRUE

	// What the 'quick' buttons are set to.
	var/list/buttons = list(BUTTON_GREEN = "Yes.",
							BUTTON_RED = "No.",
							BUTTON_BLUE = "Hello!",
							BUTTON_YELLOW = "I don't know.",
							BUTTON_PURPLE = "What?")

	// Whether the device is opened or closed. When opened, using it customizes the quick buttons or directly says input text; when closed, using it opens a radial menu to quickly say one of the buttons.
	var/opened = FALSE

/obj/item/aac_device/examine(mob/user)
	. = ..()
	. += ""
	. += SPAN_NOTICE("[opened ? "It is currently opened, allowing for custom messages to be input." : "It is closed, reducing its size and allowing for quick responses to be used."]")
	. += ""
	. += SPAN_NOTICE("You can <b>Alt-Click</b> [src] to [opened ? "close" : "open"] it.")
	. += SPAN_NOTICE("You can <b>Ctrl-Shift-Click</b> [src] to change its name.")

/obj/item/aac_device/proc/pick_button(mob/user)
	var/list/options = list(BUTTON_GREEN = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_green"),
								BUTTON_RED = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_red"),
								BUTTON_BLUE = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_blue"),
								BUTTON_YELLOW = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_yellow"),
								BUTTON_PURPLE = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_purple"))

	var/choice = show_radial_menu(user, src, options)

	if(!choice || user.stat || QDELETED(src))
		return

	return choice

/obj/item/aac_device/proc/do_speech(mob/user, message)
	audible_message("[SPAN_NAME("[src]")] beeps, \"[message]\"")
	playsound(src, 'sound/machines/twobeep.ogg', 50, FALSE)
	log_say("(AAC device) [message]", user)
	user.create_log(SAY_LOG, "(AAC device) '[message]'")

	for(var/mob/M as anything in get_mobs_in_view(7, src, ai_eyes = AI_EYE_REQUIRE_HEAR))
		if((M.client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && M.can_hear())
			M.create_chat_message(user, message)

/obj/item/aac_device/activate_self(mob/user)
	if(..())
		return

	if(opened)
		var/list/options = list("Custom Message" = image(icon = 'icons/obj/device.dmi', icon_state = "megaphone"),
									"Edit Button" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen"))

		var/choice = show_radial_menu(user, src, options)

		if(!choice || user.stat || QDELETED(src))
			return

		if(choice == "Custom Message")
			var/message = tgui_input_text(user, "Type a message:", "[src]")

			if(!message)
				return

			do_speech(user, message)

			return

		var/button = pick_button(user)
		var/new_message = tgui_input_text(user, "Type a message:", "[src]")

		buttons[button] = new_message
		to_chat(user, SPAN_NOTICE("You change the [button.toLowerCase()]'s text to [new_message].")

		return

	var/button = pick_button(user)
	do_speech(user, buttons[button])

