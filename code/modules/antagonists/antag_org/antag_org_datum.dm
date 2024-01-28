 /**
  * The lore organisation antagonists are attached to. Influences objectives, steal targets, and discounted items for the antag. Is meant to be a self contained system.
  */

/// Antag hunting antag. Might help security overall.
#define ORG_CHAOS_HUNTER -1
/// Will steal items, might kill low importance crew, usually not much trouble
#define ORG_CHAOS_MILD 0
/// Your average tator, will be an issue
#define ORG_CHAOS_AVERAGE 1
/// Orgs that specifically targets command/sec or are hijacker-tier threats.
#define ORG_CHAOS_HIGH 2

/datum/antag_org
	/// Organisation's name
	var/name = "Generic Bad Guys"
	/// Organisation's description/lore
	var/desc = "A bunch of bad guys doing a little trolling. You shouldn't see this."
	/// Text given as introduction. 'You are...'
	var/you_are = "a generic bad guy"
	/// Description given to the antagonist on gain
	var/intro_desc = "Please tell admins/coders that the antag_group wasn't set properly."
	/// List of objectives favored by this org
	var/list/objectives
	/// List of steal targets favored by this org
	var/list/steals
	/// List of discount items favored by this org. Only one out of three discounts will be from this list, rest is completely random.
	var/list/discount
	/// Estimated difficulty of playing this group, displayed when selecting your favorite.
	var/difficulty
	/// Estimation of how much trouble this antag will be for security.
	var/chaos_level
	/// This organisation is listed as an option on player preferences
	var/selectable = FALSE
