/// For use when arranging items on a tile with a staggered visual
/// appearance. Initially for use with [/obj/effect/spawner/random]s.
/datum/spawner_pixel_placer
	/// The pixel x/y divider offsets between items.
	var/pixel_offsets = 2
	/// Maximum offset distance from the center of a tile.
	var/max_pixel_offset = 16
	/// For tracking if we're staggering from the top left or bottom right.
	var/static/list/offsets = list(1, -1)
	var/offset_multiplier = 0
	var/pixel_divider
	/// The items we've added so far. Used to perform one
	/// last visual arrangement in z-order once complete.
	var/list/added_items

/datum/spawner_pixel_placer/New(pixel_offsets_, max_pixel_offset_)
	. = ..()
	pixel_offsets = pixel_offsets_
	max_pixel_offset = max_pixel_offset_
	pixel_divider = FLOOR(max_pixel_offset * 2 / pixel_offsets, 1)

/datum/spawner_pixel_placer/proc/place(atom/item, count)
	if(count == 1)
		added_items = list(item)
		return

	var/offset = offsets[(count % 2) + 1]
	if(offset == 1)
		added_items.Add(item)
		offset_multiplier++
	else
		added_items.Insert(1, item)
	var/column = FLOOR(count / pixel_divider, 1)
	var/loot_pixel_x = offset * (pixel_offsets * (offset_multiplier % pixel_divider) + (column * pixel_offsets))
	var/loot_pixel_y = offset * (pixel_offsets * (offset_multiplier % pixel_divider))
	item.pixel_x = loot_pixel_x
	item.pixel_y = -loot_pixel_y

/datum/spawner_pixel_placer/Destroy(force, ...)
	. = ..()

	// Once we've placed all our items, arrange them visually from top to bottom.
	if(!isnull(added_items))
		for(var/i in 1 to length(added_items))
			var/atom/A = added_items[i]
			A.layer += 0.001 * i

		added_items.Cut()
