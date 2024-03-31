//Simple borg hand.
//Limited use.
/// This isn't a drone item, also in engineering cyborg kits
/obj/item/gripper_engineering
	name = "magnetic gripper"
	desc = "A simple grasping tool for synthetic assets."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	actions_types = list(/datum/action/item_action/drop_gripped_item)

	//Has a list of items that it can hold.
	var/list/can_hold = list(
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
		/obj/item/light
	)

	//Item currently being held.
	var/obj/item/gripped_item = null

/obj/item/gripper_medical
	name = "medical gripper"
	desc = "A grasping tool used to help patients up once surgery is complete, or to substitute for hands in surgical operations."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"


/obj/item/gripper_medical/afterattack(atom/target, mob/living/user, proximity, params)
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

/obj/item/gripper_engineering/Initialize(mapload)
	. = ..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper_engineering/ui_action_click(mob/user)
	drop_gripped_item()

/obj/item/gripper_engineering/attack_self(mob/user)
	if(!gripped_item)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	gripped_item.attack_self(user)

/obj/item/gripper_engineering/proc/drop_gripped_item(silent = FALSE)
	if(!gripped_item)
		return
	if(!silent)
		to_chat(loc, "<span class='warning'>You drop [gripped_item].</span>")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null

/obj/item/gripper_engineering/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/// Grippers are snowflakey so this is needed to to prevent forceMoving grippers after `if(!user.drop_item())` checks done in certain attackby's. // What does this even MEAN - GDN
/obj/item/gripper_engineering/forceMove(atom/destination)
	return

/obj/item/gripper_engineering/afterattack(atom/target, mob/living/user, proximity, params)
	if(!target || !proximity) //Target is invalid or we are not adjacent.
		return FALSE

	if(gripped_item) //Already have an item.

		//Pass the attack on to the target. This might delete/relocate gripped_item.
		if(!target.attackby(gripped_item, user, params))
			// If the attackby didn't resolve or delete the target or gripped_item, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			gripped_item?.afterattack(target, user, 1, params)

		//If gripped_item either didn't get deleted, or it failed to be transfered to its target
		if(!gripped_item && contents.len)
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

/obj/item/matter_decompiler
	name = "matter decompiler"
	desc = "Eating trash, bits of glass, or other debris will replenish your stores."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	/// Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0
		)

/obj/item/matter_decompiler/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	return

/obj/item/matter_decompiler/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity)
		return // Not adjacent.

	// We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	// Used to give the right message.
	var/grabbed_something = FALSE

	for(var/atom/movable/A in T)
		if(A.decompile_act(src, user)) // Each decompileable mob or obj needs to have this defined
			grabbed_something = TRUE

	if(grabbed_something)
		to_chat(user, "<span class='notice'>You deploy your decompiler and clear out the contents of \the [T].</span>")
	else
		to_chat(user, "<span class='warning'>Nothing on \the [T] is useful to you.</span>")
	return

// Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()
	..()
	if(low_power_mode || !decompiler)
		return

	// The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new /obj/item/stack/sheet/metal/cyborg(src.module)
						stack_metal.amount = 1
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new /obj/item/stack/sheet/glass/cyborg(src.module)
						stack_glass.amount = 1
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new /obj/item/stack/sheet/wood(src.module)
						stack_wood.amount = 1
					stack = stack_wood
			stack.amount++
			decompiler.stored_comms[type]--
