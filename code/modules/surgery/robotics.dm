//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/robotics/
	can_infect = 0
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (isslime(target))
			return 0
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		if (!(affected.status & ORGAN_ROBOT))
			return 0
		return 1

/datum/surgery_step/robotics/unscrew_hatch
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
		/obj/item/weapon/coin = 50,
		/obj/item/weapon/kitchen/utensil/knife = 50
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			return affected && affected.open == 0 && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
		"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
		"\blue You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].",)
		affected.open = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].", \
		"\red Your [tool] slips, failing to unscrew [target]'s [affected.name].")

/datum/surgery_step/robotics/open_hatch
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil/ = 50
	)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			return affected && affected.open == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
		"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
		 "\blue You open the maintenance hatch on [target]'s [affected.name] with \the [tool]." )
		affected.open = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].",
		"\red Your [tool] slips, failing to open the hatch on [target]'s [affected.name].")

/datum/surgery_step/robotics/close_hatch
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil = 50
	)

	min_duration = 70
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			return affected && affected.open && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].", \
		"\blue You close and secure the hatch on [target]'s [affected.name] with \the [tool].")
		affected.open = 0
		affected.germ_level = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].",
		"\red Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].")

/datum/surgery_step/robotics/repair_brute
	allowed_tools = list(
		/obj/item/weapon/weldingtool = 100,
		/obj/item/weapon/gun/energy/plasmacutter = 50
	)

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			if(istype(tool,/obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/welder = tool
				if(!welder.isOn() || !welder.remove_fuel(1,user))
					return 0
			return affected && affected.open == 2 && affected.brute_dam > 0 && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
		"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] finishes patching damage to [target]'s [affected.name] with \the [tool].", \
		"\blue You finish patching damage to [target]'s [affected.name] with \the [tool].")
		affected.heal_damage(rand(30,50),0,1,1)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].",
		"\red Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].")
		target.apply_damage(rand(5,10), BURN, affected)

/datum/surgery_step/robotics/repair_burn
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if(..())
			var/obj/item/stack/cable_coil/C = tool
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			var/limb_can_operate = (affected && affected.open == 2 && affected.burn_dam > 0 && target_zone != "mouth")
			if(limb_can_operate)
				if(istype(C))
					if(!C.get_amount() >= 3)
						user << "<span class='warning'>You need three or more cable pieces to repair this damage.</span>"
						return 2
					C.use(3)
				return 1
			return 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
		"You begin to splice new cabling into [target]'s [affected.name].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] finishes splicing cable into [target]'s [affected.name].", \
		"\blue You finishes splicing new cable into [target]'s [affected.name].")
		affected.heal_damage(0,rand(30,50),1,1)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\red [user] causes a short circuit in [target]'s [affected.name]!",
		"\red You cause a short circuit in [target]'s [affected.name]!")
		target.apply_damage(rand(5,10), BURN, affected)

/datum/surgery_step/robotics/fix_organ_robotic //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,		\
	/obj/item/weapon/bonegel = 30, 		\
	/obj/item/weapon/screwdriver = 70,	\
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected) return
		var/is_organ_damaged = 0
		for(var/obj/item/organ/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic >= 2)
				is_organ_damaged = 1
				break
		return affected.open == 2 && is_organ_damaged

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
					"You start mending the damage to [target]'s [I.name]'s mechanisms." )

		target.custom_pain("The pain in your [affected.name] is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/I in affected.internal_organs)

			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("\blue [user] repairs [target]'s [I.name] with [tool].", \
					"\blue You repair [target]'s [I.name] with [tool]." )
					I.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("\red [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!", \
		"\red Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!")

		target.adjustToxLoss(5)
		affected.createwound(CUT, 5)

		for(var/obj/item/organ/I in affected.internal_organs)
			if(I)
				I.take_damage(rand(3,5),0)

/datum/surgery_step/robotics/detatch_organ_robotic

	allowed_tools = list(
	/obj/item/device/multitool = 100
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!(affected && (affected.status & ORGAN_ROBOT)))
			return 0
		if(affected.open != 2)
			return 0

		target.op_stage.current_organ = null

		var/list/attached_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/obj/item/organ/I = target.internal_organs_by_name[organ]
			if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
				attached_organs |= organ

		var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
		if(!organ_to_remove)
			return 0

		target.op_stage.current_organ = organ_to_remove

		return ..() && organ_to_remove

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] starts to decouple [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"You start to decouple [target]'s [target.op_stage.current_organ] with \the [tool]." )
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has decoupled [target]'s [target.op_stage.current_organ] with \the [tool]." , \
		"\blue You have decoupled [target]'s [target.op_stage.current_organ] with \the [tool].")

		var/obj/item/organ/I = target.internal_organs_by_name[target.op_stage.current_organ]
		if(I && istype(I))
			I.status |= ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, disconnecting \the [tool].", \
		"\red Your hand slips, disconnecting \the [tool].")

/datum/surgery_step/robotics/attach_organ_robotic
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
	)

	min_duration = 100
	max_duration = 120

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!(affected && (affected.status & ORGAN_ROBOT)))
			return 0
		if(affected.open != 2)
			return 0

		target.op_stage.current_organ = null

		var/list/removable_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/obj/item/organ/I = target.internal_organs_by_name[organ]
			if(I && (I.status & ORGAN_CUT_AWAY) && (I.status & ORGAN_ROBOT) && I.parent_organ == target_zone)
				removable_organs |= organ

		var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
		if(!organ_to_replace)
			return 0

		target.op_stage.current_organ = organ_to_replace
		return ..()

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
		"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\blue [user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool]." , \
		"\blue You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].")

		var/obj/item/organ/I = target.internal_organs_by_name[target.op_stage.current_organ]
		if(I && istype(I))
			I.status &= ~ORGAN_CUT_AWAY

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips, disconnecting \the [tool].", \
		"\red Your hand slips, disconnecting \the [tool].")

/datum/surgery_step/robotics/install_mmi
	allowed_tools = list(
	/obj/item/device/mmi = 100
	)

	min_duration = 60
	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

		if(target_zone != "head")
			return

		var/obj/item/device/mmi/M = tool
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!(affected && affected.open == 2))
			return 0

		if(!istype(M))
			return 0

		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			user << "<span class='danger'>That brain is not usable.</span>"
			return 2

		if(!(affected.status & ORGAN_ROBOT))
			user << "<span class='danger'>You cannot install a computer brain into a meat skull.</span>"
			return 2

		if(!target.species)
			user << "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>"
			return 2

		if(!target.species.has_organ["brain"])
			user << "<span class='danger'>You're pretty sure [target.species.name_plural] don't normally have a brain.</span>"
			return 2

		if(!isnull(target.internal_organs["brain"]))
			user << "<span class='danger'>Your subject already has a brain.</span>"
			return 2

		return 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
		"You start installing \the [tool] into [target]'s [affected.name].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("\blue [user] has installed \the [tool] into [target]'s [affected.name].", \
		"\blue You have installed \the [tool] into [target]'s [affected.name].")

		var/obj/item/device/mmi/M = tool
		var/obj/item/organ/mmi_holder/holder = new(target, 1)
		target.internal_organs_by_name["brain"] = holder
		user.unEquip(tool)
		tool.loc = holder
		holder.stored_mmi = tool
		holder.update_from_mmi()

		if(M.brainmob && M.brainmob.mind)
			M.brainmob.mind.transfer_to(target)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("\red [user]'s hand slips.", \
		"\red Your hand slips.")