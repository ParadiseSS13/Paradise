GLOBAL_LIST_EMPTY(asays)
GLOBAL_LIST_EMPTY(msays)
GLOBAL_LIST_EMPTY(devsays)
GLOBAL_LIST_EMPTY(staffsays)

/datum/say
	var/ckey
	var/rank
	var/message
	var/time

/datum/say/New(ckey = "", rank = "", message = "", time = 0)
	src.ckey = ckey
	src.rank = rank
	src.message = message
	src.time = time

/client/proc/view_msays()
	set name = "Msays"
	set desc = "View Msays from the current round."
	set category = "Admin"

	if(!check_rights(R_MENTOR | R_ADMIN))
		return

	display_says(GLOB.msays, "msay")

/client/proc/view_devsays()
	set name = "Devsays"
	set desc = "View Devsays from the current round."
	set category = "Admin"

	if(!check_rights(R_DEV_TEAM | R_ADMIN))
		return

	display_says(GLOB.devsays, "devsay")

/client/proc/view_asays()
	set name = "Asays"
	set desc = "View Asays from the current round."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	display_says(GLOB.asays, "asay")

/client/proc/view_staffsays()
	set name = "Staffsays"
	set desc = "View Staffsays from the current round."
	set category = "Admin"

	if(!check_rights(R_DEV_TEAM | R_ADMIN))
		return

	display_says(GLOB.staffsays, "staffsay")

/client/proc/display_says(list/say_list, title)

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
	<a href='byond://?src=[holder.UID()];[title]s=1'>Refresh</a>
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

	for(var/datum/say/A in say_list)
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

	var/datum/browser/popup = new(src, title, "<div align='center'>Current Round [capitalize(title)]s</div>", 1200, 825)
	popup.set_content(output.Join())
	popup.open(0)
