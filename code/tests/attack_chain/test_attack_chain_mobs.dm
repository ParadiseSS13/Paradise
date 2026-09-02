/datum/game_test/room_test/attack_chain_mobs/Run()
	var/datum/test_puppeteer/player = new(src)
	player.puppet.name = "Player"
	// To ensure punches do damage without knockdowns
	player.puppet.dna.species.punchdamagelow = 5
	player.puppet.dna.species.punchdamagehigh = 5

	var/mob/living/simple_animal/hostile/morph/morph = player.spawn_mob_nearby(/mob/living/simple_animal/hostile/morph)
	morph.ambush_prepared = TRUE
	player.spawn_obj_in_hand(/obj/item/screwdriver)
	player.click_on(morph)

	TEST_ASSERT_ANY_CHATLOG(player, "You try to use")
	TEST_ASSERT_ANY_CHATLOG(player, "suddenly collapses in on itself")
	qdel(morph)
	// Get us back up
	player.rejuvenate()

	var/datum/test_puppeteer/victim = player.spawn_puppet_nearby()
	victim.puppet.name = "Victim"
	player.click_on(victim)
	TEST_ASSERT_LAST_CHATLOG(player, "You hug Victim")
	player.set_intent(INTENT_HARM)
	player.click_on(victim)
	TEST_ASSERT_LAST_CHATLOG(player, "Player punched Victim")
	victim.rejuvenate()
	var/obj/knife = player.spawn_obj_in_hand(/obj/item/kitchen/knife)
	player.puppet.zone_selected = BODY_ZONE_PRECISE_L_FOOT
	player.click_on(victim)
	TEST_ASSERT_LAST_CHATLOG(player, "Victim in the left foot")
	victim.rejuvenate()
	player.put_away(knife)

	// Test CQC attack interception
	var/datum/martial_art/cqc/cqc = new()
	cqc.teach(player.puppet)
	player.puppet.swap_hand()
	victim.puppet.lay_down()
	player.click_on(victim)
	TEST_ASSERT_LAST_CHATLOG(player, "stomps on Victim")
	victim.rejuvenate()
	cqc.remove(player.puppet)

	player.set_intent(INTENT_HELP)
	var/mob/mining_drone = player.spawn_mob_nearby(/mob/living/basic/mining_drone)
	var/obj/scanner = player.spawn_obj_in_hand(/obj/item/mining_scanner)
	player.click_on(mining_drone)
	TEST_ASSERT_LAST_CHATLOG(player, "drop any collected ore.")
	qdel(scanner)
	player.spawn_obj_in_hand(/obj/item/borg/upgrade/modkit/cooldown/minebot)
	player.click_on(mining_drone)
	TEST_ASSERT_LAST_CHATLOG(player, "You install the modkit")
	player.retrieve(knife)
	player.set_intent(INTENT_HARM)
	player.click_on(mining_drone)
	TEST_ASSERT_LAST_CHATLOG(player, "the nanotrasen minebot with the kitchen knife")
	qdel(mining_drone)

	RegisterSignal(victim.puppet, COMSIG_HUMAN_ATTACKED, PROC_REF(cancel_attack_chain))
	player.click_on(victim)
	TEST_ASSERT_LAST_CHATLOG(player, "Attack chain cancelled by signal")
	UnregisterSignal(victim.puppet, COMSIG_HUMAN_ATTACKED)

	var/mob/living/simple_animal/pet/dog/corgi/corgi = player.spawn_mob_nearby(/mob/living/simple_animal/pet/dog/corgi)
	corgi.anchored = TRUE
	player.click_on(corgi)
	TEST_ASSERT_LAST_CHATLOG(player, "corgi with the kitchen knife")
	player.put_away(knife)
	corgi.rejuvenate()
	player.set_intent(INTENT_HELP)
	var/obj/collar = player.spawn_obj_in_hand(/obj/item/petcollar)
	player.click_on(corgi)
	TEST_ASSERT(collar in corgi.contents, "did not put collar on corgi")
	var/obj/razor = player.spawn_obj_in_hand(/obj/item/razor)
	corgi.razor_shave_delay = 0
	player.click_on(corgi)
	TEST_ASSERT(corgi.shaved, "corgi was not shaved")
	player.put_away(razor)
	corgi.death()
	var/obj/laz_injector = player.spawn_obj_in_hand(/obj/item/lazarus_injector)
	player.click_on(corgi)
	TEST_ASSERT_LAST_CHATLOG(player, "injects the corgi")
	qdel(laz_injector)

	var/mob/slime = player.spawn_mob_nearby(/mob/living/simple_animal/slime)
	slime.anchored = TRUE

	player.spawn_obj_in_hand(/obj/item/slimepotion/slime/docility)
	player.click_on(corgi)
	TEST_ASSERT_LAST_CHATLOG(player, "only works on slimes!")
	player.click_on(slime)
	TEST_ASSERT_LAST_CHATLOG(player, "You feed the slime the potion")

	var/obj/mind_transfer_slime_potion = player.spawn_obj_in_hand(/obj/item/slimepotion/transference)
	player.click_on(corgi)
	var/datum/tgui_alert/alert = player.get_last_tgui()
	TEST_ASSERT_NOTNULL(alert, "no TGUI")
	TEST_ASSERT_SUBSTRING(alert.message, "transfer your consciousness to the corgi")
	alert.set_choice("No")

	player.click_on(slime)
	alert = player.get_last_tgui()
	TEST_ASSERT_NOTNULL(alert, "no TGUI")
	TEST_ASSERT_SUBSTRING(alert.message, "transfer your consciousness to the pet slime")
	alert.set_choice("No")

	qdel(mind_transfer_slime_potion)
	qdel(corgi)
	qdel(slime)

	victim.puppet.death()
	player.spawn_obj_in_hand(/obj/item/kitchen/knife/butcher/meatcleaver)
	player.set_intent(INTENT_HARM)
	player.click_on(victim)
	// Even before this test, butchering items included a second attack message
	TEST_ASSERT_ANY_CHATLOG(player, "You hack off a chunk of meat from Victim")

/datum/game_test/room_test/attack_chain_mobs/proc/cancel_attack_chain(datum/source, mob/user)
	to_chat(user, "Attack chain cancelled by signal")
	return COMPONENT_CANCEL_ATTACK_CHAIN
