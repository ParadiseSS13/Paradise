//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////
//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	priority = 10
	pain = FALSE
	requires_organic_bodypart = FALSE

/datum/surgery_step/robotics/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/robotics/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.is_robotic())
		return FALSE
	return TRUE

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "unscrew hatch"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	allowed_surgery_tools = SURGERY_TOOLS_UNSCREW_HATCH

	time = 1.6 SECONDS

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts unscrewing the maintenance hatch on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You start unscrewing the maintenance hatch on [target]'s [affected.name] with [tool].</span>")
	return ..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You open the maintenance hatch on [target]'s [affected.name] with [tool].</span>")
	affected.cut_level = SURGERY_CUT_LEVEL_SHALLOW
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/screw_hatch
	name = "screw hatch"
	priority = -1 // Same as cauterise really
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_tools = SURGERY_TOOLS_UNSCREW_HATCH

	time = 1.6 SECONDS

/datum/surgery_step/robotics/external/screw_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts unscrewing maintenance hatch on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You start unscrewing the maintenance hatch on [target]'s [affected.name] with [tool].</span>")
	return ..()

/datum/surgery_step/robotics/external/screw_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] closes the maintenance hatch on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You close the maintenance hatch on [target]'s [affected.name] with [tool].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/screw_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to screw [target]'s [affected.name].</span>", \
	"<span class='warning'>Your [tool] slips, failing to screw [target]'s [affected.name].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_surgery_tools = SURGERY_TOOLS_OPEN_CLOSE_HATCH
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] starts prying the maintenance hatch on [target]'s [affected.name] open with [tool].</span>",
	"<span class='notice'>You start prying the maintenance hatch on [target]'s [affected.name] open with [tool].</span>")
	return ..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] opens the maintenance hatch on [target]'s [affected.name] with [tool].</span>", \
	 "<span class='notice'>You open the maintenance hatch on [target]'s [affected.name] with [tool].</span>")
	affected.cut_level = SURGERY_CUT_LEVEL_OPEN
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_surgery_tools = SURGERY_TOOLS_OPEN_CLOSE_HATCH
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_START

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] begins closing and securing the hatch on [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You begin closing and securing the hatch on [target]'s [affected.name] with [tool].</span>")
	return ..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'>You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/repair
	name = "repair internal damage"
	priority = 15
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	allowed_surgery_tools = SURGERY_TOOLS_ROBOTIC_REPAIR
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	time = 3.2 SECONDS

/datum/surgery_step/robotics/external/repair/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/success = FALSE

	if(TOOL_WELDER == tool.tool_behaviour || istype(tool, /obj/item/gun/energy/plasmacutter))
		if(affected.brute_dam <= 0 && !affected.disfigured)
			to_chat(user, "<span class='warning'>\The [affected] does not require welding repair!</span>")
		else
			var/obj/item/weldingtool/W = tool
			if(W && !tool.use(1))
				return SURGERY_FAILED // Still an early return here
			user.visible_message("<span class='notice'>[user] begins patching damage to [target]'s [affected.name]'s support structure with \the [tool].</span>", \
				"<span class='notice'>You begin patching damage to [target]'s [affected.name]'s support structure with \the [tool].</span>")
			success = TRUE

	if(istype(tool, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = tool
		if(affected.burn_dam <= 0)
			to_chat(user, "<span class='warning'>\The [affected] does not have any burn damage!</span>")
		else
			if(C.get_amount() < 4) // 4 because else the stack will disappear after you use 3
				to_chat(user, "<span class='warning'>You need four or more cable pieces to repair this damage.</span>")
			else
				C.use(3)
				user.visible_message("<span class='notice'>[user] begins splicing new cabling into [target]'s [affected.name].</span>", \
					"<span class='notice'>You begin splicing new cabling into [target]'s [affected.name].</span>")
				success = TRUE

	if(!success)
		return SURGERY_FAILED
	return ..()

/datum/surgery_step/robotics/external/repair/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/continue_repairing = FALSE
	if(TOOL_WELDER == tool.tool_behaviour || istype(tool, /obj/item/gun/energy/plasmacutter))
		user.visible_message("<span class='notice'>[user] patches damage to [target]'s [affected.name] with [tool].</span>", \
			"<span class='notice'>You patch damage to [target]'s [affected.name] with [tool].</span>")
		affected.heal_damage(rand(30, 50), 0, TRUE, TRUE)
		affected.disfigured = FALSE
		continue_repairing = affected.brute_dam > 0

	var/obj/item/stack/cable_coil/C = tool
	if(istype(C))
		user.visible_message("<span class='notice'>[user] finishes splicing cable into [target]'s [affected.name].</span>", \
			"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>")
		affected.heal_damage(0, rand(30, 50), TRUE, TRUE)
		continue_repairing = continue_repairing || affected.burn_dam > 0

	return continue_repairing ? SURGERY_CONTINUE : SURGERY_SUCCESS

/datum/surgery_step/robotics/external/repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(TOOL_WELDER == tool.tool_behaviour || istype(tool, /obj/item/gun/energy/plasmacutter))
		user.visible_message("<span class='warning'>[user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
				"<span class='warning'>Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")

	if(istype(tool, /obj/item/stack/cable_coil))
		user.visible_message("<span class='warning'>[user] causes a short circuit in [target]'s [affected.name]!</span>",
			"<span class='warning'>You cause a short circuit in [target]'s [affected.name]!</span>")

	target.apply_damage(rand(5, 10), BURN, affected)

	return SURGERY_FAILED

///////condenseing remove/extract/repair here.	/////////////
/datum/surgery_step/robotics/manipulate_robotic_organs
	name = "internal part manipulation"
	priority = 15
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	possible_locs = list("eyes", "mouth", "chest","head","groin","l_arm","r_arm")
	time = 3.2 SECONDS

/datum/surgery_step/robotics/manipulate_robotic_organs/implant
	name = "implant internal part"
	accept_any_item = TRUE // can_use will check if it's an organ or not

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	if(!istype(tool, /obj/item/organ/internal))
		return FALSE
	var/obj/item/organ/internal/I = tool
	return I.is_robotic()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return SURGERY_FAILED
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/organ/internal/I = tool

	if(!I.is_robotic())
		to_chat(user, "<span class='notice'>You can only implant cybernetic organs.</span>")
		return SURGERY_FAILED

	if(target_zone != I.parent_organ || target.get_organ_slot(I.slot))
		to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_FAILED

	if(I.damage > (I.max_damage * 0.75))
		to_chat(user, "<span class='notice'>[I] is in no state to be transplanted.</span>")
		return SURGERY_FAILED

	if(target.get_int_organ(I))
		to_chat(user, "<span class='warning'>[target] already has [I].</span>")
		return SURGERY_FAILED

	user.visible_message("<span class='notice'>[user] begins attaching [tool] inside [target].</span>", \
	"<span class='notice'>You start attaching [tool] inside [target].</span>")
	target.custom_pain("Someone's rooting around in your [affected.name]!")
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool

	if(!user.canUnEquip(I))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return SURGERY_FAILED

	user.drop_item()
	I.insert(target)
	user.visible_message("<span class='notice'>[user] attaches [I] inside [target].</span>", \
	"<span class='notice'>You attach [I] inside [target].</span>")

	return SURGERY_SUCCESS

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/manipulate_robotic_organs/mend
	name = "mend internal part"
	allowed_surgery_tools = SURGERY_TOOLS_ROBOTIC_MEND_ORGAN

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/found_damaged_organ = FALSE
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage && I.is_robotic())
			user.visible_message("<span class='notice'>[user] starts mending the damage to [target]'s [I.name]'s mechanisms.</span>", \
			"<span class='notice'>You start mending the damage to [target]'s [I.name]'s mechanisms.</span>")
			found_damaged_organ = TRUE

	if(!found_damaged_organ)
		to_chat(user, "<span class='notice'>There are no damaged components in [affected].</span>")
		return SURGERY_FAILED

	target.custom_pain("The pain in your [affected.name] is living hell!")
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I?.damage && I.is_robotic())
			user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
			"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>")
			I.damage = 0
			I.surgeryize()
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with [tool]!</span>")

	target.adjustToxLoss(5)
	affected.receive_damage(5)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I)
			I.receive_damage(rand(3, 5), 0)

	return SURGERY_FAILED

/datum/surgery_step/robotics/manipulate_robotic_organs/extract
	name = "extract internal part"
	allowed_surgery_tools = SURGERY_TOOLS_ROBOTIC_REMOVE_ORGAN
	var/obj/item/organ/internal/organ_being_removed = null

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	organ_being_removed = null
	var/list/organs = target.get_organs_zone(target_zone)
	if(!length(organs))
		to_chat(user, "<span class='notice'>There are no removable organs in [target]'s [parse_zone(target_zone)]!</span>")
		return SURGERY_FAILED
	else
		for(var/obj/item/organ/internal/O in organs)
			O.on_find(user)
			organs -= O
			organs[O.name] = O

		organ_being_removed = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
		if(organ_being_removed && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
			organ_being_removed = organs[organ_being_removed]
			if(!organ_being_removed)
				return SURGERY_FAILED
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			user.visible_message("<span class='notice'>[user] starts decoupling [target]'s [organ_being_removed] with [tool].</span>", \
			"<span class='notice'>You start decoupling [target]'s [organ_being_removed] with [tool].</span>")

			target.custom_pain("The pain in your [affected.name] is living hell!")
		else
			return SURGERY_FAILED

	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(organ_being_removed?.owner == target)
		user.visible_message("<span class='notice'>[user] decouples [target]'s [organ_being_removed] with [tool].</span>", \
			"<span class='notice'>You decouple [target]'s [organ_being_removed] with [tool].</span>")

		add_attack_logs(user, target, "Surgically removed [organ_being_removed.name]. INTENT: [uppertext(user.a_intent)]")
		spread_germs_to_organ(organ_being_removed, user)
		var/obj/item/thing = organ_being_removed.remove(target)
		if(!istype(thing))
			thing.forceMove(get_turf(target))
		else
			user.put_in_hands(thing)
	else
		user.visible_message("<span class='notice'>[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, disconnecting [tool].</span>", \
		"<span class='warning'>Your hand slips, disconnecting [tool].</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi
	name = "insert MMI"
	accept_any_item = TRUE
	possible_locs = list("chest")

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/mmi/tool, datum/surgery/surgery)
	if(!..())
		return FALSE

	if(!istype(tool))
		return FALSE
	return TRUE

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/mmi/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!tool.brainmob || !tool.brainmob.client || !tool.brainmob.ckey || tool.brainmob.stat >= DEAD)
		to_chat(user, "<span class='danger'>That brain is not usable.</span>")
		return SURGERY_FAILED

	if(!affected.is_robotic())
		to_chat(user, "<span class='danger'>You cannot install a computer brain into a meat enclosure.</span>")
		return SURGERY_FAILED

	if(!target.dna.species)
		to_chat(user, "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>")
		return SURGERY_FAILED

	if(!target.dna.species.has_organ["brain"])
		to_chat(user, "<span class='danger'>You're pretty sure [target.dna.species.name_plural] don't normally have a brain.</span>")
		return SURGERY_FAILED

	if(target.get_int_organ(/obj/item/organ/internal/brain/))
		to_chat(user, "<span class='danger'>Your subject already has a brain.</span>")
		return SURGERY_FAILED

	user.visible_message("<span class='notice'>[user] starts installing [tool] into [target]'s [affected.name].</span>", \
	"<span class='notice'>You start installing [tool] into [target]'s [affected.name].</span>")

	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/mmi/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] installs [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'>You install [tool] into [target]'s [affected.name].</span>")

	user.unEquip(tool)
	tool.attempt_become_organ(affected, target)

	return SURGERY_SUCCESS

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips!</span>.", \
		"<span class='warning'>Your hand slips!</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"
	allowed_surgery_tools = SURGERY_TOOLS_ROBOTIC_REMOVE_ORGAN
	possible_locs = list("head", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot")
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage =  SURGERY_STAGE_START

	time = 10 SECONDS

/datum/surgery_step/robotics/external/amputate/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return !affected.cannot_amputate

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] starts decoupling [target]'s [affected.name] with [tool]!</span>", \
	"<span class='notice'>You start decoupling [target]'s [affected.name] with [tool].</span>")

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	return ..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user] decouples [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You decouple [target]'s [affected.name] with [tool].</span>")

	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(TRUE, DROPLIMB_SHARP)
	if(isitem(thing))
		user.put_in_hands(thing)

	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips!</span>", \
	"<span class='warning'>Your hand slips!</span>")
	return SURGERY_FAILED

/datum/surgery_step/robotics/external/customize_appearance
	name = "reprogram limb"
	allowed_surgery_tools = SURGERY_TOOLS_ROBOTIC_REPROGRAM
	possible_locs = list("head", "chest", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage =  SURGERY_STAGE_START
	time = 4.8 SECONDS

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] begins reprogramming the appearance of [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You begin reprogramming the appearance of [target]'s [affected.name] with [tool].</span>")
	return ..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/chosen_appearance = input(user, "Select the company appearance for this limb.", "Limb Company Selection") as null|anything in GLOB.selectable_robolimbs
	if(!chosen_appearance)
		return SURGERY_FAILED
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.robotize(chosen_appearance, convert_all = FALSE)
	if(istype(affected, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = affected
		head.h_style = "Bald" // nearly all the appearance changes for heads are non-monitors; we want to get rid of a floating screen
		target.update_hair()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	user.visible_message("<span class='notice'>[user] reprograms the appearance of [target]'s [affected.name] with [tool].</span>", \
	"<span class='notice'>You reprogram the appearance of [target]'s [affected.name] with [tool].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>",
	"<span class='warning'>Your [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>")
	return SURGERY_FAILED
