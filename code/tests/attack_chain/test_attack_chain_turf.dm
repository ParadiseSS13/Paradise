/datum/game_test/attack_chain_turf/Run()
	var/datum/test_puppeteer/player = new(src)
	var/area/admin_area = get_area(player.puppet)

	// So we can actually place a mounted frame here
	admin_area.requires_power = TRUE
	var/turf/wall = player.change_turf_nearby(/turf/simulated/wall, EAST)
	player.spawn_obj_in_hand(/obj/item/mounted/frame/alarm_frame)
	player.click_on(wall)
	TEST_ASSERT(locate(/obj/machinery/alarm) in player.puppet.loc, "Did not find built air alarm frame")
	admin_area.requires_power = FALSE

	var/turf/plating = player.change_turf_nearby(/turf/simulated/floor/plating)
	var/obj/item/stack/rods/rods = player.spawn_obj_in_hand(/obj/item/stack/rods/fifty)
	rods.toolspeed = 0 // Don't want to try waiting this out in a test
	player.click_on(plating)
	var/turf/engine = get_turf(plating)
	TEST_ASSERT(istype(engine, /turf/simulated/floor/engine), "Did not find plating converted to engine floor")
	player.puppet.unEquip(rods, force = TRUE)

	var/obj/item/storage/bag/ore/ore_bag = player.spawn_obj_in_hand(/obj/item/storage/bag/ore)
	var/obj/item/stack/ore/gold/gold = player.spawn_obj_nearby(/obj/item/stack/ore/gold, SOUTH)
	var/turf/asteroid = player.change_turf_nearby(/turf/simulated/floor/plating/asteroid, SOUTH)
	player.click_on(asteroid)
	TEST_ASSERT(gold in ore_bag, "Did not find gold in ore bag")
