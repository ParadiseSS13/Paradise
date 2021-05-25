// Crew has to recover a disk from Z4
// Heads assamble a crew and send them to recover a ship and finde the disk on a remote planet

/datum/station_goal/redspacesearch
	name = "Redspace Research"
	weight = 2 //No deberia salir de forma normal por el peso

/datum/station_goal/redspacesearch/get_report()
	return {"<b>Redspace Research</b><br>
	We have lost contact with a research facility on a nearby planet to your current location. The Solar Federation gave us directions to recover and old derelict ship with the power and resistance to get into the harsh atmospherics condition on the planet and a docking port planet side that use to be a military outpost where you can dock the ship.
	<br><br>
		Protocol:
	<ul style='margin-top: 10px; margin-bottom: 10px;'>
	 <li>Recover the derelict TSF Ship from (51, 143, 3)</li>
	 <li>Assemble a team of minimum 5 members with at least one scientist and one engineer.</li>
	 <li>Give them equipement in order to recover the disk from the planet. EXPECT HOSTILE ENVIRONMENT</li>
	 <li>Secure the disk on the vault once its station side.</li>
	</ul>
	<br>
	-Nanotrasen Research Division"}

/datum/station_goal/redspacesearch/check_completion()
	if(..())
		return TRUE
	for(var/obj/item/disk/nagadisks/redspaceshit/B)
		if(B && is_station_level(B.z))
			return TRUE
	return FALSE
