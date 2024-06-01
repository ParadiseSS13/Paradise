 /**
  * The lore organisation antagonists are attached to. Influences objectives, steal targets, and discounted items for the antag. Is meant to be a self contained system.
  */
/datum/antag_org
	/// Organisation's name
	var/name = "Generic Bad Guys"
	/// Description given to the antagonist on spawn, below 'You are a Traitor!' or similar
	var/intro_desc = "You are not meant to see this. Please tell admins/coders that the antag_org wasn't set properly."
	/// Used for prob() for objectives. Higher focus means the org is less likely to diverge from their favorites.
	var/focus = 100
	/// If set, the antag's first objective will be forced to this.
	var/datum/objective/forced_objective
	/// List of objectives favored by this org
	var/list/objectives
	/// Estimation of how much trouble this antag will be for security.
	var/chaos_level
