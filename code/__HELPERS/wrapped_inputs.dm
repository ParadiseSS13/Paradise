// This exists as a wrapper to keep the raw input() opcodes to a minimum
// Anything player-facing should be using TGUI inputs
// These are only for admin related tools

/proc/wrapped_selection_input(mob/user, input_text, input_title, list/values, default)
	if(!length(values))
		CRASH("Invalid list of values provided to wrapped_selection_input()")

	if(default == null)
		default = values[1]

	return input(user, input_text, input_title, default) as null|anything in values

/proc/wrapped_number_input(mob/user, input_text, input_title, default = 0)
	return text2num(input(user, input_text, input_title, default) as num|null)

/proc/wrapped_sound_input(mob/user, input_text, input_title)
	return input(user, input_text, input_title) as null|sound

/proc/wrapped_file_input(mob/user, input_text, input_title)
	return input(user, input_text, input_title) as null|file

/proc/wrapped_icon_input(mob/user, input_text, input_title)
	return input(user, input_text, input_title) as null|icon
