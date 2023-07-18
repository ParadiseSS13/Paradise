#define MAXIMUM_PIXEL_SHIFT 12
#define PASSABLE_SHIFT_THRESHOLD 8

/datum/component/pixel_shift
	var/mob/living/owner
	/// Whether the mob is pixel shifted or not
	var/is_shifted = FALSE
	/// If we are in the shifting setting.
	var/shifting = FALSE
	/// Takes the four cardinal direction defines. Any atoms moving into this atom's tile will be allowed to from the added directions.
	var/passthroughable = NONE

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent) || isAI(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent

/datum/component/pixel_shift/RegisterWithParent()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT_KEYBIND, PROC_REF(on_pixel_shift))
	RegisterSignal(owner, COMSIG_MOB_UNPIXEL_SHIFT, PROC_REF(unpixel_shift))
	RegisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT, PROC_REF(pixel_shift))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(unpixel_shift))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(unpixel_shift))
	RegisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT_PASSABLE, PROC_REF(check_passable))
	RegisterSignal(owner, COMSIG_MOB_PIXEL_SHIFTING, PROC_REF(check_shifting))

/datum/component/pixel_shift/UnregisterFromParent()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT_KEYBIND)
	UnregisterSignal(owner, COMSIG_MOB_UNPIXEL_SHIFT)
	UnregisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED))
	UnregisterSignal(owner, COMSIG_MOB_PIXEL_SHIFT_PASSABLE)
	UnregisterSignal(owner, COMSIG_MOB_PIXEL_SHIFTING)

/datum/component/pixel_shift/proc/check_passable(mob/target, dir)
	if(passthroughable & dir)
		return COMPONENT_LIVING_PASSABLE

/datum/component/pixel_shift/proc/check_shifting()
	if(shifting)
		return COMPONENT_LIVING_PIXEL_SHIFTING

/datum/component/pixel_shift/proc/on_pixel_shift(mob/target, active)
	shifting = active

/datum/component/pixel_shift/proc/unpixel_shift()
	passthroughable = NONE
	if(is_shifted)
		is_shifted = FALSE
		owner.pixel_x = owner.get_standard_pixel_x_offset()
		owner.pixel_y = owner.get_standard_pixel_y_offset()

/datum/component/pixel_shift/proc/pixel_shift(mob/target, direction)
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
