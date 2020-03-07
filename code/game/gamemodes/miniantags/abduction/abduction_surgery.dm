/datum/surgery_step/internal/manipulate_organs/abduct
	priority = 20 //DO THIS NOT THE IMPLANT ORGAN ONE!
	possible_locs = list("chest", "head")
	time = 32
	requires_organic_bodypart = FALSE // Also for IPCs

/datum/surgery_step/internal/manipulate_organs/abduct/is_valid_target(mob/living/carbon/human/target)
	return ishuman(target)

/datum/surgery_step/internal/manipulate_organs/abduct/is_valid_user(mob/living/carbon/human/user)
	return ishuman(user) && (isabductor(user) || (locate(/obj/item/implant/abductor) in user))

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ
	name = "remove heart"
	accept_hand = TRUE
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_OPEN_INCISION_BONES, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	allowed_surgery_tools = SURGERY_TOOLS_EXTRACT_ORGAN
	var/obj/item/organ/internal/heart/foundHeart = null

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.get_organs_zone(target_zone))
		// Allows for multiple subtypes of heart.
		if(istype(I, /obj/item/organ/internal/heart))
			foundHeart = I
			break
	if(!foundHeart)
		to_chat(user, "<span class='warning'>You can't seem to find an organ that functions like a heart in [target].</span>")
		return -1
	user.visible_message("<span class='warning'>[user] starts to remove [target]'s organs.</span>", "<span class='notice'>You start to remove [target]'s organs...</span>")
	..()

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(foundHeart)
		user.visible_message("<span class='warning'>[user] pulls [foundHeart] out of [target]'s [target_zone]!</span>", "<span class='notice'>You pull [foundHeart] out of [target]'s [target_zone].</span>")
		user.put_in_hands(foundHeart)
		foundHeart.remove(target, special = TRUE)
		return TRUE
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return TRUE

/datum/surgery_step/internal/manipulate_organs/abduct/extract_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to extract anything!</span>", "<span class='warning'>Your hand slips, failing to extract anything!</span>")
	return FALSE

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert
	name = "insert gland"
	surgery_start_stage = list(SURGERY_STAGE_OPEN_INCISION, SURGERY_STAGE_OPEN_INCISION_BONES, SURGERY_STAGE_ROBOTIC_HATCH_OPEN)
	next_surgery_stage = SURGERY_STAGE_SAME
	accept_any_item = TRUE // can_use will check if it's a gland

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return ..() && istype(tool, /obj/item/organ/internal/heart/gland)

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/I in target.get_organs_zone(target_zone))
		// Allows for multiple subtypes of heart.
		if(istype(I, /obj/item/organ/internal/heart))
			to_chat(user, "<span class='warning'>Remove the original heart first!</span>")
			return -1
	
	user.visible_message("<span class ='notice'>[user] starts to insert [tool] into [target].</span>", "<span class ='notice'>You start to insert [tool] into [target]...</span>")
	..()

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class ='notice'>[user] inserts [tool] into [target].</span>", "<span class ='notice'>You insert [tool] into [target].</span>")
	user.drop_item()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, 2)
	target.setOxyLoss(0)
	target.set_heartattack(FALSE)
	for(var/v in target.viruses)
		if(istype(v, /datum/disease/critical))
			var/datum/disease/critical/V = v
			V.cure()
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.mend_fracture() // Aylmao tech baby
	return TRUE

/datum/surgery_step/internal/manipulate_organs/abduct/gland_insert/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user]'s hand slips, failing to insert the gland!</span>", "<span class='warning'>Your hand slips, failing to insert the gland!</span>")
	return FALSE
