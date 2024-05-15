/*   CONTENTS:
0. generic define gripper
1. UNIVERSAL GRIPPER
2. MEDICAL GRIPPER
3. SERVICE GRIPPER
4. ENGINEERING GRIPPER
*/

// Generic gripper. This should never appear anywhere.
/obj/item/gripper
	name = "generic gripper item"
	desc = "If you can see this, make an issue report to Github. Something has gone wrong!"
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	actions_types = list(/datum/action/item_action/drop_gripped_item)
	/// Set to TRUE to allow interaction with light fixtures and cell-containing machinery.
	var/engineering_machine_interaction = FALSE
	/// Set to TRUE to allow the gripper to shake people awake/help them up.
	var/can_help_up = FALSE
	/// Defines what items the gripper can carry.
	var/list/can_hold = list()
	/// Set to TRUE to allow ANY item to be held, bypassing can_hold checks.
	var/can_hold_all_items = FALSE
	/// The item currently being held.
	var/obj/item/gripped_item

/obj/item/gripper/examine(mob/user)
	. = ..()
	if(!gripped_item)
		. += "<span class='notice'>[src] is empty.</span>"
		return
	. += "<span class='notice'>[src] is currently holding [gripped_item].</span>"

/obj/item/gripper/examine_more(mob/user)
	. = ..()
	. += {"Cyborg grippers are well-developed, and despite some anatomical differences that manifest in some models, they can be used just as effectively as a regular hand with enough practice.

Companies like Nanotrasen use software to limit the items that a cyborg can manipulate to a specific pre-defined list, \
as part of their multi-layered protections to try and eliminate the chance of a hypothetical synthetic uprising, not wishing to see a repeat of the IPC uprising in 2525."}


/obj/item/gripper/Initialize(mapload)
	. = ..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/ui_action_click(mob/user)
	drop_gripped_item(user)

/obj/item/gripper/proc/drop_gripped_item(mob/user, silent = FALSE)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	if(!silent)
		to_chat(user, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null

/obj/item/gripper/attack_self(mob/user)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	gripped_item.attack_self(user)

/obj/item/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

// This is required to ensure that the forceMove checks on some objects don't rip the gripper out of the borg's inventory and toss it on the floor. That would hurt, a lot!
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/afterattack(atom/target, mob/living/user, proximity, params)
	//Target is invalid or we are not adjacent.
	if(!target || !proximity)
		return FALSE
	// Shake people awake, get them on their feet.
	if(ishuman(target) && can_help_up)
		var/mob/living/carbon/human/pickup_target = target
		if(!IS_HORIZONTAL(pickup_target))
			return
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
		return FALSE
	//Already have an item.
	if(gripped_item)

		//Pass the attack on to the target. This might delete/relocate gripped_item.
		if(!target.attackby(gripped_item, user, params))
			// If the attackby didn't resolve or delete the target or gripped_item, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			gripped_item?.afterattack(target, user, 1, params)

		//If gripped_item either didn't get deleted, or it failed to be transfered to its target
		if(!gripped_item && length(contents))
			gripped_item = contents[1]
			return FALSE
		else if(gripped_item && !contents.len)
			gripped_item = null

	//Check that we're not pocketing a mob.
	else if(isitem(target))
		var/obj/item/I = target
		// Make sure the item is something the gripper can hold
		if(can_hold_all_items || is_type_in_typecache(I, can_hold))
			to_chat(user, "<span class='notice'>You collect [I].</span>")
			I.forceMove(src)
			gripped_item = I
			return TRUE
		
		to_chat(user, "<span class='warning'>You hold your gripper over [target], but no matter how hard you try, you cannot make yourself grab it.</span>")
		return FALSE

	// Everything past this point requires being able to engineer.
	if(!engineering_machine_interaction)
		return
	// APC cells.
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

			user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "<span class='warning'>You remove the power cell.</span>")
	// Cell Chargers
	else if(istype(target, /obj/machinery/cell_charger))
		var/obj/machinery/cell_charger/cell_charger = target
		if(cell_charger.charging)
			gripped_item = cell_charger.charging
			cell_charger.charging.add_fingerprint(user)
			cell_charger.charging.forceMove(src)
			cell_charger.removecell()
	// Putting lights in fixtures.
	else if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light = target
		var/obj/item/light/L = light.drop_light_tube()
		L.forceMove(src)
		gripped_item = L
		user.visible_message("<span class='notice'>[user] removes the light from the fixture.</span>", "<span class='notice'>You dislodge the light from the fixture.</span>")

	return TRUE

////////////////////////////////
// MARK:	UNIVERSAL GRIPPER
////////////////////////////////
/// Universal gripper. Not supplied to any cyborg by default. Could be varedited onto a borg for event stuff. Functions almost like a real hand!
/obj/item/gripper/universal		
	name = "cyborg gripper"
	desc = "A grasping tool for cyborgs. This one is not restricted by any restraining software, allowing it to handle any object the user wishes."
	// It's UNIVERSAL so it has all functions enabled.
	engineering_machine_interaction = TRUE
	can_help_up = TRUE
	can_hold_all_items = TRUE

////////////////////////////////
// MARK:	MEDICAL GRIPPER
////////////////////////////////
// For medical borgs, for doing medical stuff!
// Not giving this anything to hold yet, but stuff may be added in the future. Organs/implants are currently viewed as too strong to hold.
/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool for cyborgs. This one is covered with hygenic medical-grade silicone rubber. \
	Use it to help patients up once surgery is complete, or to substitute for hands in surgical operations."
	can_help_up = TRUE
	// REMOVE actions_types from here if you add a can_hold list for this gripper!
	actions_types = list()

////////////////////////////////
// MARK:	SERVICE GRIPPER
////////////////////////////////
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
		/obj/item/toy/plushie
	)

////////////////////////////////
// MARK:	ENGINEERING GRIPPER
////////////////////////////////
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
