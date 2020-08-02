// Fax datum - holds all faxes sent during the round
GLOBAL_LIST_EMPTY(faxes)
GLOBAL_LIST_EMPTY(adminfaxes)

/datum/fax
	var/name = "fax"
	var/from_department = null
	var/to_department = null
	var/origin = null
	var/message = null
	var/sent_by = null
	var/sent_at = null

/datum/fax/New()
	GLOB.faxes += src

/datum/fax/admin
	var/list/reply_to = null

/datum/fax/admin/New()
	GLOB.adminfaxes += src

// Fax panel - lets admins check all faxes sent during the round
/client/proc/fax_panel()
	set name = "Fax Panel"
	set category = "Event"
	if(holder)
		holder.fax_panel(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Fax Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/admins/proc/fax_panel(var/mob/living/user)
	var/html = "<A align='right' href='?src=[UID()];refreshfaxpanel=1'>Refresh</A>"
	html += "<A align='right' href='?src=[UID()];AdminFaxCreate=1;faxtype=Administrator'>Create Fax</A>"

	html += "<div class='block'>"
	html += "<h2>Admin Faxes</h2>"
	html += "<table>"
	html += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='50px'>View</td><td width='50px'>Reply</td><td width='75px'>Replied To</td></td></tr>"
	for(var/datum/fax/admin/A in GLOB.adminfaxes)
		html += "<tr>"
		html += "<td>[A.name]</td>"
		html += "<td>[A.from_department]</td>"
		html += "<td>[A.to_department]</td>"
		html += "<td>[station_time_timestamp("hh:mm:ss", A.sent_at)]</td>"
		if(A.sent_by)
			var/mob/living/S = A.sent_by
			html += "<td>[ADMIN_PP(S,"[S.name]")]</td>"
		else
			html += "<td>Unknown</td>"
		html += "<td><A align='right' href='?src=[UID()];AdminFaxView=\ref[A.message]'>View</A></td>"
		if(!A.reply_to)
			if(A.from_department == "Administrator")
				html += "<td>N/A</td>"
			else
				html += "<td><A align='right' href='?src=[UID()];AdminFaxCreate=\ref[A.sent_by];originfax=\ref[A.origin];faxtype=[A.to_department];replyto=\ref[A.message]'>Reply</A>"
				if(A.sent_by)
					html += "<BR><A align='right' href='?src=[UID()];AdminFaxNotify=\ref[A.sent_by]'>Notify</A>"
				html += "</td>"
			html += "<td>N/A</td>"
		else
			html += "<td>N/A</td>"
			html += "<td><A align='right' href='?src=[UID()];AdminFaxView=\ref[A.reply_to]'>Original</A></td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	html += "<div class='block'>"
	html += "<h2>Departmental Faxes</h2>"
	html += "<table>"
	html += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='175px'>View</td></td></tr>"
	for(var/datum/fax/F in GLOB.faxes)
		html += "<tr>"
		html += "<td>[F.name]</td>"
		html += "<td>[F.from_department]</td>"
		html += "<td>[F.to_department]</td>"
		html += "<td>[station_time_timestamp("hh:mm:ss", F.sent_at)]</td>"
		if(F.sent_by)
			var/mob/living/S = F.sent_by
			html += "<td>[ADMIN_PP(S,"[S.name]")]</td>"
		else
			html += "<td>Unknown</td>"
		html += "<td><A align='right' href='?src=[UID()];AdminFaxView=\ref[F.message]'>View</A></td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	var/datum/browser/popup = new(user, "fax_panel", "Fax Panel", 950, 450)
	popup.set_content(html)
	popup.open()
