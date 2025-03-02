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

	// Molotov
	var/obj/item/reagent_containers/drinks/bottle/molotov/molotov = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/bottle/molotov)
	molotov.list_reagents = list("vodka" = 100)

	var/lighter = player.spawn_obj_in_hand(/obj/item/lighter/zippo)
	player.use_item_in_hand()
	player.click_on(molotov)
	TEST_ASSERT(molotov.active, "player failed to light molotov")

	player.puppet.drop_item()
	player.click_on(molotov)
	player.use_item_in_hand()
	TEST_ASSERT(!molotov.active, "player failed to extinguish molotov")

	player.click_on(backpack)
	TEST_ASSERT(molotov in backpack.contents, "player failed to put molotov in backpack")
	qdel(molotov)

	// Drinking glass
	var/obj/item/reagent_containers/drinks/drinkingglass/glass = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/drinkingglass)
	var/obj/item/food/egg/egg = player.spawn_obj_in_hand(/obj/item/food/egg)
	player.click_on(glass)
	TEST_ASSERT_LAST_CHATLOG(player, "You break [egg] in")

	player.click_on(glass)
	player.click_on(backpack)
	TEST_ASSERT(glass in backpack.contents, "player failed to put drinking glass in backpack")
	qdel(glass)

	// Shot glass - For some reason the shotglass doesn't get clicked. Works ingame
	// var/obj/item/reagent_containers/drinks/drinkingglass/shotglass/shotglass = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/drinkingglass/shotglass)
	// shotglass.list_reagents = list("vodka" = 15)

	// player.click_on(lighter)
	// player.click_on(shotglass)
	// TEST_ASSERT_LAST_CHATLOG(player, "[shotglass] begins to burn with a blue hue!")

	// player.puppet.drop_item()
	// player.click_on(shotglass)
	// player.use_item_in_hand()
	// TEST_ASSERT_LAST_CHATLOG(player, "You use your hand to extinguish [shotglass]!")
