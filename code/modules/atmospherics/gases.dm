//  Oh, right. The .dm file. The .dm file for Kuzco, the file chosen especially to datumize gases, Kuzco's .dm file. That .dm file?

#define GAS_OXYGEN "Oxygen"
#define GAS_CARBON_DIOXIDE "Carbon Dioxide"
#define GAS_NITROGEN "Nitrogen"
#define GAS_TOXINS "Toxins"
#define GAS_SLEEPING_AGENT "Sleeping Agent"
#define GAS_AGENT_B "Agent B"
#define GAS_HYDROGEN "Hydrogen"
#define GAS_WATER_VAPOR "Water Vapor"
/datum/gas
	var/name
	var/heat_capacity = 0
	var/moles_visible = null

/datum/gas/oxygen
	name = "Oxygen"
	heat_capacity = 20

/datum/gas/nitrogen
	name = "Nitrogen"
	heat_capacity = 20

/datum/gas/carbon_dioxide
	name = "Carbon Dioxide"
	heat_capacity = 30

/datum/gas/toxins
	name = "Plasma"
	heat_capacity = 200
	moles_visible = 0.5

/datum/gas/sleeping_agent
	name = "Sleeping Agent"
	heat_capacity = 40

/datum/gas/agent_b
	name = "Agent B"
	heat_capacity = 300

/datum/gas/hydrogen
	name = "Hydrogen"
	heat_capacity = 15

/datum/gas/water_vapor
	name = "Water Vapor"
	heat_capacity = 40

#undef GAS_OXYGEN
#undef GAS_CARBON_DIOXIDE
#undef GAS_NITROGEN
#undef GAS_TOXINS
#undef GAS_SLEEPING_AGENT
#undef GAS_AGENT_B
#undef GAS_HYDROGEN
#undef GAS_WATER_VAPOR
