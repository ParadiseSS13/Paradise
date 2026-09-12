/datum/technode
	var/name = "Error"
	var/desc = "If you see this, make a bug report!"
	var/id = "error"
	var/node_type = "Error"

	/// List of technode IDs required to reveal this node.
	var/list/prereqs = list()
	/// List of design IDs this node unlocks.
	var/list/unlocks = list()
	/// Points of each type required to unlock this node.
	var/list/cost = list("Research" = 250)

	/// Will this node be visible even without prereqs?
	var/starting_node = FALSE

	/// If non-zero, node will be hidden until total point generation of its type(s) reaches this point.
	var/list/cost_hidden = list() // Useful for illegal and alien nodes.

/datum/technode/New()
	if(prereqs.len == 0 && !starting_node)
		log_debug("Technode [src] and its designs are inaccessable!")
	if(unlocks.len == 0)
		log_debug("Technode [src] has no design unlocks!")
	if(cost["Research"] <= 250 && !starting_node)
		log_debug("Technode [src] has a 250 or less cost but is not a starting node!") // MIXTODO - Remove some of this logging.

#warn REMAINING TECHNODES: Weapons, MODsuits, Mech Equipment, Illegal and Alien tech, Sort various circuitboards into relevent technodes.
