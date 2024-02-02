 /**
  * The lore organisation antagonists are attached to. Influences objectives, steal targets, and discounted items for the antag. Is meant to be a self contained system.
  */

/// Antag hunting antag. Might help security overall.
#define ORG_CHAOS_HUNTER -1
/// Will steal items/kill low importance crew, usually not much trouble
#define ORG_CHAOS_MILD 0
/// Your average tator, will be an issue
#define ORG_CHAOS_AVERAGE 1
/// Orgs that specifically targets command/sec or are hijacker-tier threats.
#define ORG_CHAOS_HIGH 2

/datum/antag_org
	/// Organisation's name
	var/name = "Generic Bad Guys"
	/// Organisation's description/lore, shown in faction preference screen.
	var/desc = "A bunch of bad guys doing a little trolling. You shouldn't see this."
	/// Description given to the antagonist on spawn, below 'You are a Traitor!' or similar
	var/intro_desc = "You are not meant to see this. Please tell admins/coders that the antag_org wasn't set properly."
	/// Used for prob() for objectives, discounts, and steal targets. Higher focus means the org is less likely to diverge from their favorites.
	var/focus = 100
	/// If set, the antag's first objective will be forced to this.
	var/forced_objective
	/// List of objectives favored by this org
	var/list/objectives
	/// List of steal targets favored by this org
	var/list/steals
	/// List of discount item categories favored by this org.
	var/list/discount
	/// Estimated difficulty of playing this group, shown in factio preference screen
	var/difficulty
	/// Estimation of how much trouble this antag will be for security.
	var/chaos_level
	/// This organisation is listed as an option on player preferences
	var/selectable = FALSE
