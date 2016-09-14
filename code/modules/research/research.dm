/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- possible_tech is a list of all the /datum/tech that can potentially be researched by the player. The RefreshResearch() proc
(explained later) only goes through those when refreshing what you know. Generally, possible_tech contains ALL of the existing tech
but it is possible to add tech to the game that DON'T start in it (example: Xeno tech). Generally speaking, you don't want to mess
with these since they should be the default version of the datums. They're actually stored in a list rather then using typesof to
refer to them since it makes it a bit easier to search through them for specific information.
- know_tech is the companion list to possible_tech. It's the tech you can actually research and improve. Until it's added to this
list, it can't be improved. All the tech in this list are visible to the player.
- possible_designs is functionally identical to possbile_tech except it's for /datum/design.
- known_designs is functionally identical to known_tech except it's for /datum/design

Procs:
- TechHasReqs: Used by other procs (specifically RefreshResearch) to see whether all of a tech's requirements are currently in
known_tech and at a high enough level.
- DesignHasReqs: Same as TechHasReqs but for /datum/design and known_design.
- AddTech2Known: Adds a /datum/tech to known_tech. It checks to see whether it already has that tech (if so, it just replaces it). If
it doesn't have it, it adds it. Note: It does NOT check possible_tech at all. So if you want to add something strange to it (like
a player made tech?) you can.
- AddDesign2Known: Same as AddTech2Known except for /datum/design and known_designs.
- RefreshResearch: This is the workhorse of the R&D system. It updates the /datum/research holder and adds any unlocked tech paths
and designs you have reached the requirements for. It only checks through possible_tech and possible_designs, however, so it won't
accidentally add "secret" tech to it.
- UpdateTech is used as part of the actual researching process. It takes an ID and finds techs with that same ID in known_tech. When
it finds it, it checks to see whether it can improve it at all. If the known_tech's level is less then or equal to
the inputted level, it increases the known tech's level to the inputted level -1 or know tech's level +1 (whichever is higher).

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. All techs start at 1 and have a max of 20. Devices and some techs require a certain
level in specific techs before you can produce them.
- Req_tech:	This is a list of the techs required to unlock this tech path. If left blank, it'll automatically be loaded into the
research holder datum.

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.

									//Datum/tech go here.
	var/list/possible_tech = list()			//List of all tech in the game that players have access to (barring special events).
	var/list/known_tech = list()				//List of locally known tech.
	var/list/possible_designs = list()		//List of all designs (at base reliability).
	var/list/known_designs = list()			//List of available designs (at base reliability).

/datum/research/New()		//Insert techs into possible_tech here. Known_tech automatically updated.
	// MON DIEU!!!
	// These are semi-global, but not TOTALLY global?
	// Using research disks, you can get techs/designs from one research datum
	// onto another. What consequences this could have, I am presently unsure, but
	// I imagine nothing good.
	for(var/T in subtypesof(/datum/tech))
		possible_tech += new T(src)
	for(var/D in subtypesof(/datum/design))
		possible_designs += new D(src)
	RefreshResearch()



//Checks to see if tech has all the required pre-reqs.
//Input: datum/tech; Output: 0/1 (false/true)
/datum/research/proc/TechHasReqs(var/datum/tech/T)
	if(T.req_tech.len == 0)
		return TRUE
	for(var/req in T.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < T.req_tech[req])
			return FALSE
	return TRUE

//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(var/datum/design/D)
	if(D.req_tech.len == 0)
		return TRUE
	for(var/req in D.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < D.req_tech[req])
			return FALSE
	return TRUE

//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
//Input: datum/tech; Output: Null
/datum/research/proc/AddTech2Known(var/datum/tech/T)
	if(known_tech[T.id])
		var/datum/tech/known = known_tech[T.id]
		if(T.level > known.level)
			known.level = T.level
		return
	known_tech[T.id] = T

/datum/research/proc/AddDesign2Known(var/datum/design/D)
	if(known_designs[D.id])
		// NOTE: This is for reliability only - This is on the chopping block
		var/datum/design/known = known_designs[D.id]
		if(D.reliability > known.reliability)
			known.reliability = D.reliability
		return
	// Global datums make me nervous
	known_designs[D.id] = D

//Refreshes known_tech and known_designs list. Then updates the reliability vars of the designs in the known_designs list.
//Input/Output: n/a
/datum/research/proc/RefreshResearch()
	for(var/datum/tech/PT in possible_tech)
		if(TechHasReqs(PT))
			AddTech2Known(PT)
	for(var/datum/design/PD in possible_designs)
		if(DesignHasReqs(PD))
			AddDesign2Known(PD)
	for(var/v in known_tech)
		var/datum/tech/T = known_tech[v]
		T = Clamp(T.level, 0, 20)
	for(var/v in known_designs)
		var/datum/design/D = known_designs[v]
		// NOTE: reliability stuff, axe this later
		D.CalcReliability(known_tech)

//Refreshes the levels of a given tech.
//Input: Tech's ID and Level; Output: null
/datum/research/proc/UpdateTech(var/ID, var/level)
	var/datum/tech/KT = known_tech[ID]
	if(KT)
		if(KT.level <= level)
			// Will bump the tech to (value_of_target - 1) automatically -
			// after that it'll only bump it up by 1 until it's greater
			// than the source tech
			KT.level = max((KT.level + 1), (level - 1))

/datum/research/proc/UpdateDesigns(var/obj/item/I, var/list/temp_tech)
	for(var/T in temp_tech)
		if(temp_tech[T] - 1 >= known_tech[T])
			for(var/datum/design/D in known_designs)
				// NOTE: icky reliability stuff
				if(D.req_tech[T])
					D.reliability = min(100, D.reliability + 1)
					if(D.build_path == I.type)
						D.reliability = min(100, D.reliability + rand(1,3))
						if(I.crit_fail)
							D.reliability = min(100, D.reliability + rand(3, 5))

/datum/research/proc/FindDesignByID(var/id)
	return known_designs[id]

// A common task is for one research datum to copy over its techs and designs
// and update them on another research datum.
// Arguments:
// `other` - The research datum to send designs and techs to
/datum/research/proc/push_data(datum/research/other)
	for(var/v in known_tech)
		var/datum/tech/T = known_tech[v]
		other.AddTech2Known(T)
	for(var/v in known_designs)
		var/datum/design/D = known_designs[v]
		other.AddDesign2Known(D)
	other.RefreshResearch()


//Autolathe files
/datum/research/autolathe

/datum/research/autolathe/DesignHasReqs(var/datum/design/D)
	return D && (D.build_type & AUTOLATHE) && ("initial" in D.category)

/datum/research/autolathe/AddDesign2Known(var/datum/design/D)
	if(!(D.build_type & AUTOLATHE))
		return
	..()

/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/

/datum/tech	//Datum of individual technologies.
	var/name = "name"					//Name of the technology.
	var/desc = "description"			//General description of what it does and what it makes.
	var/id = "id"						//An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 1						//A simple number scale of the research level. Level 0 = Secret tech.
	var/max_level = 1          // Maximum level this can be at (for job objectives)
	var/rare = 1						//How much CentCom wants to get that tech. Used in supply shuttle tech cost calculation.
	var/list/req_tech = list()			//List of ids associated values of techs required to research this tech. "id" = #


//Trunk Technologies (don't require any other techs and you start knowning them).

datum/tech/materials
	name = "Materials Research"
	desc = "Development of new and improved materials."
	id = "materials"
	max_level = 7

datum/tech/engineering
	name = "Engineering Research"
	desc = "Development of new and improved engineering parts and methods."
	id = "engineering"
	max_level = 5

datum/tech/plasmatech
	name = "Plasma Research"
	desc = "Research into the mysterious substance colloqually known as 'plasma'."
	id = "plasmatech"
	max_level = 4
	rare = 3

datum/tech/powerstorage
	name = "Power Manipulation Technology"
	desc = "The various technologies behind the storage and generation of electicity."
	id = "powerstorage"
	max_level = 6

datum/tech/bluespace
	name = "'Blue-space' Research"
	desc = "Research into the sub-reality known as 'blue-space'."
	id = "bluespace"
	max_level = 6
	rare = 2

datum/tech/biotech
	name = "Biological Technology"
	desc = "Research into the deeper mysteries of life and organic substances."
	id = "biotech"
	max_level = 5

datum/tech/combat
	name = "Combat Systems Research"
	desc = "The development of offensive and defensive systems."
	id = "combat"
	max_level=6

datum/tech/magnets
	name = "Electromagnetic Spectrum Research"
	desc = "Research into the electromagnetic spectrum. No clue how they actually work, though."
	id = "magnets"
	max_level = 6

datum/tech/programming
	name = "Data Theory Research"
	desc = "The development of new computer and artificial intelligence and data storage systems."
	id = "programming"
	max_level = 5

datum/tech/syndicate
	name = "Illegal Technologies Research"
	desc = "The study of technologies that violate standard Nanotrasen regulations."
	id = "syndicate"
	max_level = 0 // Don't count towards maxed research, since it's illegal.
	rare = 4

/datum/tech/abductor
	name = "Alien Technologies Research"
	desc = "The study of technologies used by the advanced alien race known as Abductors."
	id = "abductor"
	rare = 5
	level = 0

/*
datum/tech/arcane
	name = "Arcane Research"
	desc = "Research into the occult and arcane field for use in practical science"
	id = "arcane"
	level = 0 //It didn't become "secret" as advertised.

//Branch Techs
datum/tech/explosives
	name = "Explosives Research"
	desc = "The creation and application of explosive materials."
	id = "explosives"
	req_tech = list("materials" = 3)

datum/tech/generators
	name = "Power Generation Technology"
	desc = "Research into more powerful and more reliable sources."
	id = "generators"
	req_tech = list("powerstorage" = 2)

datum/tech/robotics
	name = "Robotics Technology"
	desc = "The development of advanced automated, autonomous machines."
	id = "robotics"
	req_tech = list("materials" = 3, "programming" = 3)
*/

/datum/tech/proc/getCost(var/current_level = null)
	// Calculates tech disk's supply points sell cost
	if(!current_level)
		current_level = initial(level)

	if(current_level >= level)
		return 0

	var/cost = 0
	for(var/i=current_level+1, i<=level, i++)
		if(i == initial(level))
			continue
		cost += i*5*rare

	return cost

/obj/item/weapon/disk/tech_disk
	name = "\improper Technology Disk"
	desc = "A disk for storing technology data for further research."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/tech/stored
	var/default_name = "\improper Technology Disk"
	var/default_desc = "A disk for storing technology data for further research."

/obj/item/weapon/disk/tech_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/disk/tech_disk/proc/load_tech(datum/tech/T)
	name = "[default_name] \[[T]\]"
	desc = T.desc + " Level: '[T.level]'"
	// NOTE: This is just a reference to the tech on the system it grabbed it from
	// This seems highly fragile
	stored = T

/obj/item/weapon/disk/tech_disk/proc/wipe_tech()
	name = default_name
	desc = default_desc
	stored = null

/obj/item/weapon/disk/design_disk
	name = "\improper Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/design/blueprint
	// I'm doing this so that disk paths with pre-loaded designs don't get weird names
	// Otherwise, I'd use "initial()"
	var/default_name = "\improper Component Design Disk"
	var/default_desc = "A disk for storing device design data for construction in lathes."

/obj/item/weapon/disk/design_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/disk/design_disk/proc/load_blueprint(datum/design/D)
	name = "[default_name] \[[D]\]"
	desc = D.desc
	// NOTE: This is just a reference to the design on the system it grabbed it from
	// This seems highly fragile
	blueprint = D

/obj/item/weapon/disk/design_disk/proc/wipe_blueprint()
	name = default_name
	desc = default_desc
	blueprint = null
