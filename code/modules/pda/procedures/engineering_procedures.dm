// Procedure relevant to the whole department
/datum/procedure/engineering
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ATMOS, JOBGUIDE_ENGINEER)

// Chief engineer procedures
/datum/procedure/ce
	jobs = list(JOBGUIDE_CE)

// Engineer procedures
/datum/procedure/engineer
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ENGINEER)

// Atmos tech procedures
/datum/procedure/atmos_tech
	jobs = list(JOBGUIDE_CE, JOBGUIDE_ATMOS)

// CE SoP
/datum/procedure/ce/sop
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