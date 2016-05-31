//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.


//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/cavity_implant
	name = "cavity implant/removal"
	steps = list(/datum/surgery_step/generic/cut_open,/datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/open_encased/saw,
	/datum/surgery_step/open_encased/retract, /datum/surgery_step/cavity/make_space,/datum/surgery_step/cavity/place_item,/datum/surgery_step/cavity/close_space,/datum/surgery_step/open_encased/close,/datum/surgery_step/glue_bone, /datum/surgery_step/set_bone,/datum/surgery_step/finish_bone,/datum/surgery_step/generic/cauterize)

	possible_locs = list("chest","head")


/datum/surgery/cavity_implant/soft
	name = "cavity implant/removal"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/generic/cut_open, /datum/surgery_step/cavity/make_space,/datum/surgery_step/cavity/place_item,/datum/surgery_step/cavity/close_space,/datum/surgery_step/generic/cauterize)

	possible_locs = list("groin")

/datum/surgery/cavity_implant/synth
	name = "robotic cavity implant"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/cavity/place_item,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest","head","groin")

/datum/surgery/cavity_implant/can_start(mob/user, mob/living/carbon/target)
	if(target.get_species() == "Machine")
		return 0
	return 1

/datum/surgery/cavity_implant/synth/can_start(mob/user, mob/living/carbon/target)
	return target.get_species() == "Machine"

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
	user.visible_message("<span class='warning'> [user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)

/datum/surgery_step/cavity/make_space
	name = "make cavity space"
	allowed_tools = list(
	/obj/item/weapon/surgicaldrill = 100,	\
	/obj/item/weapon/pen = 75,	\
	/obj/item/stack/rods = 50
	)

	time = 54

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
	user.visible_message("<span class='notice'> [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>", \
	"<span class='notice'> You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>" )

	return 1

/datum/surgery_step/cavity/close_space
	name = "close cavity space"
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	time = 24

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
	if (!ishuman(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/can_fit = affected && !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)
	return ..() && can_fit

/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/I in target.internal_organs)
		if(!istype(I, /obj/item/organ))
			IC = I
			break
	if(istype(tool,/obj/item/weapon/cautery))
		to_chat(user, "you prepare to close the cavity wall.")
	else if(tool)
		user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.", \
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
	else if(IC)
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")
	else //no internal items..but we still need a message!
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")

	target.custom_pain("The pain in your [target_zone] is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)

	if(istype(tool, /obj/item/weapon/disk/nuclear))
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone.</span>")
		return 0//fail

	var/obj/item/weapon/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, "<span class='warning'>Central command would kill you if you implanted the disk into someone. Even if in a box. Especially in a box.</span>")
		return 0//fail

	if(istype(tool,/obj/item/organ))
		to_chat(user, "<span class='warning'>This isn't the type of surgery for organ transplants!</span>")
		return 0//fail

	if(!user.canUnEquip(tool, 0))
		to_chat(user, "<span class='warning'>[tool] is stuck to your hand, you can't put it in [target]!</span>")
		return 0

	if(istype(tool,/obj/item/weapon/cautery))
		return 1//god this is ugly....
	else if(tool)
		if(IC)
			to_chat(user, "<span class='notice'>There seems to be something in there already!</span>")
			return 1
		else
			user.visible_message("<span class='notice'> [user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>", \
			"<span class='notice'> You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>" )
			if((tool.w_class > get_max_wclass(affected)/2 && prob(50) && !(affected.status & ORGAN_ROBOT)))
				to_chat(user, "<span class='warning'> You tear some vessels trying to fit the object in the cavity.</span>")
				var/datum/wound/internal_bleeding/I = new ()
				affected.wounds += I
				affected.owner.custom_pain("You feel something rip in your [affected.name]!", 1)
			user.drop_item()
			target.internal_organs += tool
			tool.loc = target
			affected.cavity = 0
			return 1
	else
		if(IC)
			user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
			user.put_in_hands(IC)
			target.internal_organs -= IC
			return 1
		else
			to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
			return 0


//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/cavity_implant_rem
	name = "implant removal"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin,/datum/surgery_step/cavity/implant_removal,/datum/surgery_step/cavity/close_space,/datum/surgery_step/generic/cauterize/)
	possible_locs = list("chest")//head is for borers..i can put it elsewhere

/datum/surgery/cavity_implant_rem/synth
	name = "implant removal"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch,/datum/surgery_step/cavity/implant_removal,/datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("chest")//head is for borers..i can put it elsewhere

/datum/surgery/cavity_implant_rem/can_start(mob/user, mob/living/carbon/target)
	if(target.get_species() == "Machine")
		return 0
	return 1

/datum/surgery/cavity_implant_rem/synth/can_start(mob/user, mob/living/carbon/target)
	return target.get_species() == "Machine"

/datum/surgery_step/cavity/implant_removal
	name = "extract implant"
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)
	var/obj/item/weapon/implant/I = null
	time = 64

/datum/surgery_step/cavity/implant_removal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/weapon/implant) in target
	user.visible_message("[user] starts poking around inside [target]'s [affected.name] with \the [tool].", \
	"You start poking around inside [target]'s [affected.name] with \the [tool]." )
	target.custom_pain("The pain in your [affected.name] is living hell!",1)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/weapon/implant) in target
	if(I && (target_zone == "chest")) //implant removal only works on the chest.
		user.visible_message("<span class='notice'>[user] takes something out of [target]'s [affected.name] with \the [tool].</span>", \
		"<span class='notice'>You take [I] out of [target]'s [affected.name]s with \the [tool].</span>" )

		I.removed(target)

		var/obj/item/weapon/implantcase/case

		if(istype(user.get_item_by_slot(slot_l_hand), /obj/item/weapon/implantcase))
			case = user.get_item_by_slot(slot_l_hand)
		else if(istype(user.get_item_by_slot(slot_r_hand), /obj/item/weapon/implantcase))
			case = user.get_item_by_slot(slot_r_hand)
		else
			case = locate(/obj/item/weapon/implantcase) in get_turf(target)

		if(case && !case.imp)
			case.imp = I
			I.loc = case
			case.update_icon()
			user.visible_message("[user] places [I] into [case]!", "<span class='notice'>You place [I] into [case].</span>")
		else
			qdel(I)
		//target.sec_hud_set_implants()
		return 1
	else
		user.visible_message("<span class='notice'> [user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [affected.name].</span>")
		return 1

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	..()
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	if (affected.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if (prob(fail_prob))
			var/obj/item/weapon/implant/imp = affected.implants[1]
			user.visible_message("<span class='warning'> Something beeps inside [target]'s [affected.name]!</span>")
			playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
			spawn(25)
				imp.activate()
	return 0


//////////////////////////////////////////////////////////////////
//					EMBEDDED ITEM REOMOVAL						//
//////////////////////////////////////////////////////////////////

/datum/surgery/embedded_removal
	name = "removal of embedded objects"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/remove_object, /datum/surgery_step/generic/cauterize)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","r_hand","r_foot","l_hand","l_foot","groin","chest","head")

/datum/surgery/embedded_removal/synth
	name = "removal of embedded objects"
	steps = list(/datum/surgery_step/robotics/external/unscrew_hatch,/datum/surgery_step/robotics/external/open_hatch, /datum/surgery_step/remove_object, /datum/surgery_step/robotics/external/close_hatch)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","r_hand","r_foot","l_hand","l_foot","groin","chest","head")


/datum/surgery/embedded_removal/can_start(mob/user, mob/living/carbon/target)
	if(target.get_species() == "Machine")
		return 0
	return 1

/datum/surgery/embedded_removal/synth/can_start(mob/user, mob/living/carbon/target)
	if(target.get_species() == "Machine")
		return 1
	return 0

/datum/surgery_step/remove_object
	name = "remove embedded objects"
	time = 32
	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 20
	)
	var/obj/item/organ/external/L = null


/datum/surgery_step/remove_object/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = target.get_organ(target_zone)
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [target_zone].", "<span class='notice'>You look for objects embedded in [target]'s [target_zone]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [target_zone].", "<span class='notice'>You look for [target]'s [target_zone]...</span>")


/datum/surgery_step/remove_object/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/objects = 0
			for(var/obj/item/I in L.implants)
				if(!istype(I,/obj/item/weapon/implant))
					objects++
					I.forceMove(get_turf(H))
					L.implants -= I

					//Handle possessive brain borers.
			if(H.has_brain_worms() && target_zone == "head")//remove worms outside the loop
				var/mob/living/simple_animal/borer/worm = H.has_brain_worms()
				if(worm.controlling)
					target.release_control()
				worm.detatch()
				worm.leave_host()
				user.visible_message("a slug like creature wiggles out of [H]'s [target_zone]!")

			if(objects > 0)
				user.visible_message("[user] sucessfully removes [objects] objects from [H]'s [L.limb_name]!", "<span class='notice'>You sucessfully remove [objects] objects from [H]'s [L.limb_name].</span>")
			else
				to_chat(user, "<span class='warning'>You find no objects embedded in [H]'s [L.limb_name]!</span>")
	else
		to_chat(user, "<span class='warning'>You can't find [target]'s [target_zone], let alone any objects embedded in it!</span>")

	return 1
