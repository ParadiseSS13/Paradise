/datum/game_test/attack_chain_drinks/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/structure/reagent_dispensers/watertank/watertank = player.spawn_obj_nearby(/obj/structure/reagent_dispensers/watertank)
	var/obj/item/reagent_containers/glass/bucket/bucket = player.spawn_obj_nearby(/obj/item/reagent_containers/glass/bucket)
	var/obj/item/storage/backpack/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)

	// Drinks
	var/obj/item/reagent_containers/drinks/coffee/coffee = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/coffee)
	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [coffee]")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	coffee.reagents.total_volume = 0
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "None of [coffee] left, oh no!")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "[coffee] is empty.")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [coffee] with")

	player.click_on(backpack)
	TEST_ASSERT(coffee in backpack.contents, "player failed to put [coffee] in backpack")

	bucket.reagents.total_volume = 0
	qdel(coffee)

	// Cans
	var/obj/item/reagent_containers/drinks/cans/can = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/cans/cola)

	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You need to open [can] first!")

	player.use_item_in_hand()
	TEST_ASSERT_LAST_CHATLOG(player, "You open the drink with an audible pop!")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [can] with")

	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [can]")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	player.set_zone("head")
	player.set_intent("harm")
	can.reagents.total_volume = 0
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You crush [can] on your forehead.")

	can = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/cans/cola)
	player.set_intent("help")
	player.click_on(backpack)
	TEST_ASSERT(can in backpack.contents, "player failed to put can in backpack")
	qdel(can)

	// Bottles
	var/obj/item/reagent_containers/drinks/bottle/whiskey/bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [bottle]")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [bottle] with")

	player.set_intent("harm")
	player.click_on(player)
	TEST_ASSERT(player.check_attack_log("Hit with [bottle]"), "player failed to smash a bottle on harm intent")
	TEST_ASSERT_NOTEQUAL(player.puppet.health, player.puppet.getMaxHealth(), "bottle smash didnt deal damage")
	player.puppet.drop_item()
	player.set_intent("help")

	bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)
	player.click_on(backpack)
	TEST_ASSERT(bottle in backpack.contents, "player failed to put bottle in backpack")
	qdel(bottle)

	// TODO: Figure out molotov
