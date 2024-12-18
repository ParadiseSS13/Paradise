/datum/interaction_test
	var/list/tracked_puppets
	var/succeeded = TRUE
	var/list/fail_reasons

/datum/interaction_test/Destroy()
	for(var/datum/test_puppeteer/puppet in tracked_puppets)
		qdel(puppet)
	return ..()

/datum/interaction_test/proc/Run()
	SHOULD_CALL_PARENT(FALSE)
	Fail("Run() not implemented")

/datum/interaction_test/proc/Fail(reason = "No reason")
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, reason)

/datum/interaction_test/proc/make_puppeteer(carbon_type = /mob/living/carbon/human)
	var/datum/test_puppeteer/puppet = new(carbon_type)
	LAZYADD(tracked_puppets, puppet)
	return puppet

/datum/interaction_test/proc/make_puppeteer_near(datum/test_puppeteer/near, carbon_type = /mob/living/carbon/human)
	for(var/turf/T in RANGE_TURFS(1, near.puppet.loc))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
			var/datum/test_puppeteer/new_puppet = new(carbon_type, T)
			LAZYADD(tracked_puppets, new_puppet)
			return new_puppet

