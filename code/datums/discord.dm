/*
	DO NOT EDIT ANYTHING IN HERE WITHOUT CHECKING THE DISCORD API SPEC AND TESTING THE JSON POST FORMAT
	OTHERWISE, YOU **WILL** BREAK STUFF -aa
*/

/**
  * # Discord Webhook Payload
  *
  * Holder datum for discord webhook POST send data
  *
  * Holds all information that a webhook would need,
  * as well as a method to serialize the entire thing into JSON.
  * See https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params
  */
/datum/discord_webhook_payload
	/// Name the webhook user should post as
	var/webhook_name
	/// Content of the webhook message
	var/webhook_content
	/// List of all embed objects in the message
	var/list/datum/discord_embed/embeds

/datum/discord_webhook_payload/New()
	embeds = list()

/**
  * Webhook Serializer
  *
  * Converts the DM webhook object into JSON for a POST request.
  * Not called serialize() because thats a proc at the /datum level already
  */
/datum/discord_webhook_payload/proc/serialize2json()
	var/list/json = list()
	if(webhook_name)
		json["username"] = webhook_name
	if(webhook_content)
		var/sanitized_content = webhook_content
		sanitized_content = replacetext(sanitized_content, "@everyone", "(Attempted atEveryone)")
		sanitized_content = replacetext(sanitized_content, "@here", "(Attempted atHere)")
		// Fixes speech marks being replaced by invalid chars
		// Note that we dont have to care about having to sanitize <> out, because discord handles that
		sanitized_content = html_decode(sanitized_content)
		json["content"] = sanitized_content

	// Now serialize the embeds
	if(length(embeds))
		json["embeds"] = list()
		if(length(embeds) > 10)
			embeds.Cut(11) // Cut to 10 embeds because thats the limit of the Discord API

		for(var/e in embeds)
			var/datum/discord_embed/embed = e
			json["embeds"] += list(embed.serialize2list())

	return json_encode(json)

/**
  * # Discord Embed
  *
  * Holder datum for discord embeds
  *
  * Used in [/datum/discord_webhook_payload] and serves as a code-first means to add an embed.
  * See https://discord.com/developers/docs/resources/channel#embed-object
  */
/datum/discord_embed
	/// Title of the embed
	var/embed_title
	/// Content of the embed
	var/embed_content
	/// Colour of the strip on the side of the embed. Must be in hexadecimal WITHOUT leading hash
	var/embed_colour
	/// Timestamp the embed was sent at. Must be in 8601 format. Will be autoset on /New()
	var/embed_timestamp
	/// List of all fields in the embed
	var/list/datum/discord_embed_field/fields

/datum/discord_embed/New()
	embed_timestamp = time_stamp() // 8601 is king
	fields = list() // Initialize the list

/**
  * Embed Serializer
  *
  * Converts the DM embed object into JSON for a POST request.
  * Not called serialize() because thats a proc at the /datum level already
  */
/datum/discord_embed/proc/serialize2list()
	var/list/json = list()
	// All these fields can be nulled so presence check them all
	if(embed_title)
		json["title"] = embed_title
	if(embed_content)
		json["description"] = embed_content
	if(embed_colour)
		json["color"] = hex2num(embed_colour)
	json["timestamp"] = embed_timestamp

	// Now serialize the fields
	if(length(fields))
		json["fields"] = list()
		for(var/f in fields)
			var/datum/discord_embed_field/field = f
			json["fields"] += list(field.serialize2list())

	return json

/**
  * # Discord Embed Field
  *
  * Holder datum for discord embed fields
  *
  * Used in [/datum/discord_embed] and serves as a code-first means to add fields to an embed
  * See https://discord.com/developers/docs/resources/channel#embed-object-embed-field-structure
  */
/datum/discord_embed_field
	/// Name of the field
	var/field_name
	/// Content of the field
	var/field_content
	/// Inline flag
	var/inline = TRUE

/datum/discord_embed_field/proc/serialize2list()
	// name and content CANNOT be nulled, so assert them
	ASSERT(field_name)
	ASSERT(field_content)
	// Now serialize
	var/list/json = list()
	json["name"] = field_name
	json["value"] = field_content
	json["inline"] = inline ? "true" : "false" // Yes this has to be text IN THIS EXACT FORMAT. NO TOUCH.

	return json
