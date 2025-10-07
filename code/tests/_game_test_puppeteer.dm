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
		initial_location = locate(179, 136, 1) // Center of admin testing area
	origin_test = origin_test_
	puppet = origin_test.allocate(carbon_type, initial_location)
	var/datum/mind/new_mind = new("interaction_test_[puppet.UID()]")
	new_mind.transfer_to(puppet)

/datum/test_puppeteer/proc/spawn_puppet_nearby(carbon_type = /mob/living/carbon/human)
	for(var/turf/T in RANGE_TURFS(1, puppet.loc))
		if(!T.is_blocked_turf())
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
			if(!nearby.is_blocked_turf())
				T = nearby

	if(T)
		return origin_test.allocate(obj_type, T)

	origin_test.Fail("could not spawn obj [obj_type] near [src]")

/datum/test_puppeteer/proc/spawn_fast_tool(item_type)
	var/obj/item/fast_tool = spawn_obj_in_hand(item_type)
	fast_tool.toolspeed = 0
	return fast_tool

/datum/test_puppeteer/proc/use_item_in_hand()
	var/obj/item/item = puppet.get_active_hand()
	if(!item)
		origin_test.Fail("could not find obj in [puppet] active hand", __FILE__, __LINE__)
		return

	if(item.new_attack_chain)
		item.activate_self(puppet)
	else
		item.attack_self__legacy__attackchain(puppet)

	puppet.next_click = world.time
	puppet.next_move = world.time
	return TRUE

/datum/test_puppeteer/proc/click_on(target, params)
	var/datum/test_puppeteer/puppet_target = target
	if(istype(puppet_target))
		puppet.ClickOn(puppet_target.puppet, params)
	else
		puppet.ClickOn(target, params)

	puppet.next_click = world.time
	puppet.next_move = world.time

/datum/test_puppeteer/proc/alt_click_on(target, params)
	var/plist = params2list(params)
	plist["alt"] = TRUE
	click_on(target, list2params(plist))

/datum/test_puppeteer/proc/spawn_mob_nearby(mob_type)
	for(var/turf/T in RANGE_TURFS(1, puppet))
		if(!T.is_blocked_turf())
			var/mob/new_mob = origin_test.allocate(mob_type, T)
			return new_mob

/datum/test_puppeteer/proc/change_turf_nearby(turf_type, direction = -1)
	var/turf/T
	var/turf/center = get_turf(puppet)
	if(direction >= 0)
		T = get_step(puppet, direction)
	else
		// just check for any contents, not blocked_turf which includes turf density
		// (which we don't really care about)
		for(var/turf/nearby in RANGE_TURFS(1, center))
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

/datum/test_puppeteer/proc/set_zone(new_zone)
	puppet.zone_selected = new_zone

/datum/test_puppeteer/proc/rejuvenate()
	puppet.rejuvenate()

/datum/test_puppeteer/proc/get_last_chatlog()
	var/list/puppet_chat_list = get_chatlogs()
	if(length(puppet_chat_list))
		return puppet_chat_list[length(puppet_chat_list)]

/datum/test_puppeteer/proc/last_chatlog_has_text(snippet)
	return findtextEx(get_last_chatlog(), snippet)

/datum/test_puppeteer/proc/any_chatlog_has_text(snippet)
	for(var/chat_line in get_chatlogs())
		if(findtextEx(chat_line, snippet))
			return TRUE

	return FALSE

/datum/test_puppeteer/proc/get_chatlogs()
	if(!(puppet.mind.key in GLOB.game_test_chats))
		return list()
	return GLOB.game_test_chats[puppet.mind.key]

/datum/test_puppeteer/proc/find_nearby(atom_type)
	for(var/turf/T in RANGE_TURFS(1, puppet))
		for(var/atom/A in T.contents)
			if(istype(A, atom_type))
				return A

/datum/test_puppeteer/proc/get_last_tgui()
	if(!(puppet.mind.key in GLOB.game_test_tguis))
		return null
	var/list/tgui_list = GLOB.game_test_tguis[puppet.mind.key]
	if(!length(tgui_list))
		return null
	return tgui_list[length(tgui_list)]

// No we don't technically need to put these things into an actual backpack and
// so forth, we could just leave them lying around and teleport them to the
// player but this keeps things realistic and may surface issues we wouldn't
// think to test for.
/datum/test_puppeteer/proc/put_away(obj/object)
	if(!puppet.back)
		puppet.equip_to_appropriate_slot(new/obj/item/storage/backpack)

	var/obj/item/storage/backpack = puppet.back
	backpack.handle_item_insertion(object, puppet)

/datum/test_puppeteer/proc/retrieve(obj/object)
	if(!puppet.back)
		return

	var/obj/item/storage/backpack = puppet.back
	if(!(object in backpack.contents))
		return

	backpack.remove_item_from_storage(object)
	puppet.put_in_active_hand(object)

/datum/test_puppeteer/proc/click_on_self()
	puppet.ClickOn(puppet)
	puppet.next_click = world.time
	puppet.next_move = world.time

/datum/test_puppeteer/proc/drop_held_item()
	puppet.drop_item_to_ground(puppet.get_active_hand())
