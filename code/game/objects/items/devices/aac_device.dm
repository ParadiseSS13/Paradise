#define BUTTON_GREEN "Green Button"
#define BUTTON_RED "Red Button"
#define BUTTON_BLUE "Blue Button"
#define BUTTON_YELLOW "Yellow Button"
#define BUTTON_PURPLE "Purple Button"

/obj/item/aac_device
	name = "\improper AAC device"
	desc = "A pocket-sized, folding device with a number of buttons on its cover."
	icon = 'icons/obj/device.dmi'
	icon_state = "aac_device"
	w_class = WEIGHT_CLASS_SMALL
	new_attack_chain = TRUE

	/// What the 'quick' buttons are set to.
	var/list/buttons = list(BUTTON_GREEN = "Yes.",
							BUTTON_RED = "No.",
							BUTTON_BLUE = "Hello!",
							BUTTON_YELLOW = "I don't know.",
							BUTTON_PURPLE = "What?")

	/// Whether the device is opened or closed. When opened, using it customizes the quick buttons or directly says input text; when closed, using it opens a radial menu to quickly say one of the buttons.
	var/opened = FALSE

/obj/item/aac_device/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("You can <b>Alt-Click</b> [src] to [opened ? "close" : "open"] it.")

/obj/item/aac_device/proc/pick_button(mob/user)
	var/list/options = list(BUTTON_GREEN = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_green"),
								BUTTON_RED = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_red"),
								BUTTON_BLUE = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_blue"),
								BUTTON_YELLOW = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_yellow"),
								BUTTON_PURPLE = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_purple"))

	return show_radial_menu(user, src, options)

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
									"Change Name" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "labeler0"),
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

		if(choice == "Change Name")
			rename_interactive(user, use_prefix = FALSE)
			to_chat(user, SPAN_NOTICE("You rename \the [src]."))
			return

		var/button = pick_button(user)

		if(!button || user.stat || QDELETED(src))
			return

		var/new_message = tgui_input_text(user, "Type a message:", "[src]")

		buttons[button] = new_message
		to_chat(user, SPAN_NOTICE("You configure the [lowertext(button)] to say \"[new_message]\"."))

		return

	var/button = pick_button(user)

	if(!button || user.stat || QDELETED(src))
		return

	do_speech(user, buttons[button])

/obj/item/aac_device/AltClick(mob/user)
	if(!user.is_holding(src))
		to_chat(user, SPAN_NOTICE("You need to be holding [src] to [opened ? "close" : "open"] it."))
		return

	if(do_after(user, 1 SECONDS, target = src))
		opened = !opened
		icon_state = "aac_device[opened ? "_open" : ""]"
		w_class = opened ? WEIGHT_CLASS_NORMAL : WEIGHT_CLASS_SMALL
		to_chat(user, SPAN_NOTICE("You [opened ? "open" : "close"] [src]."))

#undef BUTTON_GREEN
#undef BUTTON_RED
#undef BUTTON_BLUE
#undef BUTTON_YELLOW
#undef BUTTON_PURPLE
