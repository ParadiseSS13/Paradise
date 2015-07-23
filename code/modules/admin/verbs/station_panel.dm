/* Stationbuse panel
This is an admin verb specifically for station-wide effects.
*/


/client/proc/station_panel()
	set name = "Stationbuse Panel"
	set desc = "Abuse the station!"
	set category = "Event"

	if(!check_rights(R_SERVER|R_EVENT))	return

	if(holder)
		holder.station_buse_panel()

/datum/admins/proc/station_buse_panel()
	if(!check_rights(R_SERVER|R_EVENT))	return

	var/dat = "<center>"

	//DOORS
	dat += "<p><b>Doors:</b> <a href='?src=\ref[src];stationPanel=lockdoors'>Bolt all doors on station-Z.</a>"
	dat += "[TAB][TAB]<a href='?src=\ref[src];stationPanel=opendoors'>Open all doors on station-Z.</a></p>"

	//ALARMS
	dat += "<p><b>Alarm:</b> <a href='?src=\ref[src];stationPanel=firedrill'>Start a fire drill (Turn on all fire-alarms).</a></p>"

	dat += "</center>"

	var/datum/browser/popup = new(usr, "stationbuse", "<div align='center'>Station-abusing panel!</div>", 500, 600)
	popup.set_content(dat)
	popup.open(0)