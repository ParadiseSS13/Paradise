/*
	Click code cleanup
	~Sayu
*/

//Delays the mob's next action by num deciseconds
// eg: 10-3 = 7 deciseconds of delay
// eg: 10*0.5 = 5 deciseconds of delay
// DOES NOT EFFECT THE BASE 1 DECISECOND DELAY OF NEXT_CLICK

/mob/proc/changeNext_move(num)
	next_move = world.time + ((num+next_move_adjust)*next_move_modifier)

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
	* item/afterattack__legacy__attackchain(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)
	if(QDELETED(A))
		return

	if(check_click_intercept(params,A))
		return

	if(next_click > world.time)
		return
	changeNext_click(1)

	var/list/modifiers = params2list(params)
	var/dragged = modifiers["drag"]
	if(dragged && !modifiers[dragged])
		return
	if(IsFrozen(A) && !is_admin(usr))
		to_chat(usr, "<span class='boldannounceic'>Interacting with admin-frozen players is not permitted.</span>")
		return
	if(modifiers["middle"] && modifiers["shift"] && modifiers["ctrl"])
		MiddleShiftControlClickOn(A)
		return
	if(modifiers["middle"] && modifiers["shift"])
		MiddleShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A, modifiers)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A, modifiers)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A, modifiers)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A, modifiers)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A, modifiers)
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

	if(isclowncar(loc) && !modifiers["shift"])
		var/obj/tgvehicle/sealed/car/clowncar/cc = loc
		return cc.fire_cannon_at(A, src, params)

	if(restrained())
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
		if(W.new_attack_chain)
			W.activate_self(src)
		else
			W.attack_self__legacy__attackchain(src)
		if(hand)
			update_inv_l_hand()
		else
			update_inv_r_hand()
		return

	// operate three levels deep here (item in backpack in src; item in box in backpack in src, not any deeper)
	if(A in direct_access())
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1, params)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return TRUE

	if(can_reach(A, W))
		if(W)
			W.melee_attack_chain(src, A, params)
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1, params)
	else
		if(W)
			if(W.new_attack_chain)
				A.base_ranged_item_interaction(src, W, params)
			else
				W.afterattack__legacy__attackchain(A, src, 0, params) // 0: not Adjacent
		else
			RangedAttack(A, params)


/**
 * A backwards depth-limited breadth-first-search to see if the target is
 * logically "in" anything adjacent to us.
 */
/atom/movable/proc/can_reach(atom/ultimate_target, obj/item/tool, view_only = FALSE) //This might break mod storage. If it does, we hardcode mods / funny bag in here
	var/list/direct_access = direct_access()
	var/depth = 1 + (view_only ? STORAGE_VIEW_DEPTH : INVENTORY_DEPTH)

	var/list/closed = list()
	var/list/checking = list(ultimate_target)

	while(length(checking) && depth > 0)
		var/list/next = list()
		--depth

		for(var/atom/target in checking)  // will filter out nulls
			if(closed[target] || isarea(target))  // avoid infinity situations
				continue

			if(isturf(target) || isturf(target.loc) || (target in direct_access) || !(target.IsObscured()) || istype(target.loc, /obj/item/storage)) //Directly accessible atoms
				if(target.Adjacent(src) || (tool && check_tool_reach(src, target, tool.reach))) //Adjacent or reaching attacks
					return TRUE

			closed[target] = TRUE

			if(!target.loc)
				continue

			if(istype(target.loc, /obj/item/storage))
				next += target.loc

		checking = next
	return FALSE

/atom/movable/proc/direct_access()
	return list(src, loc)

/mob/direct_access(atom/target)
	return ..() + contents

/mob/living/direct_access(atom/target)
	return ..() + get_contents()

/proc/check_tool_reach(atom/movable/here, atom/movable/there, reach)
	if(!here || !there)
		return FALSE
	switch(reach)
		if(0, 1)
			return FALSE //here.Adjacent(there)
		if(2 to INFINITY)
			var/obj/dummy = new(get_turf(here))
			dummy.pass_flags |= PASSTABLE
			dummy.invisibility = 120
			for(var/i in 1 to reach) //Limit it to that many tries
				var/turf/T = get_step(dummy, get_dir(dummy, there))
				if(dummy.can_reach(there))
					qdel(dummy)
					return TRUE
				if(!dummy.Move(T)) //we're blocked!
					qdel(dummy)
					return FALSE
			qdel(dummy)

/// Can this mob use keybinded click actions? (Altclick, Ctrlclick, ect)
/mob/proc/can_use_clickbinds()
	return TRUE

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
/mob/proc/UnarmedAttack(atom/A, proximity_flag, params)
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
	if(SEND_SIGNAL(A, COMSIG_ATOM_RANGED_ATTACKED, src) & COMPONENT_CANCEL_ATTACK_CHAIN)
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
		clear_forced_look()
		return
	set_forced_look(A, FALSE)

/*
	Middle shift-control-click
	Makes the mob constantly face the object (until it's out of sight)
*/
/mob/proc/MiddleShiftControlClickOn(atom/A)
	return

/mob/living/MiddleShiftControlClickOn(atom/A)
	if(incapacitated())
		return
	var/face_uid = A.UID()
	if(forced_look == face_uid || A == src)
		clear_forced_look()
		return
	set_forced_look(A, TRUE)

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
/mob/proc/ShiftClickOn(atom/A, modifiers)
	A.ShiftClick(src, modifiers)
	return
/atom/proc/ShiftClick(mob/user, modifiers)
	if(user.client && get_turf(user.client.eye) == get_turf(user))
		user.examinate(src)
	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(atom/A, modifiers)
	A.CtrlClick(src, modifiers)
	return

/atom/proc/CtrlClick(mob/user, modifiers)
	SEND_SIGNAL(src, COMSIG_CLICK_CTRL, user)
	var/mob/living/ML = user
	if(istype(ML))
		ML.pulled(src)

/*
	Alt click
*/
/mob/proc/AltClickOn(atom/A, modifiers)
	A.AltClick(src, modifiers)
	return

// See click_override.dm
/mob/living/AltClickOn(atom/A, modifiers)
	. = SEND_SIGNAL(src, COMSIG_MOB_ALTCLICKON, A, src)
	if(. & COMSIG_MOB_CANCEL_CLICKON)
		return
	if(middleClickOverride && middleClickOverride.onClick(A, src))
		return
	..()

/atom/proc/AltClick(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_CLICK_ALT, user) & COMPONENT_CANCEL_ALTCLICK)
		return
	var/turf/T = get_turf(src)
	if(T && (isturf(loc) || isturf(src)) && user.TurfAdjacent(T))
		user.set_listed_turf(T)

/// Use this instead of [/mob/proc/AltClickOn] where you only want turf content listing without additional atom alt-click interaction
/atom/proc/AltClickNoInteract(mob/user, atom/A)
	var/turf/T = get_turf(A)
	if(T && user.TurfAdjacent(T))
		user.set_listed_turf(T)

/mob/proc/TurfAdjacent(turf/T)
	return T.Adjacent(src)

/*
	Control+Shift/Alt+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(atom/A, modifiers)
	A.CtrlShiftClick(src, modifiers)
	return

/atom/proc/CtrlShiftClick(mob/user, modifiers)
	return

/mob/proc/AltShiftClickOn(atom/A, modifiers)
	A.AltShiftClick(src, modifiers)
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
	if(stat || buckled || !A || !x || !y || !A.x || !A.y) return
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
	setDir(direction)

/atom/movable/screen/click_catcher
	icon_state = "catcher"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER"

/atom/movable/screen/click_catcher/MouseEntered(location, control, params)
	return

/atom/movable/screen/click_catcher/MouseExited(location, control, params)
	return

#define MAX_SAFE_BYOND_ICON_SCALE_TILES (MAX_SAFE_BYOND_ICON_SCALE_PX / world.icon_size)
#define MAX_SAFE_BYOND_ICON_SCALE_PX (33 * 32)			//Not using world.icon_size on purpose.

/atom/movable/screen/click_catcher/proc/UpdateGreed(view_size_x = 15, view_size_y = 15)
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

/atom/movable/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/click_turf = parse_caught_click_modifiers(modifiers, get_turf(usr.client ? usr.client.eye : usr), usr.client)
		if(click_turf)
			modifiers["catcher"] = TRUE
			click_turf.Click(location, control, list2params(modifiers))
	. = 1

/mob/proc/check_click_intercept(params,A)
	// Client level intercept
	if(client?.click_intercept)
		if(call(client.click_intercept, "InterceptClickOn")(src, params, A))
			return TRUE

	// Mob level intercept
	if(click_interceptor)
		if(call(click_interceptor, "InterceptClickOn")(src, params, A))
			return TRUE

	return FALSE

#undef MAX_SAFE_BYOND_ICON_SCALE_TILES
#undef MAX_SAFE_BYOND_ICON_SCALE_PX
