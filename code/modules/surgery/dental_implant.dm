/datum/surgery_step/dental
	possible_locs = list("mouth")
	can_infect = TRUE

/datum/surgery_step/dental/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = FALSE
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		. = H.check_has_mouth()

/datum/surgery_step/dental/drill
	name = "drill bone"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_DENTAL
	allowed_surgery_behaviour = SURGERY_DRILL_BONE
	time = 30

/datum/surgery_step/dental/drill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].", "<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>")
	..()

/datum/surgery_step/dental/drill/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] drills into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>")
	return TRUE

/datum/surgery_step/dental/insert_pill
	name = "insert pill"
	surgery_start_stage = SURGERY_STAGE_DENTAL
	next_surgery_stage = SURGERY_STAGE_START
	allowed_surgery_behaviour = SURGERY_INSERT_PILL
	time = 16

/datum/surgery_step/dental/insert_pill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to wedge \the [tool] in [target]'s [parse_zone(target_zone)].", "<span class='notice'>You begin to wedge [tool] in [target]'s [parse_zone(target_zone)]...</span>")
	..()

/datum/surgery_step/dental/insert_pill/end_step(mob/living/user, mob/living/carbon/target, target_zone, var/obj/item/reagent_containers/food/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return FALSE

	var/dental_implants = 0
	for(var/obj/item/reagent_containers/food/pill in target.contents) // Can't give them more than 4 dental implants.
		dental_implants++
	if(dental_implants >= 4)
		user.visible_message("[user] pulls \the [tool] back out of [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You pull \the [tool] back out of [target]'s [parse_zone(target_zone)], there wans't enough room...</span>")
		return FALSE

	user.drop_item()
	tool.forceMove(target)

	var/datum/action/item_action/hands_free/activate_pill/P = new
	P.button_icon_state = tool.icon_state
	P.target = tool
	P.name = "Activate Pill ([tool.name])"
	P.Grant(target)

	user.visible_message("[user] wedges \the [tool] into [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You wedge [tool] into [target]'s [parse_zone(target_zone)].</span>")
	return TRUE

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return
	to_chat(owner, "<span class='caution'>You grit your teeth and burst the implanted [target]!</span>")
	add_attack_logs(owner, owner, "Swallowed implanted [target]")
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume)
	Remove(owner)
	qdel(target)
	return 1