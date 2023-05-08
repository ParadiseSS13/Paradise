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

	var/datum/callback/mousedrop = new(over, PROC_REF(MouseDrop_T), src, usr, params)
	var/result = mousedrop.InvokeAsync() // if it gets TRUE in return, we think that all is fine
	if(!result)
		usr.ClickOn(src, params) // if not, we click object

/*
recieve a mousedrop
called on object which was under the object you dragged and dropped
return TRUE if you want to prevent us click the object
actually if you do something in that proc like changing user location or whatever, you expected to return TRUE
to inform the game this action was expected and its fine
*/
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params) // return TRUE if you want to prevent us click the object after it
	return
