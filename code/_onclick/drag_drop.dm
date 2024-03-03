/*
This function is called every time we cross other turf(i guess) while dragging atom
It means that while one dragNdrop if you cross multiple turfs this function will be called multiple times
*/
/atom/MouseDrag()
	if(drag_start == 0) // we want to capture only moment of start dragging
		drag_start = world.time

/*
This function is exist to check of our current dragNdrop could be just laggy click
Currently it just checks how long our dragNdrop was. If it was lag, it would be extremely small, otherwise it would be long
returns
TRUE if current dragNdrop is lesser than 0.2 sec
FALSE if not
*/
/atom/proc/could_be_click_lag()
	return world.time - drag_start < 0.2 SECONDS // should be enough to lag

/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	var/lagging = could_be_click_lag()
	drag_start = 0
	if(!(is_screen_atom(over) || (loc && loc == over.loc)))
		if(!Adjacent(usr) || !over.Adjacent(usr)) // should stop you from dragging through windows
			if(lagging)
				usr.ClickOn(src, params)
			return

	var/datum/callback/mousedrop = new(over, PROC_REF(MouseDrop_T), src, usr, params)
	var/result = mousedrop.InvokeAsync() // if it gets TRUE in return, we think that all is fine
	if(!result && lagging)
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
