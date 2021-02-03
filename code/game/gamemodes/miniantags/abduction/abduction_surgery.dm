/datum/surgery_step/internal/manipulate_organs/abduct
	priority = 20 //DO THIS NOT THE IMPLANT ORGAN ONE!
	possible_locs = list("chest", "head")
	time = 3.2 SECONDS
	requires_organic_bodypart = FALSE // Also for IPCs

/datum/surgery_step/internal/manipulate_organs/abduct/is_valid_target(mob/living/carbon/human/target)
	return istype(target)

/datum/surgery_step/internal/manipulate_organs/abduct/is_valid_user(mob/living/carbon/human/user)
	return isabductor(user) || (istype(user) && (locate(/obj/item/implant/abductor) in user))

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ
	name = "remove heart"
	accept_hand = TRUE
	surgery_start_stage = list(SURGERY_STAGE_SKIN_RETRACTED, SURGERY_STAGE_BONES_RETRACTED, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	allowed_surgery_tools = SURGERY_TOOLS_EXTRACT_ORGAN
	var/obj/item/organ/internal/heart/found_heart = null

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	found_heart = locate(/obj/item/organ/internal/heart) in target.get_organs_zone(target_zone)
	if(!found_heart)
		to_chat(user, "<span class='warning'>You can't seem to find an organ that functions like a heart in [target].</span>")
		return SURGERY_FAILED
	user.visible_message("<span class='warning'>[user] starts to remove [target]'s organs.</span>", "<span class='notice'>You start to remove [target]'s organs...</span>")
	return ..()

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(found_heart)
		user.visible_message("<span class='warning'>[user] pulls [found_heart] out of [target]'s [target_zone]!</span>", \
		"<span class='notice'>You pull [found_heart] out of [target]'s [target_zone].</span>")
		user.put_in_hands(found_heart)
		found_heart.remove(target, special = TRUE)
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")

	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to extract anything!</span>", \
	"<span class='warning'>Your hand slips, failing to extract anything!</span>")
	return SURGERY_FAILED

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert
	name = "insert gland"
	surgery_start_stage = list(SURGERY_STAGE_SKIN_RETRACTED, SURGERY_STAGE_BONES_RETRACTED, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	accept_any_item = TRUE // can_use will check if it's a gland

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return ..() && istype(tool, /obj/item/organ/internal/heart/gland)

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/found_heart = locate(/obj/item/organ/internal/heart) in target.get_organs_zone(target_zone)
	if(found_heart)
		to_chat(user, "<span class='warning'>Remove the original heart first!</span>")
		return SURGERY_FAILED

	user.visible_message("<span class='notice'>[user] starts to insert [tool] into [target].</span>", "<span class='notice'>You start to insert [tool] into [target]...</span>")
	return ..()

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] inserts [tool] into [target].</span>", \
	"<span class='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, 2)
	target.setOxyLoss(0)
	target.set_heartattack(FALSE)
	for(var/datum/disease/critical/V in target.viruses)
		V.cure()
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.mend_fracture() // Aylmao tech baby
	return SURGERY_SUCCESS

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to insert [tool]!</span>", \
	"<span class='warning'>Your hand slips, failing to insert [tool]!</span>")
	return SURGERY_FAILED
