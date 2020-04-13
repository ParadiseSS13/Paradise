//Procedures in this file: Unsealing a Rig.

/datum/surgery/rigsuit
	name = "Rig Unsealing"
	steps = list(/datum/surgery_step/rigsuit)
	possible_locs = list("chest")

/datum/surgery/rigsuit/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/backitem = H.get_item_by_slot(slot_back)
		if(istype(backitem,/obj/item/rig)) //Check if we have a rig to operate on
			if(backitem.flags&NODROP) //Check if the rig is sealed, if not, we don't need to operate
				return 1
	return 0

//Bay12 removal
/datum/surgery_step/rigsuit
	name="Cut Seals"
	allowed_tools = list(
		/obj/item/weldingtool = 80,
		/obj/item/circular_saw = 60,
		/obj/item/gun/energy/plasmacutter = 100
		)

	can_infect = 0
	blood_level = 0

	time = 50

/datum/surgery_step/hardsuit/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!istype(target))
		return 0
	if(tool.tool_behaviour == TOOL_WELDER)
		if(!tool.tool_use_check(user, 0))
			return
		if(!tool.use(1))
			return
	return (target_zone == "chest") && istype(target.back, /obj/item/rig) && (target.back.flags&NODROP)

/datum/surgery_step/rigsuit/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through the support systems of [target]'s [target.back] with \the [tool]." , \
	"You start cutting through the support systems of [target]'s [target.back] with \the [tool].")
	..()

/datum/surgery_step/rigsuit/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/rig/rig = target.back
	if(!istype(rig))
		return
	rig.reset()
	user.visible_message("<span class='notice'>[user] has cut through the support systems of [target]'s [rig] with \the [tool].</span>", \
		"<span class='notice'>You have cut through the support systems of [target]'s [rig] with \the [tool].</span>")
	return 1

/datum/surgery_step/rigsuit/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='danger'>[user]'s [tool] can't quite seem to get through the metal...</span>", \
	"<span class='danger'>Your [tool] can't quite seem to get through the metal. It's weakening, though - try again.</span>")
	return 0
