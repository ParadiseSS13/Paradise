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
/// Log of all UIDs created in the round. Assoc list with type as key and amount as value
GLOBAL_LIST_EMPTY(uid_log)

/**
  * Gets or creates the UID of a datum
  *
  * BYOND refs are recycled, so this system prevents that. If a datum does not have a UID when this proc is ran, one will be created
  * Returns the UID of the datum
  */
/datum/proc/UID()
	if(!unique_datum_id)
		var/tag_backup = tag
		tag = null // Grab the raw ref, not the tag
		// num2text can output 8 significant figures max. If we go above 10 million UIDs in a round, shit breaks
		var/uid_number = num2text(GLOB.next_unique_datum_id++, 8)
		unique_datum_id = "\ref[src]_[uid_number]"
		md5_unique_datum_id = "[md5(unique_datum_id)]_[uid_number]" // Avoid ANY collision chance
		tag = tag_backup
		GLOB.uid_log[type]++
	return unique_datum_id

/**
  * Safety wrapper for getting MD5 UIDs
  *
  * This ensures it exists before reading it
  */
/datum/proc/MD5_UID()
	UID()
	return md5_unique_datum_id

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

/**
 * If the list `L` contains a datum UID who's type matches `D`'s type, returns the UID of that datum in the list. Otherwise returns null.
 */
/proc/is_type_in_UID_list(datum/D, list/L)
	if(!length(L))
		return

	for(var/datum_UID in L)
		var/datum/A = locateUID(datum_UID)
		if(istype(D, A))
			return datum_UID

/**
  * Opens a log of UIDs
  *
  * In-round ability to view what has created a UID, and how many times a UID for that path has been declared
  */
/client/proc/uid_log()
	set name = "View UID Log"
	set category = "Debug"
	set desc = "Shows the log of created UIDs this round"

	if(!check_rights(R_DEBUG))
		return

	var/list/sorted = sortTim(GLOB.uid_log, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/list/text = list("<h1>UID Log</h1>", "<p>Current UID: [GLOB.next_unique_datum_id]</p>", "<ul>")
	for(var/key in sorted)
		text += "<li>[key] - [sorted[key]]</li>"

	text += "</ul>"
	usr << browse(text.Join(), "window=uidlog")
