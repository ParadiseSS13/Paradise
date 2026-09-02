/datum/game_test/test_apc_construction/Run()
	var/datum/test_puppeteer/player = new(src)
	var/turf/wall = player.change_turf_nearby(/turf/simulated/wall, NORTH)
	// Allow APC construction.
	var/area/test_area = get_area(player.puppet)
	test_area.requires_power = TRUE
	// First we build the APC
	var/obj/crowbar = player.spawn_obj_in_hand(/obj/item/crowbar)
	var/player_floor = player.puppet.loc
	player.click_on(player_floor)
	player.put_away(crowbar)
	player.spawn_obj_in_hand(/obj/item/mounted/frame/apc_frame)
	player.click_on(wall)
	var/obj/machinery/power/apc/apc_frame = player.find_nearby(/obj/machinery/power/apc)
	// Make this not take 5 billion years.
	apc_frame.apc_frame_welding_time = 0
	apc_frame.apc_terminal_wiring_time = 0

	var/obj/the_electronics = player.spawn_obj_in_hand(/obj/item/apc_electronics/)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You install [the_electronics] into [apc_frame].")
	player.spawn_obj_in_hand(/obj/item/stack/cable_coil/ten)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You add cables to [apc_frame].")
	var/obj/the_cell = player.spawn_obj_in_hand(/obj/item/stock_parts/cell)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You insert [the_cell] into [apc_frame]")
	player.retrieve(crowbar)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You close the cover of [apc_frame].")

	// Now we dismantle it again.
	apc_frame.cover_locked = FALSE
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You open the cover of [apc_frame].")
	player.put_away(crowbar)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You remove [the_cell].")
	player.put_away(the_cell)
	var/obj/wirecutters = player.spawn_obj_in_hand(/obj/item/wirecutters)
	player.click_on(apc_frame)
	sleep(5 SECONDS) // This is not an APC define.
	TEST_ASSERT_LAST_CHATLOG(player, "You cut the cables and dismantle the power terminal.")
	player.put_away(wirecutters)
	player.retrieve(crowbar)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You remove the APC electronics.")
	player.put_away(crowbar)
	var/obj/welder = player.spawn_obj_in_hand(/obj/item/weldingtool)
	player.click_on(welder)
	player.click_on(apc_frame)
	TEST_ASSERT_LAST_CHATLOG(player, "You cut the APC frame from the wall.")
	test_area.requires_power = FALSE
