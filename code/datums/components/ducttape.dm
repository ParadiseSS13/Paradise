/datum/component/ducttape
	var/x_offset = 0
	var/y_offset = 0
	var/icon/tape_overlay = null
	var/hide_tape = FALSE

/datum/component/ducttape/Initialize(obj/item/I, mob/user, x, y, hide_tape)
	if(!istype(I)) //Something went wrong
		return
	if(!hide_tape) //if TRUE this hides the tape overlay and added examine text
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_tape_overlay))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(add_tape_text))
	x_offset = x
	y_offset = y
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(afterattack))
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(pick_up))
	I.update_icon() //Do this first so the action button properly shows the icon
	if(!hide_tape) //the tape can no longer be removed if TRUE
		var/datum/action/item_action/remove_tape/RT = new(I)
		if(I.loc == user)
			RT.Grant(user)
	I.add_tape()

/datum/component/proc/add_tape_text(datum/source, mob/user, list/examine_list)
	examine_list += "<span class='notice'>There's some sticky tape attached to [source].</span>"

/datum/component/ducttape/proc/add_tape_overlay(obj/item/O)
	tape_overlay = new('icons/obj/bureaucracy.dmi', "tape")
	tape_overlay.Shift(EAST, x_offset - 2)
	tape_overlay.Shift(NORTH, y_offset - 2)
	O.add_overlay(tape_overlay)

/datum/component/ducttape/proc/remove_tape(obj/item/I, mob/user)
	to_chat(user, "<span class='notice'>You tear the tape off [I]!</span>")
	playsound(I, 'sound/items/poster_ripped.ogg', 50, 1)
	new /obj/item/trash/tapetrash(user.loc)
	I.update_icon()
	I.anchored = initial(I.anchored)
	for(var/datum/action/item_action/remove_tape/RT in I.actions)
		RT.Remove(user)
		qdel(RT)
	I.cut_overlay(tape_overlay)
	user.transfer_fingerprints_to(I)
	I.remove_tape()
	qdel(src)

/datum/component/ducttape/proc/afterattack(obj/item/I, atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!isturf(target))
		return
	var/turf/source_turf = get_turf(I)
	var/turf/target_turf = target
	var/x_offset
	var/y_offset
	if(target_turf != get_turf(I)) //Trying to stick it on a wall, don't move it to the actual wall or you can move the item through it. Instead set the pixels as appropriate
		var/target_direction = get_dir(source_turf, target_turf)//The direction we clicked
		// Snowflake diagonal handling
		if(target_direction in GLOB.diagonals)
			to_chat(user, "<span class='warning'>You can't reach [target_turf].</span>")
			return
		if(target_direction & EAST)
			x_offset = 16
			y_offset = rand(-12, 12)
		else if(target_direction & WEST)
			x_offset = -16
			y_offset = rand(-12, 12)
		else if(target_direction & NORTH)
			x_offset = rand(-12, 12)
			y_offset = 16
		else if(target_direction & SOUTH)
			x_offset = rand(-12, 12)
			y_offset = -16
	if(!user.unEquip(I))
		return
	to_chat(user, "<span class='notice'>You stick [I] to [target_turf].</span>")
	I.pixel_x = x_offset
	I.pixel_y = y_offset

/datum/component/ducttape/proc/pick_up(obj/item/I, mob/user)
	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
