//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery/intermediate/robotics
	requires_bodypart = TRUE
	requires_organic_bodypart = FALSE

/datum/surgery_step/proxy/robotics


/datum/surgery/cybernetic_repair
	name = "Cybernetic Repair"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/robotics/repair_limb,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = FALSE

/datum/surgery/cybernetic_repair/internal
	name = "Internal Component Manipulation"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		// burn/brute are squished into here as well
		/datum/surgery_step/proxy/robotics/manipulate_organs,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list("eyes", "mouth", "chest","head","groin","l_arm","r_arm")
	requires_organic_bodypart = FALSE

/datum/surgery/cybernetic_amputation
	name = "Robotic Limb Amputation"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	requires_organic_bodypart = FALSE

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(affected.limb_flags & CANNOT_DISMEMBER)
			return FALSE
		return TRUE

/datum/surgery/cybernetic_customization
	name = "Cybernetic Appearance Customization"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch, /datum/surgery_step/robotics/external/open_hatch, /datum/surgery_step/robotics/external/customize_appearance)
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


/datum/surgery/intermediate/robotics/repair

/datum/surgery/intermediate/robotics/repair/burn
	steps = list(
		/datum/surgery_step/robotics/external/repair/burn
	)

/datum/surgery/intermediate/robotics/repair/brute
	steps = list(
		/datum/surgery_step/robotics/external/repair/brute
	)

/datum/surgery/intermediate/robotics/manipulate_organs/extract
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/extract)

/datum/surgery/intermediate/robotics/manipulate_organs/implant
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/implant)

/datum/surgery/intermediate/robotics/manipulate_organs/mend
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/mend)
/datum/surgery/intermediate/robotics/manipulate_organs/install_mmi
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi)
	possible_locs = list("chest")


//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	can_infect = FALSE

/datum/surgery_step/robotics/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!istype(target))
		return FALSE
	if(!hasorgans(target))
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return FALSE
	return TRUE

/datum/surgery_step/robotics/external

/datum/surgery_step/robotics/external/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!..())
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	allowed_tools = list(
		TOOL_SCREWDRIVER = 100,
		/obj/item/coin = 50,
		/obj/item/kitchen/knife = 50
	)

	time = 16

/datum/surgery_step/robotics/external/unscrew_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = ORGAN_SYNTHETIC_LOOSENED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 100,
		/obj/item/kitchen/utensil = 50
	)

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/open_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'> You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = ORGAN_SYNTHETIC_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 100,
		/obj/item/kitchen/utensil = 50
	)

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/close_hatch/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	tool.play_tool_sound(target)
	affected.open = ORGAN_CLOSED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return SURGERY_STEP_RETRY



/// The surgery step to trigger this whole situation
/datum/surgery_step/proxy/robotics/repair_limb
	name = "Repair Limb (proxy)"
	branches = list(
		/datum/surgery/intermediate/robotics/repair/burn,
		/datum/surgery/intermediate/robotics/repair/brute
	)

/datum/surgery_step/robotics/external/repair
	name = "repair damage"
	time = 3.2 SECONDS

/datum/surgery_step/robotics/external/repair/burn
	name = "repair burn damage"
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

/datum/surgery_step/robotics/external/repair/burn/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/stack/cable_coil/C = tool
	if(!(affected.burn_dam > 0))
		to_chat(user, "<span class='warning'>\The [affected] does not have any burn damage!</span>")
		return SURGERY_BEGINSTEP_SKIP
	if(!istype(C))
		return SURGERY_BEGINSTEP_SKIP
	if(!C.get_amount() >= 3)
		to_chat(user, "<span class='warning'>You need three or more cable pieces to repair this damage.</span>")
		return SURGERY_BEGINSTEP_SKIP
	C.use(3)
	user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
	"You begin to splice new cabling into [target]'s [affected.name].")



/datum/surgery_step/robotics/external/repair/burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] finishes splicing cable into [target]'s [affected.name].</span>",
		"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>"
	)
	affected.heal_damage(0, rand(30, 50), 1, 1)
	if(affected.burn_dam)
		return SURGERY_STEP_RETRY_ALWAYS
	else
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/repair/burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user] causes a short circuit in [target]'s [affected.name]!</span>",
		"<span class='warning'> You cause a short circuit in [target]'s [affected.name]!</span>"
	)
	target.apply_damage(rand(5, 10), BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/repair/brute
	name = "repair brute damage"
	allowed_tools = list(
		TOOL_WELDER = 100,
		/obj/item/gun/energy/plasmacutter = 50
	)

/datum/surgery_step/robotics/external/repair/brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.brute_dam > 0 || (affected.status & ORGAN_DISFIGURED)))
		to_chat(user, "<span class='warning'>\The [affected] does not require welding repair!</span>")
		return SURGERY_BEGINSTEP_SKIP
	if(tool.tool_behaviour == TOOL_WELDER)
		if(!tool.use(1))
			return SURGERY_BEGINSTEP_SKIP
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
	"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")

/datum/surgery_step/robotics/external/repair/brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>",
		"<span class='notice'> You finish patching damage to [target]'s [affected.name] with \the [tool].</span>"
	)
	affected.heal_damage(rand(30, 50), 0, 1, 1)
	affected.status &= ~ORGAN_DISFIGURED
	if(affected.brute_dam)
		// Keep trying until there's nothing left to patch up.
		return SURGERY_STEP_RETRY_ALWAYS
	else
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/repair/brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
		"<span class='warning'> Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>"
	)
	target.apply_damage(rand(5, 10), BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/proxy/robotics/manipulate_organs
	name = "manipulate robotic organs (proxy)"

	branches = list(
		/datum/surgery/intermediate/robotics/manipulate_organs/extract,
		/datum/surgery/intermediate/robotics/manipulate_organs/implant,
		/datum/surgery/intermediate/robotics/manipulate_organs/install_mmi,
		/datum/surgery/intermediate/robotics/manipulate_organs/mend,
		/datum/surgery/intermediate/robotics/repair/brute,
		/datum/surgery/intermediate/robotics/repair/burn
	)


/datum/surgery_step/robotics/manipulate_robotic_organs
	time = 3.2 SECONDS


/datum/surgery_step/robotics/manipulate_robotic_organs/mend
	name = "Mend cybernetic organs"
	allowed_tools = list(
		/obj/item/stack/nanopaste = 100,
		TOOL_BONEGEL = 30,
		TOOL_SCREWDRIVER = 70
	)

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
		return SURGERY_BEGINSTEP_SKIP

	target.custom_pain("The pain in your [affected.name] is living hell!")


/datum/surgery_step/robotics/manipulate_robotic_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage)
			if(I.is_robotic())
				user.visible_message("<span class='notice'> [user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'> You repair [target]'s [I.name] with [tool].</span>" )
				I.damage = 0
				I.surgeryize()
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/implant
	name = "Implant cybernetic organ"
	allowed_tools = list(
		/obj/item/organ/internal = 100
	)

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool

	if(!I.is_robotic())
		to_chat(user, "<span class='notice'>You can only implant cybernetic organs.</span>")

	if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
		to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(I.damage > (I.max_damage * 0.75))
		to_chat(user, "<span class='notice'> \The [I] is in no state to be transplanted.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(I))
		to_chat(user, "<span class='warning'> \The [target] already has [I].</span>")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message("[user] begins reattaching [target]'s [tool].", \
	"You start reattaching [target]'s [tool].")
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	target.custom_pain("Someone's rooting around in your [affected.name]!")
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool

	if(!user.canUnEquip(I, 0))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return SURGERY_STEP_INCOMPLETE

	user.drop_item()
	I.insert(target)
	user.visible_message("<span class='notice'> [user] has reattached [target]'s [I].</span>" , \
	"<span class='notice'> You have reattached [target]'s [I].</span>")
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")
	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/extract
	name = "extract cybernetic organ"
	allowed_tools = list(TOOL_MULTITOOL = 100)
	var/obj/item/organ/internal/I

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/list/organs = target.get_organs_zone(target_zone)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected && affected.is_robotic()))
		return SURGERY_BEGINSTEP_SKIP
	if(!length(organs))
		to_chat(user, "<span class='notice'>There is no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_BEGINSTEP_SKIP
	else
		for(var/obj/item/organ/internal/O in organs)
			O.on_find(user)
			organs -= O
			organs[O.name] = O

		I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
		if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
			I = organs[I]
			if(!I)
				return SURGERY_BEGINSTEP_SKIP
			user.visible_message("[user] starts to decouple [target]'s [I] with \the [tool].", \
			"You start to decouple [target]'s [I] with \the [tool]." )

			target.custom_pain("The pain in your [affected.name] is living hell!")
		else
			return SURGERY_BEGINSTEP_SKIP

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!I || I.owner != target)
		user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		"<span class='notice'> [user] has decoupled [target]'s [I] with \the [tool].</span>" ,
		"<span class='notice'> You have decoupled [target]'s [I] with \the [tool].</span>"
	)

	add_attack_logs(user, target, "Surgically removed [I.name]. INTENT: [uppertext(user.a_intent)]")
	spread_germs_to_organ(I, user)
	var/obj/item/thing = I.remove(target)
	if(!istype(thing))
		thing.forceMove(get_turf(target))
	else
		user.put_in_hands(thing)
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")

	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi
	name = "insert robotic brain"
	allowed_tools = list(/obj/item/mmi = 100)

/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target_zone != "chest")
		to_chat(user, "<span class='notice'> You must target the chest cavity.</span>")

		return SURGERY_BEGINSTEP_SKIP

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/mmi/M = tool

	if(!affected)
		return SURGERY_BEGINSTEP_SKIP

	if(!istype(M))
		return SURGERY_BEGINSTEP_SKIP

	if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
		to_chat(user, "<span class='danger'>That brain is not usable.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(!affected.is_robotic())
		to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(!target.dna.species)
		to_chat(user, "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>")
		return SURGERY_BEGINSTEP_ABORT

	if(!target.dna.species.has_organ["brain"])
		to_chat(user, "<span class='danger'>You're pretty sure [target.dna.species.name_plural] don't normally have a brain.</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(/obj/item/organ/internal/brain))
		to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message("[user] starts installing \the [tool] into [target]'s [affected.name].", \
	"You start installing \the [tool] into [target]'s [affected.name].")


/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>",
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>"
	)

	var/obj/item/mmi/M = tool

	user.unEquip(tool)
	M.attempt_become_organ(affected,target)
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips!</span>.",
		"<span class='warning'> Your hand slips!</span>")
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"

	allowed_tools = list(
		TOOL_MULTITOOL = 100
	)

	time = 10 SECONDS

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'> You have decoupled [target]'s [affected.name] with \the [tool].</span>")


	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1, DROPLIMB_SHARP)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)

	user.visible_message("<span class='warning'> [user]'s hand slips!</span>", \
	"<span class='warning'> Your hand slips!</span>")
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/customize_appearance
	name = "reprogram limb"
	allowed_tools = list(TOOL_MULTITOOL = 100)
	time = 4.8 SECONDS

/datum/surgery_step/robotics/external/customize_appearance/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(..())
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		if(!affected)
			return FALSE
		return TRUE

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to reprogram the appearance of [target]'s [affected.name] with [tool]." , \
	"You begin to reprogram the appearance of [target]'s [affected.name] with [tool].")
	..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/chosen_appearance = input(user, "Select the company appearance for this limb.", "Limb Company Selection") as null|anything in GLOB.selectable_robolimbs
	if(!chosen_appearance)
		return SURGERY_STEP_INCOMPLETE
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
	affected.open = ORGAN_CLOSED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>")
	return SURGERY_STEP_RETRY
