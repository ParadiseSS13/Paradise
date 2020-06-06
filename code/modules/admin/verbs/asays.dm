GLOBAL_LIST_EMPTY(asays)

/datum/asays
	var/ckey = ""
	var/rank = ""
	var/message = ""
	var/time = 0

/client/proc/view_asays()
	set name = "View Asays"
	set desc = "View Asays from the current round."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/output = {"
		<style>
		td, th
		{
			border: 1px solid #425c6e;
			padding: 3px;
		}

		thead
		{
			color: #517087;
			font-weight: bold;
			table-layout: fixed;
		}
	</style>
	<table style='width: 100%; border-collapse: collapse; table-layout: auto;'>
	"}

	// Header & body start
	output += {"
		<thead>
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

	var/datum/browser/popup = new(src, "asays", "<div align='center'>Current Round Asays</div>", 1200, 825)
	popup.set_content(output)
	popup.open(0)
