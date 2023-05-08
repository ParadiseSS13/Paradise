/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	if(!(istype(over, /obj/screen) || (loc && loc == over.loc)))
		if(!Adjacent(usr) || !over.Adjacent(usr)) // should stop you from dragging through windows
			usr.ClickOn(src, params)
			return

	INVOKE_ASYNC(over, PROC_REF(MouseDrop_T), src, usr, params)

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params)
	user.ClickOn(dropping, params)
	return
