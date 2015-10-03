/*
	Click code cleanup
	~Sayu
*/

// 1 decisecond click delay (above and beyond mob/next_move)
/mob/var/next_click	= 0

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
/mob/proc/ClickOn( var/atom/A, var/params )
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
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

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A)

	if(next_move > world.time) // in the year 2000...
		return

	if(istype(loc,/obj/mecha))
		if(!locate(/turf) in list(A,A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A,src)

	if(restrained())
		changeNext_move(CLICK_CD_HANDCUFFED) //Doing shit in cuffs shall be vey slow
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_hand()

	if(W == A)
		W.attack_self(src)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)
		return

	// operate two STORAGE levels deep here (item in backpack in src; NOT item in box in backpack in src)
	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 1))
		// No adjacency needed
		if(W)
			var/resolved = A.attackby(W,src)
			if(!resolved && A && W)
				W.afterattack(A,src,1,params) // 1 indicates adjacency
		else
			if(ismob(A))
				changeNext_move(CLICK_CD_MELEE)
			UnarmedAttack(A, 1)

		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(A.Adjacent(src)) // see adjacent.dm
			if(W)
				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example, params)
				var/resolved = A.attackby(W,src,params)
				if(!resolved && A && W)
					W.afterattack(A,src,1,params) // 1: clicking something Adjacent
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

/mob/proc/changeNext_move(num)
	next_move = world.time + num

// Default behavior: ignore double clicks, consider them normal clicks instead
/mob/proc/DblClickOn(var/atom/A, var/params)
	return

/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(var/atom/A, var/proximity_flag)
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
/mob/proc/RangedAttack(var/atom/A, var/params)
	if(ishuman(src) && (istype(src:gloves, /obj/item/clothing/gloves/color/yellow/power)) && a_intent == I_HARM)
		PowerGlove(A)
	if(!mutations.len) return
	if((LASER in mutations) && a_intent == I_HARM)
		LaserEyes(A) // moved into a proc below
		return
	else
		if(TK in mutations)
			A.attack_tk(src)
/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(var/atom/A)
	return

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(var/atom/A)
	pointed(A)
	return

// See click_override.dm
/mob/living/MiddleClickOn(var/atom/A)
 if(src.middleClickOverride)
 	middleClickOverride.onClick(A, src)
 else
 	..()

/mob/living/carbon/MiddleClickOn(var/atom/A)
	if(!src.stat && src.mind && src.mind.changeling && src.mind.changeling.chosen_sting && (istype(A, /mob/living/carbon)) && (A != src))
		next_click = world.time + 5
		mind.changeling.chosen_sting.try_to_sting(src, A)
	else
		..()

// In case of use break glass
/*
/atom/proc/MiddleClick(var/mob/M as mob)
	return
*/

/*
	Shift click
	For most mobs, examine.
	This is overridden in ai.dm
*/
/mob/proc/ShiftClickOn(var/atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(var/mob/user)
	if(user.client && user.client.eye == user)
		user.examinate(src)
	return

/*
	Ctrl click
	For most objects, pull
*/
/mob/proc/CtrlClickOn(var/atom/A)
	A.CtrlClick(src)
	return
/atom/proc/CtrlClick(var/mob/user)
	return

/atom/movable/CtrlClick(var/mob/user)
	if(Adjacent(user))
		user.start_pulling(src)

/*
	Alt click
	Unused except for AI
*/
/mob/proc/AltClickOn(var/atom/A)
	A.AltClick(src)
	return

// See click_override.dm
/mob/living/AltClickOn(var/atom/A)
 if(src.middleClickOverride)
 	middleClickOverride.onClick(A, src)
 else
 	..()

/mob/living/carbon/AltClickOn(var/atom/A)
	if(!src.stat && src.mind && src.mind.changeling && src.mind.changeling.chosen_sting && (istype(A, /mob/living/carbon)) && (A != src))
		next_click = world.time + 5
		mind.changeling.chosen_sting.try_to_sting(src, A)
	else
		..()

/atom/proc/AltClick(var/mob/user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		if(user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = T.name
	return

/mob/proc/TurfAdjacent(var/turf/T)
	return T.Adjacent(src)

/*
	Control+Shift/Alt+Shift click
	Unused except for AI
*/
/mob/proc/CtrlShiftClickOn(var/atom/A)
	A.CtrlShiftClick(src)
	return

/atom/proc/CtrlShiftClick(var/mob/user)
	return

/mob/proc/AltShiftClickOn(var/atom/A)
	A.AltShiftClick(src)
	return

/atom/proc/AltShiftClick(var/mob/user)
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
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn( 1 )
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		src << "\red You're out of energy!  You need food!"

/mob/proc/PowerGlove(atom/A)
	return

/mob/living/carbon/human/PowerGlove(atom/A)
	var/obj/item/clothing/gloves/color/yellow/power/G = src:gloves
	var/time = 100
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(A)
	var/obj/structure/cable/cable = locate() in T
	if(!cable || !istype(cable))
		src << "<span class='warning'>There is no cable here to power the gloves.</span>"
		return
	if(world.time < G.next_shock)
		src << "<span class='warning'>[G] aren't ready to shock again!</span>"
		return
	src.visible_message("<span class='warning'>[name] fires an arc of electricity!</span>", \
	"<span class='warning'>You fire an arc of electricity!</span>", \
	"You hear the loud crackle of electricity!")
	var/datum/powernet/PN = cable.get_powernet()
	var/available = 0
	var/obj/item/projectile/beam/lightning/L = new /obj/item/projectile/beam/lightning/(get_turf(src))
	if(PN)
		available = PN.avail
		L.damage = PN.get_electrocute_damage()
		if(available >= 5000000)
			L.damage = 205
		if(L.damage >= 200)
			time = 200
		else if(L.damage >= 100)
			time = 150
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	if(L.damage <= 0)
		qdel(L)
	if(L)
		playsound(get_turf(src), 'sound/effects/eleczap.ogg', 75, 1)
		L.tang = L.adjustAngle(get_angle(U,T))
		L.icon = midicon
		L.icon_state = "[L.tang]"
		L.firer = usr
		L.def_zone = get_organ_target()
		L.original = src
		L.current = U
		L.starting = U
		L.yo = U.y - T.y
		L.xo = U.x - T.x
		spawn( 1 )
			L.process()

	next_move = world.time + 12
	G.next_shock = world.time + time
// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(var/atom/A)

/*	// Snowflake for space vines. //Are you fucking kidding me?
	var/is_buckled = 0
	if(buckled)
		if(istype(buckled))
			if(!buckled.movable)
				is_buckled = 1
		else
			is_buckled = 0*/

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
	usr.dir = direction

/*	if(buckled && buckled.movable)
		buckled.dir = direction
		buckled.handle_rotation()*/
		
/obj/screen/click_catcher
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "passage0"
	layer = 0
	mouse_opacity = 2
	screen_loc = "CENTER-7,CENTER-7"

/obj/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && istype(usr, /mob/living/carbon))
		var/mob/living/carbon/C = usr
		C.swap_hand()
	else
		var/turf/T = screen_loc2turf(modifiers["screen-loc"], get_turf(usr))
		T.Click(location, control, params)
	return 1