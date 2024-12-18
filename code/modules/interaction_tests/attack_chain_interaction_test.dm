/datum/interaction_test/attack_chain

/datum/interaction_test/attack_chain/Run()
	var/datum/test_puppeteer/cultist = make_puppeteer()
	var/datum/test_puppeteer/target = make_puppeteer_near(cultist)
	cultist.puppet.mind.add_antag_datum(/datum/antagonist/cultist)
	cultist.spawn_obj_in_hand(/obj/item/melee/cultblade/dagger)
	cultist.set_intent("harm")
	cultist.click_on(target)

	if(!target.check_attack_log("Attacked with ritual dagger"))
		Fail("non-cultist missing dagger attack log")
	if(target.puppet.health == target.puppet.getMaxHealth())
		Fail("cultist attacking non-cultist with dagger caused no damage")

	target.rejuvenate()
	target.puppet.mind.add_antag_datum(/datum/antagonist/cultist)

	cultist.click_on(target)
	if(target.puppet.health < target.puppet.getMaxHealth())
		Fail("cultist attacking cultist with dagger caused damage")


