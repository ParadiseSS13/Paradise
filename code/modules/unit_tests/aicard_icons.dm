/datum/unit_test/aicard_icons/Run()
	var/mob/living/silicon/ai/ai_box = new /mob/living/silicon/ai/
	var/obj/item/aicard/int_card = new /obj/item/aicard/

	var/list/ai_icon_list = ai_box.icon
	var/list/aicard_icon_list = int_card.icon

	var/list/ai_icon_exclusions = list("eye", "ai-holo-old", "holo-angel", "holo-borb", "holo-biggestfan", "holo-cloudkat", "holo-donut", "holo-frostphoenix", "holo1", "holo2", "holo3", "holo4", "0", "1", "2", "3", "3b", "4")

	ai_icon_list = ai_icon_list - ai_icon_exclusions

	for(var/icn_st in ai_icon_list)
		if(!(locate(icn_st) in aicard_icon_list))
			Fail("Every AI Display must have a corresponding icon of the same name in [int_card.icon] for intelicards, [icn_st] is missing!")

	//The exclusions list will need to be updated anytime any non-display icons are added to ai.dmi
