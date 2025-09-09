/*   CONTENTS:
*	0. Generic Gripper
*	1. Gripper Types
*		1.1 Universal Gripper
*		1.2 Medical Gripper
*		1.3 Service Gripper
*		1.4 Mining Gripper
*		1.5 Engineering Gripper
*/

// Generic gripper. This should never appear anywhere.
/obj/item/gripper
	name = "generic gripper item"
	desc = "If you can see this, make an issue report to Github. Something has gone wrong!"
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	actions_types = list(/datum/action/item_action/drop_gripped_item)
	flags = ABSTRACT
	new_attack_chain = TRUE
	/// Set to TRUE to removal of cells/lights from machine objects containing them.
	var/engineering_machine_interaction = FALSE
	/// Defines what items the gripper can carry.
	var/list/can_hold = list()
	/// Set to TRUE to allow ANY item to be held, bypassing can_hold checks.
	var/can_hold_all_items = FALSE
	/// Set to TRUE to allow the gripper to shake people awake and help them up.
	var/can_help_up = FALSE
	/// The item currently being held.
	var/obj/item/gripped_item
	/// Tracks gripper's state, prevents us from spamming actions
	var/busy = FALSE

/obj/item/gripper/examine(mob/user)
	. = ..()
	if(!gripped_item)
		. += "<span class='notice'>[src] is empty.</span>"
		return
	. += "<span class='notice'>[src] is currently holding [gripped_item].</span>"

/obj/item/gripper/examine_more(mob/user)
	. = ..()
	. += "Cyborg grippers are well-developed, and despite some anatomical differences that manifest in some models, they can be used just as effectively as a regular hand with enough practice."
	. += ""
	. += "Companies like Nanotrasen use software to limit the items that a cyborg can manipulate to a specific pre-defined list, \
	as part of their multi-layered protections to try and eliminate the chance of a hypothetical synthetic uprising, not wishing to see a repeat of the IPC uprising in 2525."

/obj/item/gripper/Initialize(mapload)
	. = ..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/ui_action_click(mob/user)
	drop_gripped_item(user)

/obj/item/gripper/proc/drop_gripped_item(mob/user, silent = FALSE)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return FALSE
	if(!silent)
		to_chat(user, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null
	return TRUE

/obj/item/gripper/activate_self(mob/user)
	. = ..()
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return ITEM_INTERACT_COMPLETE

	if(gripped_item.new_attack_chain)
		gripped_item.activate_self(user)
	else
		gripped_item.attack_self__legacy__attackchain(user)
	return ITEM_INTERACT_COMPLETE

// This is required to ensure that the forceMove checks on some objects don't rip the gripper out of the borg's inventory and toss it on the floor. That would hurt, a lot!
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!target)
		return ITEM_INTERACT_COMPLETE

	if(busy)
		return TRUE // prevents us from punching atom we clicked on, don't wanna return interact_complete because we didn't really complete anything

	// Does the gripper already have an item?
	if(gripped_item)
		busy = TRUE

		// Pass the attack on to the target. This might delete/relocate gripped_item.
		if(!target.item_interaction(user, gripped_item, modifiers))
			gripped_item.melee_attack_chain(user, target, list2params(modifiers))
		// Check to see if there is still an item in the gripper (stackable items trigger this).
		if(!gripped_item && length(contents))
			gripped_item = contents[1]
		// If the gripper thinks it has something but it actually doesn't, we fix this.
		else if(gripped_item && !length(contents))
			gripped_item = null

		busy = FALSE

		return ITEM_INTERACT_COMPLETE

	// Is the gripper interacting with an item?
	if(isitem(target))
		var/obj/item/I = target
		// Make sure the item is something the gripper can hold
		if(can_hold_all_items || is_type_in_typecache(I, can_hold))
			to_chat(user, "<span class='notice'>You collect [I].</span>")
			I.forceMove(src)
			gripped_item = I
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='warning'>You hold your gripper over [target], but no matter how hard you try, you cannot make yourself grab it.</span>")
		return ITEM_INTERACT_COMPLETE

	// Everything past this point requires being able to engineer.
	if(!engineering_machine_interaction)
		// Allow attack chain to continue into pre_attack()
		return

	// Removing cells from APCs.
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened && A.cell)
			gripped_item = A.cell
			A.cell.add_fingerprint(user)
			A.cell.update_icon()
			A.cell.forceMove(src)
			A.cell = null
			A.charging = APC_NOT_CHARGING
			A.update_icon()
			user.visible_message(
				"<span class='warning'>[user] removes the cell from [A]!</span>",
				"<span class='warning'>You remove the cell from [A].</span>"
				)
		return ITEM_INTERACT_COMPLETE

	// Removing cells from cell chargers.
	if(istype(target, /obj/machinery/cell_charger))
		var/obj/machinery/cell_charger/cell_charger = target
		if(cell_charger.charging)
			gripped_item = cell_charger.charging
			cell_charger.charging.add_fingerprint(user)
			cell_charger.charging.forceMove(src)
			cell_charger.removecell()
		user.visible_message(
			"<span class='notice'>[user] removes the cell from [cell_charger].</span>",
			"<span class='notice'>You remove the cell from [cell_charger].</span>"
			)
		return ITEM_INTERACT_COMPLETE

	// Removing lights from fixtures.
	if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light = target
		var/obj/item/light/L = light.drop_light_tube()
		L.forceMove(src)
		gripped_item = L
		user.visible_message(
			"<span class='notice'>[user] removes [L] from [light].</span>",
			"<span class='notice'>You remove [L] from [light].</span>"
			)
		return ITEM_INTERACT_COMPLETE

/obj/item/gripper/emag_act(mob/user)
	emagged = !emagged
	..()
	return TRUE

/obj/item/gripper/pre_attack(atom/atom_target, mob/living/user, params)
	. = FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK
	if(gripped_item)
		gripped_item.attack(atom_target, user)
		return

	if(!ismob(atom_target))
		return ..()

	var/mob/living/target = atom_target
	// If a human target is horizonal, try to help them up. Unless you're trying to kill them.
	if(ishuman(target) && user.a_intent == INTENT_HELP && can_help_up)
		var/mob/living/carbon/human/pickup_target = target
		if(IS_HORIZONTAL(pickup_target))
			// Same restorative effects as when a human tries to help someone up.
			pickup_target.AdjustSleeping(-10 SECONDS)
			pickup_target.AdjustParalysis(-6 SECONDS)
			pickup_target.AdjustStunned(-6 SECONDS)
			pickup_target.AdjustWeakened(-6 SECONDS)
			pickup_target.AdjustKnockDown(-6 SECONDS)
			pickup_target.adjustStaminaLoss(-10)
			pickup_target.resting = FALSE
			pickup_target.stand_up()
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			user.visible_message(
				"<span class='notice'>[user] shakes [pickup_target] trying to wake [pickup_target.p_them()] up!</span>",
				"<span class='notice'>You shake [pickup_target] trying to wake [pickup_target.p_them()] up!</span>"
				)
			return

	if(user.a_intent == INTENT_HELP)
		if(target == user)
			user.visible_message(
				"<span class='notice'>[user] gives [user.p_themselves()] a hug to make [user.p_themselves()] feel better.</span>",
				"<span class='notice'>You give yourself a hug to make yourself feel better.</span>"
				)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			return

		// Checks if holder_type exists to prevent picking up animals like mice, because we're about to use the hands that borgs secretly have.
		if(isanimal_or_basicmob(target) && !target.holder_type)
			var/list/modifiers = params2list(params)
			// This enables borgs to get the floating heart icon and mob emote from simple_animals that have petbonus == TRUE.
			target.attack_hand(user, modifiers)
			return

		if(user.zone_selected == BODY_ZONE_HEAD)
			user.visible_message(
				"<span class='notice'>[user] playfully boops [target] on the head.</span>",
				"<span class='notice'>You playfully boop [target] on the head.</span>"
				)
			user.do_attack_animation(target, ATTACK_EFFECT_BOOP)
			playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
			return

		if(ishuman(target))
			user.visible_message(
				"<span class='notice'>[user] hugs [target] to make [target.p_them()] feel better.</span>",
				"<span class='notice'>You hug [target] to make [target.p_them()] feel better.</span>"
				)
		else
			user.visible_message(
				"<span class='notice'>[user] pets [target]!</span>",
				"<span class='notice'>You pet [target]!</span>"
				)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		return

	if(user.a_intent == INTENT_HARM && !emagged)
		if(target == user)
			user.visible_message(
			"<span class='notice'>[user] gives [user.p_themselves()] a firm bear-hug to make [user.p_themselves()] feel better.</span>",
			"<span class='notice'>You give yourself a firm bear-hug to make yourself feel better.</span>"
			)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			return

		if(!ishuman(target) || user.zone_selected == BODY_ZONE_HEAD)
			user.visible_message(
				"<span class='warning'>[user] bops [target] on the head!</span>",
				"<span class='warning'>You bop [target] on the head!</span>"
				)
			user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
			playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		else
			user.visible_message(
				"<span class='warning'>[user] hugs [target] in a firm bear-hug! [target] looks uncomfortable...</span>",
				"<span class='warning'>You hug [target] firmly to make [target.p_them()] feel better! [target] looks uncomfortable...</span>"
				)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		return

	// Just in case.
	if(!emagged)
		return

	if(target == user)
		user.visible_message(
			"<span class='danger'>[user] punches [user.p_themselves()] in the face!.</span>",
			"<span class='userdanger'>You punch yourself in the face!</span>"
			)
		user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
		playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
		user.adjustBruteLoss(15)
		return

	if(ishuman(target))
		// Try to punch them in the face... Unless it fell off or something.
		if(user.zone_selected == BODY_ZONE_HEAD && target.get_organ("head"))
			user.visible_message(
				"<span class='danger'>[user] punches [target] squarely in the face!</span>",
				"<span class='danger'>You punch [target] in the face!</span>"
				)
			var/obj/item/organ/external/head/their_face = target.get_organ("head")
			user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
			playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
			their_face.receive_damage(15)
			target.UpdateDamageIcon()
			return

	user.visible_message(
		"<span class='danger'>[user] crushes [target] in [user.p_their()] grip!</span>",
		"<span class='danger'>You crush [target] in your grip!</span>"
		)
	playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
	target.adjustBruteLoss(15)

// MARK: Gripper Types

/*
* Universal Gripper
* Not supplied to any cyborg by default.
* Can be varedited onto a borg for event stuff.
* Functions almost like a real hand!
*/
/obj/item/gripper/universal
	name = "cyborg gripper"
	desc = "A grasping tool for cyborgs. This one is not restricted by any restraining software, allowing it to handle any object the user wishes."
	// It's UNIVERSAL so it has all functions enabled.
	engineering_machine_interaction = TRUE
	can_help_up = TRUE
	can_hold_all_items = TRUE

/obj/item/gripper/universal/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src,TRAIT_SURGICAL_OPEN_HAND, ROUNDSTART_TRAIT)

// Medical Gripper
// For medical borgs, for doing medical stuff!
// Not giving this anything to hold yet, but stuff may be added in the future. Organs/implants are currently viewed as too strong to hold.
/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool for cyborgs. This one is covered with hygenic medical-grade silicone rubber. \
	Use it to help patients up once surgery is complete, or to substitute for hands in surgical operations."
	can_help_up = TRUE
	// REMOVE actions_types from here if you add a can_hold list for this gripper!
	actions_types = list()

/obj/item/gripper/medical/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src,TRAIT_SURGICAL_OPEN_HAND, ROUNDSTART_TRAIT)

// Service Gripper
// For service borgs. To make them slightly better at their job.
/obj/item/gripper/service
	name = "service gripper"
	desc = "A grasping tool for cyborgs. This version is made from hygenic easy-clean material. Maybe some day you'll be able to grab food with it..."
	// For waking up drunkards.
	can_help_up = TRUE
	// Everything in this list is currently for either playing games or otherwise assisting the crew in mundane, non-impactful ways.
	can_hold = list(
		/obj/item/deck,
		/obj/item/cardhand,
		/obj/item/coin,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/toy/plushie,
		/obj/item/clothing/mask/cigarette
	)

// Mining Gripper
// For mining borgs. Mostly for self-application of goliath armour.
/obj/item/gripper/mining
	name = "mining gripper"
	desc = "A grasping tool for cyborgs. This ruggedized version will let you add goliath plating to yourself and activate survival capsules. You could also use it to swing a pickaxe if you don't feel like using your drill."
	can_hold = list(
		/obj/item/pickaxe,	// Because the image of a mining borg ignoring its built-in drill and instead choosing to swing an old-fashioned pickaxe is funny.
		/obj/item/stack/sheet/animalhide/goliath_hide,
		/obj/item/survivalcapsule
	)

//	Engineering Gripper
// For engineering and sabotage borgs, and drones.
/obj/item/gripper/engineering
	name = "engineering gripper"
	desc = "A grasping tool for cyborgs. This version can hold a wide variety of constructon components for use in engineering work."
	engineering_machine_interaction = TRUE
	can_hold = list(
		/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/intercom_electronics,
		/obj/item/apc_electronics,
		/obj/item/tracker_electronics,
		/obj/item/stock_parts,
		/obj/item/vending_refill,
		/obj/item/mounted/frame,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/igniter,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stack/tile/light,
		/obj/item/light
	)
