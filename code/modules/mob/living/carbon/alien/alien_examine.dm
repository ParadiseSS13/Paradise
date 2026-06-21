/mob/living/carbon/alien/examine_what_am_i(skip_gloves = FALSE, skip_suit_storage = FALSE, skip_jumpsuit = FALSE, skip_shoes = FALSE, skip_mask = FALSE, skip_ears = FALSE, skip_eyes = FALSE, skip_face = FALSE)
	return ", an <b><font color='#473879'>alien</font></b>!"

/mob/living/carbon/alien/examine_visible_clothing(skip_gloves, skip_suit_storage, skip_jumpsuit, skip_shoes, skip_mask, skip_ears, skip_eyes, skip_face)
	return list(
		list("[p_are()] holding", l_hand, "in", "left claw"),
		list("[p_are()] holding", r_hand, "in", "right claw"),
		list("[p_are()] wearing", head, "on", "head"),
		list("[p_are()] wearing", wear_suit, null, null),
		list("[p_have()]", back, "on", "back"),
	)

/mob/living/carbon/alien/examine_show_ssd()
	if(!key)
		return "[SPAN_DEADSAY("[p_they(TRUE)] [p_are()] completely catatonic, an unfocused look in [p_their()] eyes.")]\n"
	else if(!client)
		return "[p_they(TRUE)] [p_have()] suddenly fallen asleep, suffering from Space Sleep Disorder. [p_they(TRUE)] may wake up soon.\n"

	return ""
