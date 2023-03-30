/* Windoor (window door) assembly -Nodrak //I hope you step on a plug
 * Step 1: Create a windoor out of rglass
 * Step 2: Add plasteel to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Crowbar the door to complete
 */


/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'
	name = "windoor assembly"
	icon_state = "l_windoor_assembly01"
	desc = "A small glass and wire assembly for windoors."
	anchored = FALSE
	density = FALSE
	dir = NORTH
	max_integrity = 300
	var/ini_dir
	var/obj/item/airlock_electronics/electronics
	var/created_name

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = FALSE		//Whether or not this creates a secure windoor
	var/state = "01"	//How far the door assembly has progressed

/obj/structure/windoor_assembly/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to rotate it clockwise.</span>"

/obj/structure/windoor_assembly/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		dir = set_dir
	ini_dir = dir
	air_update_turf(1)

/obj/structure/windoor_assembly/Destroy()
	density = FALSE
	QDEL_NULL(electronics)
	air_update_turf(1)
	return ..()

/obj/structure/windoor_assembly/Move()
	var/turf/T = loc
	. = ..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing]_[secure ? "secure_" : ""]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	return 1

/obj/structure/windoor_assembly/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/structure/windoor_assembly/attack_hand(mob/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && user.dna.species.obj_damage)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage)
		return
	. = ..()

/obj/structure/windoor_assembly/attackby(obj/item/W, mob/user, params)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	add_fingerprint(user)
	switch(state)
		if("01")
			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			if(istype(W, /obj/item/stack/sheet/plasteel) && !secure)
				var/obj/item/stack/sheet/plasteel/P = W
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more [P] to do this!</span>")
					return
				to_chat(user, "<span class='notice'>You start to reinforce [src] with [P]...</span>")
				if(do_after(user, 40 * P.toolspeed * gettoolspeedmod(user), target = src))
					if(!src || secure || P.get_amount() < 2)
						return
					playsound(loc, P.usesound, 100, 1)
					P.use(2)
					to_chat(user, "<span class='notice'>You reinforce [src].</span>")
					secure = TRUE
					name = "secure [(src.anchored) ? "anchored" : ""] windoor assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(iscoil(W) && anchored)
				user.visible_message("<span class='notice'>[user] wires [src]...</span>", "<span class='notice'>You start to wire [src]...</span>")
				if(do_after(user, 40 * W.toolspeed * gettoolspeedmod(user), target = src))
					if(!src || !anchored || state != "01")
						return
					var/obj/item/stack/cable_coil/CC = W
					CC.use(1)
					to_chat(user, "<span class='notice'>You wire [src].</span>")
					playsound(loc, CC.usesound, 100, 1)
					state = "02"
					name = "[(src.secure) ? "secure" : ""] wired windoor assembly"
			else
				return ..()

		if("02")
			//Adding airlock electronics for access. Step 6 complete.
			if(istype(W, /obj/item/airlock_electronics))
				if(electronics)
					to_chat(user, "<span class='notice'>There's already [electronics] inside!")
					return
				playsound(loc, W.usesound, 100, 1)
				user.visible_message("<span class='notice'>[user] installs [W] into [src]...</span>", "<span class='notice'>You start to install [W.name] into [src]...</span>")
				if(do_after(user, 40 * W.toolspeed * gettoolspeedmod(user), target = src))
					if(!src || electronics)
						return
					user.drop_item()
					W.forceMove(src)
					to_chat(user, "<span class='notice'>You install [W].</span>")
					electronics = W
					name = "[(src.secure) ? "secure" : ""] near finished windoor assembly"
			else if(istype(W, /obj/item/pen))
				var/t = rename_interactive(user, W)
				if(!isnull(t))
					created_name = t
				return
			else
				return ..()

	//Update to reflect changes(if applicable)
	update_icon()

/obj/structure/windoor_assembly/crowbar_act(mob/user, obj/item/I)	//Crowbar to complete the assembly, Step 7 complete.
	if(state != "02")
		return
	. = TRUE
	if(!electronics)
		to_chat(user, "<span class='warning'>[src] is missing electronics!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	user << browse(null, "window=windoor_access")
	user.visible_message("<span class='notice'>[user] pries [src] into the frame...</span>", "<span class='notice'>You start prying [src] into the frame...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return
	if(loc && electronics)
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				return
		density = TRUE //Shouldn't matter but just incase
		to_chat(user, "<span class='notice'>You finish the [(src.secure) ? "secure" : ""] windoor.</span>")
		var/obj/machinery/door/window/windoor
		if(secure)
			windoor = new /obj/machinery/door/window/brigdoor(src.loc)
			if(facing == "l")
				windoor.icon_state = "leftsecureopen"
				windoor.base_state = "leftsecure"
			else
				windoor.icon_state = "rightsecureopen"
				windoor.base_state = "rightsecure"
		else
			windoor = new /obj/machinery/door/window(loc)
			if(facing == "l")
				windoor.icon_state = "leftopen"
				windoor.base_state = "left"
			else
				windoor.icon_state = "rightopen"
				windoor.base_state = "right"
		windoor.setDir(dir)
		windoor.density = FALSE
		windoor.unres_sides = electronics.unres_access_from

		windoor.req_access = electronics.selected_accesses
		windoor.check_one_access = electronics.one_access
		windoor.electronics = src.electronics
		electronics.forceMove(windoor)
		electronics = null
		if(created_name)
			windoor.name = created_name
		qdel(src)
		windoor.close()

/obj/structure/windoor_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != "02" || electronics)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", "<span class='notice'>You begin removing the circuit board from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || electronics)
		return
	to_chat(user, "<span class='notice'>You remove [electronics].</span>")
	name = "[(src.secure) ? "secure" : ""] wired windoor assembly"
	var/obj/item/airlock_electronics/ae
	ae = electronics
	electronics = null
	ae.forceMove(loc)

/obj/structure/windoor_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != "02")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begin cutting the wires from [src]...</span>", "<span class='notice'>You begin cutting the wires from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != "02")
		return
	to_chat(user, "<span class='notice'>You cut [src] wires.</span>")
	new/obj/item/stack/cable_coil(get_turf(user), 1)
	state = "01"
	name = "[(src.secure) ? "secure" : ""] anchored windoor assembly"
	update_icon()

/obj/structure/windoor_assembly/wrench_act(mob/user, obj/item/I)
	if(state != "01")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!anchored)	//Wrenching an unsecure assembly anchors it in place. Step 4 complete
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		user.visible_message("<span class='notice'>[user] begin tightening the bolts on [src]...</span>", "<span class='notice'>You begin tightening the bolts on [src]...</span>")

		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || anchored || state != "01")
			return
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		to_chat(user, "<span class='notice'>You tighten bolts on [src].</span>")
		anchored = TRUE
		name = "[(src.secure) ? "secure" : ""]  anchored windoor assembly"
	else	//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
		user.visible_message("<span class='notice'>[user] begin loosening the bolts on [src]...</span>", "<span class='notice'>You begin loosening the bolts on [src]...</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !anchored || state != "01")
			return
		to_chat(user, "<span class='notice'>You loosen bolts on [src].</span>")
		anchored = FALSE
		name = "[(src.secure) ? "secure" : ""] windoor assembly"
	update_icon()

/obj/structure/windoor_assembly/welder_act(mob/user, obj/item/I)
	if(state != "01")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume) && state == "01")
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/item/stack/sheet/rglass/RG = new (get_turf(src), 5)
		RG.add_fingerprint(user)
		if(secure)
			var/obj/item/stack/rods/R = new (get_turf(src), 4)
			R.add_fingerprint(user)
		qdel(src)


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE
	var/target_dir = turn(dir, 270)

	if(!valid_window_location(loc, target_dir))
		to_chat(usr, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE

	setDir(target_dir)

	ini_dir = dir
	update_icon()
	return TRUE

/obj/structure/windoor_assembly/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		revrotate()

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(facing == "l")
		to_chat(usr, "The windoor will now slide to the right.")
		facing = "r"
	else
		facing = "l"
		to_chat(usr, "The windoor will now slide to the left.")

	update_icon()
	return
