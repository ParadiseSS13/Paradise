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
	I.update_icon() //Do this first so the action button preoperly shows the icon
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

/datum/component/ducttape/proc/afterattack(datum/source, atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!isturf(target))
		return
	var/list/clickparams = params2list(params)
	var/x_offset = text2num(clickparams["icon-x"]) - 16
	var/y_offset = text2num(clickparams["icon-y"]) - 16
	var/turf/T = target
	var/obj/item/I = source
	to_chat(user, "<span class='notice'>You stick [I] to [T].</span>")
	user.unEquip(I)
	I.forceMove(T)
	I.pixel_x = x_offset
	I.pixel_y = y_offset
