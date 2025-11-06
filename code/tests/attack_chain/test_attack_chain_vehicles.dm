/datum/game_test/room_test/attack_chain_vehicles/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/item/key/janitor/janicart_key = player.spawn_obj_in_hand(/obj/item/key/janitor)
	var/obj/vehicle/janicart/janicart = player.spawn_obj_nearby(/obj/vehicle/janicart)

	player.click_on(janicart)
	TEST_ASSERT_EQUAL(janicart.inserted_key, janicart_key, "did not find janicart key in vehicle")

	player.spawn_obj_in_hand(/obj/item/borg/upgrade/vtec)
	player.click_on(janicart)
	TEST_ASSERT(player.last_chatlog_has_text("You upgrade the janicart"), "VTEC upgrade not applied properly")

	TEST_ASSERT_NULL(janicart.mybag, "unexpected trash bag on janicart")
	var/obj/item/storage/bag/trash/bag = player.spawn_obj_in_hand(/obj/item/storage/bag/trash)
	player.click_on(janicart)
	TEST_ASSERT_EQUAL(janicart.mybag, bag, "trash bag not attached to janicart")

	var/obj/item/kitchen/knife/knife = player.spawn_obj_in_hand(/obj/item/kitchen/knife)
	player.set_intent("harm")
	player.click_on(janicart)
	TEST_ASSERT(janicart.obj_integrity < janicart.max_integrity, "knife attack not performed")

	player.set_intent("help")
	player.click_on(janicart)
	TEST_ASSERT(knife in bag, "knife not placed in trash bag")
