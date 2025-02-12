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
	var/moles_visible

/datum/gas/oxygen
	name = "GAS_OXYGEN"

/datum/gas/carbon_dioxide
	name = "GAS_CARBON_DIOXIDE"

/datum/gas/nitrogen
	name = "GAS_NITROGEN"

/datum/gas/toxins
	name = "GAS_TOXINS"
	moles_visible = 0.5

/datum/gas/sleeping_agent
	name = "GAS_SLEEPING_AGENT"

/datum/gas/agent_b
	name = "GAS_AGENT_B"

/datum/gas/hydrogen
	name = "GAS_HYDROGEN"


/datum/gas/water_vapor
	name = "GAS_WATER_VAPOR"
