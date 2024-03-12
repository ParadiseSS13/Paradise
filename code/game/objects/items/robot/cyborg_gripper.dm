/*   CONTENTS:
0. generic define gripper
1. UNIVERSAL GRIPPER
2. NUCLEAR OPS GRIPPER
3. MEDICAL GRIPPER
4. SERVICE GRIPPER
5. ENGINEERING GRIPPER
*/

/obj/item/gripper   // Generic gripper. This should never appear anywhere.
	name = "generic gripper item"
	desc = "If you can see this, make an issue report to Github. Something has gone wrong!"
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	actions_types = list(/datum/action/item_action/drop_gripped_item)
	var/engineering_machine_interaction = FALSE	// Used to stop non-engi grippers from grabbing cells and lightbulbs from certain machines.
	var/can_help_up = FALSE	// Used to stop non-medical/service grippers from shaking people awake or helping them up.
	var/list/can_hold = list(
		/obj/item
    )

	var/obj/item/gripped_item    // Item currently being held.

/obj/item/gripper/examine_more(mob/user)
    . = ..()
    . += "Cyborg grippers are well-developed, and despite some anatomical differences that manifest in some models, \
    they can be used just as effectively as a regular hand with enough practice. \
    Companies like Nanotrasen use software to limit the items that a cyborg can manipulate to a specific pre-defined list, as part of their multi-layered \
    protections to try and eliminate the chance of a hypothetical synthetic uprising, not wishing to see a repeat of the IPC uprising in 2525."


/obj/item/gripper/Initialize(mapload)
	. = ..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/ui_action_click(mob/user)
	drop_gripped_item()

/obj/item/gripper/proc/drop_gripped_item(silent = FALSE)
	if(!gripped_item)
		return
	if(!silent)
		to_chat(loc, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null

/obj/item/gripper/attack_self(mob/user)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	gripped_item.attack_self(user)

/obj/item/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/// Grippers are snowflakey so this is needed to to prevent forceMoving grippers after `if(!user.drop_item())` checks done in certain attackby's. // What does this even MEAN - GDN
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/afterattack(atom/target, mob/living/user, proximity, params)
	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return FALSE

	if(ishuman(target) && can_help_up)	// Shake people awake, get them on their feet.
		var/mob/living/carbon/human/pickup_target = target
		if(!IS_HORIZONTAL(pickup_target))
			return
		pickup_target.AdjustSleeping(-10 SECONDS)
		pickup_target.AdjustParalysis(-6 SECONDS)
		pickup_target.AdjustStunned(-6 SECONDS)
		pickup_target.AdjustWeakened(-6 SECONDS)
		pickup_target.AdjustKnockDown(-6 SECONDS)
		pickup_target.stand_up()
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		user.visible_message( \
			"<span class='notice'>[user] shakes [pickup_target] trying to wake [pickup_target.p_them()] up!</span>",\
			"<span class='notice'>You shake [pickup_target] trying to wake [pickup_target.p_them()] up!</span>",\
			)
		return

	if(gripped_item) //Already have an item.

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

	else if(isitem(target)) //Check that we're not pocketing a mob.
		var/obj/item/I = target
		if(is_type_in_typecache(I, can_hold)) // Make sure the item is something the gripper can hold
			to_chat(user, "<span class='notice'>You collect [I].</span>")
			I.forceMove(src)
			gripped_item = I
		else
			to_chat(user, "<span class='warning'>Your gripper cannot hold [target].</span>")
			return FALSE

	if(!engineering_machine_interaction)	// Everything past this point requires being able to engineer.
		return

	else if(istype(target,/obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell)

				gripped_item = A.cell

				A.cell.add_fingerprint(user)
				A.cell.update_icon()
				A.cell.forceMove(src)
				A.cell = null

				A.charging = APC_NOT_CHARGING
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!</span>", "You remove the power cell.")

	else if(istype(target, /obj/machinery/cell_charger))
		var/obj/machinery/cell_charger/cell_charger = target
		if(cell_charger.charging)
			gripped_item = cell_charger.charging
			cell_charger.charging.add_fingerprint(user)
			cell_charger.charging.forceMove(src)
			cell_charger.removecell()

	else if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light = target
		var/obj/item/light/L = light.drop_light_tube()
		L.forceMove(src)
		gripped_item = L
		user.visible_message("<span class='notice'>[user] removes the light from the fixture.</span>", "<span class='notice'>You dislodge the light from the fixture.</span>")

	return TRUE

/******************************
/     UNIVERSAL GRIPPER
******************************/
/obj/item/gripper/universal		// Universal gripper. Not supplied to any cyborg by default. Could be varedited onto a borg for event stuff. Functions almost like a real hand!
	name = "cyborg gripper"
	desc = "A grasping tool for cyborgs. This one is not restricted by any restraining software, allowing it to handle any object the user wishes."
	engineering_machine_interaction = TRUE	// It's UNIVERSAL so it can do both of these things.
	can_help_up = TRUE
	can_hold = list(
        /obj/item
    )

/******************************
/     NUCLEAR OPS GRIPPER
******************************/
/obj/item/gripper/nuclear		// For syndicate nuke-ops borgs. Get dat fokkin' disk!
	name = "suspicious disk gripper"
	desc = "A suspicious grasping tool to allow you to \''get dat fokkin' disk!''\ "
	can_hold = list(
        /obj/item/disk			// Can hold any disk so that no disk cannot be gotten. 
    )

/******************************
/       MEDICAL GRIPPER
******************************/
/obj/item/gripper/medical  		// For medical borgs, for doing medical stuff!
	name = "medical gripper"
	desc = "A grasping tool for cyborgs. This one is covered with hygenic medical-grade silicone rubber. \
    Use it to help patients up once surgery is complete, or to substitute for hands in surgical operations."
	can_help_up = TRUE
	actions_types = list(null)	// REMOVE THIS if you add anything to the can_hold list for this gripper!
	can_hold = null 						// Not giving this anything to hold yet, but stuff may be added in the future. Organs/implants are currently viewed as too strong to hold.

/******************************
/       SERVICE GRIPPER
******************************/
/obj/item/gripper/service   	// For service borgs. To make them slightly better at their job.
	name = "service gripper"
	desc = "A grasping tool for cyborgs. This version is made from hygenic easy-clean material. Maybe some day you'll be able to grab food with it..."
	can_help_up = TRUE			// For waking up drunkards.
	can_hold = list(
        /obj/item/deck,
        /obj/item/cardhand, 	// For playing card games!
        /obj/item/paper,	    // The "important" papers and photos you had the borg make shouldn't be sullied on the dirty floor.
        /obj/item/photo,
        /obj/item/toy/plushie   // To allow the borg to bring you a soft toy. D'aww!
    )

/******************************
/     ENGINEERING GRIPPER
******************************/
/obj/item/gripper/engineering   	// For engineering and sabotage borgs, and drones.
	name = "engineering gripper"
	desc = "A grasping tool for cyborgs. This version can hold a wide veriaty of constructon components for use in engineering work."
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
	