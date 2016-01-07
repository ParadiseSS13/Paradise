//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.


//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/cavity_implant
	name = "cavity implant"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/generic/cut_open, /datum/surgery_step/cavity/make_space,/datum/surgery_step/cavity/place_item,/datum/surgery_step/cavity/close_space,/datum/surgery_step/generic/cauterize/)

	possible_locs = list("chest","head","groin")

/datum/surgery_step/cavity
	priority = 1

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && affected.open == (affected.encased ? 3 : 2) && !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/affected)
	switch (affected.limb_name)
		if ("head")
			return 1
		if ("chest")
			return 3
		if ("groin")
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/affected)
	switch (affected.limb_name)
		if ("head")
			return "cranial"
		if ("chest")
			return "thoracic"
		if ("groin")
			return "abdominal"
	return ""

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("\red [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!", \
	"\red Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!")
	affected.createwound(CUT, 20)

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75,	\
	/obj/item/stack/rods = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && !affected.cavity && !affected.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
	"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	affected.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("\blue [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].", \
	"\blue You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )

	return 1

/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].", \
	"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1)
	affected.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("\blue [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].", \
	"\blue You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool]." )

	return 1


/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(/obj/item = 100)

	min_duration = 80
	max_duration = 100


/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/can_fit = affected && !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)
	return ..() && can_fit

/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
	"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

	if(istype(tool, /obj/item/weapon/disk/nuclear))
		user << "Central command would kill you if you implanted the disk into someone."
		return 0//fail
	else
		user.visible_message("\blue [user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"\blue You put \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
		if (tool.w_class > get_max_wclass(affected)/2 && prob(50) && !(affected.status & ORGAN_ROBOT))
			user << "\red You tear some vessels trying to fit such big object in this cavity."
			var/datum/wound/internal_bleeding/I = new ()
			affected.wounds += I
			affected.owner.custom_pain("You feel something rip in your [affected.name]!", 1)
		user.drop_item()
		affected.hidden = tool
		target.internal_organs += tool
		tool.loc = target
		affected.cavity = 0

		return 1

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

///Fethas note:I might could condense this down but it would need to take out the part with poking around with a hemostat
/datum/surgery/cavity_implant_rem
	name = "implant removal"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/generic/cut_open,/datum/surgery_step/cavity/implant_removal,/datum/surgery_step/cavity/close_space,/datum/surgery_step/generic/cauterize/)
	possible_locs = list("chest","head","groin")

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/cavity/implant_removal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts poking around inside [target]'s [affected.name] with \the [tool].", \
	"You start poking around inside [target]'s [affected.name] with \the [tool]." )
	target.custom_pain("The pain in your [affected.name] is living hell!",1)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/find_prob = 0

	if (affected.implants.len)

		var/obj/item/obj = affected.implants[1]

		if(istype(obj,/obj/item/weapon/implant))
			var/obj/item/weapon/implant/imp = obj
			if (imp.islegal())
				find_prob +=60
			else
				find_prob +=40
		else
			find_prob +=50

		if (prob(find_prob))
			user.visible_message("\blue [user] takes something out of [target]'s [affected.name] with \the [tool].", \
			"\blue You take [obj] out of [target]'s [affected.name]s with \the [tool]." )
			affected.implants -= obj

			target.sec_hud_set_implants()

			//Handle possessive brain borers.
			if(istype(obj,/mob/living/simple_animal/borer))
				var/mob/living/simple_animal/borer/worm = obj
				if(worm.controlling)
					target.release_control()
				worm.detatch()
				worm.leave_host()

			obj.loc = get_turf(target)
			if(istype(obj,/obj/item/weapon/implant))
				var/obj/item/weapon/implant/imp = obj
				imp.imp_in = null
				imp.implanted = 0

			return 1
		else
			user.visible_message("\blue [user] removes \the [tool] from [target]'s [affected.name].", \
			"\blue There's something inside [target]'s [affected.name], but you just missed it this time." )
			return -1 //or maybe 0....
	else if (affected.hidden)
		user.visible_message("\blue [user] takes something out of incision on [target]'s [affected.name] with \the [tool].", \
		"\blue You take something out of incision on [target]'s [affected.name]s with \the [tool]." )
		affected.hidden.loc = get_turf(target)
		if(!affected.hidden.blood_DNA)
			affected.hidden.blood_DNA = list()
		affected.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
		affected.hidden.update_icon()
		affected.hidden = null
		return 1

	else
		user.visible_message("\blue [user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.", \
		"\blue You could not find anything inside [target]'s [affected.name]." )
		return -1

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	..()
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	if (affected.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if (prob(fail_prob))
			var/obj/item/weapon/implant/imp = affected.implants[1]
			user.visible_message("\red Something beeps inside [target]'s [affected.name]!")
			playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
			spawn(25)
				imp.activate()
	return 0

