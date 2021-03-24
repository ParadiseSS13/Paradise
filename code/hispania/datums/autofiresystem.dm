/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.
	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.
	Note that this proc can be overridden, and is in the case of screen objects.
*/

/client/MouseDown(object,location,control,params)
	if (CH)
		if (!CH.MouseDown(object,location,control,params))
			return
	.=..()

/client/MouseUp(object,location,control,params)
	if (CH)
		if (!CH.MouseUp(object,location,control,params))
			return
	return ..()

/client/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	if (CH)
		if (!CH.MouseDrag(over_object,src_location,over_location,src_control,over_control,params))
			return
	return ..()

/client/Click(atom/target, location, control, params)
	var/list/L = params2list(params)
	var/draggedMiddle = L["drag"]	// Returns anything pressed down during the left click event as we are in Click() method by left or middle click
	var/left = L["left"]		// Obivously checking if the left got clicked and not held down.

	// Deny the exploit when middleclick is pressed during the left click event
	if(draggedMiddle == "middle" && left)
		return

	if (CH)
		if (!CH.Click(target, location, control, params))
			return

	if(!target.Click(location, control, params))
		usr.ClickOn(target, params)

/datum/click_handler
//	var/mob_type
	var/species
	var/handler_name
	var/one_use_flag = 1//drop client.CH after succes ability use
	var/client/owner

/datum/click_handler/New(client/_owner)
	owner = _owner

/datum/click_handler/Destroy()
	..()
	if (owner)
		owner.CH = null
	return ..()
//	owner = null

//Return false from these procs to discard the click afterwards
/datum/click_handler/proc/Click(atom/target, location, control, params)
	return TRUE

/datum/click_handler/proc/MouseDown(object,location,control,params)
	return TRUE

/datum/click_handler/proc/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	return TRUE

/datum/click_handler/proc/MouseUp(object,location,control,params)
	return TRUE

/datum/click_handler/proc/resolve_world_target(a,location, control, params)
	if (istype(a, /obj/screen/click_catcher))
		var/obj/screen/click_catcher/CC = a
		return CC.resolve(owner.mob)

	if (istype(a, /turf))
		return a

	else if (istype(a, /atom))
		var/atom/A = a
		if (istype(A.loc, /turf))
			return A
	return

/datum/click_handler/fullauto
	var/atom/target
	var/list/targetparams
	var/obj/item/gun/reciever //The thing we send firing signals to.

/datum/click_handler/fullauto/Click()
	return TRUE //Doesn't work with normal clicks

//Next loop will notice these vars and stop shooting
/datum/click_handler/fullauto/proc/stop_firing()
	target = null

/datum/click_handler/fullauto/proc/do_fire()
	reciever.afterattack(target, owner.mob, TRUE, targetparams)

/datum/click_handler/fullauto/MouseDown(object, location, control, params)
	if(owner.mob.in_throw_mode)
		var/obj/item/gun/projectile/automatic/fullauto/signal = reciever
		reciever.throw_at(target, reciever.throw_range, reciever.throw_speed, owner.mob, null, null, null, owner.mob.move_force)
		stop_firing()
		signal.modeupdate(owner.mob,FALSE)
		return FALSE
	if(!isturf(owner.mob.loc)) // This stops from firing full auto weapons inside closets or in /obj/effect/dummy/chameleon chameleon projector
		return FALSE

	object = resolve_world_target(object, location, control, params)
	if(object)
		target = object
		targetparams = params
		while(target)
			owner.mob.face_atom(target)
			do_fire(params)
			sleep(reciever.fire_delay)
	return TRUE

/datum/click_handler/fullauto/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	src_location = resolve_world_target(src_location, src_location, src_control, params)
	if(src_location)
		target = src_location
		return FALSE
	return TRUE

/datum/click_handler/fullauto/MouseUp(object, location, control, params)
	stop_firing()
	return TRUE

/datum/click_handler/fullauto/Destroy()
	stop_firing() //Without this it keeps firing in an infinite loop when deleted
	return ..()

///////////////////////////////////////////////////////////////////////////////////////////////////

/mob/proc/kill_CH()
	if (src.client.CH)
		qdel(src.client.CH)

/obj/screen/click_catcher/proc/resolve(mob/user, location, control, params)
	var/list/modifiers = params2list(params)
	var/turf/T = params2turf(modifiers["screen-loc"], get_turf(usr))
	return T
