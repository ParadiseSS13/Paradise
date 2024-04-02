/// Stores information about a chat payload
/datum/chat_payload
	/// Sequence number of this payload
	var/sequence = 0
	/// Message we are sending
	var/list/content
	/// Resend count
	var/resends = 0
	var/target
	var/list/targets
	var/delivery_attempt = 0

/datum/chat_payload/Destroy(force = FALSE, ...)
	target = null
	targets.Cut()
	return ..()

/// Converts the chat payload into a JSON string
/datum/chat_payload/proc/into_message()
	return "{\"sequence\":[sequence],\"content\":[json_encode(content)]}"

/// Returns an HTML-encoded message from our contents.
/datum/chat_payload/proc/get_content_as_html()
	return message_to_html(content)
