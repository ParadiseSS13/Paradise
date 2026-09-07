/datum/game_test/room_test/aicard_icons/Run()
	var/mob/living/silicon/ai/ai_box = allocate(/mob/living/silicon/ai)
	var/obj/item/aicard/int_card = allocate(/obj/item/aicard)

	var/list/ai_icon_list = icon_states(ai_box.icon)
	var/list/aicard_icon_list = icon_states(int_card.icon)

	var/list/ai_icon_exclusions = list("eye", "ai-holo-old", "holo-angel", "holo-borb", "holo-biggestfan", "holo-cloudkat", "holo-donut", "holo-frostphoenix", "holo1", "holo2", "holo3", "holo4", "0", "1", "2", "3", "3b", "4")

	for(var/excl in ai_icon_exclusions)
		ai_icon_list -= excl

	for(var/icn_st in ai_icon_list)
		if(icn_st in aicard_icon_list)
			continue

		TEST_FAIL("Every AI Display must have a corresponding icon of the same name in [int_card.icon] for intelicards, [icn_st] is missing!")

	//The exclusions list will need to be updated anytime any non-display icons are added to ai.dmi
