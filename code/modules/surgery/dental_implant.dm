/datum/surgery/dental_implant
	name = "dental implant"
	steps = list(/datum/surgery_step/generic/drill, /datum/surgery_step/insert_pill)
	possible_locs = list("mouth")

/datum/surgery/dental_implant/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!H.check_has_mouth())
			return 0
		return 1

/datum/surgery_step/insert_pill
	name = "insert pill"
	allowed_tools = list(/obj/item/weapon/reagent_containers/food/pill = 100)
	time = 16

/datum/surgery_step/insert_pill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to wedge \the [tool] in [target]'s [parse_zone(target_zone)].", "<span class='notice'>You begin to wedge [tool] in [target]'s [parse_zone(target_zone)]...</span>")
	..()

/datum/surgery_step/insert_pill/end_step(mob/living/user, mob/living/carbon/target, target_zone, var/obj/item/weapon/reagent_containers/food/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return 0

	var/dental_implants = 0
	for(var/obj/item/weapon/reagent_containers/food/pill in target.internal_organs) // Can't give them more than 4 dental implants.
		dental_implants++
	if(dental_implants >= 4)
		user.visible_message("[user] pulls \the [tool] back out of [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You pull \the [tool] back out of [target]'s [parse_zone(target_zone)], there wans't enough room...</span>")
		return 0

	user.drop_item()
	target.internal_organs += tool
	tool.forceMove(target)

	var/datum/action/item_action/hands_free/activate_pill/P = new
	P.button_icon_state = tool.icon_state
	P.target = tool
	P.name = "Activate Pill ([tool.name])"
	P.Grant(target)

	user.visible_message("[user] wedges \the [tool] into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You wedge [tool] into [target]'s [parse_zone(target_zone)].</span>")
	return 1

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return
	to_chat(owner, "<span class='caution'>You grit your teeth and burst the implanted [target]!</span>")
	add_logs(owner, null, "swallowed an implanted pill", target)
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume)
	Remove(owner)
	qdel(target)
	return 1