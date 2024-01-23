//Simple borg hand.
/obj/item/gripper
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	actions_types = list(/datum/action/item_action/drop_gripped_item)

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/stock_parts,
		/obj/item/light,
		/obj/item/mounted/frame/apc_frame,
	)

	//Item currently being held.
	var/obj/item/gripped_item = null

/obj/item/gripper/Initialize(mapload)
	. = ..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/ui_action_click(mob/user)
	drop_gripped_item()

/obj/item/gripper/verb/drop_item_gripped()
	set name = "Drop Gripped Item"
	set desc = "Release an item from your magnetic gripper."
	set category = "Robot Commands"
	drop_gripped_item()

/obj/item/gripper/attack_self(mob/user)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	gripped_item.attack_self(user)

/obj/item/gripper/tool_act(mob/living/user, obj/item/tool, tool_type)
	if(!gripped_item)
		return
	gripped_item.tool_act(user, tool, tool_type)
	if(QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything

/obj/item/gripper/attackby(obj/item/weapon, mob/user, params)
	if(!gripped_item)
		return FALSE
	gripped_item.attackby(weapon, user, params)
	if(QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything

/obj/item/gripper/proc/drop_gripped_item(silent = FALSE)
	if(!gripped_item)
		return FALSE
	if(!silent)
		to_chat(loc, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null
	return TRUE

/obj/item/gripper/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/// Grippers are snowflakey so this is needed to to prevent forceMoving grippers after `if(!user.drop_from_active_hand())` checks done in certain attackby's.
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/proc/isEmpty()
	return isnull(gripped_item)

/obj/item/gripper/afterattack(atom/target, mob/living/user, proximity, params)
	if(!target || !proximity) // Target is invalid or we are not adjacent.
		return FALSE

	if(gripped_item) // Already have an item.

		// Pass the attack on to the target. This might delete/relocate gripped_item.
		if(!target.attackby(gripped_item, user, params))
			// If the attackby didn't resolve or delete the target or gripped_item, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			gripped_item?.afterattack(target, user, 1, params)

		// If gripped_item either didn't get deleted, or it failed to be transfered to its target
		if(!gripped_item && contents.len)
			gripped_item = contents[1]
			return FALSE
		else if(gripped_item && !contents.len)
			gripped_item = null

	else if(istype(target, /obj/item)) // Check that we're not pocketing a mob.
		var/obj/item/I = target
		if(is_type_in_typecache(I, can_hold)) // Make sure the item is something the gripper can hold
			to_chat(user, "<span class='notice'>You collect [I].</span>")
			I.forceMove(src)
			gripped_item = I
		else
			to_chat(user, "<span class='warning'>Your gripper cannot hold [target].</span>")
			return FALSE

	else if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		if(A.opened)
			if(A.cell && is_type_in_typecache(A.cell, can_hold))

				gripped_item = A.cell

				A.cell.add_fingerprint(user)
				A.cell.update_icon()
				A.cell.forceMove(src)
				A.cell = null

				A.charging = APC_NOT_CHARGING
				A.update_icon()

				user.visible_message("<span class='warning'>[user] removes the power cell from [A]!", "You remove the power cell.")

	else if(istype(target, /obj/machinery/cell_charger))
		var/obj/machinery/cell_charger/cell_charger = target
		if(cell_charger.charging)
			gripped_item = cell_charger.charging
			cell_charger.charging.add_fingerprint(user)
			cell_charger.charging.forceMove(src)
			cell_charger.removecell()

	else if(ishuman(target))
		var/mob/living/carbon/human/pickup_target = target
		if(!IS_HORIZONTAL(pickup_target))
			return FALSE
		pickup_target.AdjustSleeping(-10 SECONDS)
		pickup_target.AdjustParalysis(-6 SECONDS)
		pickup_target.AdjustStunned(-6 SECONDS)
		pickup_target.AdjustWeakened(-6 SECONDS)
		pickup_target.AdjustKnockDown(-6 SECONDS)
		pickup_target.stand_up()
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		user.visible_message( \
			"<span class='notice'>[user] shakes [pickup_target] trying to wake [pickup_target.p_them()] up!",\
			"<span class='notice'>You shake [pickup_target] trying to wake [pickup_target.p_them()] up!",\
			)

	return TRUE


// ===================
// different grippers
// ===================
/obj/item/gripper/engineering
	name = "engineering gripper"
	desc = "A simple grasping tool for synthetic assets."
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
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/display/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/mounted/frame/extinguisher,
		/obj/item/mounted/frame/light_switch,
		/obj/item/assembly/prox_sensor,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/tile/light,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/assembly/igniter,
		/obj/item/flash,
	)

/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool used to hold organs and help patients up once surgery is complete."
	can_hold = list(/obj/item/organ,
					/obj/item/reagent_containers/iv_bag,
					/obj/item/robot_parts,
					/obj/item/stack/sheet/mineral/plasma, // for repair plasmamans
					/obj/item/mmi,
					/obj/item/reagent_containers/pill,
					/obj/item/reagent_containers/drinks,
					/obj/item/reagent_containers/glass,
					/obj/item/reagent_containers/syringe,
					)

/obj/item/gripper/medical/attack_self(mob/user)
	return

/obj/item/gripper/service
	name = "Card gripper"
	desc = "A grasping tool used to take IDs for paying taxes and waking up drunken crewmates"
	can_hold = list(/obj/item/card,
					/obj/item/camera_film,
					/obj/item/paper,
					/obj/item/photo,
					/obj/item/toy/plushie,
					/obj/item/disk/data,
					/obj/item/disk/design_disk,
					/obj/item/disk/plantgene,
					)

/obj/item/gripper/nuclear
	name = "Nuclear gripper"
	desc = "Designed for all your nuclear needs."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "diskgripper"
	can_hold = list(/obj/item/disk/nuclear)


/obj/item/gripper/medical
	name = "medical gripper"
	desc = "A grasping tool used to help patients up once surgery is complete, or to substitute for hands in surgical operations."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

/obj/item/gripper/medical/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity || !target || !ishuman(target))
		return
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
