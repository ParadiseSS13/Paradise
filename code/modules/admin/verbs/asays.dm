GLOBAL_LIST_EMPTY(asays)

/datum/asays
	var/ckey
	var/rank
	var/message
	var/time

/datum/asays/New(ckey = "", rank = "", message = "", time = 0)
	src.ckey = ckey
	src.rank = rank
	src.message = message
	src.time = time

/client/proc/view_asays()
	set name = "Asays"
	set desc = "View Asays from the current round."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/list/output = list({"
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
	<a href='byond://?src=[holder.UID()];asays=1'>Refresh</a>
	<table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 3px;'>
	"})

	// Header & body start
	output += {"
		<thead>
			<tr>
				<th width="5%">Time</th>
				<th width="10%">Ckey</th>
				<th width="85%">Message</th>
			</tr>
		</thead>
		<tbody>
	"}

	for(var/datum/asays/A in GLOB.asays)
		var/timestr = time2text(A.time, "hh:mm:ss")
		output += {"
			<tr>
				<td width="5%">[timestr]</td>
				<td width="10%"><b>[A.ckey] ([A.rank])</b></td>
				<td width="85%">[A.message]</td>
			</tr>
		"}

	output += {"
		</tbody>
	</table>"}

	var/datum/browser/popup = new(src, "asays", "<div align='center'>Current Round Asays</div>", 1200, 825)
	popup.set_content(output.Join())
	popup.open(0)
