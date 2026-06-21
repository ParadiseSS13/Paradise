/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tube"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=2;engineering=3"
	materials = list(MAT_METAL = 1166, MAT_GLASS = 1166)
	amount = 6
	max_amount = 6
	merge_type = /obj/item/stack/nanopaste

/obj/item/stack/nanopaste/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(ismob(target))
		if(isrobot(target))	// Repairing cyborgs.
			var/mob/living/silicon/robot/R = target
			if(!R.getBruteLoss() && !R.getFireLoss())
				to_chat(user, SPAN_NOTICE("All [R]'s systems are nominal."))
				return ITEM_INTERACT_COMPLETE

			R.heal_overall_damage(15, 15)
			use(1)
			user.visible_message(
				SPAN_NOTICE("[user] applies some [src] at [R]'s damaged areas."),
				SPAN_NOTICE("You apply some [src] at [R]'s damaged areas.")
			)
			return ITEM_INTERACT_COMPLETE

		if(ishuman(target)) // Repairing robotic limbs and IPCs.
			var/mob/living/carbon/human/H = target
			var/obj/item/organ/external/external_limb = H.get_organ(user.zone_selected)
			if(!external_limb)
				to_chat(user, SPAN_WARNING("[H] is missing that limb!"))
				return ITEM_INTERACT_COMPLETE

			if(!external_limb.is_robotic())
				to_chat(user, SPAN_WARNING("That limb is not robotic!"))
				return ITEM_INTERACT_COMPLETE

			robotic_limb_repair(user, external_limb, H)
		return ITEM_INTERACT_COMPLETE

	if(ismecha(target))
		var/obj/mecha/mecha = target
		if((mecha.obj_integrity >= mecha.max_integrity) && !mecha.internal_damage)
			to_chat(user, SPAN_NOTICE("[mecha] is at full integrity!"))
			return ITEM_INTERACT_COMPLETE

		if(mecha.state == MECHA_MAINT_OFF)
			to_chat(user, SPAN_WARNING("[mecha] cannot be repaired without maintenance protocols active!"))
			return ITEM_INTERACT_COMPLETE

		if(mecha.repairing)
			to_chat(user, SPAN_NOTICE("[mecha] is currently being repaired!"))
			return ITEM_INTERACT_COMPLETE

		if(mecha.internal_damage & MECHA_INT_TANK_BREACH)
			mecha.clearInternalDamage(MECHA_INT_TANK_BREACH)
			user.visible_message(SPAN_NOTICE("[user] repairs the damaged air tank."), SPAN_NOTICE("You repair the damaged air tank."))
			return ITEM_INTERACT_COMPLETE

		if(mecha.obj_integrity < mecha.max_integrity)
			mecha.obj_integrity += min(20, mecha.max_integrity - mecha.obj_integrity)
			use(1)
			user.visible_message(SPAN_NOTICE("[user] applies some [src] to [mecha]'s damaged areas."),\
			SPAN_NOTICE("You apply some [src] to [mecha]'s damaged areas."))
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/item/stack/nanopaste/proc/robotic_limb_repair(mob/user, obj/item/organ/external/external_limb, mob/living/carbon/human/H)
	if(!external_limb.get_damage())
		to_chat(user, SPAN_NOTICE("Nothing to fix here."))
		return
	use(1)
	var/remaining_heal = 15
	var/new_remaining_heal = 0
	external_limb.heal_damage(robo_repair = TRUE) //should in, theory, heal the robotic organs in just the targeted area with it being external_limb instead of other_external_limb
	var/list/childlist
	if(!isnull(external_limb.children))
		childlist = external_limb.children.Copy()
	var/parenthealed = FALSE
	while(remaining_heal > 0)
		var/obj/item/organ/external/other_external_limb
		if(external_limb.get_damage())
			other_external_limb = external_limb
		else if(LAZYLEN(childlist))
			other_external_limb = pick_n_take(childlist)
			if(!other_external_limb.get_damage() || !other_external_limb.is_robotic())
				continue
		else if(external_limb.parent && !parenthealed)
			other_external_limb = external_limb.parent
			parenthealed = TRUE
			if(!other_external_limb.get_damage() || !other_external_limb.is_robotic())
				break
		else
			break
		new_remaining_heal = max(remaining_heal - other_external_limb.get_damage(), 0)
		other_external_limb.heal_damage(remaining_heal, remaining_heal, FALSE, TRUE)
		remaining_heal = new_remaining_heal
		user.visible_message(SPAN_NOTICE("[user] applies some nanite paste at [H]'s [other_external_limb.name] with [src]."))
	if(H.bleed_rate && ismachineperson(H))
		H.bleed_rate = 0

/obj/item/stack/nanopaste/cyborg
	energy_type = /datum/robot_storage/energy/medical/nanopaste
	is_cyborg = TRUE

/obj/item/stack/nanopaste/cyborg/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(get_amount() <= 0)
		to_chat(user, SPAN_WARNING("You don't have enough energy to dispense more [name]!"))
	else
		return ..()

/obj/item/stack/nanopaste/cyborg/syndicate
	energy_type = /datum/robot_storage/energy/medical/nanopaste/syndicate
