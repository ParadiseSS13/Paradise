#define MAX_TEETH_PILL_IMPLANTS 4

/datum/surgery_step/dental
	possible_locs = list("mouth")
	can_infect = TRUE

/datum/surgery_step/dental/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target) && target.check_has_mouth()

/datum/surgery_step/dental/drill
	name = "drill bone"
	surgery_start_stage = SURGERY_STAGE_START
	next_surgery_stage = SURGERY_STAGE_DENTAL
	allowed_surgery_tools = SURGERY_TOOLS_DRILL
	time = 3 SECONDS

/datum/surgery_step/dental/drill/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to drill into [target]'s [parse_zone(target_zone)].</span>", "<span class='notice'>You begin to drill into [target]'s [parse_zone(target_zone)]...</span>")
	return ..()

/datum/surgery_step/dental/drill/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] drills into [target]'s [parse_zone(target_zone)]!</span>", "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>")
	return SURGERY_SUCCESS

/datum/surgery_step/dental/insert_pill
	name = "insert pill"
	surgery_start_stage = SURGERY_STAGE_DENTAL
	next_surgery_stage = SURGERY_STAGE_START
	accept_any_item = TRUE // can_use will check if it's a pill or not
	time = 1.6 SECONDS

/datum/surgery_step/dental/insert_pill/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/reagent_containers/food/pill/tool, datum/surgery/surgery)
	return ..() && istype(tool)

/datum/surgery_step/dental/insert_pill/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/reagent_containers/food/pill/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to wedge [tool] in [target]'s [parse_zone(target_zone)].</span>", "<span class='notice'>You begin to wedge [tool] in [target]'s [parse_zone(target_zone)]...</span>")
	return ..()

/datum/surgery_step/dental/insert_pill/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/reagent_containers/food/pill/tool, datum/surgery/surgery)
	var/dental_implants = 0
	for(var/obj/item/reagent_containers/food/pill in (target.contents - target.l_store - target.r_store)) // Can't give them more than 4 dental implants.
		dental_implants++
	if(dental_implants >= MAX_TEETH_PILL_IMPLANTS)
		user.visible_message("<span class='notice'>[user] pulls [tool] back out of [target]'s [parse_zone(target_zone)]!</span>", "<span class='notice'>You pull [tool] back out of [target]'s [parse_zone(target_zone)], there wasn't enough room...</span>")
		return SURGERY_FAILED

	user.drop_item()
	tool.forceMove(target)

	var/datum/action/item_action/hands_free/activate_pill/P = new(tool)
	P.button_icon_state = tool.icon_state
	P.name = "Activate Pill ([tool.name])"
	P.Grant(target)

	user.visible_message("<span class='notice'>[user] wedges [tool] into [target]'s [parse_zone(target_zone)]!</span>", "<span class='notice'>You wedge [tool] into [target]'s [parse_zone(target_zone)].</span>")
	return SURGERY_SUCCESS

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return
	to_chat(owner, "<span class='caution'>You grit your teeth and burst the implanted [target]!</span>")
	add_attack_logs(owner, owner, "Swallowed implanted [target]")
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, REAGENT_INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume)
	Remove(owner)
	qdel(target)
	return TRUE

#undef MAX_TEETH_PILL_IMPLANTS
