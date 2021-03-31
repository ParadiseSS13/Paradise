/mob/proc/set_input_focus(datum/new_focus)
	if(input_focus == new_focus)
		return
	input_focus = new_focus
	reset_perspective(input_focus) // Maybe this should be done manually? You figure it out, reader
