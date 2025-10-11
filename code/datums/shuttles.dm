/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/map_files/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/admin_notes

/datum/map_template/shuttle/proc/preload()
	return

/datum/map_template/shuttle/New()
	if(port_id && suffix)
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

/datum/map_template/shuttle/admin
	port_id = "admin"
	name = "Base Shuttle Template (Admin)"


// Shuttles start here:

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "NTV Bullet (Bar)"
	description = "A luxuriously outfitted shuttle featuring a full-sized bar, gambling table, and bathroom suite. The Command section is equipped with a spacious drawing room."

/datum/map_template/shuttle/emergency/cyb
	suffix = "cyb"
	name = "Emergency shuttle (Cyberiad)"

/datum/map_template/shuttle/emergency/dept
	suffix = "dept"
	name = "NTV Charon (Departmental)"
	description = "A modified Charon-class shuttle featuring areas for each department, and a small bar."
	admin_notes = "Designed to reduce chaos. Each dept requires dept access."

/datum/map_template/shuttle/emergency/military
	suffix = "mil"
	name = "NTV Charon (Militarized)"
	description = "A militarized Charon-class shuttle hull featuring defense turrets and minimal crew comforts."
	admin_notes = "Designed to ensure a safe evacuation during xeno outbreaks."


/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "NCV Snappop(tm)"
	description = "Hey kids and grownups! Are you bored of DULL and TEDIOUS \
		shuttle journeys while you're evacuating for probably BORING reasons? \
		Well then order the Snappop(tm) today! We've got fun activities for \
		everyone, an all access cockpit, and no boring security brig! Boo! \
		Play dress up with your friends! Collect all the bedsheets before \
		your neighbor does! Check if the AI is watching you with our patent \
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
	name = "Emergency shuttle (Metastation)"

/datum/map_template/shuttle/emergency/clockwork
	suffix = "clockwork"
	name = "Clockwork Shuttle"
	description = "A shuttle constructed mostly from brass and clockwork. \
	A large portion of the shuttle is dominated by a chapel that appears to be dedicated to the worship of Ratvar, the Clockwork Justicular."
	admin_notes = "Contains 4 inactive clockwork marauder constructs. Put players into the constructs if you want them to move."

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Looks like this shuttle may have wandered into the \
		darkness between the stars en route to the station. Let's not think \
		too hard about where all the bodies came from."
	admin_notes = "Contains inactive \
		constructs. Put players in constructs if you want them to move. \
		Cloning pods in 'medbay' area are showcases and nonfunctional."

/datum/map_template/shuttle/emergency/old
	suffix = "old"
	name = "Retired Station shuttle."
	description = "An older model of the station shuttle."

/datum/map_template/shuttle/emergency/jungle
	suffix = "jungle"
	name = "Emergency shuttle JUNG-13"
	description = "You can hear screeching and hissing as this shuttle docks."

/datum/map_template/shuttle/emergency/raven
	suffix = "raven"
	name = "NSV Raven"
	description = "The NSV Raven is a former high-risk salvage frigate, now repurposed into an emergency escape shuttle. \
	Formerly first on the scene to pick through war zones for valuable remains, it now serves as an excellent escape option for stations under heavy fire from outside forces. \
	This escape shuttle boasts shields and numerous anti-personnel turrets guarding its perimeter to fend off meteors and enemy boarding attempts."
	admin_notes = "Comes with turrets that will target simple mobs."

/datum/map_template/shuttle/emergency/shadow
	suffix = "shadow"
	name = "NRTV Shadow"
	description = "Guaranteed to get you somewhere FAST. Featuring a supercharged plasma-injection burn drive, this bad boy will put more distance between you and certain death than any other!"
	admin_notes = "The aft of the ship has a plasma tank that starts ignited. May get released by crew. The plasma windows next to the engine heaters will also erupt into flame, and also risk getting released by crew."

/datum/map_template/shuttle/emergency/lance
	suffix = "lance"
	name = "NAV Lance"
	description = "Based on a rejected design by an over-eager member of Nanotrasen Asset Protection, the NAV Lance is designed to tactically slam into destroyed stations, \
	dispatching threats and saving crew at the same time! \
	Be careful to stay out of its path. Comes with a beacon to choose where it docks!"
	admin_notes = "WARNING: This shuttle is designed to crash into the station. It has turrets, similar to the raven. Place down the beacon please. Once the shuttle is loaded, it cannot be unloaded."

/datum/map_template/shuttle/emergency/cherenkov
	suffix = "cherenkov"
	name = "NXV Cherenkov"
	description = "A vessel with a highly experimental supermatter-powered drive that enables it to travel much faster. \
	To minimize crew exposure to radiation, the vessel's drive section is held far from the crew section by long struts. \
	Personal Protective Equipment in the form of suits and meson goggles are available for use, and the medbay is equipped with anti-radiation treatment, and surgical equipment for removing any unwanted growths."
	admin_notes = "The supermatter engine on this shuttle is not a prop, it is fully functional. It is pre-configured into a safe operating mode and should remain stable unless it is tampered with."

/datum/map_template/shuttle/emergency/lance/preload()
	message_admins("Preloading [name]!")
	var/obj/docking_port/stationary/CCport = SSshuttle.getDock("emergency_away")
	CCport.setDir(4)
	CCport.forceMove(locate(136, 107, 1))
	CCport.height = 50
	CCport.dheight = 0
	CCport.width = 19
	CCport.dwidth = 9
	var/obj/docking_port/stationary/syndicate = SSshuttle.getDock("emergency_syndicate")
	syndicate.setDir(8)
	syndicate.forceMove(locate(202, 199, 1))
	syndicate.height = 50
	syndicate.dheight = 0
	syndicate.width = 19
	syndicate.dwidth = 9
	var/obj/docking_port/stationary/home = SSshuttle.getDock("emergency_home")
	SSshuttle.stationary_docking_ports -= home
	qdel(home, TRUE)
	SSshuttle.emergency_locked_in = TRUE

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standard issue Box/Metastation Centcom ferry."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoy! We got all kinds o' meat aft here. Meat from plant \
		people, people who be dark, not in a racist way, just they're dark \
		black. Oh, and lizard meat too, mighty popular that is. Definitely \
		100% fresh, just ask this guy here. *person on meatspike moans* See? \
		Definitely high quality meat, nothin' wrong with it, nothin' added, \
		definitely no zombifyin' reagents!"
	admin_notes = "Meat currently contains no zombifying reagents, people on \
		meatspike must be spawned in."

/datum/map_template/shuttle/admin/hospital
	suffix = "hospital"
	name = "NHV Asclepius"
	description = "Nanotrasen Hospital ship, providing medical assistance during disasters."

/datum/map_template/shuttle/admin/admin
	suffix = "admin"
	name = "NTV Argos"
	description = "Default Admin ship. An older ship used for special operations."

/datum/map_template/shuttle/admin/armory
	suffix = "armory"
	name = "NRV Sparta"
	description = "Armory Shuttle, with plenty of guns to hand out and some general supplies."

/datum/map_template/shuttle/admin/skipjack
	suffix = "skipjack"
	name = "Vox Skipjack"
	description = "Vox skipjack ship."

// Trader Shuttles:
/datum/map_template/shuttle/trader
	port_id = "trader_base"
	prefix = "_maps/map_files/shuttles/trader/"

/datum/map_template/shuttle/trader/sol
	suffix = "sol"
	name = "Solgov Trade Freighter"
	description = "Trading vessel for solgov traders."

/datum/map_template/shuttle/trader/ussp
	suffix = "ussp"
	name = "USSP Trade Barge"
	description = "Trading vessel for USSP traders."

/datum/map_template/shuttle/trader/cybersun
	suffix = "syndicate"
	name = "Cybersun Trade Skiff"
	description = "Trading vessel for cybersun traders."

/datum/map_template/shuttle/trader/glint_scale
	suffix = "glint"
	name = "Glint Scale Trade Hound"
	description = "Trading vessel for glint scale traders."

/datum/map_template/shuttle/trader/steadfast
	suffix = "stead"
	name = "Steadfast Co. Trade Freighter"
	description = "Trading vessel for steadfast company traders."

/datum/map_template/shuttle/trader/synthetic
	suffix = "synth"
	name = "Synthetic Union Trade Vessel"
	description = "Trading vessel for synthetic union traders."

/datum/map_template/shuttle/trader/skipjack
	suffix = "skip"
	name = "Vox Trade Skipjack"
	description = "Trading vessel for skipjack traders."

/datum/map_template/shuttle/trader/skrell
	suffix = "skrell"
	name = "Skrellian Trade Skiff"
	description = "Trading vessel for skrellian central authority traders."

/datum/map_template/shuttle/trader/technocracy
	suffix = "techno"
	name = "Technocracy Trade Pod"
	description = "Trading vessel for technocracy traders."

/datum/map_template/shuttle/trader/guild
	suffix = "guild"
	name = "Merchant Guild Trade Freighter"
	description = "Trading vessel for merchant guild traders."
