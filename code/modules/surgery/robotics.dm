//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery/cybernetic_repair
	name = "Cybernetic Repair"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/external/repair)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/internal
	name = "Internal Component Manipulation"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/robotics/manipulate_robotic_organs)
	possible_locs = list("eyes", "mouth", "chest","head","groin","l_arm","r_arm")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_amputation
	name = "Robotic Limb Amputation"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = 0

/datum/surgery/cybernetic_repair/can_start(mob/user, mob/living/carbon/target)

	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0
		if(!affected.is_robotic())
			return 0
		return 1

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0
		if(!affected.is_robotic())
			return 0
		if(affected.cannot_amputate)
			return 0
		return 1

//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	can_infect = 0

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(!istype(target))
		return 0
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	return 1

/datum/surgery_step/robotics/external

/datum/surgery_step/robotics/external/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(!..())
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.is_robotic())
		return 0
	return 1

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_UNSCREW_HATCH)

	time = 16

/datum/surgery_step/robotics/external/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return TRUE

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)

	time = 24

/datum/surgery_step/robotics/external/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return 0
		return 1

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'> You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = 2
	return TRUE

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)

	time = 24

/datum/surgery_step/robotics/external/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	return TRUE

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/repair
	name = "repair damage internally"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH, SURGERY_ROBOTIC_HEAL_BRUTE, SURGERY_ROBOTIC_HEAL_BURN)
	time = 32

/datum/surgery_step/robotics/external/repair/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return -1

	if(surgery_behaviour == SURGERY_ROBOTIC_HEAL_BURN)
		var/obj/item/stack/cable_coil/C = tool
		if(!(affected.burn_dam > 0))
			to_chat(user, "<span class='warning'>The [affected] does not have any burn damage!</span>")
			return -1
		if(!istype(C))
			return -1
		if(!C.get_amount() >= 3)
			to_chat(user, "<span class='warning'>You need three or more cable pieces to repair this damage.</span>")
			return -1
		C.use(3)
		user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
		"You begin to splice new cabling into [target]'s [affected.name].")

	else if(surgery_behaviour == SURGERY_ROBOTIC_HEAL_BRUTE)
		if(!(affected.brute_dam > 0 || affected.disfigured))
			to_chat(user, "<span class='warning'>The [affected] does not require welding repair!</span>")
			return -1
		if(tool.tool_behaviour == TOOL_WELDER)
			if(!tool.use(1))
				return -1
		user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
		"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")

	else if(surgery_behaviour == SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	else
		log_runtime(EXCEPTION("Invalid surgery behaviour: '[surgery_behaviour]', tool: '[tool]'"), src)
		return -1
	..()

/datum/surgery_step/robotics/external/repair/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	switch(surgery_behaviour)
		if(SURGERY_ROBOTIC_HEAL_BRUTE)
			user.visible_message("<span class='notice'> [user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
			"<span class='notice'> You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
			affected.heal_damage(rand(30,50),0,1,1)
			affected.disfigured = FALSE
		if(SURGERY_ROBOTIC_HEAL_BURN)
			user.visible_message("<span class='notice'> [user] finishes splicing cable into [target]'s [affected.name].</span>", \
			"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>")
			affected.heal_damage(0,rand(30,50),1,1)
		if(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
			user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
			"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
			affected.open = 0
			return TRUE
	return FALSE

/datum/surgery_step/robotics/external/repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	switch(surgery_behaviour)
		if(SURGERY_ROBOTIC_HEAL_BRUTE)
			user.visible_message("<span class='warning'> [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
			"<span class='warning'> Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
			target.apply_damage(rand(5,10), BURN, affected)
		if(SURGERY_ROBOTIC_HEAL_BURN)
			user.visible_message("<span class='warning'> [user] causes a short circuit in [target]'s [affected.name]!</span>",
			"<span class='warning'> You cause a short circuit in [target]'s [affected.name]!</span>")
			target.apply_damage(rand(5,10), BURN, affected)
		if(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
			user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
			"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return FALSE

///////condenseing remove/extract/repair here.	/////////////
/datum/surgery_step/robotics/manipulate_robotic_organs

	name = "internal part manipulation"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_OPEN_CLOSE_HATCH, SURGERY_IMPLANT_ORGAN_MANIP, SURGERY_ROBOTIC_MEND, SURGERY_ROBOTIC_EXTRACT_ORGAN, SURGERY_ROBOTIC_INSERT_MMI)
	var/obj/item/organ/internal/organ_being_removed = null
	var/obj/item/organ/external/affected = null
	time = 32

/datum/surgery_step/robotics/manipulate_robotic_organs/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	organ_being_removed = null
	affected = target.get_organ(target_zone)
	if(surgery_behaviour == SURGERY_IMPLANT_ORGAN_MANIP)
		var/obj/item/organ/internal/I = tool

		if(!I.is_robotic())
			to_chat(user, "<span class='notice'>You can only implant cybernetic organs.</span>")

		if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
			to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return -1

		if(I.damage > (I.max_damage * 0.75))
			to_chat(user, "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
			return -1

		if(target.get_int_organ(I))
			to_chat(user, "<span class='warning'> \The [target] already has [I].</span>")
			return -1

		user.visible_message("[user] begins reattaching [target]'s [tool].", \
		"You start reattaching [target]'s [tool].")
		target.custom_pain("Someone's rooting around in your [affected.name]!")
	else if(surgery_behaviour == SURGERY_ROBOTIC_INSERT_MMI)
		if(target_zone != "chest")
			to_chat(user, "<span class='notice'> You must target the chest cavity.</span>")

			return -1
		var/obj/item/mmi/M = tool


		if(!affected)
			return -1

		if(!istype(M))
			return -1

		if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
			to_chat(user, "<span class='danger'>That brain is not usable.</span>")
			return -1

		if(!affected.is_robotic())
			to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>")
			return -1

		if(!target.dna.species)
			to_chat(user, "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>")
			return -1

		if(!target.dna.species.has_organ["brain"])
			to_chat(user, "<span class='danger'>You're pretty sure [target.dna.species.name_plural] don't normally have a brain.</span>")
			return -1

		if(target.get_int_organ(/obj/item/organ/internal/brain/))
			to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
			return -1

		user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
		"You start installing \the [tool] into [target]'s [affected.name].")

	else if(surgery_behaviour == SURGERY_ROBOTIC_EXTRACT_ORGAN)
		var/list/organs = target.get_organs_zone(target_zone)
		if(!(affected && affected.is_robotic()))
			return -1
		if(!organs.len)
			to_chat(user, "<span class='notice'>There is no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		else
			for(var/obj/item/organ/internal/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			organ_being_removed = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(organ_being_removed && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
				organ_being_removed = organs[organ_being_removed]
				if(!organ_being_removed) return -1
				user.visible_message("[user] starts to decouple [target]'s [organ_being_removed] with \the [tool].", \
				"You start to decouple [target]'s [organ_being_removed] with \the [tool]." )

				target.custom_pain("The pain in your [affected.name] is living hell!")
			else
				return -1

	else if(surgery_behaviour == SURGERY_ROBOTIC_MEND)
		if(!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		var/found_damaged_organ = FALSE
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage && I.is_robotic())
				user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
				"You start mending the damage to [target]'s [I.name]'s mechanisms.")
				found_damaged_organ = TRUE

		if(!found_damaged_organ)
			to_chat(user, "There are no damaged components in [affected].")
			return -1

		target.custom_pain("The pain in your [affected.name] is living hell!")

	else if(surgery_behaviour == SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
		user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
		"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")

	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(surgery_behaviour == SURGERY_ROBOTIC_MEND)
		if(!hasorgans(target))
			return
		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I && I.damage)
				if(I.is_robotic())
					user.visible_message("<span class='notice'> [user] repairs [target]'s [I.name] with [tool].</span>", \
					"<span class='notice'> You repair [target]'s [I.name] with [tool].</span>" )
					I.damage = 0
					I.surgeryize()
	else if(surgery_behaviour == SURGERY_IMPLANT_ORGAN_MANIP)
		var/obj/item/organ/internal/I = tool

		if(!user.canUnEquip(I, 0))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
			return 0

		user.drop_item()
		I.insert(target)
		user.visible_message("<span class='notice'> [user] has reattached [target]'s [I].</span>" , \
		"<span class='notice'> You have reattached [target]'s [I].</span>")

	else if(surgery_behaviour == SURGERY_ROBOTIC_INSERT_MMI)
		user.visible_message("<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>")

		var/obj/item/mmi/M = tool

		user.unEquip(tool)
		M.attempt_become_organ(affected,target)

	else if(surgery_behaviour == SURGERY_ROBOTIC_EXTRACT_ORGAN)
		if(organ_being_removed && organ_being_removed.owner == target)
			user.visible_message("<span class='notice'> [user] has decoupled [target]'s [organ_being_removed] with \the [tool].</span>" , \
		"<span class='notice'> You have decoupled [target]'s [organ_being_removed] with \the [tool].</span>")

			add_attack_logs(user, target, "Surgically removed [organ_being_removed.name]. INTENT: [uppertext(user.a_intent)]")
			spread_germs_to_organ(organ_being_removed, user)
			var/obj/item/thing = organ_being_removed.remove(target)
			if(!istype(thing))
				thing.forceMove(get_turf(target))
			else
				user.put_in_hands(thing)
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	else if(surgery_behaviour == SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
		affected.open = 0
		affected.germ_level = 0
		return TRUE
	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)

	if(surgery_behaviour == SURGERY_ROBOTIC_MEND)
		if(!hasorgans(target))
			return
		var/obj/item/organ/external/affected = target.get_organ(target_zone)

		user.visible_message("<span class='warning'> [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

		target.adjustToxLoss(5)
		affected.receive_damage(5)

		for(var/obj/item/organ/internal/I in affected.internal_organs)
			if(I)
				I.receive_damage(rand(3,5),0)

	else if(surgery_behaviour == SURGERY_IMPLANT_ORGAN_MANIP)
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if(surgery_behaviour == SURGERY_ROBOTIC_EXTRACT_ORGAN)
		user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	else if(surgery_behaviour == SURGERY_ROBOTIC_INSERT_MMI)
		user.visible_message("<span class='warning'> [user]'s hand slips!</span>.", \
		"<span class='warning'> Your hand slips!</span>")
	else if(surgery_behaviour == SURGERY_ROBOTIC_OPEN_CLOSE_HATCH)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
		"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return FALSE


/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_EXTRACT_ORGAN)

	time = 100

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'> You have decoupled [target]'s [affected.name] with \the [tool].</span>")


	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1,DROPLIMB_SHARP)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)

	return TRUE

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	user.visible_message("<span class='warning'> [user]'s hand slips!</span>", \
	"<span class='warning'> Your hand slips!</span>")
	return FALSE

/datum/surgery/cybernetic_customization
	name = "Cybernetic Appearance Customization"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch, /datum/surgery_step/robotics/external/customize_appearance)
	possible_locs = list("head", "chest", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")
	requires_organic_bodypart = FALSE

/datum/surgery/cybernetic_customization/can_start(mob/user, mob/living/carbon/human/target)
	if(ishuman(target))
		var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
		if(!affected)
			return FALSE
		if(!(affected.status & ORGAN_ROBOT))
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/customize_appearance
	name = "reprogram limb"
	allowed_surgery_behaviours = list(SURGERY_ROBOTIC_REPROGRAM)
	time = 48

/datum/surgery_step/robotics/external/customize_appearance/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to reprogram the appearance of [target]'s [affected.name] with [tool]." , \
	"You begin to reprogram the appearance of [target]'s [affected.name] with [tool].")
	..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/chosen_appearance = input(user, "Select the company appearance for this limb.", "Limb Company Selection") as null|anything in selectable_robolimbs
	if(!chosen_appearance)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.robotize(chosen_appearance, convert_all = FALSE)
	if(istype(affected, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = affected
		head.h_style = "Bald" // nearly all the appearance changes for heads are non-monitors; we want to get rid of a floating screen
		target.update_hair()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	user.visible_message("<span class='notice'> [user] reprograms the appearance of [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'> You reprogram the appearance of [target]'s [affected.name] with [tool].</span>")
	affected.open = 0
	return TRUE

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery, surgery_behaviour)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>")
	return FALSE
