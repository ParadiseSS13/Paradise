/**
 * # Hallucination - Backrooms
 *
 * Temporarily sends the target to the backrooms. Their body's movement matches their movement in the backrooms.
 */

/var/global/backrooms_occupied = FALSE

/obj/effect/hallucination/no_delete/backrooms
	// hallucination_icon = '' // TODO
	// hallucination_icon_state = "" // TODO

// This controls the hallucination at a high level - determine when to copy/warp them and when to return them.
/datum/hallucination_manager/backrooms
	var/mob/living/carbon/human/human_owner
	var/mob/living/carbon/human/backrooms_clone
	var/list/obj/item/created_items
	initial_hallucination = /obj/effect/hallucination/no_delete/backrooms

	// TODO: i feel like we have gone too deep
	var/static/list/clothing_var_whitelist = list(
		"name", "desc", "icon", "icon_state", "color", "dyeing_key", "dyeable",
		"item_state", "slot_flags", "w_class", "flags_cover", "body_parts_covered",
		"slowdown", "sprite_sheets", "sprite_sheets_inhand", "icon_override", "belt_icon"
	)

/datum/hallucination_manager/backrooms/on_spawn()
	if(ishuman(owner))
		human_owner = owner
	else
		return

	// One person at a time in the backrooms, no backroom brawls allowed.
	if(backrooms_occupied == FALSE)
		backrooms_occupied = TRUE
	else
		return

	var/obj/spawn_location = pick(GLOB.backroomswarp)

	// Create the beautiful lovely clone
	var/human_type = human_owner.type
	backrooms_clone = new human_type(spawn_location)
	copy_appearance_and_clothes(human_owner, backrooms_clone)

	// Put the mind in the backrooms, but we still need to maintain control over the original.
	human_owner.mind.transfer_to(backrooms_clone)
	backrooms_clone.share_control = human_owner

/datum/hallucination_manager/backrooms/proc/copy_appearance_and_clothes(var/mob/living/carbon/human/original, var/mob/living/carbon/target)
	target.real_name = original.dna.real_name
	original.dna.transfer_identity(target)

	var/list/obj/item/stuff_to_keep = list()

	// Figure out what they're wearing, so they're still wearing it in the backrooms
	// Want them to look as close to their real counterpart as possible, without introducing risk of weird stuff happening with items.
	for(var/obj/item/I in human_owner)
		if(I == human_owner.w_uniform || I == human_owner.shoes || I == human_owner.glasses || I == human_owner.head)
			// Keep dyes and all other metadata associated with items.
			var/obj/cloned_item = new I.type()
			for(var/property in clothing_var_whitelist)
				if(property in I.vars)
					cloned_item.vars[property] = I.vars[property]
			stuff_to_keep += cloned_item

	// They're spawned naked, but just to be safe...
	for(var/obj/item/I in backrooms_clone)
		qdel(I)

	// Now populate clone inventory
	created_items = list()
	for(var/obj/item/I in stuff_to_keep)
		backrooms_clone.equip_to_appropriate_slot(I)
		created_items += I

	// Force the clone facing the same direction as the original for immersion!
	backrooms_clone.dir = human_owner.dir

// Cleanup - runs when time is up
/datum/hallucination_manager/backrooms/on_trigger()
	if(backrooms_clone.mind)
		backrooms_clone.mind.transfer_to(human_owner)

	// Delete all created items, then the clone
	for(var/obj/item/I in created_items)
		qdel(I)
	qdel(backrooms_clone)

	backrooms_occupied = FALSE
	qdel(src) // Cleanup hallucination manager
