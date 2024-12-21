/datum/test_puppeteer
	var/mob/living/carbon/puppet
	var/list/tracked_atoms

/datum/test_puppeteer/New(carbon_type, turf/initial_location)
	if(!initial_location)
		initial_location = locate(179, 136, 1) // Center of admin testing area
	puppet = new carbon_type(initial_location)
	var/datum/mind/new_mind = new("interaction_test_[rand(1, 999999)]")
	new_mind.transfer_to(puppet)

/datum/test_puppeteer/proc/spawn_obj_in_hand(obj_type)
	var/obj/new_obj = new obj_type(null)
	puppet.put_in_hands(new_obj)
	LAZYADD(tracked_atoms, new_obj)
	return new_obj

/datum/test_puppeteer/proc/click_on(target, params)
	var/datum/test_puppeteer/puppet_target = target
	if(istype(puppet_target))
		puppet.ClickOn(puppet_target.puppet, params)
		return

	puppet.ClickOn(target, params)

/datum/test_puppeteer/proc/spawn_mob_nearby(mob_type)
	for(var/turf/T in RANGE_TURFS(1, puppet))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
			var/mob/new_mob = new mob_type(T)
			LAZYADD(tracked_atoms, new_mob)
			return new_mob

/datum/test_puppeteer/Destroy(force, ...)
	qdel(puppet)
	for(var/atom/A in tracked_atoms)
		qdel(A)

	return ..()

/datum/test_puppeteer/proc/check_attack_log(snippet)
	for(var/log_text in puppet.attack_log_old)
		if(findtextEx(log_text, snippet))
			return TRUE

/datum/test_puppeteer/proc/set_intent(new_intent)
	puppet.a_intent_change(new_intent)

/datum/test_puppeteer/proc/rejuvenate()
	puppet.rejuvenate()
