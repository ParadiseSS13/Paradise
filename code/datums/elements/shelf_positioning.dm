/// Shelf positioning allows for custom positioning on shelves for individual items.
/datum/element/shelf_positioning
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/x_offset
	var/y_offset
	var/scale
	var/rotation

// Allow for custom offsets, scales, and rotations for specific items
// when added to a shelf.
/datum/element/shelf_positioning/Attach(datum/target, x_offset_ = 0, y_offset_ = 0, scale_ = 0, rotation_ = 0)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	x_offset = x_offset_
	y_offset = y_offset_
	scale = scale_
	rotation = rotation_

	RegisterSignal(target, COMSIG_SHELF_ITEM_ADDED, PROC_REF(on_shelf_item_added))

/datum/element/shelf_positioning/proc/on_shelf_item_added(obj/item/target, default_scale)
	SIGNAL_HANDLER // COMSIG_SHELF_ITEM_ADDED
	target.pixel_x += x_offset
	target.pixel_y += y_offset
	if(rotation)
		target.transform = turn(target.transform, rotation)
	if((!default_scale) && scale)
		target.transform *= scale
