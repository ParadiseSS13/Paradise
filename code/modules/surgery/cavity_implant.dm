/datum/surgery_step/cavity
	priority = 1
	possible_locs = list("chest","head","groin")

/datum/surgery_step/cavity/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected)
		return FALSE
	if(requires_organic_bodypart && affected.is_robotic())
		return FALSE
	return TRUE
	

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/affected)
	switch(affected.limb_name)
		if("head")
			return 1
		if("chest")
			return 3
		if("groin")
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/affected)
	switch(affected.limb_name)
		if("head")
			return "cranial"
		if("chest")
			return "thoracic"
		if("groin")
			return "abdominal"
	return ""

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.receive_damage(20)

/datum/surgery_step/cavity/make_space
	name = "make cavity space"
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION_CUT, SURGERY_STAGE_OPEN_INCISION_BONES)
	next_surgery_stage = SURGERY_STAGE_CAVITY_OPEN
	allowed_surgery_behaviour = SURGERY_MAKE_CAVITY
	time = 54

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!")
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>", \
	"<span class='notice'> You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>" )

	return TRUE

// Base is for the groin only
/datum/surgery_step/cavity/close_space
	name = "close cavity space"
	surgery_start_stage = list(SURGERY_STAGE_CAVITY_OPEN, SURGERY_STAGE_CAVITY_CLOSING)
	next_surgery_stage = SURGERY_STAGE_OPEN_INCISION
	allowed_surgery_behaviour = SURGERY_CAUTERIZE_INCISION
	time = 24

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!")
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	next_surgery_stage = affected.encased ? SURGERY_STAGE_OPEN_INCISION_BONES : next_surgery_stage // Return to the open bone incision
	user.visible_message("<span class='notice'> [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>", \
	"<span class='notice'> You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>" )

	return TRUE


/datum/surgery_step/cavity/place_item
	name = "implant/extract object"
	priority = 0 // Pretty low
	surgery_start_stage = SURGERY_STAGE_CAVITY_OPEN
	next_surgery_stage = SURGERY_STAGE_CAVITY_CLOSING
	accept_hand = TRUE
	accept_any_item = TRUE
	var/obj/item/IC = null
	time = 32

/datum/surgery_step/cavity/place_item/robot
	name = "insert/unplug object"
	surgery_start_stage = SURGERY_STAGE_ROBOTIC_HATCH_OPEN
	next_surgery_stage = SURGERY_STAGE_SAME
	requires_organic_bodypart = FALSE
	priority = 0

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!..())
		return FALSE
	
	if(tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		var/can_fit = !affected.hidden && tool.w_class <= get_max_wclass(affected)
		if(!can_fit)
			return FALSE
	return TRUE

/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			IC = I
			break
	if(tool)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
	else
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")

	target.custom_pain("The pain in your [target_zone] is living hell!")
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

	if(istype(tool, /obj/item/disk/nuclear))
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone.</span>")
		return FALSE //fail

	var/obj/item/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone. Even if in a box. Especially in a box.</span>")
		return FALSE //fail

	if(istype(tool,/obj/item/organ))
		to_chat(user, "<span class='warning'>This isn't the type of surgery for organ transplants!</span>")
		return FALSE//fail

	if(!user.canUnEquip(tool, 0))
		to_chat(user, "<span class='warning'>[tool] is stuck to your hand, you can't put it in [target]!</span>")
		return FALSE

	if(tool)
		if(IC)
			to_chat(user, "<span class='notice'>There seems to be something in there already!</span>")
			return TRUE
		else
			user.visible_message("<span class='notice'> [user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>", \
			"<span class='notice'> You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>" )
			if((tool.w_class > get_max_wclass(affected) / 2 && prob(50) && !affected.is_robotic()))
				to_chat(user, "<span class='warning'> You tear some vessels trying to fit the object in the cavity.</span>")
				affected.internal_bleeding = TRUE
				affected.owner.custom_pain("You feel something rip in your [affected.name]!")
			user.drop_item()
			affected.hidden = tool
			tool.forceMove(affected)
			return TRUE
	else
		if(IC)
			user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
			user.put_in_hands(IC)
			affected.hidden = null
			return TRUE
		else
			to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
			return FALSE