/datum/technode
var/name = "Error"
var/desc = "If you see this, make a bug report!"
var/id = ""
var/icon = ""

/// List of technode IDs required to reveal this node.
var/list/prereqs = list()
/// List of design IDs this node unlocks.
var/list/unlocks = list()
/// Points of each type required to unlock this node.
var/list/cost = list("research" = 500, "illegal" = 0, "alien" = 0)

/// Is this node unlocked by default?
var/innate = FALSE

// The following are not mutually exclusive, and may be used togeather.
/// Is this node hidden until its prereqs are met?
var/hidden = FALSE
/// If non-zero, node will be hidden until total point generation of its type(s) reaches this point.
var/list/cost_hidden = list() // Useful for illegal and alien nodes.
/// Is this node hidden even when unlocked?
var/super_hidden = FALSE // Primarily for the basenode.

// Used as a dummy prereq for starting nodes.
/datum/technode/core
super_hidden = TRUE
