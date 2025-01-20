/**
 * A testing object used to control mobs in game tests.
 *
 * Puppeteers provide an easy way to create mobs and objects,
 * perform interactions in the same way that a player would,
 * and check the state of the mob during tests.
 */
/datum/test_puppeteer
	var/mob/living/carbon/puppet
	var/datum/game_test/origin_test

/datum/test_puppeteer/New(datum/game_test/origin_test_, carbon_type = /mob/living/carbon/human, turf/initial_location)
	if(!ispath(carbon_type, /mob/living/carbon/human))
		origin_test.Fail("unexpected puppeteer carbon type [carbon_type]", __FILE__, __LINE__)

	if(!initial_location)
		initial_location = locate(20, 210, 2) // Center of admin testing area // SS220 EDIT - center of admin testing area at Admin_Zone.dmm
	origin_test = origin_test_
	puppet = origin_test.allocate(carbon_type, initial_location)
	var/datum/mind/new_mind = new("interaction_test_[puppet.UID()]")
	new_mind.transfer_to(puppet)

/datum/test_puppeteer/proc/spawn_puppet_nearby(carbon_type = /mob/living/carbon/human)
	for(var/turf/T in RANGE_TURFS(1, puppet.loc))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
			return new/datum/test_puppeteer(origin_test, carbon_type, T)

	origin_test.Fail("could not spawn puppeteer near [src]")

/datum/test_puppeteer/proc/spawn_obj_in_hand(obj_type)
	var/obj/new_obj = origin_test.allocate(obj_type, null)
	if(puppet.put_in_hands(new_obj))
		return new_obj

	origin_test.Fail("could not spawn obj [obj_type] in hand of [puppet]")

/datum/test_puppeteer/proc/spawn_obj_nearby(obj_type, direction = -1)
	var/turf/T
	if(direction >= 0)
		T = get_step(puppet, direction)
	else
		for(var/turf/nearby in RANGE_TURFS(1, puppet.loc))
			if(!is_blocked_turf(nearby, exclude_mobs = FALSE))
				T = nearby

	if(T)
		return origin_test.allocate(obj_type, T)

	origin_test.Fail("could not spawn obj [obj_type] near [src]")

/datum/test_puppeteer/proc/click_on(target, params)
	var/datum/test_puppeteer/puppet_target = target
	sleep(max(puppet.next_click, puppet.next_move) - world.time + 1)
	if(istype(puppet_target))
		puppet.ClickOn(puppet_target.puppet, params)
		return

	puppet.ClickOn(target, params)

/datum/test_puppeteer/proc/spawn_mob_nearby(mob_type)
	for(var/turf/T in RANGE_TURFS(1, puppet))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
			var/mob/new_mob = origin_test.allocate(mob_type, T)
			return new_mob

/datum/test_puppeteer/proc/change_turf_nearby(turf_type, direction = -1)
	var/turf/T
	if(direction >= 0)
		T = get_step(puppet, direction)
	else
		// just check for any contents, not blocked_turf which includes turf density
		// (which we don't really care about)
		for(var/turf/nearby in RANGE_TURFS(1, puppet))
			if(!length(nearby.contents))
				T = nearby

	if(T)
		T.ChangeTurf(turf_type)
		return T

	origin_test.Fail("could not spawn turf [turf_type] near [src]")

/datum/test_puppeteer/proc/check_attack_log(snippet)
	for(var/log_text in puppet.attack_log_old)
		if(findtextEx(log_text, snippet))
			return TRUE

/datum/test_puppeteer/proc/set_intent(new_intent)
	puppet.a_intent_change(new_intent)

/datum/test_puppeteer/proc/rejuvenate()
	puppet.rejuvenate()

/datum/test_puppeteer/proc/last_chatlog_has_text(snippet)
	if(!(puppet.mind.key in GLOB.game_test_chats))
		return FALSE
	var/list/puppet_chat_list = GLOB.game_test_chats[puppet.mind.key]
	var/last_chat_html = puppet_chat_list[length(puppet_chat_list)]
	return findtextEx(last_chat_html, snippet)
