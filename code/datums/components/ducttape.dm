/datum/component/ducttape
	var/x_offset = 0
	var/y_offset = 0
	var/icon/tape_overlay = null

/datum/component/ducttape/Initialize(obj/item/I, mob/user, x, y)
	if(!istype(I)) //Something went wrong
		return
	x_offset = x
	y_offset = y
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/add_tape_text)
	RegisterSignal(parent, COMSIG_OBJ_UPDATE_ICON, .proc/add_tape_overlay)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/afterattack)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/pick_up)
	I.update_icon() //Do this first so the action button properly shows the icon
	var/datum/action/item_action/remove_tape/RT = new(I)
	if(I.loc == user)
		RT.Grant(user)

/datum/component/proc/add_tape_text(datum/source, mob/user)
	to_chat(user, "<span class='notice'>There's some sticky tape attached to [source].</span>")

/datum/component/ducttape/proc/add_tape_overlay(obj/item/O)
	tape_overlay = new('icons/obj/bureaucracy.dmi', "tape")
	tape_overlay.Shift(EAST, x_offset - 2)
	tape_overlay.Shift(NORTH, y_offset - 2)
	O.overlays += tape_overlay

/datum/component/ducttape/proc/remove_tape(obj/item/I, mob/user)
	to_chat(user, "<span class='notice'>You tear the tape off [I]!</span>")
	playsound(I, 'sound/items/poster_ripped.ogg', 50, 1)
	new /obj/item/trash/tapetrash(user.loc)
	I.update_icon()
	I.anchored = initial(I.anchored)
	for(var/datum/action/item_action/remove_tape/RT in I.actions)
		RT.Remove(user)
		RT.Destroy()
	I.overlays.Cut(tape_overlay)
	user.transfer_fingerprints_to(I)
	Destroy()

/datum/component/ducttape/proc/afterattack(obj/item/I, atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!isturf(target))
		return
	if(!user.unEquip(I))
		return
	var/turf/source_turf = get_turf(I)
	var/turf/target_turf = target
	var/list/clickparams = params2list(params)
	var/x_offset = text2num(clickparams["icon-x"]) - 16
	var/y_offset = text2num(clickparams["icon-y"]) - 16
	if(target_turf != get_turf(I)) //Trying to stick it on a wall, don't move it to the actual wall or you can move the item through it. Instead set the pixels as appropriate
		var/target_direction = get_dir(source_turf, target_turf)//The direction we clicked
		if(target_direction & EAST)
			x_offset += 32
		else if(target_direction & WEST)
			x_offset -= 32
		if(target_direction & NORTH)
			y_offset += 32
		else if(target_direction & SOUTH)
			y_offset -= 32
	to_chat(user, "<span class='notice'>You stick [I] to [target_turf].</span>")
	I.pixel_x = x_offset
	I.pixel_y = y_offset

/datum/component/ducttape/proc/pick_up(obj/item/I, mob/user)
	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
