//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery/cybernetic_repair
	name = "Cybernetic Repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/repair_brute,/datum/surgery_step/robotics/external/repair_burn,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/internal
	name = "Internal Cybernetic Mainpulation"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/manipulate_robotic_organs)
	possible_locs = list("chest","head","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_amputation
	name = "robotic limb amputation"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/can_start(mob/user, mob/living/carbon/target)

	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(!(affected.status & ORGAN_ROBOT))
			return 0
		return 1

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target)

	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(!(affected.status & ORGAN_ROBOT))
			return 0
		return 1

//to do, moar surgerys or condense down ala mainpulate organs.
/datum/surgery_step/robotics
	can_infect = 0

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
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
	return 1

/datum/surgery_step/robotics/external

/datum/surgery_step/robotics/external/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if (!..())
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (!(affected.status & ORGAN_ROBOT))
		return 0
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	allowed_tools = list(
		/obj/item/weapon/screwdriver = 100,
		/obj/item/weapon/coin = 50,
		/obj/item/weapon/kitchen/knife = 50
	)

	max_duration = 110

/datum/surgery_step/robotics/external/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == 0 && target_zone != "mouth"

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil/ = 50
	)

	max_duration = 40

/datum/surgery_step/robotics/external/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open == 1

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'> You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = 2
	return 1

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 100,
		/obj/item/weapon/kitchen/utensil = 50
	)

	max_duration = 100

/datum/surgery_step/robotics/external/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && affected.open && target_zone != "mouth"

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0
	return 1

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return 0

/datum/surgery_step/robotics/external/repair_brute
	name = "Repair brute damage"
	allowed_tools = list(
		/obj/item/weapon/weldingtool = 100,
		/obj/item/weapon/gun/energy/plasmacutter = 50
	)

	max_duration = 60

/datum/surgery_step/robotics/external/repair_brute/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(istype(tool,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/welder = tool
			if(!welder.isOn() || !welder.remove_fuel(1,user))
				return 0
		return affected && affected.open == 2 && (affected.brute_dam > 0 || affected.disfigured)&& target_zone != "mouth"

/datum/surgery_step/robotics/external/repair_brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")
	..()

/datum/surgery_step/robotics/external/repair_brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
	affected.heal_damage(rand(30,50),0,1,1)
	if(affected.disfigured)
		affected.disfigured = 0
		affected.update_icon()
		target.regenerate_icons()
	return 1

/datum/surgery_step/robotics/external/repair_brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
	target.apply_damage(rand(5,10), BURN, affected)
	return 0

/datum/surgery_step/robotics/external/repair_burn
	name = "repair heat damage"
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

	max_duration = 60

/datum/surgery_step/robotics/external/repair_burn/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
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

/datum/surgery_step/robotics/external/repair_burn/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
	"You begin to splice new cabling into [target]'s [affected.name].")
	..()

/datum/surgery_step/robotics/external/repair_burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] finishes splicing cable into [target]'s [affected.name].</span>", \
	"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>")
	affected.heal_damage(0,rand(30,50),1,1)
	return 1

/datum/surgery_step/robotics/external/repair_burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user] causes a short circuit in [target]'s [affected.name]!</span>",
	"<span class='warning'> You cause a short circuit in [target]'s [affected.name]!</span>")
	target.apply_damage(rand(5,10), BURN, affected)
	return 0

///////condenseing remove/extract/repair here.	/////////////
/datum/surgery_step/robotics/manipulate_robotic_organs

	name = "internal part mainpulation"
	allowed_tools = list(/obj/item/device/mmi = 100)
	var/implements_extract = list(/obj/item/device/multitool = 100)
	var/implements_mend = list(	/obj/item/stack/nanopaste = 100,/obj/item/weapon/bonegel = 30, /obj/item/weapon/screwdriver = 70)
	var/implements_insert = list(/obj/item/weapon/screwdriver = 100)
	var/implements_finish =list(/obj/item/weapon/retractor = 100,/obj/item/weapon/crowbar = 100,/obj/item/weapon/kitchen/utensil = 50)
	var/current_type
	var/obj/item/organ/internal/I = null
	var/obj/item/organ/external/affected = null
	max_duration = 90

/datum/surgery_step/robotics/manipulate_robotic_organs/New()
	..()
	allowed_tools = allowed_tools + implements_extract + implements_mend + implements_insert + implements_finish




/datum/surgery_step/robotics/manipulate_robotic_organs/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	I = null
	affected = target.get_organ(target_zone)
	if(implement_type in implements_insert)
		current_type = "insert"
		//I = tool
		var/off_tool = user.get_inactive_hand()

		if(!off_tool || !istype(off_tool,/obj/item/organ/internal))
			user << "<span class='notice'>You need a replacement internal part in your off hand.</span>"
			return -1
		I = off_tool //and please god let it be an organ...
		if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
			user << "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>"
			return -1

		if(I.damage > (I.max_damage * 0.75))
			user << "<span class='notice'> \The [I] is in no state to be transplanted.</span>"
			return -1

		if(target.get_int_organ(I))
			user << "<span class='warning'> \The [target] already has [I].</span>"
			return -1

		user.visible_message("[user] begins reattaching [target]'s [off_tool] with \the [tool].", \
		"You start reattaching [target]'s [off_tool] with \the [tool].")
		target.custom_pain("Someone's rooting around in your [affected.name]!",1)
	else if(istype(tool,/obj/item/device/mmi))
		current_type = "install"

		if(target_zone != "chest")
			user << "<span class='notice'> You must target the chest cavity.</span>"

			return -1
		var/obj/item/device/mmi/M = tool


		if(!(affected && affected.open_enough_for_surgery()))
			return -1

		if(!istype(M))
			return -1

		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			user << "<span class='danger'>That brain is not usable.</span>"
			return -1

		if(!(affected.status & ORGAN_ROBOT))
			user << "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>"
			return -1

		if(!target.species)
			user << "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>"
			return -1

		if(!target.species.has_organ["brain"])
			user << "<span class='danger'>You're pretty sure [target.species.name_plural] don't normally have a brain.</span>"
			return -1

		if(target.get_int_organ(/obj/item/organ/internal/brain/))
			user << "<span class='danger'>Your subject already has a brain.</span>"
			return -1

		user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
		"You start installing \the [tool] into [target]'s [affected.name].")

	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.get_organs_zone(target_zone)
		if(!(affected && (affected.status & ORGAN_ROBOT)))
			return -1
		if(!affected.open_enough_for_surgery())
			return -1
		if(!organs.len)
			user << "<span class='notice'>There is no removeable organs in [target]'s [parse_zone(target_zone)]!</span>"
			return -1
		else
			for(var/obj/item/organ/internal/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
				I = organs[I]
				if(!I) return -1
				user.visible_message("[user] starts to decouple [target]'s [I] with \the [tool].", \
				"You start to decouple [target]'s [I] with \the [tool]." )

				target.custom_pain("The pain in your [affected.name] is living hell!",1)
			else
				return -1

	else if(implement_type in implements_mend)
		current_type = "mend"
		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
					"You start mending the damage to [target]'s [I.name]'s mechanisms." )

		target.custom_pain("The pain in your [affected.name] is living hell!",1)

	else if(implement_type in implements_finish)
		current_type = "finish"
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")


	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(current_type == "mend")

		if (!hasorgans(target))
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage > 0)
				if(I.robotic >= 2)
					user.visible_message("<span class='notice'> [user] repairs [target]'s [I.name] with [tool].</span>", \
					"<span class='notice'> You repair [target]'s [I.name] with [tool].</span>" )
					I.damage = 0
	else if(current_type == "insert")
		var/obj/item/organ/internal/I = target.get_int_organ(surgery.current_organ)

		var/off_tool = user.get_inactive_hand()
		I = off_tool
		//user.drop_item()
		I.insert(target)
		user.visible_message("<span class='notice'> [user] has reattached [target]'s [I] with \the [tool].</span>" , \
		"<span class='notice'> You have reattached [target]'s [I] with \the [tool].</span>")

		if(I && istype(I))
			I.status &= ~ORGAN_CUT_AWAY
		qdel(off_tool)
	else if (current_type == "install")
		user.visible_message("<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>")

		var/obj/item/device/mmi/M = tool
		var/obj/item/organ/internal/brain/mmi_holder/holder = new()
		if (istype(M, /obj/item/device/mmi/posibrain))
			holder.robotize()

		holder.insert(target)
		user.unEquip(tool)
		tool.forceMove(holder)
		holder.stored_mmi = tool
		holder.update_from_mmi()

		if(M.brainmob && M.brainmob.mind)
			M.brainmob.mind.transfer_to(target)

	else if(current_type == "extract")
		if(I && I.owner == target)
			user.visible_message("<span class='notice'> [user] has decoupled [target]'s [surgery.current_organ] with \the [tool].</span>" , \
		"<span class='notice'> You have decoupled [target]'s [surgery.current_organ] with \the [tool].</span>")

			add_logs(target,user, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			spread_germs_to_organ(I, user)
			I.status |= ORGAN_CUT_AWAY
			I.remove(target)
			I.loc = get_turf(target)
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	else if(current_type == "finish")
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
		affected.open = 0
		affected.germ_level = 0
		return 1
	return 0

/datum/surgery_step/robotics/manipulate_robotic_organs/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	if(current_type == "mend")
		if (!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("<span class='warning'> [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

		target.adjustToxLoss(5)
		affected.createwound(CUT, 5)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.take_damage(rand(3,5),0)

	else if(current_type == "insert")
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if(current_type == "extract")
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if (current_type == "install")
		user.visible_message("<span class='warning'> [user]'s hand slips!</span>.", \
		"<span class='warning'> Your hand slips!</span>")
	else if(current_type == "finish")
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
		"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return -1



/datum/surgery_step/robotics/install_mmi
	allowed_tools = list(
	/obj/item/device/mmi = 100
	)

	max_duration = 80

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

		if(target_zone != "chest")
			return 0

		var/obj/item/device/mmi/M = tool
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!(affected && affected.open_enough_for_surgery()))
			return 0

		if(!istype(M))
			return 0

		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			user << "<span class='danger'>That brain is not usable.</span>"
			return 2

		if(!(affected.status & ORGAN_ROBOT))
			user << "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>"
			return 2

		if(!target.species)
			user << "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>"
			return 2

		if(!target.species.has_organ["brain"])
			user << "<span class='danger'>You're pretty sure [target.species.name_plural] don't normally have a brain.</span>"
			return 2

		if(target.get_int_organ(/obj/item/organ/internal/brain/))
			user << "<span class='danger'>Your subject already has a brain.</span>"
			return 2

		return 1

	begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
		"You start installing \the [tool] into [target]'s [affected.name].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>")

		var/obj/item/device/mmi/M = tool
		var/obj/item/organ/internal/brain/mmi_holder/holder = new()
		if (istype(M, /obj/item/device/mmi/posibrain))
			holder.robotize()

		holder.insert(target)
		user.unEquip(tool)
		tool.forceMove(holder)
		holder.stored_mmi = tool
		holder.update_from_mmi()

		if(M.brainmob && M.brainmob.mind)
			M.brainmob.mind.transfer_to(target)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("<span class='warning'> [user]'s hand slips.</span>", \
		"<span class='warning'> Your hand slips.</span>")

/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"

	allowed_tools = list(
	/obj/item/device/multitool = 100)

	max_duration = 110

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!",1)
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'> You have decoupled [target]'s [affected.name] with \the [tool].</span>")


	add_logs(target,user ,"surgically removed [affected.name] from", addition="INTENT: [uppertext(user.a_intent)]")//log it

	affected.droplimb(1,DROPLIMB_EDGE)
	return 1

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='warning'> [user]'s hand slips!</span>", \
	"<span class='warning'> Your hand slips!</span>")
	return 0