//  Oh, right. The .dm file. The .dm file for Kuzco, the file chosen especially to datumize gases, Kuzco's .dm file. That .dm file?

/datum/gas
	var/name = ""
	var/amount = 0
	var/heat_capacity = 0
	var/moles_visible = null

/datum/gas/oxygen
	name = "Oxygen"
	amount = 0
	heat_capacity = 20

/datum/gas/nitrogen
	name = "Nitrogen"
	amount = 0
	heat_capacity = 20

/datum/gas/carbon_dioxide
	name = "Carbon Dioxide"
	amount = 0
	heat_capacity = 30

/datum/gas/toxins
	amount = 0
	heat_capacity = 200
	moles_visible = 0.5

/datum/gas/sleeping_agent
	amount = 0
	heat_capacity = 40

/datum/gas/agent_b
	amount = 0
	heat_capacity = 300

/datum/gas/hydrogen
	amount = 0
	heat_capacity = 15

/datum/gas/water_vapor
	amount = 0
	heat_capacity = 40

