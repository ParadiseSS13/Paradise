/// An element for making visual modifications to items when worn externally by
/// a carbon mob. This could range to anything from changing its pixel offsets
/// to its color or size.
/datum/element/clothing_adjustment
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

/datum/element/clothing_adjustment/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_item_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_item_dropped))

/datum/element/clothing_adjustment/proc/on_item_equipped(datum/source, mob/target)
	SIGNAL_HANDLER // COMSIG_ITEM_DROPPED
	return

/datum/element/clothing_adjustment/proc/on_item_dropped(datum/source, mob/target)
	SIGNAL_HANDLER // COMSIG_ITEM_DROPPED
	return

/datum/element/clothing_adjustment/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/element/clothing_adjustment/monitor_headgear
	var/pixel_x
	var/pixel_y

/datum/element/clothing_adjustment/monitor_headgear/Attach(datum/target, pixel_x_ = 0, pixel_y_ = 0)
	if(pixel_x_ == 0 && pixel_y_ == 0)
		return ELEMENT_INCOMPATIBLE

	. = ..()

	pixel_x = pixel_x_
	pixel_y = pixel_y_

/datum/element/clothing_adjustment/monitor_headgear/on_item_equipped(datum/source, mob/target)
	RegisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(on_carbon_apply_overlay), override = TRUE)

/datum/element/clothing_adjustment/monitor_headgear/on_item_dropped(datum/source, mob/target)
	UnregisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY)

/datum/element/clothing_adjustment/monitor_headgear/proc/on_carbon_apply_overlay(mob/living/carbon/human/source, cache_index)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != HEAD_LAYER || !istype(source))
		return

	var/obj/item/organ/external/head/head = source.get_organ(BODY_ZONE_HEAD)

	if(!istype(head))
		return

	var/datum/robolimb/robohead = GLOB.all_robolimbs[head.model]
	if(!robohead?.is_monitor)
		return

	var/mutable_appearance/overlay = source.overlays_standing[cache_index]
	overlay.pixel_x = pixel_x
	overlay.pixel_y = pixel_y

// Clothing Adjustments Handling Skkulakin

/datum/element/clothing_adjustment/skulk_headgear
	var/alist/directions

/datum/element/clothing_adjustment/skulk_headgear/Attach(datum/target, alist/_directions)
	if(!istype(_directions))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	directions = _directions

/datum/element/clothing_adjustment/skulk_headgear/on_item_equipped(datum/source, mob/target)
	RegisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(on_carbon_apply_overlay), override = TRUE)

/datum/element/clothing_adjustment/skulk_headgear/on_item_dropped(datum/source, mob/target)
	UnregisterSignal(target, list(COMSIG_CARBON_APPLY_OVERLAY))

	var/mob/living/carbon/human/human = target
	if(!istype(human))
		return

	human.update_inv_head()

/datum/element/clothing_adjustment/skulk_headgear/proc/on_carbon_apply_overlay(mob/living/carbon/human/source, cache_index)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != HEAD_LAYER || !istype(source))
		return

	var/datum/species = source.dna?.species
	if(!istype(species))
		return

	if(!istype(species, /datum/species/skulk))
		return

	var/icon/I = new()
	var/image/overlay = source.overlays_standing[cache_index]
	for(var/dir in GLOB.cardinal)
		var/icon/dir_image = icon(overlay.icon, overlay.icon_state)
		if(overlay.color)
			dir_image.Blend(overlay.color, ICON_MULTIPLY)
		dir_image.Shift(NORTH, directions[dir][1])
		dir_image.Shift(WEST, directions[dir][2])
		I.Insert(dir_image, dir = dir)

	source.overlays_standing[cache_index] = I

/obj/item/clothing/head/Initialize(mapload)
	. = ..()
	var/skulk_adjustment = string_assoc_list(alist(SOUTH = list(-1, 0), NORTH = list(-1, 0), EAST = list(0, -2), WEST = list(0, 2)))
	AddElement(/datum/element/clothing_adjustment/skulk_headgear, skulk_adjustment)

/datum/element/clothing_adjustment/skulk_mask
	var/alist/directions

/datum/element/clothing_adjustment/skulk_mask/Attach(datum/target, alist/_directions)
	if(!istype(_directions))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	directions = _directions

/datum/element/clothing_adjustment/skulk_mask/on_item_equipped(datum/source, mob/target)
	RegisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(on_carbon_apply_overlay), override = TRUE)

/datum/element/clothing_adjustment/skulk_mask/on_item_dropped(datum/source, mob/target)
	UnregisterSignal(target, list(COMSIG_CARBON_APPLY_OVERLAY))

	var/mob/living/carbon/human/human = target
	if(!istype(human))
		return

	human.update_inv_wear_mask()

/datum/element/clothing_adjustment/skulk_mask/proc/on_carbon_apply_overlay(mob/living/carbon/human/source, cache_index)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != FACEMASK_LAYER || !istype(source))
		return

	var/datum/species = source.dna?.species
	if(!istype(species))
		return

	if(!istype(species, /datum/species/skulk))
		return

	var/icon/I = new()
	var/image/overlay = source.overlays_standing[cache_index]
	for(var/dir in GLOB.cardinal)
		var/icon/dir_image = icon(overlay.icon, overlay.icon_state)
		if(overlay.color)
			dir_image.Blend(overlay.color, ICON_MULTIPLY)
		dir_image.Shift(NORTH, directions[dir][1])
		dir_image.Shift(WEST, directions[dir][2])
		I.Insert(dir_image, dir = dir)

	source.overlays_standing[cache_index] = I

/obj/item/clothing/mask/Initialize(mapload)
	. = ..()
	var/skulk_adjustment = string_assoc_list(alist(SOUTH = list(-1, 0), NORTH = list(-1, 0), EAST = list(0, -2), WEST = list(0, 2)))
	AddElement(/datum/element/clothing_adjustment/skulk_mask, skulk_adjustment)

/datum/element/clothing_adjustment/skulk_glasses
	var/alist/directions

/datum/element/clothing_adjustment/skulk_glasses/Attach(datum/target, alist/_directions)
	if(!istype(_directions))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	directions = _directions

/datum/element/clothing_adjustment/skulk_glasses/on_item_equipped(datum/source, mob/target)
	RegisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(on_carbon_apply_overlay), override = TRUE)

/datum/element/clothing_adjustment/skulk_glasses/on_item_dropped(datum/source, mob/target)
	UnregisterSignal(target, list(COMSIG_CARBON_APPLY_OVERLAY))

	var/mob/living/carbon/human/human = target
	if(!istype(human))
		return

	human.update_inv_glasses()

/datum/element/clothing_adjustment/skulk_glasses/proc/on_carbon_apply_overlay(mob/living/carbon/human/source, cache_index)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != GLASSES_OVER_LAYER || !istype(source))
		return

	var/datum/species = source.dna?.species
	if(!istype(species))
		return

	if(!istype(species, /datum/species/skulk))
		return

	var/icon/I = new()
	var/image/overlay = source.overlays_standing[cache_index]
	for(var/dir in GLOB.cardinal)
		var/icon/dir_image = icon(overlay.icon, overlay.icon_state)
		if(overlay.color)
			dir_image.Blend(overlay.color, ICON_MULTIPLY)
		dir_image.Shift(NORTH, directions[dir][1])
		dir_image.Shift(WEST, directions[dir][2])
		I.Insert(dir_image, dir = dir)

	source.overlays_standing[cache_index] = I
