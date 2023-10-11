/*
	Click code cleanup
	~Sayu
*/


// THESE DO NOT AFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
/mob/var/next_move_adjust = 0 //Amount to adjust action delays by, + or -
/mob/var/next_move_modifier = 1 //Value to multiply action delays by

//Delays the mob's next action by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num+next_move_adjust)*next_move_modifier)

// 1 decisecond click delay (above and beyond mob/next_move)
//This is mainly modified by click code, to modify click delays elsewhere, use next_move and changeNext_move()
/mob/var/next_click	= 0

// THESE DO AFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK
/mob/var/next_click_adjust = 0
/mob/var/next_click_modifier = 1 //Value to multiply click delays by

//Delays the mob's next click by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_click(num)
	next_click = world.time + ((num+next_click_adjust)*next_click_modifier)


/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/
/atom/Click(location,control,params)
	usr.ClickOn(src, params)
/atom/DblClick(location,control,params)
	usr.DblClickOn(src,params)

/*
	Standard mob ClickOn()
	Handles exceptions: Buildmode, middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)
	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	var/list/modifiers = params2list(params)
	var/dragged = modifiers["drag"]
	if(dragged && !modifiers[dragged])
		return
	if(IsFrozen(A) && !is_admin(usr))
		to_chat(usr, "<span class='boldannounce'>Interacting with admin-frozen players is not permitted.</span>")
		return
	if(modifiers["middle"] && modifiers["shift"] && modifiers["ctrl"])
		MiddleShiftControlClickOn(A)
		return
	if(modifiers["middle"] && modifiers["shift"])
		MiddleShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(incapacitated(ignore_restraints = 1, ignore_grab = 1))
		return

	face_atom(A)

	if(next_move > world.time) // in the year 2000...
		return

	if(!modifiers["catcher"] && A.IsObscured())
		return

	if(ismecha(loc))
		if(!locate(/turf) in list(A,A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A, src, params)

	if(restrained())
		changeNext_move(CLICK_CD_HANDCUFFED) //Doing shit in cuffs shall be vey slow
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	if(isLivingSSD(A))
		if(client && client.send_ssd_warning(A))
			return

	var/obj/item/W = get_active_hand()

	if(W == A)
		W.attack_self(src)
		if(hand)
			update_inv_l_hand()
		else
			update_inv_r_hand()
		return

	// operate three levels deep here (item in backpack in src; item in box in backpack in src, not any deeper)
	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 2))
		// No adjacency needed
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1)

		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return TRUE

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				W.melee_attack_chain(src, A, params)
			else
				if(ismob(A))
					changeNext_move(CLICK_CD_MELEE)
				UnarmedAttack(A, 1)

			return
		else // non-adjacent click
			if(W)
				W.afterattack(A,src,0,params) // 0: not Adjacent
			else
				RangedAttack(A, params)

	return

//Is the atom obscured by a PREVENT_CLICK_UNDER_1 object above it
/atom/proc/IsObscured()
	if(!isturf(loc)) //This only makes sense for things directly on turfs for now
		return FALSE
	var/turf/T = get_turf_pixel(src)
	if(!T)
		return FALSE
	for(var/atom/movable/AM in T)
		if(AM.flags & PREVENT_CLICK_UNDER && AM.density && AM.layer > layer)
			return TRUE
	return FALSE

/turf/IsObscured()
	for(var/atom/movable/AM in src)
		if(AM.flags & PREVENT_CLICK_UNDER && AM.density)
			return TRUE
	return FALSE

// Default behavior: ignore double clicks, consider them normal clicks instead
/mob/proc/DblClickOn(atom/A, params)
	return

/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		changeNext_move(CLICK_CD_MELEE)
	return

/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(atom/A, params)
	if(SEND_SIGNAL(src, COMSIG_MOB_ATTACK_RANGED, A, params) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(atom/A)
	return

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(atom/A)
	pointed(A)
	return

// See click_override.dm
/mob/living/MiddleClickOn(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_MIDDLECLICKON, A, src)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	if(middleClickOverride)
		middleClickOverride.onClick(A, src)
	else
		..()


/*
	Middle shift-click
	Makes the mob face the direction of the clicked thing
*/
/mob/proc/MiddleShiftClickOn(atom/A)
	return

/mob/living/MiddleShiftClickOn(atom/A)
	if(incapacitated())
		return
	var/face_dir = get_cardinal_dir(src, A)
	if(!face_dir || forced_look == face_dir || A == src)
		forced_look = null
		to_chat(src, "<span class='notice'>Cancelled direction lock.</span>")
		return
	forced_look = face_dir
	to_chat(src, "<span class='userdanger'>You are now facing [dir2text(forced_look)]. To cancel this, shift-middleclick yourself.</span>")

/*
	Middle shift-control-click
	Makes the mob constantly face the object (until it's out of sight)
*/
/mob/proc/MiddleShiftControlClickOn(atom/A)
	return

/mob/living/MiddleShiftControlClickOn(atom/A)
	var/face_uid = A.UID()
	if(forced_look == face_uid || A == src)
		forced_look = null
		to_chat(src, "<span class='notice'>Cancelled direction lock.</span>")
		return
	forced_look = face_uid
	to_chat(src, "<span class='userdanger'>You are now facing [A]. To cancel this, shift-middleclick yourself.</span>")

// In case of use break glass
/*
/atom/proc/MiddleClick(mob/M as mob)
	return
*/

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(mob/user)
	if(user.client && get_turf(user.client.eye) == get_turf(user))
		user.examinate(src)
	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	var/mob/living/ML = user
	if(istype(ML))
		ML.pulled(src)

/*
	Alt click
*/
/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)
	return

// See click_override.dm
/mob/living/AltClickOn(atom/A)
	. = SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, A, src)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	if(middleClickOverride && middleClickOverride.onClick(A, src))
		return
	..()

/atom/proc/AltClick(mob/user)
	SEND_SIGNAL(src, COMSIG_CLICK_ALT, user)
	var/turf/T = get_turf(src)
	if(T && (isturf(loc) || isturf(src)) && user.TurfAdjacent(T))
		user.listed_turf = T
		user.client.statpanel = T.name

/// Use this instead of [/mob/proc/AltClickOn] where you only want turf content listing without additional atom alt-click interaction
/atom/proc/AltClickNoInteract(mob/user, atom/A)
	var/turf/T = get_turf(A)
	if(T && user.TurfAdjacent(T))
		user.listed_turf = T
		user.client.statpanel = T.name

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/*
	Control+Shift/Alt+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/atom/proc/CtrlShiftClick(mob/user)
	return

/mob/proc/AltShiftClickOn(atom/A)
	A.AltShiftClick(src)
	return

/mob/proc/ShiftMiddleClickOn(atom/A)
	return

/atom/proc/AltShiftClick(mob/user)
	return

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	changeNext_move(CLICK_CD_RANGE)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)

	var/obj/item/projectile/beam/LE = new /obj/item/projectile/beam(loc)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)

	LE.firer = src
	LE.firer_source_atom = src
	LE.def_zone = ran_zone(zone_selected)
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	LE.fire()

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
	if( stat || buckled || !A || !x || !y || !A.x || !A.y ) return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) return

	var/direction
	if(abs(dx) < abs(dy))
		if(dy > 0)	direction = NORTH
		else		direction = SOUTH
	else
		if(dx > 0)	direction = EAST
		else		direction = WEST
	dir = direction

/obj/screen/click_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"

/obj/screen/click_catcher/MouseEntered(location, control, params)
	return

/obj/screen/click_catcher/MouseExited(location, control, params)
	return

#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32)			//Not using world.icon_size on purpose.

/obj/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
	var/icon/newicon = icon('icons/mob/screen_gen.dmi', "catcher")
	var/ox = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_x)
	var/oy = min(MAX_SAFE_BYOND_ICON_SCALE_TILES, view_size_y)
	var/px = view_size_x * world.icon_size
	var/py = view_size_y * world.icon_size
	var/sx = min(MAX_SAFE_BYOND_ICON_SCALE_PX, px)
	var/sy = min(MAX_SAFE_BYOND_ICON_SCALE_PX, py)
	newicon.Scale(sx, sy)
	icon = newicon
	screen_loc = "CENTER-[(ox-1)*0.5],CENTER-[(oy-1)*0.5]"
	var/matrix/M = new
	M.Scale(px/sx, py/sy)
	transform = M

/obj/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/T = params2turf(modifiers["screen-loc"], get_turf(usr))
		params += "&catcher=1"
		if(T)
			T.Click(location, control, params)
	. = 1
