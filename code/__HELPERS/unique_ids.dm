/// At what number do we roll UIDs over for the next ground.
#define UID_ROLLOVER_COUNT 950000
// ^ This needs to exist because BYOND will print a number in scientific notation if its big enough, breaking all hrefs

// Unique Datum Identifiers

// Basically, a replacement for plain \refs that ensure the reference still
// points to the exact same datum/client, but doesn't prevent GC like tags do.

// An unintended side effect of the way UIDs are formatted is that the locate()
// proc will ignore the number and attempt to locate the reference. I consider
// this a feature, since it means they're conveniently backwards compatible.

// Turns this:
//   var/myref = "\ref[mydatum]"
//   var/datum/D = locate(myref)
// into this:
//   var/myUID = mydatum.UID()
//   var/datum/D = locateUID(myUID)

/// The next UID to be used (Increments by 1 for each UID)
GLOBAL_VAR_INIT(next_unique_datum_id, 1)
/// The next UID group to be used (Increments by 1 every time UID goes above a certain number [UID_ROLLOVER_COUNT])
GLOBAL_VAR_INIT(next_uid_group, 1)
/// Log of all UIDs created in the round
GLOBAL_LIST_EMPTY(uid_log)

/**
  * Gets the UID of a datum
  *
  * BYOND refs are recycled, so this system prevents that. If a datum does not have a UID when this proc is ran, one will be created
  * Returns the UID of the datum
  */
/datum/proc/UID()
	if(!unique_datum_id)
		var/tag_backup = tag
		tag = null // Grab the raw ref, not the tag
		if(GLOB.next_unique_datum_id >= UID_ROLLOVER_COUNT)
			GLOB.next_unique_datum_id = 1
			GLOB.next_uid_group++ // Increase by 1 for next group
			log_debug("UID() encountered a UID greater than the rollover count ([UID_ROLLOVER_COUNT]). Incrementing UID group.")
		unique_datum_id = "\ref[src]_[GLOB.next_unique_datum_id++]-[GLOB.next_uid_group]"
		tag = tag_backup
		GLOB.uid_log[type]++
	return unique_datum_id

/**
  * Locates a datum based off of the UID
  *
  * Replacement for locate() which takes a UID instead of a ref
  * Returns the datum, if found
  */
/proc/locateUID(uid)
	if(!istext(uid))
		return null

	var/splitat = findlasttext(uid, "_")

	if(!splitat)
		return null

	var/datum/D = locate(copytext(uid, 1, splitat))

	if(D && D.unique_datum_id == uid)
		return D
	return null

/client/verb/uid_testing()
	set name = "View UID Log"
	set category = "Debug"
	set desc = "If this got merged in, please scream at someone"

	if(!check_rights(R_DEBUG))
		return

	var/list/sorted = sortTim(GLOB.uid_log, cmp=/proc/cmp_numeric_dsc, associative = TRUE)
	var/list/text = list("<h1>UID Log</h1>", "<p>Current UID: [GLOB.next_unique_datum_id]</p>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	usr << browse(text.Join(), "window=uidlog")
