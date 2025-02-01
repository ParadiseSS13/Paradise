/datum/game_test/attack_chain_applicator/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
	var/obj/item/reagent_containers/applicator/mender = player.spawn_obj_in_hand(/obj/item/reagent_containers/applicator/burn)

	mender.delay = 0
	target.puppet.apply_damage(1, BURN)
	player.click_on(target)
	TEST_ASSERT(target.check_attack_log("Automends with"), "player failed to use mender on target")
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "mender failed to mend damage")

	player.puppet.attack_log_old = null
	player.puppet.apply_damage(1, BURN)
	player.use_item_in_hand()
	TEST_ASSERT(player.check_attack_log("Automends with"), "player failed to use mender on target")
	TEST_ASSERT_EQUAL(player.puppet.health, player.puppet.getMaxHealth(), "mender failed to mend damage")

	mender.reagents.total_volume = 0
	player.click_on(target)
	TEST_ASSERT_LAST_CHATLOG(player, "[mender] is empty")

	var/obj/item/storage/backpack/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

	// ToasTODO: Add an AltClick test
