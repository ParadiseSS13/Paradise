/datum/cooking/recipe/test_soylent
	container_type = /obj/item/reagent_containers/cooking/pot
	product_type = /obj/item/food/soylentgreen
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
		PCWJ_ADD_REAGENT("water", 10),
		PCWJ_USE_STOVE(J_MED, 1 SECONDS),
	)
	appear_in_default_catalog = FALSE

/datum/game_test/room_test/cooking/Run()
	var/datum/test_puppeteer/player = new(src)
	player.puppet.name = "Player"

	// Burger
	var/obj/structure/table/table = player.spawn_obj_nearby(__IMPLIED_TYPE__, SOUTH)
	var/obj/item/reagent_containers/cooking/board/board = player.spawn_obj_nearby(__IMPLIED_TYPE__, SOUTH)
	player.spawn_obj_in_hand(/obj/item/food/bun)
	player.click_on(board)
	TEST_ASSERT_LAST_CHATLOG(player, "You add the bun")
	player.spawn_obj_in_hand(/obj/item/food/meat/patty)
	player.click_on(board)
	TEST_ASSERT_LAST_CHATLOG(player, "You add the patty")
	player.spawn_obj_in_hand(/obj/item/food/grown/lettuce)
	player.click_on(board)
	TEST_ASSERT_LAST_CHATLOG(player, "You finish cooking with the cutting board")
	player.alt_click_on(board)
	TEST_ASSERT(locate(/obj/item/food/burger) in get_turf(board), "could not find completed burger")

	// Soylent
	var/obj/machinery/cooking/stovetop/stove = player.spawn_obj_nearby(__IMPLIED_TYPE__, EAST)
	var/obj/item/reagent_containers/cooking/pot/pot = player.spawn_obj_in_hand(__IMPLIED_TYPE__)
	player.click_on(table)
	var/obj/item/food/meat/human/meat = player.spawn_obj_in_hand(__IMPLIED_TYPE__)
	player.click_on(pot)
	TEST_ASSERT_LAST_CHATLOG(player, "You add [meat]")
	player.spawn_obj_in_hand(/obj/item/food/meat/human)
	player.click_on(pot)
	var/obj/item/reagent_containers/glass/beaker/beaker = player.spawn_obj_in_hand(__IMPLIED_TYPE__)
	beaker.reagents.add_reagent("water", 10)
	player.click_on(pot)
	player.put_away(beaker)
	player.click_on(pot)
	player.click_on(stove, "icon-x=18&icon-y=18")
	var/surface_idx = stove.clickpos_to_surface(list("icon-x" = 18, "icon-y" = 18))
	var/datum/cooking_surface/surface = stove.surfaces[surface_idx]
	surface.temperature = J_MED
	surface.turn_on(player.puppet)
	var/attempt_count = 10
	while(attempt_count)
		sleep(1 SECONDS)
		if(locate(/obj/item/food/soylentgreen) in pot)
			surface.turn_off(player.puppet)
			return
		attempt_count--

	TEST_FAIL("could not find complete soylent after 10 attempts")
