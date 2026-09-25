///assoc list of ckey -> /datum/persistent_client
GLOBAL_LIST_EMPTY_TYPED(persistent_clients_by_ckey, /datum/persistent_client)
/// A flat list of all persistent clients, for her looping pleasure.
//GLOBAL_LIST_EMPTY_TYPED(persistent_clients, /datum/persistent_client)

/// Tracks information about a client between log in and log outs
/datum/persistent_client
	/// The true client
	var/client/client
	/// The mob this persistent client is currently bound to.
	var/mob/mob

	/// Major version of BYOND this client is using.
	var/byond_version
	/// Build number of BYOND this client is using.
	var/byond_build

	/// Action datums assigned to this player
	var/list/datum/action/player_actions = list()

	/// Callbacks invoked when this client logs in again
	var/list/post_login_callbacks = list()
	/// Callbacks invoked when this client logs out
	var/list/post_logout_callbacks = list()

	/// List of names this key played under this round
	/// assoc list of name -> mob tag
	var/list/played_names = list()
	/// Lazylist of preference slots this client has joined the round under
	/// Numbers are stored as strings
	var/list/joined_as_slots

	/// Tracks achievements they have earned
	var/datum/achievement_data/achievements

	/// World.time this player last died
	var/time_of_death = 0

	/// Holds admin/mentor PM history.
	var/datum/pm_tracker/pm_tracker
	/// The Global Antag Candidacy setting from the new player menu.
	var/skip_antag = FALSE
	/// Used to prevent rapid mouse spamming.
	var/time_died_as_mouse = null
	/// All of the minds this client has been associated with.
	var/list/minds = list()
	/// Ckeys that sent us kudos.
	var/list/kudos_received_from = list()

/datum/persistent_client/New(ckey, client)
	src.client = client
	achievements = new(ckey)
	GLOB.persistent_clients_by_ckey[ckey] = src
	GLOB.persistent_clients += src

/datum/persistent_client/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	. = QDEL_HINT_LETMELIVE
	CRASH("Who the FUCK tried to delete a persistent client? Get your head checked you leadskull.")

/// Setter for the mob var, handles both references.
/datum/persistent_client/proc/set_mob(mob/new_mob)
	if(mob == new_mob)
		return

	mob?.persistent_client = null
	new_mob?.persistent_client?.set_mob(null)

	mob = new_mob
	new_mob?.persistent_client = src

/// Writes all of the `played_names` into an HTML-escaped string.
/datum/persistent_client/proc/get_played_names(sanitize = TRUE, seperator = "; ")
	var/list/previous_names = list()
	for(var/previous_name in played_names)
		var/combined_name = "[previous_name] ([played_names[previous_name]])"
		previous_names += sanitize ? html_encode(combined_name) : combined_name
	return previous_names.Join(seperator)

/// Returns the full version string (i.e 515.1642) of the BYOND version and build.
/datum/persistent_client/proc/full_byond_version()
	if(!byond_version)
		return "Unknown"
	return "[byond_version].[byond_build || "xxx"]"

///Redirect proc that makes it easier to call the unlock achievement proc. Achievement type is the typepath to the award, user is the mob getting the award, and value is an optional variable used for leaderboard value increments
/datum/persistent_client/proc/give_award(achievement_type, mob/user, value = 1)
	return achievements.unlock(achievement_type, user, value)

/// Adds the new names to the player's played_names list on their /datum/persistent_client for use of admins.
/// `ckey` should be their ckey, and `data` should be an associative list with the keys being the names they played under and the values being the unique mob ID tied to that name.
/proc/log_played_names(ckey, data)
	if(!ckey)
		return

	var/datum/persistent_client/writable = GLOB.persistent_clients_by_ckey[ckey]
	if(isnull(writable))
		return

	for(var/name in data)
		if(!name)
			continue
		var/mob_tag = data[name]
		var/encoded_name = html_encode(name)
		if(writable.played_names.Find("[encoded_name]"))
			continue
		writable.played_names += list("[encoded_name]" = mob_tag)
