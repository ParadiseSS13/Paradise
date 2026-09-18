/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	weight = 6
	combos = list(/datum/martial_combo/plasma_fist/tornado_sweep, /datum/martial_combo/plasma_fist/throwback, /datum/martial_combo/plasma_fist/plasma_fist)
	has_explaination_verb = TRUE

/datum/martial_art/plasma_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(A,D)
	return TRUE

/datum/martial_art/plasma_fist/explaination_header(user)
	to_chat(user, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")

/obj/item/plasma_fist_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	new_attack_chain = TRUE

/obj/item/plasma_fist_scroll/activate_self(mob/living/carbon/human/user)
	if(!ishuman(user))
		return ..()

	var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
	F.teach(user)
	to_chat(user, SPAN_BOLDANNOUNCEIC("You have learned the ancient martial art of Plasma Fist."))
	user.drop_item_to_ground(src, TRUE)
	visible_message(SPAN_WARNING("[src] crumbles to dust!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_COMPLETE
