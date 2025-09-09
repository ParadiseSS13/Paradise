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
receive a mousedrop
called on object which was under the object you dragged and dropped
return TRUE if you want to prevent us click the object
actually if you do something in that proc like changing user location or whatever, you expected to return TRUE
to inform the game this action was expected and its fine
*/
/atom/proc/MouseDrop_T(atom/dropping, mob/user, params) // return TRUE if you want to prevent us click the object after it
	return FALSE

/client/MouseDown(datum/object, location, control, params)
	if(QDELETED(object)) // Yep, you can click on qdeleted things before they have time to nullspace. Fun.
		return
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)
	var/delay = mob.CanMobAutoclick(object, location, params)
	if(delay)
		selected_target[1] = object
		selected_target[2] = params
		while(selected_target[1])
			Click(selected_target[1], location, control, selected_target[2])
			sleep(delay)

/client/MouseUp(object, location, control, params)
	if(SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEUP, object, location, control, params) & COMPONENT_CLIENT_MOUSEUP_INTERCEPT)
		click_intercept_time = world.time
	selected_target[1] = null

/mob/proc/CanMobAutoclick(object, location, params)
	return FALSE

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return FALSE
	var/obj/item/active_item = get_active_hand()
	return active_item?.CanItemAutoclick(object, location, params)

/obj/item/proc/CanItemAutoclick(object, location, params)
	return FALSE

/atom/proc/IsAutoclickable()
	return TRUE

/obj/screen/IsAutoclickable()
	return FALSE

/obj/screen/click_catcher/IsAutoclickable()
	return TRUE

// The actual arguments of this:
// MouseDrag(src_object as null|atom in usr.client,
//           over_object as null|atom in usr.client,
//           src_location as null|turf|text in usr.client,
//           over_location as null|turf|text in usr.client,
//           src_control as text, over_control as text, params as text)
/client/MouseDrag(src_object, atom/over_object, src_location, turf/over_location, src_control, over_control, params)
	var/list/modifiers = params2list(params)
	if(!drag_start) // If we're just starting to drag
		drag_start = world.time
		drag_details = modifiers.Copy()
	mouseParams = params
	mouse_location_UID = isturf(over_location) ? over_location.UID() : over_location
	mouse_object_UID = over_object?.UID()
	if(selected_target[1] && over_object?.IsAutoclickable())
		selected_target[1] = over_object
		selected_target[2] = params
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDRAG, src_object, over_object, src_location, over_location, src_control, over_control, params)
	return ..()

/client/MouseDrop(atom/src_object, atom/over_object, atom/src_location, atom/over_location, src_control, over_control, params)
	..()
	drag_start = 0
	drag_details = null
