//////////////////////////////////////////////////////////////////////////////////////
// This file houses all the code for cookie datum serialization and deserialization
//
// If you are going to modify ANYTHING in here, please test it THOROUGHLY
// The serialization and deserialization here is so complicated that you WILL break something here
// PLEASE test things properly if you modify this file. -aa07
//
//////////////////////////////////////////////////////////////////////////////////////

// Everything in this file is intentionally NOT autodocumented. PLEASE keep it that way.
// All these defines are integral to the workings and mesh together with the database.
// DO NOT EDIT THESE UNDER ANY CIRCUMSTANCES EVER
#define COOKIERECORD_FIRST_INFRACTION "First cookie match: "
#define COOKIERECORD_LAST_INFRACTION "Last cookie match: "
#define COOKIERECORD_TOTAL_INFRACTIONS "Total cookie matches: "
#define COOKIERECORD_MATCHED_CKEYS "Matched ckeys: "
#define COOKIERECORD_MATCHED_IPS "Matched IPs: "
#define COOKIERECORD_MATCHED_CIDS "Matched CIDS: "
#define COOKIERECORD_PSUEDO_CKEY "ALICE-COOKIE_RECORD"

/datum/cookie_record
	var/cookie_holder_ckey
	var/first_infraction_date
	var/last_infraction_date
	var/infraction_count
	var/list/matched_ckeys = list()
	var/list/matched_ips = list()
	var/list/matched_cids = list()

// Some of these params can be null, others CAN NOT
/datum/cookie_record/New(holder_ckey, matched_ckey, matched_ip, matched_cid)
	// Right off the bat
	cookie_holder_ckey = holder_ckey

	var/has_note = FALSE
	var/raw_text = ""
	// Now lets see if we have a note logging the infraction in the past
	var/datum/db_query/check_existing_note = SSdbcore.NewQuery("SELECT notetext FROM notes WHERE ckey=:ckey AND adminckey=:ackey", list(
		"ckey" = cookie_holder_ckey,
		"ackey" = COOKIERECORD_PSUEDO_CKEY
	))
	if(!check_existing_note.warn_execute())
		qdel(check_existing_note)
		return
	if(check_existing_note.NextRow())
		has_note = TRUE
		raw_text = check_existing_note.item[1]
	qdel(check_existing_note)

	if(has_note)
		deserialize_and_load(raw_text)
		infraction_count++
	else
		// Sane defaults
		first_infraction_date = SQLtime()
		infraction_count = 1

	last_infraction_date = SQLtime()
	matched_ckeys |= matched_ckey
	matched_ips |= matched_ip
	matched_cids |= matched_cid

	serialize_and_save(has_note)

/*
	Expected output below. These are parsed from raw_text by splitting by <br>
	[1] COOKIERECORD_FIRST_INFRACTION
	[2] COOKIERECORD_LAST_INFRACTION
	[3] COOKIERECORD_TOTAL_INFRACTIONS
	[4] COOKIERECORD_MATCHED_CKEYS
	[5] COOKIERECORD_MATCHED_IPS
	[6] COOKIERECORD_MATCHED_CIDS
*/

/datum/cookie_record/proc/deserialize_and_load(raw_text)
	var/list/lines = splittext(raw_text, "<br>")
	// Text
	first_infraction_date = splittext(lines[1], COOKIERECORD_FIRST_INFRACTION)[2]
	last_infraction_date = splittext(lines[2], COOKIERECORD_LAST_INFRACTION)[2]
	// Number
	infraction_count = text2num(splittext(lines[3], COOKIERECORD_TOTAL_INFRACTIONS)[2]) // Make sure its a number
	// Lists
	matched_ckeys = splittext(splittext(lines[4], COOKIERECORD_MATCHED_CKEYS)[2], ",")
	matched_ips = splittext(splittext(lines[5], COOKIERECORD_MATCHED_IPS)[2], ",")
	matched_cids = splittext(splittext(lines[6], COOKIERECORD_MATCHED_CIDS)[2], ",")

/datum/cookie_record/proc/serialize_and_save(has_note)
	var/serialized_text
	var/list/serialized_list = list()
	serialized_list.len = 6 // Make it 6 off the bat

	serialized_list[1] = "[COOKIERECORD_FIRST_INFRACTION][first_infraction_date]"
	serialized_list[2] = "[COOKIERECORD_LAST_INFRACTION][last_infraction_date]"
	serialized_list[3] = "[COOKIERECORD_TOTAL_INFRACTIONS][infraction_count]"
	serialized_list[4] = "[COOKIERECORD_MATCHED_CKEYS][matched_ckeys.Join(",")]"
	serialized_list[5] = "[COOKIERECORD_MATCHED_IPS][matched_ips.Join(",")]"
	serialized_list[6] = "[COOKIERECORD_MATCHED_CIDS][matched_cids.Join(",")]"

	serialized_text = serialized_list.Join("<br>")

	if(has_note) // They have a note. Update.
		var/datum/db_query/update_existing_note = SSdbcore.NewQuery("UPDATE notes SET notetext=:nt, timestamp=NOW(), round_id=:rid WHERE ckey=:ckey AND adminckey=:ackey", list(
			"nt" = serialized_text,
			"rid" = GLOB.round_id,
			"ckey" = cookie_holder_ckey,
			"ackey" = COOKIERECORD_PSUEDO_CKEY
		))
		if(!update_existing_note.warn_execute())
			qdel(update_existing_note)
			return
		qdel(update_existing_note)
	else // They dont have a note. Insert.
		add_note(cookie_holder_ckey, serialized_text, adminckey = COOKIERECORD_PSUEDO_CKEY, logged = FALSE, checkrights = FALSE, automated = TRUE, sanitise_html = FALSE) // No sanitize because we rely on formatting

#undef COOKIERECORD_FIRST_INFRACTION
#undef COOKIERECORD_LAST_INFRACTION
#undef COOKIERECORD_TOTAL_INFRACTIONS
#undef COOKIERECORD_MATCHED_CKEYS
#undef COOKIERECORD_MATCHED_IPS
#undef COOKIERECORD_MATCHED_CIDS
#undef COOKIERECORD_PSUEDO_CKEY
