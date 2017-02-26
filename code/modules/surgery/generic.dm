//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	if(affected.status & ORGAN_DESTROYED)
		return 0
	if(affected.status & ORGAN_ROBOT)
		return 0
	return 1


/datum/surgery_step/generic/cut_open
	name = "make incision"

	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchen/knife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	/obj/item/weapon/scissors = 10,		\
	/obj/item/weapon/twohanded/chainsaw = 1, \
	/obj/item/weapon/claymore = 5, \
	/obj/item/weapon/melee/energy/ = 5, \
	/obj/item/weapon/pen/edagger = 5,  \
	)

	time = 16

/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts the incision on [target]'s [affected.name] with \the [tool].", \
		"You start the incision on [target]'s [affected.name] with \the [tool].")
		target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.name]!",1)
		..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] has made an incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You have made an incision on [target]'s [affected.name] with \the [tool].</span>",)
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	return 1

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, slicing open [target]'s [affected.name] in a wrong spot with \the [tool]!</span>")
	affected.createwound(CUT, 10)
	return 0

/datum/surgery_step/generic/clamp_bleeders
	name = "clamp bleeders"

	allowed_tools = list(
	/obj/item/weapon/scalpel/laser3 = 115, \
	/obj/item/weapon/scalpel/laser2 = 110, \
	/obj/item/weapon/scalpel/laser1 = 105, \
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 20
	)

	time = 24


/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
		var/obj/item/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts clamping bleeders in [target]'s [affected.name] with \the [tool].", \
		"You start clamping bleeders in [target]'s [affected.name] with \the [tool].")
		target.custom_pain("The pain in your [affected.name] is maddening!",1)
		..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] clamps bleeders in [target]'s [affected.name] with \the [tool]</span>.",	\
	"<span class='notice'> You clamp bleeders in [target]'s [affected.name] with \the [tool].</span>")
	affected.clamp()
	spread_germs_to_organ(affected, user)
	return 1

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",	\
	"<span class='warning'> Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.name] with \the [tool]!</span>",)
	affected.createwound(CUT, 10)
	return 0

/datum/surgery_step/generic/retract_skin
	name = "retract skin"

	allowed_tools = list(
	/obj/item/weapon/scalpel/manager = 120, \
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	time = 24

/datum/surgery_step/generic/retract_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.name] with \the [tool]."
	if(target_zone == "chest")
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if(target_zone == "groin")
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [affected.name] is on fire!",1)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'> [user] keeps the incision open on [target]'s [affected.name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'> You keep the incision open on [target]'s [affected.name] with \the [tool].</span>"
	if(target_zone == "chest")
		msg = "<span class='notice'> [user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the ribcage open on [target]'s torso with \the [tool]."
	if(target_zone == "groin")
		msg = "<span class='notice'> [user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'> You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	affected.open = 2
	return 1

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'> [user]'s hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'> Your hand slips, tearing the edges of incision on [target]'s [affected.name] with \the [tool]!</span>"
	if(target_zone == "chest")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
	if(target_zone == "groin")
		msg = "<span class='warning'> [user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'> Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	target.apply_damage(12, BRUTE, affected, sharp=1)
	return 0

/datum/surgery_step/generic/cauterize

	name = "cauterize incision"

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

/datum/surgery_step/generic/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [affected.name] with \the [tool].")
	target.custom_pain("Your [affected.name] is being burned!",1)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] cauterizes the incision on [target]'s [affected.name] with \the [tool].</span>", \
	"<span class='notice'> You cauterize the incision on [target]'s [affected.name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0
	affected.status &= ~ORGAN_BLEEDING
	return 1

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, leaving a small burn on [target]'s [affected.name] with \the [tool]!</span>")
	target.apply_damage(3, BURN, affected)
	return 0

//drill bone
/datum/surgery_step/generic/drill
	name = "drill bone"
	allowed_tools = list(/obj/item/weapon/surgicaldrill = 100, /obj/item/weapon/pickaxe/drill = 60, /obj/item/mecha_parts/mecha_equipment/drill = 60, /obj/item/weapon/screwdriver = 20)
	time = 30

/datum/surgery_step/generic/drill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].", "<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>")
	..()

/datum/surgery_step/generic/drill/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] drills into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>")
	return 1


/datum/surgery_step/generic/amputate
	name = "amputate limb"

	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/melee/energy/sword/cyborg/saw = 100, \
	/obj/item/weapon/hatchet = 75, \
	/obj/item/weapon/melee/arm_blade = 60
	)

	time = 100

/datum/surgery_step/generic/amputate/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(target_zone == "eyes")	//there are specific steps for eye surgery
		return 0
	if(!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(affected == null)
		return 0
	if(affected.status & ORGAN_DESTROYED)
		return 0
	return !affected.cannot_amputate

/datum/surgery_step/generic/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to amputate [target]'s [affected.name] with \the [tool]." , \
	"You are beginning to cut through [target]'s [affected.amputation_point] with \the [tool].")
	target.custom_pain("Your [affected.amputation_point] is being ripped apart!",1)
	..()

/datum/surgery_step/generic/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'> [user] amputates [target]'s [affected.name] at the [affected.amputation_point] with \the [tool].</span>", \
	"<span class='notice'> You amputate [target]'s [affected.name] with \the [tool].</span>")

	add_logs(user, target, "surgically removed [affected.name] from", addition="INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1,DROPLIMB_EDGE)
	if(istype(thing,/obj/item))
		user.put_in_hands(thing)
	return 1

/datum/surgery_step/generic/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'> [user]'s hand slips, sawing through the bone in [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'> Your hand slips, sawwing through the bone in [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(CUT, 30)
	affected.fracture()
	return 0
