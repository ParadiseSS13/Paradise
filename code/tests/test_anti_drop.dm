/datum/game_test/anti_drop_implant/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/item/organ/internal/cyberimp/brain/anti_drop/anti_drop = new/obj/item/organ/internal/cyberimp/brain/anti_drop
	var/obj/item/autosurgeon/organ/syndicate/autosurg = player.spawn_obj_in_hand(/obj/item/autosurgeon/organ/syndicate)

	autosurg.insert_organ(anti_drop)
	TEST_ASSERT(autosurg.storedorgan == anti_drop, "failed to inser antidrop in autosurgeon")
	player.use_item_in_hand()
	TEST_ASSERT(anti_drop in player.puppet.internal_organs, "failed to insert anti_drop in player")
	qdel(autosurg)

	var/obj/item/belt = player.spawn_obj_in_hand(/obj/item/storage/belt)
	var/obj/item/screwdriver = player.spawn_obj_in_hand(/obj/item/screwdriver)
	anti_drop.ui_action_click()
	TEST_ASSERT_LAST_CHATLOG(player, "hand's")
	TEST_ASSERT((belt.flags & NODROP) && (screwdriver.flags & NODROP), "nodrop failed to apply")
	// TEST_ASSERT(screwdriver.flags & NODROP, "nodrop failed to apply")

	var/left_hand = player.puppet.l_hand
	var/right_hand = player.puppet.r_hand


	anti_drop.emp_act()
	TEST_ASSERT(!player.puppet.l_hand && !player.puppet.r_hand, "player failed to throw items")
	TEST_ASSERT_ANY_CHATLOG(player, "arm spasms")
	TEST_ASSERT(!(belt.flags & NODROP) && !(screwdriver.flags & NODROP), "emp throw failed to remove NODROP")

	belt.forceMove(get_turf(player))
	player.click_on(belt)
	TEST_ASSERT(belt in get_both_hands(player), "player failed to pick up belt")

	player.puppet.equip_to_appropriate_slot(belt)
	player.puppet.drop_item_to_ground(belt)
	TEST_ASSERT(belt.loc = player, "belt removed with NODROP")

	anti_drop.ui_action_click()
	player.puppet.drop_item_to_ground(belt)
	TEST_ASSERT(belt.loc != player, "failed to remove belt after disabling NODROP")




