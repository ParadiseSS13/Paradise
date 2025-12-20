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

/datum/element/clothing_adjustment/monitor_headgear/proc/on_carbon_apply_overlay(mob/living/carbon/source, cache_index, mutable_appearance/overlay)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != HEAD_LAYER || !istype(source))
		return

	var/obj/item/organ/external/head/head = source.get_organ(BODY_ZONE_HEAD)

	if(!istype(head))
		return

	var/datum/robolimb/robohead = GLOB.all_robolimbs[head.model]
	if(!robohead?.is_monitor)
		return

	overlay.pixel_x = pixel_x
	overlay.pixel_y = pixel_y

// Clothing Adjustments Handling Skkulakin

/datum/element/clothing_adjustment/skulk_headgear
	var/alist/directions

/datum/element/clothing_adjustment/skulk_headgear/Attach(datum/target, alist/directions)
	if(!istype(directions))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	directions = directions

/datum/element/clothing_adjustment/skulk_headgear/proc/update_overlay(mob/living/carbon/human/target, face_dir = null)
	if(!face_dir)
		face_dir = target.dir

	var/mutable_appearance/overlay = target.overlays_standing[HEAD_LAYER]
	overlay.pixel_x = directions[face_dir][0]
	overlay.pixel_y = directions[face_dir][1]

/datum/element/clothing_adjustment/skulk_headgear/on_item_equipped(datum/source, mob/target)
	RegisterSignal(target, COMSIG_CARBON_APPLY_OVERLAY, PROC_REF(on_carbon_apply_overlay), override = TRUE)
	RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_atom_dir_change), override = TRUE)

/datum/element/clothing_adjustment/skulk_headgear/on_item_dropped(datum/source, mob/target)
	UnregisterSignal(target, list(COMSIG_CARBON_APPLY_OVERLAY, COMSIG_ATOM_DIR_CHANGE))

/datum/element/clothing_adjustment/skulk_headgear/proc/on_carbon_apply_overlay(mob/living/carbon/human/source, cache_index, mutable_appearance/overlay)
	SIGNAL_HANDLER // COMSIG_CARBON_APPLY_OVERLAY
	if(cache_index != HEAD_LAYER || !istype(source))
		return

	var/datum/species = source.dna?.species
	if(!istype(species))
		return

	if(!istype(species, /datum/species/skulk))
		return

	update_overlay(source)

/datum/element/clothing_adjustment/skulk_headgear/proc/on_atom_dir_change(mob/living/carbon/human/source, old_dir, new_dir)
	SIGNAL_HANDLER // COMSIG_ATOM_DIR_CHANGE
	if(old_dir == new_dir)
		return

	update_overlay(source, new_dir)
