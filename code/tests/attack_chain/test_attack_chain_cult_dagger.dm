/datum/game_test/room_test/attack_chain_cult_dagger/Run()
	var/datum/test_puppeteer/cultist = new(src)
	var/datum/test_puppeteer/target = cultist.spawn_puppet_nearby()

	cultist.puppet.mind.add_antag_datum(/datum/antagonist/cultist)
	cultist.spawn_obj_in_hand(/obj/item/melee/cultblade/dagger)
	cultist.set_intent("harm")
	cultist.click_on(target)

	TEST_ASSERT(target.check_attack_log("Attacked with ritual dagger"), "non-cultist missing dagger attack log")
	TEST_ASSERT_NOTEQUAL(target.puppet.health, target.puppet.getMaxHealth(), "cultist attacking non-cultist with dagger caused no damage")

	target.rejuvenate()
	target.puppet.mind.add_antag_datum(/datum/antagonist/cultist)

	cultist.click_on(target)
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "cultist attacking cultist with dagger caused damage")

	// Test some new -> old attack chain shenanigans
	target.puppet.mind.remove_antag_datum(/datum/antagonist/cultist)

	ADD_TRAIT(cultist.puppet, TRAIT_PACIFISM, "test")
	cultist.click_on(target)
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "non-cultist attacked by pacifist")
