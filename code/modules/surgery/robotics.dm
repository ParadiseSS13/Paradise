//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////
//to do, moar surgerys or condense down ala manipulate organs.
/datum/surgery_step/robotics
	can_infect = 0
	priority = 10
	pain = FALSE
	requires_organic_bodypart = FALSE

/datum/surgery_step/robotics/is_valid_target(mob/living/carbon/human/target)
	return istype(target) && ismachine(target)

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
	allowed_surgery_behaviour = SURGERY_ROBOTIC_UNSCREW_HATCH

	time = 16

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to unscrew the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have opened the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	return TRUE

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to unscrew [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to unscrew [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/screw_hatch
	name = "screw hatch"
	priority = -1 // Same as cauterise really
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_behaviour = SURGERY_ROBOTIC_UNSCREW_HATCH

	time = 16

/datum/surgery_step/robotics/external/screw_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to screw the maintenance hatch on [target]'s [affected.name] with \the [tool].", \
	"You start to screw the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/screw_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has closed the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have closed the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 0
	return TRUE

/datum/surgery_step/robotics/external/screw_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to screw [target]'s [affected.name].</span>", \
	"<span class='warning'> Your [tool] slips, failing to screw [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/open_hatch
	name = "open hatch"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_OPEN_CLOSE_HATCH
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN

	time = 24

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].",
	"You start to pry open the maintenance hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] opens the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>", \
	 "<span class='notice'> You open the maintenance hatch on [target]'s [affected.name] with \the [tool].</span>" )
	affected.open = 2
	return TRUE

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to open the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool] slips, failing to open the hatch on [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/close_hatch
	name = "close hatch"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_OPEN_CLOSE_HATCH
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_START

	time = 24

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to close and secure the hatch on [target]'s [affected.name] with \the [tool]." , \
	"You begin to close and secure the hatch on [target]'s [affected.name] with \the [tool].")
	..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] closes and secures the hatch on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You close and secure the hatch on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	return TRUE

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to close the hatch on [target]'s [affected.name].</span>")
	return FALSE

/datum/surgery_step/robotics/external/repair
	name = "repair damage internally"
	priority = 15
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	possible_locs = list("chest","head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","groin")
	time = 32

/datum/surgery_step/robotics/external/repair/brute
	name = "repair internal brute damage"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_HEAL_BRUTE

/datum/surgery_step/robotics/external/repair/brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.brute_dam > 0 || affected.disfigured))
		to_chat(user, "<span class='warning'>The [affected] does not require welding repair!</span>")
		return -1
	if(tool.tool_behaviour == TOOL_WELDER)
		var/obj/item/weldingtool/W = tool
		if(W)
			if(!W.tool_enabled || !tool.use(1))
				return -1
	user.visible_message("[user] begins to patch damage to [target]'s [affected.name]'s support structure with \the [tool]." , \
		"You begin to patch damage to [target]'s [affected.name]'s support structure with \the [tool].")

	..()

/datum/surgery_step/robotics/external/repair/brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'> [user] finishes patching damage to [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'> You finish patching damage to [target]'s [affected.name] with \the [tool].</span>")
	affected.heal_damage(rand(30,50),0,1,1)
	affected.disfigured = FALSE
	
	return affected.brute_dam > 0 ? SURGERY_CONTINUE : FALSE

/datum/surgery_step/robotics/external/repair/brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>",
		"<span class='warning'> Your [tool.name] slips, damaging the internal structure of [target]'s [affected.name].</span>")
	target.apply_damage(rand(5,10), BURN, affected)

	return FALSE

/datum/surgery_step/robotics/external/repair/burn
	name = "repair internal burn damage"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_HEAL_BURN

/datum/surgery_step/robotics/external/repair/burn/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	
	if(!(affected.burn_dam > 0))
		to_chat(user, "<span class='warning'>The [affected] does not have any burn damage!</span>")
		return -1
	var/obj/item/stack/cable_coil/C = tool
	if(istype(C))
		if(!C.get_amount() >= 3)
			to_chat(user, "<span class='warning'>You need three or more cable pieces to repair this damage.</span>")
			return -1
		C.use(3)
		user.visible_message("[user] begins to splice new cabling into [target]'s [affected.name]." , \
			"You begin to splice new cabling into [target]'s [affected.name].")

	..()

/datum/surgery_step/robotics/external/repair/burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	
	user.visible_message("<span class='notice'> [user] finishes splicing cable into [target]'s [affected.name].</span>", \
		"<span class='notice'> You finishes splicing new cable into [target]'s [affected.name].</span>")
	affected.heal_damage(0,rand(30,50),1,1)
	
	return affected.burn_dam > 0 ? SURGERY_CONTINUE : FALSE

/datum/surgery_step/robotics/external/repair/burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'> [user] causes a short circuit in [target]'s [affected.name]!</span>",
		"<span class='warning'> You cause a short circuit in [target]'s [affected.name]!</span>")
	
	return FALSE

///////condenseing remove/extract/repair here.	/////////////
/datum/surgery_step/robotics/manipulate_robotic_organs
	name = "internal part manipulation"
	priority = 15
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage =  SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	possible_locs = list("eyes", "mouth", "chest","head","groin","l_arm","r_arm")
	time = 32

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
		return -1
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
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
	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool

	if(!user.canUnEquip(I, 0))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you can't put it in [target]!</span>")
		return FALSE

	user.drop_item()
	I.insert(target)
	user.visible_message("<span class='notice'> [user] has reattached [target]'s [I].</span>" , \
	"<span class='notice'> You have reattached [target]'s [I].</span>")

	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")
	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/mend
	name = "mend internal part"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_MEND

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && I.damage)
			if(I.is_robotic())
				user.visible_message("<span class='notice'> [user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'> You repair [target]'s [I.name] with [tool].</span>" )
				I.damage = 0
				I.surgeryize()
	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'> [user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	affected.receive_damage(5)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I)
			I.receive_damage(rand(3,5),0)

	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/extract
	name = "extract internal part"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_EXTRACT_ORGAN
	var/obj/item/organ/internal/organ_being_removed = null

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	
	organ_being_removed = null
	var/list/organs = target.get_organs_zone(target_zone)
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
			if(!organ_being_removed)
				return -1
			var/obj/item/organ/external/affected = target.get_organ(target_zone)
			user.visible_message("[user] starts to decouple [target]'s [organ_being_removed] with \the [tool].", \
			"You start to decouple [target]'s [organ_being_removed] with \the [tool]." )
			
			target.custom_pain("The pain in your [affected.name] is living hell!")
		else
			return -1

	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
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
	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips, disconnecting \the [tool].</span>", \
		"<span class='warning'> Your hand slips, disconnecting \the [tool].</span>")
	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi
	name = "insert MMI"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_INSERT_MMI
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

	..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/mmi/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has installed \the [tool] into [target]'s [affected.name].</span>", \
		"<span class='notice'> You have installed \the [tool] into [target]'s [affected.name].</span>")

	user.unEquip(tool)
	tool.attempt_become_organ(affected, target)

	return FALSE

/datum/surgery_step/robotics/manipulate_robotic_organs/mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips!</span>.", \
		"<span class='warning'> Your hand slips!</span>")
	return FALSE

/datum/surgery_step/robotics/external/amputate
	name = "remove robotic limb"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_EXTRACT_ORGAN
	possible_locs = list("head","l_arm", "l_hand","r_arm","r_hand","r_leg","r_foot","l_leg","l_foot")
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage =  SURGERY_STAGE_START

	time = 100

/datum/surgery_step/robotics/external/amputate/is_zone_valid(mob/living/carbon/target, target_zone, current_stage)
	if(!..())
		return FALSE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return !affected.cannot_amputate

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to decouple [target]'s [affected.name] with \the [tool].", \
	"You start to decouple [target]'s [affected.name] with \the [tool]." )

	target.custom_pain("Your [affected.amputation_point] is being ripped apart!")
	..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has decoupled [target]'s [affected.name] with \the [tool].</span>" , \
	"<span class='notice'> You have decoupled [target]'s [affected.name] with \the [tool].</span>")

	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1,DROPLIMB_SHARP)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)

	return TRUE

/datum/surgery_step/robotics/external/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'> [user]'s hand slips!</span>", \
	"<span class='warning'> Your hand slips!</span>")
	return FALSE

/datum/surgery_step/robotics/external/customize_appearance
	name = "reprogram limb"
	allowed_surgery_behaviour = SURGERY_ROBOTIC_REPROGRAM
	possible_locs = list("head", "chest", "l_arm", "l_hand", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "groin")
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED
	next_surgery_stage =  SURGERY_STAGE_START
	time = 48

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to reprogram the appearance of [target]'s [affected.name] with [tool]." , \
	"You begin to reprogram the appearance of [target]'s [affected.name] with [tool].")
	..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
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

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>",
	"<span class='warning'> Your [tool.name] slips, failing to reprogram [target]'s [affected.name].</span>")
	return FALSE
