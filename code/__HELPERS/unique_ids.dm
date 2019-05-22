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

var/global/next_unique_datum_id = 1

// /client/var/tmp/unique_datum_id = null

/datum/proc/UID()
	if(!unique_datum_id)
		var/tag_backup = tag
		tag = null // Grab the raw ref, not the tag
		unique_datum_id = "\ref[src]_[next_unique_datum_id++]"
		tag = tag_backup
	return unique_datum_id

/proc/locateUID(uid)
	if(!istext(uid))
		return null

	var/splitat = findlasttext(uid, "_")

	if(!splitat)
		return null

	var/datum/D = locate(copytext(uid, 1, splitat))

	// We might locate a client instead of a datum, but just using : is easier
	// than actually checking and typecasting
	if(D && D:unique_datum_id == uid)
		return D
	return null
