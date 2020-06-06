GLOBAL_LIST_EMPTY(asays)

/datum/asays
	var/ckey = ""
	var/rank = ""
	var/message = ""
	var/time = 0

/client/proc/viewasays()
	set name = "View Asays"
	set desc = "View Asays from the current round."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/output = "<table style='width: 100%;'>"

	// Header & body start
	output += {"
		<thead style='color: #517087; font-weight: bold; table-layout: fixed;'>
			<tr>
				<th>Time</th>
				<th>Ckey</th>
				<th>Message</th>
			</tr>
		</thead>
		<tbody>
	"}

	for (var/datum/asays/A in GLOB.asays)
		var/timestr = time2text(A.time, "hh:mm:ss")
		output += {"
			<tr>
				<td>[timestr]</td>
				<td><b>[A.ckey] ([A.rank])</b></td>
				<td>[A.message]</td>
			</tr>
		"}

	output += {"
		</tbody>
	</table>"}

	var/datum/browser/popup = new(src, "asays", "<div align='center'>Current Round Asays</div>", 1000, 800)
	popup.set_content(output)
	popup.open(0)
