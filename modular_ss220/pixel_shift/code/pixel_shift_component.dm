#define MAXIMUM_PIXEL_SHIFT 12
#define PASSABLE_SHIFT_THRESHOLD 8

/datum/component/pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = TRUE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent) || isAI(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(unpixel_shift))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_LIVING_PROCESS_SPACEMOVE, PROC_REF(pre_move_check))
	RegisterSignal(parent, COMSIG_LIVING_CAN_PASS, PROC_REF(check_passable))

/datum/component/pixel_shift/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_DOWN)
	UnregisterSignal(parent, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED))
	UnregisterSignal(parent, COMSIG_LIVING_PROCESS_SPACEMOVE)
	UnregisterSignal(parent, COMSIG_LIVING_CAN_PASS)

/datum/component/pixel_shift/proc/pre_move_check(mob/source, movement_dir)
	SIGNAL_HANDLER
	if(shifting)
		pixel_shift(source, movement_dir)
		return COMPONENT_BLOCK_SPACEMOVE

/datum/component/pixel_shift/proc/check_passable(mob/source, atom/movable/mover, target, height)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/owner = parent
	if(!istype(mover, /obj/item/projectile) && !mover.throwing && passthroughable & get_dir(owner, mover))
		return COMPONENT_LIVING_PASSABLE

/datum/component/pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = TRUE
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/datum/component/pixel_shift/proc/unpixel_shift()
	SIGNAL_HANDLER
	passthroughable = NONE
	if(is_shifted)
		var/mob/living/owner = parent
		owner.pixel_x = owner.get_standard_pixel_x_offset()
		owner.pixel_y = owner.get_standard_pixel_y_offset()
	qdel(src)

/datum/component/pixel_shift/proc/pixel_shift(mob/target, direction)
	var/mob/living/owner = parent
	if(HAS_TRAIT(owner, TRAIT_RESTRAINED) || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || length(owner.grabbed_by) || owner.stat != CONSCIOUS)
		return
	passthroughable = NONE
	switch(direction)
		if(NORTH)
			if(owner.pixel_y < MAXIMUM_PIXEL_SHIFT + initial(owner.pixel_y))
				owner.pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(owner.pixel_x < MAXIMUM_PIXEL_SHIFT + initial(owner.pixel_x))
				owner.pixel_x++
				is_shifted = TRUE
		if(SOUTH)
			if(owner.pixel_y > -MAXIMUM_PIXEL_SHIFT + initial(owner.pixel_y))
				owner.pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(owner.pixel_x > -MAXIMUM_PIXEL_SHIFT + initial(owner.pixel_x))
				owner.pixel_x--
				is_shifted = TRUE

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	if(owner.pixel_y - initial(owner.pixel_y) > PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= EAST | SOUTH | WEST
	else if(owner.pixel_y - initial(owner.pixel_y) < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | EAST | WEST
	if(owner.pixel_x - initial(owner.pixel_x) > PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | SOUTH | WEST
	else if(owner.pixel_x - initial(owner.pixel_x) < -PASSABLE_SHIFT_THRESHOLD)
		passthroughable |= NORTH | EAST | SOUTH

#undef MAXIMUM_PIXEL_SHIFT
#undef PASSABLE_SHIFT_THRESHOLD
