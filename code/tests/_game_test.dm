GLOBAL_LIST_EMPTY(game_test_chats)
GLOBAL_LIST_EMPTY(game_test_tguis)

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

#define TEST_ASSERT_LAST_CHATLOG(puppet, text) if(!puppet.last_chatlog_has_text(text)) { return Fail("Expected `[text]` in last chatlog but got `[puppet.get_last_chatlog()]`", __FILE__, __LINE__) }

#define TEST_ASSERT_ANY_CHATLOG(puppet, text) if(!puppet.any_chatlog_has_text(text))  { return Fail("Expected `[text]` in any chatlog but got [jointext(puppet.get_chatlogs(), "\n")]", __FILE__, __LINE__) }

#define TEST_ASSERT_NOT_CHATLOG(puppet, text) if(puppet.any_chatlog_has_text(text))  { return Fail("Didn't expect `[text]` in any chatlog but got [jointext(puppet.get_chatlogs(), "\n")]", __FILE__, __LINE__) }

#define TEST_ASSERT_SUBSTRING(haystack, needle) if(!findtextEx(haystack, needle))  { return Fail("`[needle]` not found in string `[haystack]`", __FILE__, __LINE__) }

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

	// failure tracking
	var/succeeded = TRUE
	var/list/allocated
	var/list/fail_reasons

/datum/game_test/New()

/datum/game_test/Destroy()
	QDEL_LIST_CONTENTS(allocated)
	// clear the whole test area, not just the bounds of the landmarks
	for(var/turf/T in get_area_turfs(/area/game_test))
		for(var/atom/movable/AM in T)
			qdel(AM)

	return ..()

/datum/game_test/proc/Run()
	Fail("Run() called parent or not implemented")

/datum/game_test/proc/Fail(reason = "No reason", file = "OUTDATED_TEST", line = 1)
	succeeded = FALSE

	if(!istext(reason))
		reason = "FORMATTED: [reason != null ? reason : "NULL"]"

	LAZYADD(fail_reasons, list(list(reason, file, line)))

/datum/game_test/proc/get_available_turfs()
	return get_area_turfs(findEventArea())

/// Allocates an instance of the provided type, and places it somewhere in an available loc
/// Instances allocated through this proc will be destroyed when the test is over
/datum/game_test/proc/allocate(type, ...)
	var/list/arguments = args.Copy(2)
	if(ispath(type, /atom))
		if(!arguments.len)
			arguments = list(pick(get_available_turfs()))
		else if(arguments[1] == null)
			arguments[1] = pick(get_available_turfs())
	var/instance
	// Byond will throw an index out of bounds if arguments is empty in that arglist call. Sigh
	if(length(arguments))
		instance = new type(arglist(arguments))
	else
		instance = new type()
	LAZYADD(allocated, instance)
	return instance

/datum/game_test/room_test
	var/list/available_turfs
	var/testing_area_name = "test_generic.dmm"
	var/obj/effect/landmark/bottom_left
	var/obj/effect/landmark/top_right

/datum/game_test/room_test/New()
	. = ..()
	if(!length(available_turfs))
		load_testing_area()
		available_turfs = get_test_turfs()

/datum/game_test/room_test/Destroy()
	. = ..()
	// Gotta destroy these landmarks so the next test
	// doesn't end up seeing them if it tries to load a new map
	qdel(bottom_left)
	qdel(top_right)

/datum/game_test/room_test/get_available_turfs()
	return available_turfs

/datum/game_test/room_test/proc/load_testing_area()
	var/list/testing_levels = levels_by_trait(GAME_TEST_LEVEL)
	if(!length(testing_levels))
		Fail("Could not find appropriate z-level for spawning test areas")
	var/testing_z_level = pick(testing_levels)
	var/datum/map_template/generic_test_area = GLOB.map_templates[testing_area_name]
	if(!generic_test_area.load(locate(TRANSITIONEDGE + 1, TRANSITIONEDGE + 1, testing_z_level)))
		Fail("Could not place generic testing area on z-level [testing_z_level]")

/datum/game_test/room_test/proc/get_test_turfs()
	var/list/result = list()
	for(var/obj/effect/landmark in GLOB.landmarks_list)
		if(istype(landmark, /obj/effect/landmark/game_test/bottom_left_corner))
			bottom_left = landmark
		else if(istype(landmark, /obj/effect/landmark/game_test/top_right_corner))
			top_right = landmark

	if(!(bottom_left && top_right))
		Fail("could not find test area landmarks")

	for(var/turf/T in block(bottom_left.loc, top_right.loc))
		result |= T

	if(!length(result))
		Fail("could not find any test turfs")

	return result
