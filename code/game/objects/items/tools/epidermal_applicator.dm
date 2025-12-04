/obj/item/epidermal_applicator
	name = "epidermal applicator"
	desc = "A pen-shaped device developed by Zeng-Hu, used to apply synthetic skin to prosthetic limbs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "skin_applicator"
	// lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	// righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	origin_tech = "biotech=5;materials=3;engineering=4"

	/// Current amount of metal stored in the applicator
	var/metal_stored = 0
	/// Maximum metal that can be stored
	var/max_metal_stored = 5
	/// Metal required per application
	var/metal_per_use = 5

	var/applying = FALSE

/obj/item/epidermal_applicator/Initialize(mapload)
	. = ..()
	// Start with empty storage
	metal_stored = 0

/obj/item/epidermal_applicator/examine(mob/user)
	. = ..()

	if(metal_stored >= metal_per_use)
		. += "<span class='notice'>It is loaded and ready to apply an epidermal layer to a body part.</span>"
	else
		. += "<span class='notice'>It needs [metal_per_use - metal_stored] more metal sheets.</span>"

/obj/item/epidermal_applicator/proc/is_insertion_ready(mob/user)
	if(!user)
		return FALSE
	return TRUE

/obj/item/epidermal_applicator/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	return NONE

/obj/item/epidermal_applicator/attackby__legacy__attackchain(obj/item/used, mob/user, params)
	if(istype(used, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = used
		var/space_left = max_metal_stored - metal_stored
		if(space_left <= 0)
			to_chat(user, "<span class='warning'>[src] is already full!</span>")
			return

		var/to_load = min(space_left, M.amount)
		M.use(to_load)
		metal_stored += to_load

		to_chat(user, "<span class='notice'>You load [to_load] sheet[to_load > 1 ? "s" : ""] of metal into [src].</span>")
		return

	return ..()

/obj/item/epidermal_applicator/attack_self__legacy__attackchain(mob/user)
	// Allow easier self-application
	var/zone = user.zone_selected
	if(!zone)
		to_chat(user, "<span class='warning'>You need to select a body part first!</span>")
		return

	attack__legacy__attackchain(user, user, zone)

/obj/item/epidermal_applicator/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	if(!ishuman(M))
		return

	// Ensure we have a valid def_zone
	if(!def_zone)
		def_zone = user.zone_selected
	if(!def_zone)
		to_chat(user, "<span class='warning'>You need to select a body part first!</span>")
		return

	var/mob/living/carbon/human/target = M
	var/obj/item/organ/external/affected = target.get_organ(def_zone)

	if(!affected)
		to_chat(user, "<span class='warning'>[target] doesn't have a [parse_zone(def_zone)]!</span>")
		return

	// Show these identically so it can't be used to test whether a limb is synthetic or not.
	if(!affected.is_robotic() || affected.has_synthetic_skin)
		to_chat(user, "<span class='warning'>The [affected.name] doesn't need skin.</span>")
		return

	// Do not put skin on a monitor. No.
	if(ismachineperson(target) && def_zone == BODY_ZONE_HEAD && affected.model)
		var/datum/robolimb/R = GLOB.all_robolimbs[affected.model]
		if(R && R.is_monitor)
			to_chat(user, "<span class='warning'>The applicator fails to find purchase on your big cube head. Probably for the best.</span>")
			return

	// Check if we have enough metal
	if(metal_stored < metal_per_use)
		to_chat(user, "<span class='warning'>[src] needs [metal_per_use] metal to function.</span>")
		return

	if(applying)
		to_chat(user, "<span class='warning'>[src] is already in use!</span>")
		return

	// Start application process
	apply_synthetic_skin(target, affected, user, def_zone)

/obj/item/epidermal_applicator/proc/apply_synthetic_skin(mob/living/carbon/human/target, obj/item/organ/external/affected, mob/living/user, def_zone)
	applying = TRUE

	var/chosen_identity = "Unknown" // Default identity

	// Ask for identity choice if applying to head BEFORE the do_after
	if(def_zone == BODY_ZONE_HEAD)
		var/list/identity_choices = list("Unknown")
		var/list/choice_map = list("Unknown" = "Unknown")

		// Add real name option
		if(target.dna?.real_name)
			var/real_name_choice = "[target.dna.real_name]"
			identity_choices += real_name_choice
			choice_map[real_name_choice] = target.dna.real_name

		// Check for offhand ID
		var/obj/item/offhand_item = user.get_inactive_hand()
		var/offhand_id_name = null
		if(istype(offhand_item, /obj/item/card/id))
			var/obj/item/card/id/id_card = offhand_item
			offhand_id_name = id_card.registered_name
		else if(is_pda(offhand_item))
			var/obj/item/pda/pda = offhand_item
			offhand_id_name = pda.owner

		// Add ID name option if found
		if(offhand_id_name && offhand_id_name != "")
			var/id_name_choice = "[offhand_id_name]"
			identity_choices += id_name_choice
			choice_map[id_name_choice] = offhand_id_name

		// Present choice to user
		var/chosen_identity_option = tgui_input_list(user, "Choose facial identity:", "Identity Selection", identity_choices)
		if(!chosen_identity_option)
			applying = FALSE
			return // Cancel if no choice made

		chosen_identity = choice_map[chosen_identity_option]

	user.visible_message(
		"<span class='notice'>[user] begins applying synthetic skin to [target == user ? "their" : "[target]'s"] [affected.name] with [src].</span>",
		"<span class='notice'>You begin applying synthetic skin to [target == user ? "your" : "[target]'s"] [affected.name]...</span>"
	)

	// Play start sound
	playsound(get_turf(src), 'sound/effects/spray.ogg', 50, TRUE)

	// 10 second do-after
	if(do_after(user, 10 SECONDS, target = target))
		// Play end sound
		playsound(get_turf(src), 'sound/effects/spray3.ogg', 50, TRUE)

		// Consume metal
		metal_stored -= metal_per_use

		// Apply synthetic skin
		affected.has_synthetic_skin = TRUE

		// Set identity if applying to head (we already got the choice above)
		if(def_zone == BODY_ZONE_HEAD)
			affected.synthetic_skin_identity = chosen_identity
			if(ishuman(target))
				target.real_name = chosen_identity

	// Clear force_icon so it uses the masquerade logic instead of hardcoded robotic sprites
	affected.force_icon = null

	// Apply to connected torso parts as well
	if(def_zone == BODY_ZONE_CHEST)
		var/obj/item/organ/external/groin_limb = target.bodyparts_by_name["groin"]
		if(groin_limb && groin_limb.is_robotic() && !groin_limb.has_synthetic_skin)
			groin_limb.has_synthetic_skin = TRUE
			groin_limb.force_icon = null
			groin_limb.mob_icon = null
			groin_limb.compile_icon()

	if(def_zone == BODY_ZONE_PRECISE_GROIN)
		var/obj/item/organ/external/chest_limb = target.bodyparts_by_name["chest"]
		if(chest_limb && chest_limb.is_robotic() && !chest_limb.has_synthetic_skin)
			chest_limb.has_synthetic_skin = TRUE
			chest_limb.force_icon = null
			chest_limb.mob_icon = null
			chest_limb.compile_icon()

	// Force the organ to completely regenerate its mob_icon
	affected.mob_icon = null  // Clear the cached icon
	affected.compile_icon()   // Force regeneration

	// Force complete body rebuild to bypass icon cache
	target.update_body(rebuild_base = TRUE)
	target.UpdateDamageIcon()

	user.visible_message(
		"<span class='notice'>[user] successfully applies synthetic skin to [target == user ? "their" : "[target]'s"] [affected.name].</span>",
		"<span class='notice'>You successfully apply synthetic skin to [target == user ? "your" : "[target]'s"] [affected.name].</span>"
	)

	if(target != user)
		to_chat(target, "<span class='notice'>You feel a thin layer of synthetic skin form over your [affected.name].</span>")

	applying = FALSE
