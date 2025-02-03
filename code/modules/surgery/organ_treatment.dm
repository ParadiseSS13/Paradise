
/datum/surgery/intermediate/manipulate/repair_organ
	name = "Repair organs (abstract)"
	desc = "An intermediate surgery to treat minor damage to a patient's organs."
	steps = list(/datum/surgery_step/organ_repair)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)


/datum/surgery/intermediate/manipulate/repair_organ/robotic
	name = "Repair robotic organs (abstract)"
	desc = "An intermediate surgery to treat minor damage to a patient's organs."
	steps = list(/datum/surgery_step/organ_repair)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)


/datum/surgery_step/organ_repair
	name = "repair organs surgically"
	allowed_tools = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/energy/sword = 65,
		/obj/item/kitchen/knife = 45,
		/obj/item/shard = 35
	)

	time = 5.2 SECONDS

	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

	blood_level = SURGERY_BLOODSPREAD_FULLBODY
	can_infect = TRUE

	/// Whether or not this surgery can treat robotic internal organs.
	var/robotic = FALSE

	var/obj/item/organ/internal/organ_selected

/datum/surgery_step/organ_repair/Destroy(force, ...)
	if(organ_selected)
		organ_selected = null

	return ..()

/datum/surgery_step/organ_repair/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/list/organs_inside = list()

	for(var/obj/item/organ/internal/org as anything in affected.internal_organs)
		if(org.is_robotic() && !robotic)
			continue
		if(!org.is_robotic() && robotic)
			continue
		organs_inside |= org

	if(!length(organs_inside))
		// this should probably only be called by
		return SURGERY_BEGINSTEP_SKIP


	if(length(organs_inside) > 1)
		organ_selected = tgui_input_list(user, "Which organ would you like to operate on?", "Select Organ", organs_inside)

	else
		organ_selected = organs_inside[1]

	if(!organ_selected)
		return SURGERY_BEGINSTEP_SKIP
	if(organ_selected.repaired_by_operation)
		to_chat(user, "<span class='warning'>[organ_selected] has already been patched up once before, further operations would just make it worse.</span>")
		return SURGERY_BEGINSTEP_SKIP
	if(organ_selected.damage == 0)
		to_chat(user, "<span class='notice'>[organ_selected] is already in perfect condition!</span>")
		return SURGERY_BEGINSTEP_SKIP

	if(organ_selected.is_dead())
		// need mito to bring it back from the dead.
		to_chat(user, "<span class='warning'>[organ_selected] has completely shut down, you can't fix it like this.</span>")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		"<span class='notice'>[user] begins to patch up [target]'s [organ_selected.name].</span>",
		"<span class='notice'>You start to patch up [target]'s [organ_selected.name].</span>"
	)

	. = ..()
	if(!.)
		return

	affected.custom_pain("Something's stabbing your [organ_selected.name]! It's almost too much to bear...")

	return SURGERY_BEGINSTEP_CONTINUE

/datum/surgery_step/organ_repair/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(QDELETED(organ_selected))
		stack_trace("The organ in [user]'s [affected] was deleted while performing the surgery.")
		user.visible_message("<span class='notice'>...but it's not there anymore!</span>")
		return SURGERY_STEP_CONTINUE

	organ_selected.damage = 0
	organ_selected.repaired_by_operation = TRUE
	// a bit more fragile
	organ_selected.min_broken_damage -= 10


	user.visible_message(
		"<span class='notice'>[user] surgically excises the most damaged parts of [target]'s [organ_selected.name].</span>",
		"<span class='notice'>You surgically excises the most damaged parts of [target]'s [organ_selected.name].</span>"
	)


	return SURGERY_STEP_CONTINUE


/datum/surgery_step/organ_repair/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(QDELETED(organ_selected))
		stack_trace("The organ in [user]'s [affected] was deleted while performing the surgery.")
		user.visible_message("<span class='notice'>...but it's not there anymore!</span>")
		return SURGERY_STEP_CONTINUE

	organ_selected.receive_damage(20)
	organ_selected.repaired_by_operation = TRUE

	var/error = pick("stabs", "jabs", "slices")
	user.visible_message(
		"<span class='danger'>[user] accidentally [error] [target]'s [organ_selected]!</span>",
		"<span class='danger'>Your hand slips, accidentally [error] [target]'s [organ_selected]!</span>"
	)
	affected.custom_pain("You feel a sharp stabbing pain emanating from your [organ_selected]!")
	return SURGERY_STEP_RETRY


/datum/surgery_step/organ_repair/robotic
	name = "repair robotic organs"
	robotic = TRUE

	allowed_tools = list(
		TOOL_SCREWDRIVER = 100,
		/obj/item/coin = 45,
	)

/datum/surgery_step/internal/manipulate_organs/mend
	name = "mend organs"
	allowed_tools = list(
		/obj/item/stack/medical/bruise_pack/advanced = 100,
		/obj/item/stack/medical/bruise_pack = 20,
		/obj/item/stack/nanopaste = 100
	)

	preop_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/internal/manipulate_organs/mend/proc/get_tool_name(obj/item/tool)
	var/tool_name = "[tool]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/nanopaste))
		tool_name = "[tool]" //what else do you call nanopaste medically?

	return tool_name

/datum/surgery_step/internal/manipulate_organs/mend/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!iscarbon(target))
		to_chat(user, "They do not have organs to mend!")
		// note that we want to return skip here so we can go "back" to the proxy step
		return SURGERY_BEGINSTEP_SKIP

	var/any_organs_damaged = FALSE

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)


		if(I.is_damaged())
			any_organs_damaged = TRUE
			if(I.is_robotic() && istype(tool, /obj/item/stack/nanopaste))
				user.visible_message(
					"[user] starts treating damage to [target]'s [I.name] with [tool_name].",
					"You start treating damage to [target]'s [I.name] with [tool_name]."
				)
			else if(I.damage < I.min_broken_damage && !I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste))
				if(!(I.sterile))
					spread_germs_to_organ(I, user, tool)
				user.visible_message(
					"[user] starts treating damage to [target]'s [I.name] with [tool_name].",
					"You start treating damage to [target]'s [I.name] with [tool_name]."
				)

			else
				to_chat(user, "The damage on [I] is too severe to treat solely with [tool].</span>")
		else
			to_chat(user, "[I] does not appear to be damaged.")

	if(!any_organs_damaged)
		return SURGERY_BEGINSTEP_SKIP

	if(affected)
		affected.custom_pain("The pain in your [affected.name] is living hell!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!iscarbon(target))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/stack/healing_stack = tool

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(I)
			I.surgeryize()
		if(I && I.damage)
			if(!I.is_robotic() && !istype(tool, /obj/item/stack/nanopaste) && I.damage <= I.min_broken_damage )
				user.visible_message(
					"<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>",
					"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>",
					chat_message_type = MESSAGE_TYPE_COMBAT
				)
				I.heal_internal_damage(istype(tool, /obj/item/stack/medical/bruise_pack/advanced) ? 20 : 10)
				healing_stack.use(1)
			else if(I.is_robotic() && istype(tool, /obj/item/stack/nanopaste))
				user.visible_message(
					"<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>",
					"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>",
					chat_message_type = MESSAGE_TYPE_COMBAT
				)
				I.heal_internal_damage(20, TRUE)
				healing_stack.use(1)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!iscarbon(target))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		"<span class='warning'>[user]'s hand slips, getting messy and tearing the inside of [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='warning'>Your hand slips, getting messy and tearing the inside of [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack) || istype(tool, /obj/item/stack/nanopaste))
		dam_amt = 5
		target.adjustToxLoss(10)
		if(affected)
			affected.receive_damage(5)

	var/list/organs = get_organ_list(target_zone, target, affected)

	for(var/obj/item/organ/internal/I in organs)
		if(I && I.damage && !(I.tough))
			I.receive_damage(dam_amt,0)

	return SURGERY_STEP_RETRY
