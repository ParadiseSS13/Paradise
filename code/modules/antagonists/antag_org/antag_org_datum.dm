 /**
  * The lore organization antagonists are attached to. Influences objectives and steal targets.
  */
/datum/antag_org
	/// Organization's name
	var/name = "Buggy Organization, adminhelp this please"
	/// Description given to the antagonist on spawn, below 'You are a Traitor!' or similar
	var/intro_desc = "You are not meant to see this. Please tell admins/coders that the antag_org wasn't set properly."
	/// Used for prob() for objectives. Higher focus means the org is less likely to diverge from their favorites.
	var/focus = 100
	/// If set, the antag's first objective(s) will be forced to this.
	var/list/forced_objectives
	/// List of objectives favored by this org
	var/list/objectives
	/// Department(s) targeted by this organization if any
	var/list/targeted_departments
	/// List of theft targets favored by this organization if any
	var/list/theft_targets
	/// Estimation of how much trouble this antag will be for security.
	var/chaos_level
