/datum/surgery/dental_implant
	name = "dental implant"
	steps = list(/datum/surgery_step/generic/drill, /datum/surgery_step/insert_pill)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)

/datum/surgery/dental_implant/can_start(mob/user, mob/living/carbon/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.check_has_mouth())
			return FALSE
		return TRUE

/datum/surgery_step/insert_pill
	name = "insert pill"
	allowed_tools = list(/obj/item/reagent_containers/pill = 100)
	time = 1.6 SECONDS

/datum/surgery_step/insert_pill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"[user] begins to wedge \the [tool] in [target]'s [parse_zone(target_zone)].",
		"<span class='notice'>You begin to wedge [tool] in [target]'s [parse_zone(target_zone)]...</span>",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/insert_pill/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/reagent_containers/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return SURGERY_STEP_INCOMPLETE

	var/dental_implants = 0
	for(var/obj/item/reagent_containers/pill in target.contents) // Can't give them more than 4 dental implants.
		dental_implants++
	if(dental_implants >= 4)
		user.visible_message("[user] pulls \the [tool] back out of [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You pull \the [tool] back out of [target]'s [parse_zone(target_zone)], there wans't enough room...</span>", chat_message_type = MESSAGE_TYPE_COMBAT)
		return SURGERY_STEP_INCOMPLETE

	user.drop_item()
	tool.forceMove(target)

	var/datum/action/item_action/hands_free/activate_pill/P = new(tool)
	P.name = "Activate Pill ([tool.name])"
	P.Grant(target)

	user.visible_message("[user] wedges \the [tool] into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You wedge [tool] into [target]'s [parse_zone(target_zone)].</span>", chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_CONTINUE

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/New(Target, obj/item/tool)
	button_icon = tool.icon
	button_icon_state = tool.icon_state
	return ..()

/datum/action/item_action/hands_free/activate_pill/Trigger(left_click = TRUE)
	if(!..(left_click, FALSE))
		return
	to_chat(owner, "<span class='caution'>You grit your teeth and burst the implanted [target]!</span>")
	add_attack_logs(owner, owner, "Swallowed implanted [target]")
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, REAGENT_INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume)
	Remove(owner)
	qdel(target)
	return TRUE

