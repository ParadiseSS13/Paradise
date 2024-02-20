/datum/surgery/cavity_implant
	name = "Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)

/datum/surgery/cavity_implant/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE
	return TRUE

/datum/surgery/cavity_implant/soft
	desc = "Implant an object into a cavity not protected by bone."
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_PRECISE_GROIN)

/datum/surgery/cavity_implant/soft/boneless
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)

/datum/surgery/cavity_implant/soft/boneless/can_start(mob/user, mob/living/carbon/target)
	if(!HAS_TRAIT(target, TRAIT_NO_BONES))
		return FALSE
	return TRUE

/datum/surgery/cavity_implant/synth
	name = "Robotic Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/cavity_manipulation/robotic,
		/datum/surgery_step/cavity/close_space/synth,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = FALSE


/datum/surgery_step/proxy/cavity_manipulation
	name = "Cavity Manipulation (proxy)"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant,
		/datum/surgery/intermediate/open_cavity/extract,
		/datum/surgery/intermediate/bleeding
	)

	insert_self_after = TRUE

/datum/surgery_step/proxy/cavity_manipulation/robotic
	name = "Robotic Cavity Manipulation (proxy)"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant/robotic,
		/datum/surgery/intermediate/open_cavity/extract/robotic
	)

/datum/surgery/intermediate/open_cavity
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)

/datum/surgery/intermediate/open_cavity/implant
	name = "implant object"
	steps = list(
		/datum/surgery_step/cavity/place_item
	)

/datum/surgery/intermediate/open_cavity/extract
	name = "extract object"
	steps = list(
		/datum/surgery_step/cavity/remove_item
	)

/datum/surgery/intermediate/open_cavity/implant/robotic
	requires_organic_bodypart = FALSE

/datum/surgery/intermediate/open_cavity/extract/robotic
	requires_organic_bodypart = FALSE


/datum/surgery_step/cavity

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/affected)
	switch(affected.limb_name)
		if(BODY_ZONE_HEAD)
			return WEIGHT_CLASS_TINY
		if(BODY_ZONE_CHEST)
			return WEIGHT_CLASS_NORMAL
		if(BODY_ZONE_PRECISE_GROIN)
			return WEIGHT_CLASS_SMALL
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/affected)
	switch(affected.limb_name)
		if(BODY_ZONE_HEAD)
			return "cranial"
		if(BODY_ZONE_CHEST)
			return "thoracic"
		if(BODY_ZONE_PRECISE_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/cavity/proc/get_item_inside(obj/item/organ/external/affected)
	var/obj/item/extracting
	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	return extracting

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'> [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>",
		"<span class='warning'> Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>"
	)
	affected.receive_damage(20)
	return SURGERY_STEP_RETRY

/datum/surgery_step/cavity/make_space
	name = "make cavity space"
	allowed_tools = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 90,
		/obj/item/pen = 90,
		/obj/item/stack/rods = 60
	)

	time = 5.4 SECONDS

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].",
		"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."
	)
	affected.custom_pain("The pain in your chest is living hell!")
	return ..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>",
		"<span class='notice'> You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>"
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/close_space
	name = "close cavity space"
	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].",
		"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]."
	)
	affected.custom_pain("The pain in your chest is living hell!")
	return ..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='notice'> [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>",
		"<span class='notice'> You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>"
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/close_space/synth
	name = "seal cavity"
	allowed_tools = list(
		TOOL_WELDER = 100,
		/obj/item/scalpel/laser = 60,
		TOOL_CAUTERY = 50,
		/obj/item/lighter = 30,
	)


/datum/surgery_step/cavity/remove_item
	name = "extract object"
	accept_hand = TRUE

/datum/surgery_step/cavity/remove_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// Check even if there isn't anything inside
	user.visible_message(
		"[user] checks for items in [target]'s [target_zone].",
		"<span class='notice'>You check for items in [target]'s [target_zone]...</span>"
	)
	return ..()

/datum/surgery_step/cavity/remove_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/extracting
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	if(!extracting)
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
		return SURGERY_STEP_CONTINUE
	user.visible_message(
		"<span class='notice'>[user] pulls [extracting] out of [target]'s [target_zone]!</span>",
		"<span class='notice'>You pull [extracting] out of [target]'s [target_zone].</span>"
	)
	user.put_in_hands(extracting)
	affected.hidden = null
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/remove_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"<span class='warning'>[user] grabs onto something else by mistake, damaging it!.</span>",
		"<span class='warning'>You grab onto something else inside [target]'s [get_cavity(affected)] cavity by mistake, damaging it!</span>"
	)

	affected.damage += rand(3, 5)

	return SURGERY_STEP_INCOMPLETE

/datum/surgery_step/cavity/place_item
	name = "implant object"
	accept_any_item = TRUE

	time = 3.2 SECONDS


/datum/surgery_step/cavity/place_item/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/disk/nuclear))
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone.</span>")
		return FALSE

	var/obj/item/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, "<span class='warning'>Central Command would kill you if you implanted the disk into someone. Especially if in a [tool].</span>")
		return FALSE

	if(istype(tool, /obj/item/organ))
		to_chat(user, "<span class='warning'>This isn't the type of surgery for organ transplants!</span>")
		return FALSE

	if(!user.canUnEquip(tool, 0))
		to_chat(user, "<span class='warning'>[tool] is stuck to your hand!</span>")
		return FALSE

	if(istype(tool, /obj/item/cautery))
		// Pass it to the next step
		return FALSE

	return TRUE


/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/can_fit = !affected.hidden && tool.w_class <= get_max_wclass(affected)
	if(!can_fit)
		to_chat(user, "<span class='warning'>\The [tool] won't fit in \the [affected]!</span>")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		"[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.",
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity."
	)
	affected.custom_pain("The pain in your [target_zone] is living hell!")
	return ..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	if(get_item_inside(affected))
		to_chat(user, "<span class='notice'>There seems to be something in there already!</span>")
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		"<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>",
		"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>"
	)
	if((tool.w_class > get_max_wclass(affected) / 2 && prob(50) && !affected.is_robotic()))
		user.visible_message(
			"<span class='warning'>[user] tears some blood vessels trying to fit the object in the cavity!</span>",
			"<span class='danger'>You tear some blood vessels trying to fit the object into the cavity!</span>",
			"<span class='warning'>You hear some gentle tearing.</span>")
		affected.cause_internal_bleeding()
	user.drop_item()
	affected.hidden = tool
	tool.forceMove(target)
	return SURGERY_STEP_CONTINUE
