/datum/game_test/attack_chain_drinks/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
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

	// Bottles
	var/obj/item/reagent_containers/drinks/bottle/whiskey/bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)
	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "[bottle] is full.")

	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [bottle]")

	player.set_intent("harm")
	player.click_on(player)
	TEST_ASSERT(player.check_attack_log("Hit with [bottle]"), "player failed to smash a bottle on harm intent")
	TEST_ASSERT_NOTEQUAL(player.puppet.health, player.puppet.getMaxHealth(), "bottle smash didnt deal damage")

	// Get backpack putting working
	// player.puppet.drop_item()
	// player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)
	// player.click_on(backpack)
	// TEST_ASSERT_LAST_CHATLOG(player, "You put")

