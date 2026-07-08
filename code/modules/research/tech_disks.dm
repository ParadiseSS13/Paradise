/obj/item/disk/tech_disk
	name = "\improper Technology Disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/tech_id = null
	var/tech_name = null
	// These variables are copied from /datum/tech. They must be copied and cached
	// to prevent retroactively updating all disks when a new research level is unlocked
	/// The level of the copied technology. Please see /datum/tech.level
	var/tech_level = 0
	/// The rarity of the copied technology. Affects sell price. Please see /datum/tech.rare
	var/tech_rarity = 0
	var/default_name = "\improper Technology Disk"
	var/default_desc = "A disk for storing technology data for further research."

/obj/item/disk/tech_disk/proc/load_tech(datum/tech/T)
	name = "[default_name] \[[T]\]"
	desc = T.desc + "\n [SPAN_NOTICE("Level: [T.level]")]"
	// NOTE: This is just a reference to the tech on the system it grabbed it from
	// This seems highly fragile
	tech_id = T.id
	tech_name = T.name
	tech_level = T.level
	tech_rarity = T.rare

/obj/item/disk/tech_disk/proc/wipe_tech()
	name = default_name
	desc = default_desc
	tech_id = null
	tech_name = null
	tech_level = 0
	tech_rarity = 0

/*
	var/points = 0
	/// "research", "illegal", "alien"
	var/p_type = null

// Discs can only hold one kind of research, so we need some special behavior.
// Returns TRUE if operation was complete, FALSE if not.
/obj/item/disk/tech_disk/proc/load_research(research_points, r_type)
	if(points < 0) // Incase we magically get negative points.
		points = 0
		log_debug("Tech Disk [src] had negative points, points set to 0")
	if(points == 0)
		points += research_points
		p_type = r_type
	if(points > 0 && p_type == r_type)
		points += research_points
		return TRUE
	return FALSE

/obj/item/disk/tech_disk/proc/wipe_research()
	points = 0
	p_type = null

*/


/obj/item/disk/design_disk
	name = "\improper Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon_state = "datadisk2"
	var/datum/design/blueprint
	// I'm doing this so that disk paths with pre-loaded designs don't get weird names
	// Otherwise, I'd use "initial()"
	var/default_name = "\improper Component Design Disk"
	var/default_desc = "A disk for storing device design data for construction in lathes."

/obj/item/disk/design_disk/proc/load_blueprint(datum/design/D)
	name = "[default_name] \[[D]\]"
	desc = D.desc
	// NOTE: This is just a reference to the design on the system it grabbed it from
	// This seems highly fragile
	blueprint = D

/obj/item/disk/design_disk/proc/wipe_blueprint()
	name = default_name
	desc = default_desc
	blueprint = null

/datum/research/autolathe/syndicate/New()
	// Used by syndi autolathe in syndie space base ruin. Removes methods of contacting main station.
	. = ..()
	known_designs -= "intercom_electronics"
	known_designs -= "radio_headset"
	known_designs -= "bounced_radio"
	known_designs -= "newscaster_frame"
