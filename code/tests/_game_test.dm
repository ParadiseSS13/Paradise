/// For advanced cases, fail unconditionally but don't return (so a test can return multiple results)
#define TEST_FAIL(reason) (Fail(reason || "No reason", __FILE__, __LINE__))

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

#define TEST_ASSERT_NOT(assertion, reason) if(assertion) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is not null
#define TEST_ASSERT_NOTNULL(a, reason) if(isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is null
#define TEST_ASSERT_NULL(a, reason) if(!isnull(a)) { return Fail("Expected null value but received [a]: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if(lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while(FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if(lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while(FALSE)

/**
 * Usage:
 *
 * - Override /Run() to run your test code
 * - Call Fail() to fail the test (You should specify a reason)
 * - You may use /New() and /Destroy() for setup/teardown respectively
 * - You can use the run_loc_bottom_left and run_loc_top_right to get turfs for testing
 *
**/
/datum/game_test
	//Bit of metadata for the future maybe
	var/list/procs_tested

	//usable vars
	var/turf/run_loc_bottom_left
	var/turf/run_loc_top_right

	//internal shit
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

/datum/game_test/New()
	run_loc_bottom_left = locate(1, 1, 1)
	run_loc_top_right = locate(5, 5, 1)

/datum/game_test/Destroy()
	QDEL_LIST_CONTENTS(allocated)
	//clear the test area
	for(var/atom/movable/AM in block(run_loc_bottom_left, run_loc_top_right))
		qdel(AM)
	return ..()

/datum/game_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/game_test/proc/Fail(reason = "No reason", file = "OUTDATED_TEST", line = 1)
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, list(list(reason, file, line)))

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/game_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if(ispath(type, /atom))
		if(!arguments.len)
			arguments = list(run_loc_bottom_left)
		else if(arguments[1] == null)
			arguments[1] = run_loc_bottom_left
	var/instance
	// Byond will throw an index out of bounds if arguments is empty in that arglist call. Sigh
	if(length(arguments))
		instance = new type(arglist(arguments))
	else
		instance = new type()
	LAZYADD(allocated, instance)
	return instance

/datum/game_test/proc/puppeteer(carbon_type = /mob/living/carbon/human, turf/initial_location)
	TEST_ASSERT(ispath(carbon_type, /mob/living/carbon/human), "unexpected puppeteer carbon type [carbon_type]")
	var/datum/test_puppeteer/puppeteer = new

	if(!initial_location)
		initial_location = locate(179, 136, 1) // Center of admin testing area
	puppeteer.origin_test = src
	puppeteer.puppet = allocate(carbon_type, initial_location)
	var/datum/mind/new_mind = new("interaction_test_[puppeteer.puppet.UID()]")
	new_mind.transfer_to(puppeteer.puppet)

	return puppeteer

/datum/test_puppeteer
	var/mob/living/carbon/puppet
	var/datum/game_test/origin_test

/datum/test_puppeteer/proc/spawn_puppet_nearby(carbon_type = /mob/living/carbon/human)
	for(var/turf/T in RANGE_TURFS(1, puppet.loc))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
			return origin_test.puppeteer(carbon_type, T)

	origin_test.Fail("could not spawn puppeteer near [src]")

/datum/test_puppeteer/proc/spawn_obj_in_hand(obj_type)
	var/obj/new_obj = origin_test.allocate(obj_type, null)
	if(puppet.put_in_hands(new_obj))
		return new_obj

	origin_test.Fail("could not spawn obj [obj_type] in hand of [puppet]")

/datum/test_puppeteer/proc/spawn_obj_nearby(obj_type)
	for(var/turf/T in RANGE_TURFS(1, puppet.loc))
		if(!is_blocked_turf(T, exclude_mobs = FALSE))
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

/datum/test_puppeteer/proc/check_attack_log(snippet)
	for(var/log_text in puppet.attack_log_old)
		if(findtextEx(log_text, snippet))
			return TRUE

/datum/test_puppeteer/proc/set_intent(new_intent)
	puppet.a_intent_change(new_intent)

/datum/test_puppeteer/proc/rejuvenate()
	puppet.rejuvenate()
