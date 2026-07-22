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
	var/list/cost = list("research" = 500)

	/// Will this node be visible even without prereqs?
	var/starting_node = FALSE

	// The following are not mutually exclusive, and may be used togeather.
	/// Is this node hidden until its prereqs are met?
	var/hidden = TRUE
	/// If non-zero, node will be hidden until total point generation of its type(s) reaches this point.
	var/list/cost_hidden = list() // Useful for illegal and alien nodes.
