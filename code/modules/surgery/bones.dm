//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////
///Surgery Datums
/datum/surgery/bone_repair
	name = "Reparacion de Hueso"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/glue_bone, /datum/surgery_step/set_bone, /datum/surgery_step/finish_bone, /datum/surgery_step/generic/cauterize)
	possible_locs = list("chest", "l_arm", "l_hand", "r_arm", "r_hand","r_leg", "r_foot", "l_leg", "l_foot", "groin")

/datum/surgery/bone_repair/skull
	name = "Reparacion de Craneo"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/clamp_bleeders, /datum/surgery_step/generic/retract_skin, /datum/surgery_step/glue_bone, /datum/surgery_step/mend_skull, /datum/surgery_step/finish_bone, /datum/surgery_step/generic/cauterize)
	possible_locs = list("head")

/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(!affected)
			return 0
		if(affected.is_robotic())
			return 0
		if(affected.cannot_break)
			return 0
		if(affected.status & ORGAN_BROKEN)
			return 1
		return 1


//surgery steps
/datum/surgery_step/glue_bone
	name = "Reparar Hueso"

	allowed_tools = list(
	/obj/item/bonegel = 100,	\
	/obj/item/screwdriver = 90
	)
	can_infect = 1
	blood_level = 1

	time = 24

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		return affected && !affected.is_robotic() && !(affected.cannot_break)

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a aplicar medicamentos a los huesos dañados de [target] con su \the [tool]." , \
	"Comienzas a aplicar medicamento en los huesos dañados de [target] con tu [tool].")
	target.custom_pain("Algo en tu [affected.name] te esta causando mucho dolor!")
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='notice'> [user] aplica su [tool] en el hueso de [target]</span>", \
			"<span class='notice'> Aplicas algo de tu [tool] en los huesos de [target] con tu [tool].</span>")

		return 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='warning'> Las manos de [user] se resbalan, manchando su [tool] en la incision de [target] !</span>" , \
		"<span class='warning'> Tus manos se resbalan, manchando tu [tool] en la incision de [target]!</span>")
		return 0

/datum/surgery_step/set_bone
	name = "Recolocar hueso - Bone Setter"

	allowed_tools = list(
	/obj/item/bonesetter = 100,	\
	/obj/item/wrench = 90	\
	)

	time = 32

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !affected.is_robotic()

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a re colocar el hueso de [target] en su lugar con su [tool]." , \
		"Comienzas a recolocar el hueso de [target] en su lugar con tu [tool].")
	target.custom_pain("El dolor de tu [affected.name] te va a desmayar!")
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected.status & ORGAN_BROKEN)
		user.visible_message("<span class='notice'> [user] recoloca el hueso en el [affected.name] de [target] con su [tool].</span>", \
			"<span class='notice'> Recolocas el hueso en el [affected.name] de [target] con [tool].</span>")
		return 1
	else
		user.visible_message("<span class='notice'> [user] recoloca el hueso en el [affected.name] de [target] con tu [tool].</span>", \
			"<span class='notice'> Recolocas el hueso en el [affected.name] de [target] con [tool].</span>")
		return 1

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> La mano de [user] se resbala, da&ntildeando el hueso de [target] en su [affected.name] con su [tool]!</span>" , \
		"<span class='warning'> Tu mano se resbala, da&ntildeando el hueso de [target] en su [affected.name] con tu [tool]!</span>")
	affected.receive_damage(5)
	return 0

/datum/surgery_step/mend_skull
	name = "juntar craneo"

	allowed_tools = list(
	/obj/item/bonesetter = 100,	\
	/obj/item/wrench = 90		\
	)

	time = 32

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !affected.is_robotic() && affected.limb_name == "head"

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] empieza a juntar el craneo de [target] con su [tool]."  , \
		"Empieza a juntar el craneo de [target] con [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] sets [target]'s [affected.encased] with \the [tool].</span>" , \
		"<span class='notice'> You set [target]'s [affected.encased] with \the [tool].</span>")

	return 1

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>La mano de [user] se resbala, da&ntildeando la cara de [target] con su [tool]!</span>"  , \
		"<span class='warning'>Tu mano se resbala, da&ntildeando la cara de [target] con [tool]!</span>")
	var/obj/item/organ/external/head/h = affected
	h.receive_damage(10)
	h.disfigure()
	return 0

/datum/surgery_step/finish_bone
	name = "medicate bones"

	allowed_tools = list(
	/obj/item/bonegel = 100,	\
	/obj/item/screwdriver = 90
	)
	can_infect = 1
	blood_level = 1

	time = 24

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	return affected && !affected.is_robotic()

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] comienza a terminar de reparar los huesos da&ntildeados de [target] en su [affected.name] con su [tool].", \
	"Comienzas a terminar de reparar los huesos da&ntildeados de [target] en su [affected.name] con [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] reparo los huesos da&ntildeados de [target] en su [affected.name] con su [tool].</span>"  , \
		"<span class='notice'> Reparaste los huesos da&ntildeados de [target] en su [affected.name] con su [tool].</span>" )
	affected.mend_fracture()
	return TRUE

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'> La mano de [user] se resbala, manchando su [tool] en la incision de [target]!</span>" , \
	"<span class='warning'> Tu mano se resbala, manchando tu [tool] en la incision de [target].!</span>")
	return 0
