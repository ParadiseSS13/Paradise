/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message to the recipient (target) as soon as possible.
 * trailing_newline, confidential, and handle_whitespace currently have no effect, please fix this in the future or remove the arguments to lower cache!
 */
/proc/to_chat_immediate(target, html, type, text, avoid_highlighting = FALSE, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE, ticket_id = -1)
	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	// Build a message
	var/message = list()
	if(type)
		message["type"] = type
	if(text)
		message["text"] = text
	if(html)
		message["html"] = html
	if(avoid_highlighting)
		message["avoidHighlighting"] = avoid_highlighting
	if(ticket_id != -1)
		message["ticket_id"] = ticket_id

	// send it immediately
	SSchat.send_immediate(target, message)

/**
 * Sends the message to the recipient (target).
 *
 * Recommended way to write to_chat calls:
 * ```
 * to_chat(client, "You have found <strong>[object]</strong>", MESSAGE_TYPE_INFO,
 * ```
 * Always remember to close spans!
 *
 * Arguments:
 * - target: Refers to the target of the to_chat message. Valid targets include clients, mobs, and the static world controller
 * - html: The Message to be sent to the TARGET. Converted to a string if not already one in this function
 * - type: The chat tab that this message will be sent to, a list of all valid types can be found in chat.dm
 * - text: Unused
 * - avoid_highlighting: Unused
 *
 * `trailing_newline`, `confidential`, and `handle_whitespace` currently have no effect, please fix this in the future or remove the arguments to lower cache!
 */
/proc/to_chat(target, html, type, text, avoid_highlighting, handle_whitespace = TRUE, trailing_newline = TRUE, confidential = FALSE, ticket_id = -1)
	if(Master.current_runlevel == RUNLEVEL_INIT || !SSchat?.initialized)
		to_chat_immediate(target, html, type, text)
		return

	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	// Build a message
	var/message = list()
	if(type)
		message["type"] = type
	if(text)
		message["text"] = text
	if(html)
		message["html"] = html
	if(avoid_highlighting)
		message["avoidHighlighting"] = avoid_highlighting
	if(ticket_id != -1)
		message["ticket_id"] = ticket_id
	SSchat.queue(target, message)
