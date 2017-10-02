/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/map_files/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/admin_notes

/datum/map_template/shuttle/New()
	shuttle_id = "[port_id]_[suffix]"
	mappath = "[prefix][shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"


// Shuttles start here:

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "The Emergency Escape Bar"
	description = "Features include a bathroom, a quality lounge for the heads, and a \
		small gambling table."


/datum/map_template/shuttle/emergency/cyb
	suffix = "cyb"
	name = "emergency shuttle (Cyberiad)"

/datum/map_template/shuttle/emergency/dept
	suffix = "dept"
	name = "emergency shuttle (department)"
	description = "Features include: areas for each department, and a small bar."
	admin_notes = "Designed to reduce chaos. Each dept requires dept access."

/datum/map_template/shuttle/emergency/military
	suffix = "mil"
	name = "emergency shuttle (military)"
	description = "Troop transport with point defense turrets."
	admin_notes = "Designed to ensure a safe evacuation during xeno outbreaks."


/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Snappop(tm)!"
	description = "Hey kids and grownups! Are you bored of DULL and TEDIOUS \
		shuttle journeys after you're evacuating for probably BORING reasons. \
		Well then order the Snappop(tm) today! We've got fun activities for \
		everyone, an all access cockpit, and no boring security brig! Boo! \
		Play dress up with your friends! Collect all the bedsheets before \
		your neighbour does! Check if the AI is watching you with our patent \
		pending \"Peeping Tom AI Multitool Detector\" or PEEEEEETUR for \
		short. Have a fun ride!"
	admin_notes = "Brig is replaced by anchored greentext book surrounded by \
		lavaland chasms, stationside door has been removed to prevent \
		accidental dropping."

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Secure Transport Vessel 5 (STV5)"
	description = "Well, looks like Centcomm only had this ship in the area, \
		they probably weren't expecting you to need evac for a while. \
		Probably best if you don't rifle around in whatever equipment they \
		were transporting. I hope you're friendly with your coworkers, \
		because there is very little space in this thing.\n\
		\n\
		Contains contraband armory guns, maintenance loot, and abandoned \
		crates!"
	admin_notes = "Due to origin as a solo piloted secure vessel, has an \
		active GPS onboard labeled STV5."

/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "emergency shuttle (Metastation)"

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Looks like this shuttle may have wandered into the \
		darkness between the stars on route to the station. Let's not think \
		too hard about where all the bodies came from."
	admin_notes = "Contains inactive \
		constructs. Put players in constructs if you want them to move. \
		Cloning pods in 'medbay' area are showcases and nonfunctional."


/datum/map_template/shuttle/emergency/old
	suffix = "old"
	name = "Retired Station shuttle."
	description = "an older model of the station shuttle."

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standard issue Box/Metastation Centcom ferry."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoy! We got all kinds o' meat aft here. Meat from plant \
		people, people who be dark, not in a racist way, just they're dark \
		black. Oh and lizard meat too,mighty popular that is. Definitely \
		100% fresh, just ask this guy here. *person on meatspike moans* See? \
		Definitely high quality meat, nothin' wrong with it, nothin' added, \
		definitely no zombifyin' reagents!"
	admin_notes = "Meat currently contains no zombifying reagents, people on \
		meatspike must be spawned in."
