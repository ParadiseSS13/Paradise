// kinda like duct tape but not shit (just kidding, its shit but in a different way)
/datum/component/sticky
	/// The atom we are stickied to
	var/atom/attached_to
	/// Our priority overlay put on top of attached_to
	var/icon/overlay
	/// Do we drop on attached_to's destroy? If not, we qdel
	var/drop_on_attached_destroy = FALSE

/datum/component/sticky/Initialize(_drop_on_attached_destroy = FALSE)
	if(!isitem(parent))
		stack_trace("/datum/component/sticky's parent is not an item, its [parent.type]")
		return COMPONENT_INCOMPATIBLE

	drop_on_attached_destroy = _drop_on_attached_destroy
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(stick_to_it))

/datum/component/sticky/proc/stick_to_it(obj/item/I, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if(!in_range(I, target))
		return
	if(isstorage(target))
		var/obj/item/storage/S = target
		if(S.can_be_inserted(parent))
			return
	if(target.GetComponent(/datum/component/sticky))
		return
	if(!user.canUnEquip(I))
		return

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, unEquip), I)

	var/list/click_params = params2list(params)
	//Center the icon where the user clicked.
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return

	attached_to = target
	move_to_the_thing(parent)
	if(user)
		to_chat(user, "<span class='notice'>You attach [parent] to [attached_to].</span>")

	overlay = icon(I.icon, I.icon_state)
	//Clamp it so that the icon never moves more than 16 pixels in either direction
	overlay.Shift(EAST, clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2))
	overlay.Shift(NORTH, clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2))

	attached_to.add_overlay(overlay, priority = TRUE)
	I.invisibility = INVISIBILITY_ABSTRACT

	RegisterSignal(attached_to, COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY, PROC_REF(pick_up))
	RegisterSignal(attached_to, COMSIG_PARENT_EXAMINE, PROC_REF(add_sticky_text))
	RegisterSignal(attached_to, COMSIG_PARENT_QDELETING, PROC_REF(on_attached_destroy))
	if(ismovable(attached_to))
		RegisterSignal(attached_to, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		START_PROCESSING(SSobj, src)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/sticky/proc/pick_up(atom/A, mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(!attached_to)
		return
	if(user.a_intent != INTENT_GRAB)
		return
	if(user.get_active_hand())
		return
	attached_to.cut_overlay(overlay, priority = TRUE)

	var/obj/item/I = parent
	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
	move_to_the_thing(parent)
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), I)
	if(user)
		to_chat(user, "<span class='notice'>You take [parent] off of [attached_to].</span>")


	I.invisibility = initial(I.invisibility)
	UnregisterSignal(attached_to, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY, COMSIG_PARENT_EXAMINE))
	STOP_PROCESSING(SSobj, src)
	attached_to = null
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/sticky/proc/add_sticky_text(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!in_range(user, attached_to))
		return
	examine_list += "<span class='notice'>There is [parent] attached to [source], grab [attached_to.p_them()] to remove it.</span>"

/datum/component/sticky/proc/on_move(datum/source, oldloc, move_dir)
	SIGNAL_HANDLER
	if(!attached_to)
		stack_trace("/datum/component/sticky was called on_move, but without an attached atom")
		return
	move_to_the_thing(parent)

/datum/component/sticky/process() // because sometimes the item can move inside something, like a crate
	if(!attached_to)
		return PROCESS_KILL
	move_to_the_thing(parent)

/datum/component/sticky/proc/on_attached_destroy(datum/source)
	SIGNAL_HANDLER
	if(!drop_on_attached_destroy)
		qdel(parent)
		return

	var/turf/T = get_turf(source)
	if(!T)
		T = get_turf(parent)
	move_to_the_thing(parent, T)

/datum/component/sticky/proc/move_to_the_thing(obj/item/I, turf/target)
	if(!istype(I))
		return // only items should be able to have the sticky component
	if(!target)
		target = get_turf(attached_to)
	INVOKE_ASYNC(I, TYPE_PROC_REF(/atom/movable, forceMove), target)
