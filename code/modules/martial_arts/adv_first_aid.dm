/datum/martial_art/adv_first_aid
	name = "Advanced First Aid"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/adv_first_aid/set_bone, /datum/martial_combo/adv_first_aid/mend_bleeding)

/datum/martial_art/adv_first_aid/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	to_chat(H, "<span class = 'userdanger'>You have learnt advanced first aid!</span>")

/datum/martial_art/adv_first_aid/remove(mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the tecnhniques of advanced first aid...</span>")

/datum/martial_art/adv_first_aid/explaination_header(user)
	to_chat(user, "<b><i>You focus on your medical training.</i></b>")
