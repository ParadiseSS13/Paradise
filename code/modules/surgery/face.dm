//Procedures in this file: Facial reconstruction surgery
//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery/plastic_surgery
	name = "Face Repair"
	steps = list(/datum/surgery_step/generic/cut_face, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/face/mend_vocal, /datum/surgery_step/face/fix_face,/datum/surgery_step/face/cauterize)
	possible_locs = list("head")



/datum/surgery/plastic_surgery/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_sel.selecting)
		if(!affected)
			return 0
		if(affected.status & ORGAN_ROBOT)
			return 0
		if(!affected.disfigured)
			return 0
		return 1

/datum/surgery_step/face
	priority = 2
	can_infect = 0

/datum/surgery_step/generic/cut_face
	name = "make incision"
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchen/knife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	time = 16

/datum/surgery_step/generic/cut_face/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
		"You start to cut open [target]'s face and neck with \the [tool].")
		..()

/datum/surgery_step/generic/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("<span class='notice'> [user] has cut open [target]'s face and neck with \the [tool].</span>" , \
		"<span class='notice'> You have cut open [target]'s face and neck with \the [tool].</span>",)

		return 1

/datum/surgery_step/generic/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s hand slips, slicing [target]'s throat wth \the [tool]!</span>" , \
		"<span class='warning'> Your hand slips, slicing [target]'s throat wth \the [tool]!</span>" )
		affected.createwound(CUT, 60)
		target.losebreath += 4

		return 0

/datum/surgery_step/face/mend_vocal
	name = "mend vocal cords"
	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/hemostat = 100, 	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 10	//I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	time = 24

/datum/surgery_step/face/mend_vocal/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
		"You start mending [target]'s vocal cords with \the [tool].")
		..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("<span class='notice'> [user] mends [target]'s vocal cords with \the [tool].</span>", \
		"<span class='notice'> You mend [target]'s vocal cords with \the [tool].</span>")
		return 1

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("<span class='warning'> [user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
		target.losebreath += 4
		return 0

/datum/surgery_step/face/fix_face
	name = "reshape face"
	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 55,	\
	/obj/item/weapon/kitchen/utensil/fork = 75)

	time = 64

/datum/surgery_step/face/fix_face/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] starts pulling skin on [target]'s face back in place with \the [tool].", \
		"You start pulling skin on [target]'s face back in place with \the [tool].")
		..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("<span class='notice'> [user] pulls skin on [target]'s face back in place with \the [tool].</span>",	\
		"<span class='notice'> You pull skin on [target]'s face back in place with \the [tool].</span>")
		return 1

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
		target.apply_damage(10, BRUTE, affected, sharp=1, edge=1)
		return 0

/datum/surgery_step/face/cauterize
	name = "close incision"
	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	time = 24

/datum/surgery_step/face/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
		..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='notice'> [user] cauterizes the incision on [target]'s face and neck with \the [tool].</span>", \
		"<span class='notice'> You cauterize the incision on [target]'s face and neck with \the [tool].</span>")
		affected.open = 0
		affected.status &= ~ORGAN_BLEEDING
		var/obj/item/organ/external/head/h = affected
		h.disfigured = 0
		h.update_icon()
		target.regenerate_icons()

		return 1

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class='warning'> [user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>", \
		"<span class='warning'> Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>")
		target.apply_damage(4, BURN, affected)

		return 0
