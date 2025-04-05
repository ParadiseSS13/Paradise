/datum/procedure/supply
	jobs = list(
		JOBGUIDE_QM,
		JOBGUIDE_CARGO_TECH,
		JOBGUIDE_MINER,
		JOBGUIDE_EXPLORER,
		JOBGUIDE_SMITH
		)

/datum/procedure/qm
	jobs = list(JOBGUIDE_QM)

/datum/procedure/cargo_tech
	jobs = list(JOBGUIDE_QM, JOBGUIDE_CARGO_TECH)

/datum/procedure/miner
	jobs = list(JOBGUIDE_QM, JOBGUIDE_MINER)

/datum/procedure/explorer
	jobs = list(JOBGUIDE_QM, JOBGUIDE_EXPLORER)

/datum/procedure/smith
	jobs = list(JOBGUIDE_QM, JOBGUIDE_SMITH)

/datum/procedure/qm/sop
	name = "Quartermaster SOP"
	catalog_category = "SOP"
	steps = list(
		"The Quartermaster must ensure that every approved order is delivered within 15 minutes of having been placed and approved",
		"In the event of a major crisis, such as Nuclear Operatives or a Blob Organism, expediency is to be favored over paperwork, as excessive bureaucracy may be detrimental to the well-being of the station",
		"The Quartermaster is permitted to hack the Autolathe, or to have a Cargo Tech do so, assuming they do not produce illegal materials",
		"The Quartermaster is not permitted to authorize the ordering of Security equipment and/or gear without express permission from the Head of Security and/or Captain. An exception is made during extreme emergencies, such as Nuclear Operatives or a Blob Organism, where said equipment is to be delivered to Security, post haste",
		"The Quartermaster is permitted to authorize non-departmental orders (such as a Medical Doctor asking for Insulated Gloves) without express permission from the respective Head of Staff (in this example, the Chief Engineer), utilizing their best judgement, although they may still request a stamped form. However, any breach of Standard Operating Procedure and/or Space Law that results from said order will also implicate the Quartermaster",
		"The Quartermaster is not permitted to authorize a Supermatter Crate without express permission from the Chief Engineer",
		"The Quartermaster is required to follow the guidelines put in place for Cargo Technicians."
		)

/datum/procedure/cargo_tech/sop
	name = "Cargo Tech SOP"
	catalog_category = "SOP"
	steps = list(
		"The Quartermaster must ensure that every approved order is delivered within 15 minutes of having been placed and approved",
		"In the event of a major crisis, such as Nuclear Operatives or a Blob Organism, expediency is to be favored over paperwork, as excessive bureaucracy may be detrimental to the well-being of the station",
		"The Quartermaster is permitted to hack the Autolathe, or to have a Cargo Tech do so, assuming they do not produce illegal materials",
		"The Quartermaster is not permitted to authorize the ordering of Security equipment and/or gear without express permission from the Head of Security and/or Captain. An exception is made during extreme emergencies, such as Nuclear Operatives or a Blob Organism, where said equipment is to be delivered to Security, post haste",
		"The Quartermaster is permitted to authorize non-departmental orders (such as a Medical Doctor asking for Insulated Gloves) without express permission from the respective Head of Staff (in this example, the Chief Engineer), utilizing their best judgement, although they may still request a stamped form. However, any breach of Standard Operating Procedure and/or Space Law that results from said order will also implicate the Quartermaster",
		"The Quartermaster is not permitted to authorize a Supermatter Crate without express permission from the Chief Engineer",
		"The Quartermaster is required to follow the guidelines put in place for Cargo Technicians."
		)


/datum/procedure/miner/sop
	name = "Miner SOP"
	catalog_category = "SOP"
	steps = list(
		"Shaft Miners are not permitted to bring Gibtonite aboard the station",
		"Shaft Miners must deliver at least 1000 Points of mined material to the Ore Redemption Machine within one (1) hour",
		"Shaft Miners are not permitted to hoard materials. All mined materials are to be left in the Ore Redemption Machine",
		"Shaft Miners are not permitted to throw people into manufactured wormholes, nor are they permitted to trick people into using Bluespace Crystals, or throwing Bluespace Crystals at anyone",
		"Shaft Miners are not permitted to mine their way into the Labor Camp",
		"Shaft Miners are not permitted to give Lavaland acquired items to station crew, unless the Quartermaster approves",
		"Shaft Miners are bound by guidelines set for Cargo Technicians when inside the Cargo Office or Bay."
		)

/datum/procedure/explorer/sop
	name = "Explorer SOP"
	catalog_category = "SOP"
	steps = list(
		"Explorers must bring any contraband found in space to Security immediately upon return to the station",
		"Explorers are not to make use of any weaponry found in space without a permit, and must bring any found to Security immediately upon return to the station",
		"Explorers are not to allow usage of the teleporter room to crew lacking access without Command approval",
		"Explorers must expand the telecommunication network in one space sector with the use of their telecommunication relay kit",
		"Explorers must keep in contact with the Supply department while on an expedition",
		"Explorers are not permitted to give weapons or other illict items/drugs acquired through space expeditions to station crew unless the Quartermaster and Head of Security approves within Space Law",
		"Explorers are bound by the guidelines set for Cargo Technicians when inside the Cargo Office or Bay",
		"Explorers are required to bring any salvage they find to the Supply Shuttle for selling."
		)

/datum/procedure/smith/sop
	name = "Smith SOP"
	catalog_category = "SOP"
	steps = list(
		"SOP missing"
	)
