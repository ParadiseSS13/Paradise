/datum/game_test/room_test/attack_chain_stunbaton/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
	player.spawn_obj_in_hand(/obj/item/melee/baton/loaded)

	// Prod with inactive baton.
	player.set_intent("help")
	player.click_on(target)
	TEST_ASSERT_EQUAL(FALSE, target.puppet.getStaminaLoss(), "Inactive baton delt stamina damage.")
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "Inactive help intent baton did damage.")

	// Prod with active baton.
	player.use_item_in_hand()
	player.click_on(target)
	TEST_ASSERT_NOTEQUAL(FALSE, target.puppet.getStaminaLoss(), "Active help baton did not deal stamina damage.")
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "Active help intent baton did damage.")

	target.rejuvenate()
	sleep(4 SECONDS) // Baton cooldown + anti baton timer.

	// Police brutality with active baton.
	player.set_intent("harm")
	player.click_on(target)
	TEST_ASSERT_NOTEQUAL(FALSE, target.puppet.getStaminaLoss(), "Active harm baton did not deal stamina damage.")
	TEST_ASSERT_NOTEQUAL(target.puppet.health, target.puppet.getMaxHealth(), "harm baton did no damage.")
