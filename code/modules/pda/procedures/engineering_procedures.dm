// Procedure relevant to engineering as a whole
/datum/procedure/engineering
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ATMOS, JOBGUIDE_ENGINEER)

// Chief engineer procedure
/datum/procedure/ce
	jobs = list(JOBGUIDE_CE)

// Engineer procedure
/datum/procedure/engineer
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ENGINEER)

// Atmos tech procedure
/datum/procedure/atmos_tech
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ATMOS)

// MARK: SOP
/datum/procedure/ce/sop
	name = "Chief Engineer SOP"
	catalog_category = "SOP"
	steps = list(
		"The Chief Engineer must make sure that the Supermatter Engine and/or Solar Panels are fully set up and supplying power to the station before any further action is taken by themselves or their team",
		"The Chief Engineer, along with the Research Director, is responsible for maintaining the integrity of Telecommunications. The Chief Engineer must not hinder the proper functionality of Telecommunications, and must diagnose and repair any issues that arise",
		"The Chief Engineer is bound to the same rules regarding the axe as Atmospheric Technicians",
		"The Chief Engineer is permitted to carry a telescopic baton and a flash",
		"The Chief Engineer is responsible for maintaining the integrity of all engines set up on the station. Neglecting this duty is grounds for termination should the engine malfunction",
		"The Chief Engineer is responsible for maintaining the integrity of the Station's Atmospherics System. Failure to maintain this integrity is grounds for termination",
		"The Chief Engineer may declare an area \"Condemned\", if it is damaged to the point where repairs cannot reasonably be completed within an acceptable frame of time",
		"The Chief Engineer is permitted to grant Building Permits to crewmembers, but must keep the Station Blueprints in a safe location at all times",)

/datum/procedure/engineer/sop
	name = "Engineer SOP"
	catalog_category = "SOP"
	steps = list(
		"Engineers must properly activate and wire the Supermatter Engine and/or Solar Panels at the start of the shift, before any other actions are undertaken",
		"Engineers are responsible for maintaining the integrity of the engines. Neglecting this duty is grounds for termination should an engine malfunction",
		"Engineers are not permitted to construct additional engines (such as additional SM/Tesla/Singularity engines, or solar panels) until at least one engine is correctly set up and powering the station",
		"Engineers are permitted to carry out solo reconstruction/rebuilding/personal projects if there is no damage to the station that requires fixing",
		"Engineers must check each active engine at least once per 30 minutes",
		"The Supermatter Engine, if online and under emitter fire, must be constantly monitored.",
		"Engineers must respond promptly to breaches, regardless of size. Failure to report within fifteen (15) minutes will be considered a breach of Standard Operating Procedure, unless there are no spare Engineers to report or an Atmospheric Technician has arrived on scene first. All Hazard Zones must be cordoned off with Engineering Tape or holobarriers, for the sake of everyone else",
		"Engineers are permitted to hack doors to gain unauthorized access to locations if said locations happen to require urgent repairs",
		"Engineers are to maintain the integrity of the Station's Power Network. In addition, when hotwiring to the grid, the grid must be maintained under 1MW",
		"Engineers must ensure there is at least one (1) engineering MODsuit available on the station at all times, unless there is an emergency that requires the use of all suits"
		)

/datum/procedure/atmos_tech/sop
	name = "Atmospherics Technician SOP"
	catalog_category = "SOP"
	steps = list(
		"Atmospheric Technicians are permitted to completely repipe the Atmospherics Piping Setup, provided they do not pump harmful gases into anywhere except the Turbine",
		"Atmospheric Technicians are not permitted to create volatile mixes using Plasma and Oxygen, nor are they permitted to create any potentially harmful mixes with Carbon Dioxide and/or Nitrous Oxide. An exception is made when working with the Turbine",
		"Atmospheric Technicians are permitted to cool Plasma and store it for later use in Radiation Collectors. Likewise, they are permitted to cool Nitrogen or Carbon Dioxide and store it for use as coolant for the Supermatter Engine",
		"Atmospheric Technicians are not permitted to take the axe out of its case unless there is an immediate and urgent threat to their life or urgent access to crisis locations is necessary. The axe must be returned to the case afterwards, and the case locked",
		"Atmospheric Technicians are not permitted to tamper with the default values on Air Alarms. They are, however, permitted to create small, acclimatized rooms for species that require special atmospheric conditions (such as Plasmamen and Vox), provided they receive express permission from the Chief Engineer",
		"Atmospheric Technicians must periodically check on the Central Alarms Computer, in periods of, at most, thirty (30) minutes",
		"Atmospheric Technicians must respond promptly to piping and station breaches. Failure to report within fifteen (15) minutes will be considered a breach of Standard Operating Procedure, unless there are no spare Atmospheric Technicians to report, or an Engineer has arrived on scene first. All Hazard Zones must be cordoned off with Engineering Tape or holobarriers, for the sake of everyone else.",
		)
/* MARK: Engineering
*
*
*
*
*
* MARK: SM Delam
*/
/datum/procedure/engineering/supermatter_delam
	catalog_category = "Supermatter Delamination"

/datum/procedure/engineering/supermatter_delam/moles
	name = "Coolant Critical Mass Procedure"
	steps = list(
		"Remove gas from the chamber until the console reads under 12000 moles per tile",
		"If for whatever reason gas cannot be pumped out of the chamber use an RCD to remove a floor tile, then rebuild it."
		)

/datum/procedure/engineering/supermatter_delam/fire
	name = "Chamber Fire Procedure"
	steps = list(
		"Prepare cold N2. As much as you can in a reasonable time, but no more than 100,000 moles",
		"Scrub all gasses other than N2",
		"Inject cold N2 into the engine while using a fire extinguisher",
		"If unsuccessful, stop injecting N2, remove a floor tile with an RCD, then replace it and quickly inject cold N2",
		"Alternatively to the previous step use a nanofrost particle launcher on the vent side of the chamber and unweld the vents once the fire has ceased"
		)

/datum/procedure/engineering/supermatter_delam/power
	name = "Charge Inertia Chain Reaction Procedure"
	steps = list(
		"If the engine is also on fire, perform the chamber fire procedure",
		"Reduce the portion of CO2 in the gas mix by injecting N2 or N2O, this will quickly drop EER",
		"Alternatively, reduce the amount of CO2 in the chamber, this will more slowly drop EER"
		)

/datum/procedure/engineering/supermatter_delam/breach
	name = "Chamber Breach Procedure"
	steps = list(
		"Prepare cold N2. As much as you can in a reasonable time, but no more than 100,000 moles",
		"Fix the walls of the chamber before fixing the floor if it is breached",
		"Fix the floor of the chamber and quickly inject the cold N2",
		"If the loop is too broken to allow injecting gas and there is not enough time to repair it use a passive vent piped to a nitrogen caniser to refill the chamber instead"
		)
// MARK: SM operation

/datum/procedure/engineering/supermatter_operation
	catalog_category = "Supermatter Operation"

/datum/procedure/engineering/supermatter_operation/basic_setup
	name = "Basic Setup"
	steps = list(
		"Replace all pumps aside from the one connecting the input and output sides with pipes",
		"Turn on the pumps on the two N2 tanks, or pump in N2 from atmos",
		"Turn on all filters and set them to maximum, making sure at least one filters N2",
		"Go to the air alarm and set all vents to 0Kpa on internal pressure target",
		"Set all scrubbers to extended and scrub all gasses(Don't use siphon, just set each gas individually)"
		)

// MARK: Disassembly

/datum/procedure/engineering/disassembly
	catalog_category = "Disassembly"

/datum/procedure/engineering/disassembly/wall
	name = "Wall Disassembly"
	steps = list(
		"Apply welder on harm intent (2 sheets of the wall material returned)",
		"Apply wrench to girder (2 metal returned)"
		)

/datum/procedure/engineering/disassembly/r_wall
	name = "Reinforced Wall Disassembly"
	steps = list(
		"Apply wirecutters",
		"Apply screwdriver",
		"Apply active welder",
		"Apply crowbar",
		"Apply wrench",
		"active welder",
		"Apply crowbar (1 plasteel returned)",
		"Apply screwdriver",
		"Apply wirecutters",
		"Apply wrench (1 plasteel, 2 metal returned)",
		)

/datum/procedure/engineering/disassembly/general_machinery
	name = "General Machine Disassembly"
	steps = list(
		"Apply screwdriver",
		"Apply crowbar",
		"Apply wirecutter to mahcine frame",
		"Apply wrench to machine frame(5 metal sheets returned)",
		)

/datum/procedure/engineering/disassembly/airlock
	name = "Airlock Disassembly"
	steps = list(
		"Make sure Wire Panel is screwed closed",
		"Weld airlock closed with active welding tool on harm intent",
		"Apply screwdriver",
		"Make sure the bolts are up (Airlock Unbolted)",
		"Apply wirecutters/multitool, cut/pulse the test wire",
		"Apply crowbar (airlock electronics returned)",
		"Apply wirecutters to airlock assembly(cable returned)",
		"Apply wrench to airlock assembly",
		"Apply active welder to airlock assembly(4 metal or mineral returned)",
		)

// MARK: Assembly

/datum/procedure/engineering/assembly
	catalog_category = "Assembly"

/datum/procedure/engineering/assembly/wall
	name = "Wall Assembly"
	steps = list(
		"Use metal in-hand",
		"Select \"wall girders\"",
		"Apply wall material to girder",
		)

/datum/procedure/engineering/assembly/r_wall
	name = "Reinforced Wall Assembly"
	steps = list(
		"Use metal in-hand",
		"Select \"wall girders\"",
		"Apply plasteel to girder",
		"Apply plasteel again",
		)

/datum/procedure/engineering/assembly/general_machinery
	name = "General Machine Assembly"
	steps = list(
		"Use metal in-hand",
		"Select \"machine frame\"",
		"Apply wires to frame",
		"Insert the circuitboard into the frame",
		"Insert parts into the frame",
		"Apply screwdriver to the frame"
		)

/datum/procedure/engineering/assembly/airlock
	name = "Airlock Assembly"
	steps = list(
		"Use metal or mineral in-hand",
		"Select \"airlock assemblies\"",
		"Select desired sub-type",
		"Apply wrench",
		"Apply cable coil",
		"Apply glass (optional)",
		"Use airlock electronics in-hand to set access",
		"Insert airlock electronics",
		"(optional) use a multiltool to enable the electrochromic function",
		"(optional)Use pen to rename",
		"Apply screwdriver"
		)


/* MARK: Engineer
*
*
*
*
*
* MARK: Power
*/

/datum/procedure/engineer/power
	catalog_category = "Power"

/datum/procedure/engineer/power/smes_shift_start
	name = "Shift Start SMES Setup Procedure"
	steps = list(
		"Set the power input to maximum on all SMES",
		"Set the power output to a total of 400KW across all SMES",
		"If there is a power deficit and the SMES are empty, reduce the output so that all SMES receive the same amount of power"
		)

/datum/procedure/engineer/power/apc_repair
	name = "Shorted APC Repair Procedure"
	steps = list(
		"Open the APC with a screwdriver",
		"Use wirecutter to mend the damaged wires",
		"Close the APC with a screwdriver",
		"Unlock the APC with your ID",
		"Set the breaker to On",
		"Lock the APC with your ID"
		)

/* MARK: Atmos Tech
*
*
*
*
*
* MARK: Atmospherics
*/

/datum/procedure/atmos_tech/atmospherics
	catalog_category = "Atmospherics"

/datum/procedure/atmos_tech/atmospherics/shift_start_setup
	name = "Shift Start Setup"
	steps = list(
		"Set all filters to maximum pressure",
		"Replace the volume pump going into distro with either a pipe or a pressure pump",
		"Build heat exchanging pipes in space and connect them to the line going to the Supermatter"
		)
