/datum/game_test/attack_chain_condiment/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/item/reagent_containers/saltshaker = player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/saltshaker)

	var/obj/structure/reagent_dispensers/watertank = player.spawn_obj_nearby(/obj/structure/reagent_dispensers/watertank)
	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "[saltshaker] is full!")

	var/obj/machinery/kitchen_machine/grill = player.spawn_obj_nearby(/obj/machinery/kitchen_machine/grill)
	player.click_on(grill)
	TEST_ASSERT_ANY_CHATLOG(player, "You transfer")
	TEST_ASSERT_NOT_CHATLOG(player, "You hit")

	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You swallow some")

	saltshaker.reagents.total_volume = 0
	player.click_on(grill)
	TEST_ASSERT_LAST_CHATLOG(player, "is empty!")
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "None of [saltshaker] left, oh no!")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill")

	var/obj/item/storage/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

	var/obj/item/food/sliced/margherita_pizza = player.spawn_obj_nearby(/obj/item/food/sliced/margherita_pizza)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(margherita_pizza)
	TEST_ASSERT_LAST_CHATLOG(player, "You tear open")

	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")