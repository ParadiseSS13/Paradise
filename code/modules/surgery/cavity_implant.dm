/datum/surgery/cavity_implant
	name = "Cavity Implant/Removal"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/cavity/make_space,/datum/surgery_step/cavity/place_item,/datum/surgery_step/cavity/close_space,/datum/surgery_step/open_encased/close,/datum/surgery_step/glue_bone, /datum/surgery_step/set_bone,/datum/surgery_step/finish_bone,/datum/surgery_step/generic/cauterize)
	possible_locs = list("chest","head")


/datum/surgery/cavity_implant/soft
	name = "Cavity Implant/Removal"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/generic/cut_open, /datum/surgery_step/cavity/make_space,/datum/surgery_step/cavity/place_item,/datum/surgery_step/cavity/close_space,/datum/surgery_step/generic/cauterize)

	possible_locs = list("groin")

/datum/surgery/cavity_implant/synth
	name = "Robotic Cavity Implant/Removal"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/cavity/place_item,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest","head","groin")
	requires_organic_bodypart = 0

/datum/surgery/cavity_implant/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected)
		return 0
	if(affected.is_robotic())
		return 0
	return 1

/datum/surgery/cavity_implant/synth/can_start(mob/user, mob/living/carbon/human/target)
	if(!istype(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected)
		return 0
	return affected.is_robotic()

/datum/surgery_step/cavity
	priority = 1

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

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.receive_damage(20)

/datum/surgery_step/cavity/make_space
	name = "make cavity space"
	allowed_tools = list(
	/obj/item/surgicaldrill = 100,	\
	/obj/item/pen = 90,	\
	/obj/item/stack/rods = 60
	)

	time = 54

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!")
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>", \
	"<span class='notice'> You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>" )

	return 1

/datum/surgery_step/cavity/close_space
	name = "close cavity space"
	allowed_tools = list(
	/obj/item/scalpel/laser = 100, \
	/obj/item/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 90,	\
	/obj/item/lighter = 60,			\
	/obj/item/weldingtool = 30
	)

	time = 24

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!")
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>", \
	"<span class='notice'> You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>" )

	return 1


/datum/surgery_step/cavity/place_item
	name = "implant/extract object"
	accept_hand = 1
	accept_any_item = 1
	var/obj/item/IC = null
	allowed_tools = list(/obj/item = 100)

	time = 32


/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!ishuman(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		to_chat(user, "<span class='warning'>\The [target] lacks a [parse_zone(target_zone)]!</span>")
		return 0
	if(tool)
		var/can_fit = !affected.hidden && tool.w_class <= get_max_wclass(affected)
		if(!can_fit)
			to_chat(user, "<span class='warning'>\The [tool] won't fit in \The [affected.name]!</span>")
			return 0
	return ..()

/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			IC = I
			break
	if(istype(tool,/obj/item/cautery))
		to_chat(user, "<span class='notice'>You prepare to close the cavity wall.</span>")
	else if(tool)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
	else if(IC)
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")
	else //no internal items..but we still need a message!
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")

	target.custom_pain("The pain in your [target_zone] is living hell!")
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

	if(istype(tool, /obj/item/disk/nuclear))
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone.</span>")
		return 0//fail

	var/obj/item/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone. Even if in a box. Especially in a box.</span>")
		return 0//fail

	if(istype(tool,/obj/item/organ))
		to_chat(user, "<span class='warning'>This isn't the type of surgery for organ transplants!</span>")
		return 0//fail

	if(!user.canUnEquip(tool, 0))
		to_chat(user, "<span class='warning'>[tool] is stuck to your hand, you can't put it in [target]!</span>")
		return 0

	if(istype(tool,/obj/item/cautery))
		return 1//god this is ugly....
	else if(tool)
		if(IC)
			to_chat(user, "<span class='notice'>There seems to be something in there already!</span>")
			return 1
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
			return 1
	else
		if(IC)
			user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
			user.put_in_hands(IC)
			affected.hidden = null
			return 1
		else
			to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
			return 0