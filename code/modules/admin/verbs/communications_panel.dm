GLOBAL_LIST_EMPTY(commspanel_announcements)
GLOBAL_LIST_EMPTY(commspanel_messages)

/*
	Communications panel - lets admins check all messages/announcements/prays sent during the round.
*/
/client/proc/communications_panel()
	set name = "Communications Panel"
	set category = "Event"
	if(holder)
		holder.communications_panel(usr)
	feedback_add_details("admin_verb","CMP")
	return

/datum/admins/proc/communications_panel(mob/user)
	var/html = "<A align='right' href='?src=[UID()];refreshcommspanel=1'>Refresh</A>"

	html += "<div class='block'>"
	html += "<h2>Announcements</h2>"
	html += "<table>"
	html += {"<tr style='font-weight:bold;'>
			<td width='75px'>Sent At</td>
			<td width='200px'>Announcer</td>
			<td width='150px'>Type</td>
			<td width='150px'>Language</td>
			<td width='300px'>Message</td>
			</tr>"}
	for(var/list/A in GLOB.announcements)
		html += "<tr>"
		html += "<td>[station_time_timestamp("hh:mm:ss", A["timestamp"])]</td>"
		html += "<td>[A["announcer"]]</td>"
		html += "<td>[A["type"]]</td>"
		html += "<td>[A["language"]]</td>"
		html += "<td>[A["message"]]</td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	html += "<div class='block'>"
	html += "<h2>Messages/Prays</h2>"
	html += "<table>"
	html += {"<tr style='font-weight:bold;'>
			<td width='75px'>Sent At</td>
			<td width='800px'>Text</td>
			</tr>"}
	for(var/list/M in GLOB.messages)
		html += "<tr>"
		html += "<td>[station_time_timestamp("hh:mm:ss", M["timestamp"])]</td>"
		html += "<td>[M["text"]]</td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	var/datum/browser/popup = new(user, "communications_panel", "Communications Panel", 950, 600)
	popup.set_content(html)
	popup.open()

proc/Track_announcement(formatted_message, message_announcer, announcement_type, message_language)
	GLOB.commspanel_announcements += list(list(
			"message" = formatted_message,
			"announcer" = message_announcer,
			"type" = announcement_type,
			"language" = message_language,
			"timestamp" = station_time()
		))

proc/Track_message(text)
	GLOB.commspanel_messages += list(list(
			"text" = text,
			"timestamp" = station_time()
		))
