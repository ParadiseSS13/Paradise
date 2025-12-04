/obj/item/organ/internal/cyberimp/chest/skinmonger
	name = "\improper Skinmonger"
	desc = "A chest-mounted implant that continuously produces and replaces synthetic skin to cover an IPC's chassis. \
			Will not apply skin to a monitor-shaped head."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	implant_color = "#FFDDAA"
	slot = "chest_synthetic_skin"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=6;biotech=7;syndicate=4"
	emp_proof = FALSE
	augment_icon = "nutripump"
	var/regeneration_active = TRUE  // Whether regeneration is allowed. This is disabled temporarily by an EMP
	var/regen_cooldown = 30 SECONDS  // How long to wait after finding a target body part to replace skin on
	var/regenerating = FALSE  // Whether we're currently regenerating
	var/configured_identity = "Unknown"  // Normally synthetic skin doesn't have memory of the identity we're disguised as. This implant does, though
	var/initial_surge_used = FALSE  // Flag for tracking if we've used up the implant's initial deployment of skin

/obj/item/organ/internal/cyberimp/chest/skinmonger/insert(mob/living/carbon/M, special = 0)
	. = ..()

	if(ismachineperson(M))
		// Ask for desired identity
		var/new_identity = input(M, "The Skinmonger generously offers to turn you into someone else.", "Skinmonger Identity", "Unknown") as text|null
		if(new_identity)
			configured_identity = new_identity

	if(!initial_surge_used)
		apply_full_synthetic_skin(M)
		to_chat(M, "<span class='warning'>In an instant, a surge of skin wraps around you and binds itself to your chassis!</span>")
		playsound(M, 'sound/surgery/organ2.ogg', 70, 1, frequency = 0.8)
		initial_surge_used = TRUE

/obj/item/organ/internal/cyberimp/chest/skinmonger/remove(mob/living/carbon/M, special = 0)
	. = ..()
	regenerating = FALSE
	remove_all_synthetic_skin(M)
	to_chat(M, "<span class='warning'>You feel your synthetic skin melt away.</span>")

// Called when synthetic skin is removed from any part - starts regeneration cycle
/obj/item/organ/internal/cyberimp/chest/skinmonger/proc/start_regeneration()
	if(!regeneration_active || regenerating)
		return

	regenerating = TRUE
	// Wait before we trigger the first regen.
	addtimer(CALLBACK(src, .proc/regenerate_next_part), regen_cooldown)

/obj/item/organ/internal/cyberimp/chest/skinmonger/proc/regenerate_next_part()
	if(!owner || !regeneration_active || !regenerating)
		return

	var/mob/living/carbon/human/H = owner
	var/list/unskinned_parts = list()

	// Find all robotic parts without synthetic skin.
	for(var/obj/item/organ/external/E in H.bodyparts)
		if(!E.is_robotic() || E.has_synthetic_skin)
			continue

		// Skip monitor heads
		if(E.limb_name == "head" && E.model)
			var/datum/robolimb/R = GLOB.all_robolimbs[E.model]
			if(R && R.is_monitor)
				continue

		unskinned_parts += E

	// If no parts need skin, kill the regen cycle
	if(!length(unskinned_parts))
		regenerating = FALSE
		return

	// Pick a random part and apply skin
	var/obj/item/organ/external/chosen_part = pick(unskinned_parts)
	chosen_part.has_synthetic_skin = TRUE
	// Set identity for head regeneration
	if(chosen_part.limb_name == "head")
		var/identity_to_use = configured_identity
		chosen_part.synthetic_skin_identity = identity_to_use
		if(ishuman(H))
			H.real_name = identity_to_use
	// Refresh sprite
	chosen_part.force_icon = null
	chosen_part.mob_icon = null
	chosen_part.compile_icon()
	H.update_body(rebuild_base = TRUE)

	to_chat(H, "<span class='notice'>You feel a wave of synthetic skin gush forth from your chassis and bind to your [chosen_part.name].</span>")

	// Schedule next regeneration if more parts need skin. Otherwise, we're done
	if(length(unskinned_parts) > 1)
		addtimer(CALLBACK(src, .proc/regenerate_next_part), regen_cooldown)
	else
		regenerating = FALSE

// One-time application of skin across the entire chassis when the implant is inserted.
/obj/item/organ/internal/cyberimp/chest/skinmonger/proc/apply_full_synthetic_skin(mob/living/carbon/human/target)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	var/head_skinned = FALSE
	for(var/obj/item/organ/external/E in H.bodyparts)
		if(!E.is_robotic() || E.has_synthetic_skin)
			continue

		// Skip monitor heads
		if(E.limb_name == "head" && E.model)
			var/datum/robolimb/R = GLOB.all_robolimbs[E.model]
			if(R && R.is_monitor)
				continue

		E.has_synthetic_skin = TRUE
		// Set configured identity for head
		if(E.limb_name == "head")
			E.synthetic_skin_identity = configured_identity
			head_skinned = TRUE
		// Clear force_icon so the masquerade logic works
		E.force_icon = null
		// Force icon regeneration
		E.mob_icon = null
		E.compile_icon()

	// Apply facial identity if head was skinned
	if(head_skinned)
		H.real_name = configured_identity

	H.update_body(rebuild_base = TRUE)

/obj/item/organ/internal/cyberimp/chest/skinmonger/proc/remove_all_synthetic_skin(mob/living/carbon/human/target)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	for(var/obj/item/organ/external/E in H.bodyparts)
		if(E.is_robotic() && E.has_synthetic_skin)
			E.remove_synthetic_skin(silent = TRUE) // silent because it spams the user otherwise

	to_chat(H, "<span class='warning'>All synthetic skin across your body dissolves away!</span>")
	H.update_body(rebuild_base = TRUE)

// EMP wipes all synthetic skin and puts the implant on cooldown
/obj/item/organ/internal/cyberimp/chest/skinmonger/emp_act(severity)
	. = ..()
	if(!.)
		return

	regenerating = FALSE
	regeneration_active = FALSE
	remove_all_synthetic_skin(owner)

	addtimer(CALLBACK(src, .proc/restart_regeneration), regen_cooldown)

/obj/item/organ/internal/cyberimp/chest/skinmonger/proc/restart_regeneration()
	if(owner)
		regeneration_active = TRUE
		start_regeneration()
