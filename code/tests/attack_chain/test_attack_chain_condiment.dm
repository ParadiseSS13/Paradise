/datum/game_test/attack_chain_condiment/Run()
	var/datum/test_puppeteer/player = new(src)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/saltshaker)

	var/obj/machinery/kitchen_machine/grill = player.spawn_obj_nearby(/obj/machinery/kitchen_machine/grill)
	player.click_on(grill)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")
	TEST_ASSERT_NOT(player.last_chatlog_has_text("You hit"), "player hit grille with condiment")

	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You swallow some")

	var/obj/item/storage/backpack/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack) // doesnt work for some arcane reason
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

	var/obj/item/food/sliced/margherita_pizza = player.spawn_obj_nearby(/obj/item/food/sliced/margherita_pizza)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(margherita_pizza)
	TEST_ASSERT_LAST_CHATLOG(player, "You tear open")

	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")