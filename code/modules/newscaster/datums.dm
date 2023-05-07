/**
  * # Feed Network
  *
  * Singleton that contains all informations related to newscasters (channels, stories).
  */
/datum/feed_network
	/// Contains all of the feed channels created during the round.
	var/list/datum/feed_channel/channels = list()
	/// Contains all of the feed stories created during the round.
	var/list/datum/feed_message/stories = list()
	/// The current wanted issue.
	var/datum/feed_message/wanted_issue

/**
  * Returns the [/datum/feed_channel] with the given name, or null if not found.
  *
  * Arguments:
  * * name - The name
  */
/datum/feed_network/proc/get_channel_by_name(name)
	RETURN_TYPE(/datum/feed_channel)
	for(var/fc in channels)
		var/datum/feed_channel/FC = fc
		if(FC.channel_name == name)
			return FC

/**
  * Returns the [/datum/feed_channel] with the given author, or null if not found.
  *
  * Arguments:
  * * author - The author
  */
/datum/feed_network/proc/get_channel_by_author(author)
	RETURN_TYPE(/datum/feed_channel)
	for(var/fc in channels)
		var/datum/feed_channel/FC = fc
		if(FC.author == author)
			return FC

/**
  * Returns the [/datum/feed_channel] at the given index, or null if not found.
  *
  * Arguments:
  * * idx - The index
  */
/datum/feed_network/proc/get_channel_by_idx(idx)
	RETURN_TYPE(/datum/feed_channel)
	if(!ISINDEXSAFE(channels, idx))
		return
	return channels[idx]


/**
  * # Feed Message
  *
  * Describes a single feed story. Always owned by a [/datum/feed_channel].
  */
/datum/feed_message
	/// The author of the story.
	var/author = ""
	/// The author's ckey (admins are watching you post WGW in the newscaster)
	var/author_ckey = ""
	/// The title of the story.
	var/title = ""
	/// The textual contents of the story.
	var/body = ""
	/// The story's icon.
	var/icon/img = null
	/// Flags that dictate the story should be censored.
	var/censor_flags = 0
	/// Whether the story is admin-locked.
	var/admin_locked = FALSE
	/// The number of views the story has.
	var/view_count = 0
	/// The world.time at which the story was published.
	var/publish_time = 0

/datum/feed_message/New()
	publish_time = world.time

/**
  * Clears the story's information.
  *
  * Does not delete it from the owning channel.
  */
/datum/feed_message/proc/clear()
	author = ""
	title = ""
	body = ""
	img = null
	censor_flags = 0
	admin_locked = 0
	view_count = 0
	publish_time = 0

/**
  * # Feed Channel
  *
  * Describes a single feed channel. Owns a list of [/datum/feed_message].
  */
/datum/feed_channel
	/// The name of the channel.
	var/channel_name = ""
	/// The author of the channel.
	var/author = ""
	/// The author's ckey
	var/author_ckey = ""
	/// The description of the channel.
	var/description = ""
	/// The channel's icon.
	var/icon = "newspaper"
	/// The fallback author name to display if the channel is censored.
	var/backup_author = ""
	/// Lazy list. Contains all [/datum/feed_message] pertaining to the channel.
	var/list/datum/feed_message/messages
	/// Whether the channel is public or not.
	var/is_public = FALSE
	/// Whether the channel is frozen or not.
	var/frozen = FALSE
	/// Whether the channel is censored or not.
	var/censored = FALSE
	/// Whether the channel is admin-locked.
	var/admin_locked = FALSE

/datum/feed_channel/Destroy()
	for(var/m in messages)
		GLOB.news_network.stories -= m
	return ..()

/**
  * Returns whether the given user can publish new stories to this channel.
  *
  * Arguments:
  * * user - The user
  * * scanned_user - The user's identifying information on the newscaster
  */
/datum/feed_channel/proc/can_publish(mob/user, scanned_user = "Unknown")
	return (!frozen && (is_public || (author == scanned_user))) || user?.can_admin_interact()

/**
  * Returns whether the given user can edit or delete this channel.
  *
  * Arguments:
  * * user - The user
  * * scanned_user - The user's identifying information on the newscaster
  */
/datum/feed_channel/proc/can_modify(mob/user, scanned_user = "Unknown")
	return (!frozen && author == scanned_user) || user?.can_admin_interact()

/**
  * Clears the channel's information.
  *
  * Discards all owned stories.
  */
/datum/feed_channel/proc/clear()
	channel_name = ""
	author = ""
	backup_author = ""
	messages = list()
	is_public = FALSE
	frozen = FALSE
	censored = FALSE
	admin_locked = FALSE

/**
  * Adds a new [story][/datum/feed_message] to the channel and network singleton.
  *
  * Arguments:
  * * M - The story to add.
  */
/datum/feed_channel/proc/add_message(datum/feed_message/M)
	ASSERT(istype(M))

	if(!length(M.title))
		M.title = "[channel_name] Story #[length(messages) + 1]"
	LAZYADD(messages, M)
	GLOB.news_network.stories += M
	// Update all newscaster TGUIs
	for(var/nc in GLOB.allNewscasters)
		SStgui.update_uis(nc)

/**
  * Returns the text to be said by newscasters when announcing new news from a channel.
  *
  * Arguments:
  * * title - Optional. The headline to announce along with the channel's name. Typically the newest story's title.
  */
/datum/feed_channel/proc/get_announce_text(title)
	if(length(title))
		return "Breaking news from [channel_name]: [title]"
	return "Breaking news from [channel_name]"
