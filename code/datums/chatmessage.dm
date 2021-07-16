/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME		0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN		5 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE		0.7 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY		0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY	0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT	11
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH			96
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH		110
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP			0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z			(CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP
/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x)			text2num(copytext(x, findtextEx(x, "x") + 1))

/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  */
/datum/chatmessage
	/// The visual element of the chat messsage
	var/image/message
	/// The location in which the message is appearing
	var/atom/message_loc
	/// The client who heard this message
	var/client/owned_by
	/// Contains the scheduled destruction time, used for scheduling EOL
	var/scheduled_destruction
	/// Contains the time that the EOL for the message will be complete, used for qdel scheduling
	var/eol_complete
	/// Contains the approximate amount of lines for height decay
	var/approx_lines
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/prev

/**
  * Constructs a chat message overlay
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * italics - Should we use italics or not
  * * lifespan - The lifespan of the message in deciseconds
  * * symbol - The symbol type of the message
  */
/datum/chatmessage/New(text, atom/target, mob/owner, italics, size, lifespan = CHAT_MESSAGE_LIFESPAN, symbol)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return
	INVOKE_ASYNC(src, .proc/generate_image, text, target, owner, lifespan, italics, size, symbol)

/datum/chatmessage/Destroy()
	if (owned_by)
		if (owned_by.seen_messages)
			LAZYREMOVEASSOC(owned_by.seen_messages, message_loc, src)
		owned_by.images.Remove(message)
	owned_by = null
	message_loc = null
	message = null
	leave_subsystem()
	return ..()

/**
  * Calls qdel on the chatmessage when its parent is deleted, used to register qdel signal
  */
/datum/chatmessage/proc/on_parent_qdel()
	qdel(src)

/**
  * Generates a chat message image representation
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * radio_speech - Fancy shmancy radio icon represents that we use radio
  * * lifespan - The lifespan of the message in deciseconds
  * * italics - Just copy and paste, sir
  * * size - Size of the message
  * * symbol - The symbol type of the message
  */
/datum/chatmessage/proc/generate_image(text, atom/target, mob/owner, lifespan, italics, size, symbol)
	// Register client who owns this message
	owned_by = owner.client
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, .proc/on_parent_qdel)

	// Clip message
	var/maxlen = CHAT_MESSAGE_MAX_LENGTH
	var/datum/html/split_holder/s = split_html(text)
	if (length_char(s.inner_text) > maxlen)
		var/chattext = copytext_char(s.inner_text, 1, maxlen + 1) + "..."
		text = jointext(s.opening, "") + chattext + jointext(s.closing, "")

	// Calculate target color if not already present
	if (!target.chat_color || target.chat_color_name != target.name)
		target.chat_color = colorize_string(target.name)
		target.chat_color_name = target.name

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	var/output_color = sanitize_color(target.get_runechat_color()) // Get_runechat_color can be overriden on atoms to display a specific one (Example: Humans having their hair colour as runechat colour)

	// Symbol for special runechats (emote)
	switch(symbol)
		if(RUNECHAT_SYMBOL_EMOTE)
			symbol = "<span style='font-size: 9px; color: #3399FF;'>*</span> "
			size = size || "small"
		else
			symbol = null

	// Approximate text height
	var/static/regex/html_metachars = new(@"&[A-Za-z]{1,7};", "g")
	var/complete_text = "<span class='center maptext[size ? " [size]" : ""]' style='[italics ? "font-style: italic; " : ""]color: [output_color]'>[symbol][text]</span>"
	var/mheight = WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH))
	approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	message_loc = target
	if (owned_by.seen_messages)
		var/idx = 1
		var/combined_height = approx_lines
		for(var/msg in owned_by.seen_messages[message_loc])
			var/datum/chatmessage/m = msg
			animate(m.message, pixel_y = m.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			combined_height += m.approx_lines
			var/sched_remaining = m.scheduled_destruction - world.time
			if (!m.eol_complete)
				var/remaining_time = (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** combined_height)
				m.enter_subsystem(world.time + remaining_time) // push updated time to runechat SS

	// Reset z index if relevant
	if (current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	// Build message image
	message = image(loc = message_loc, layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx++)
	message.plane = GAME_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.alpha = 0
	message.pixel_y = owner.bound_height * 0.95
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (CHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5
	message.maptext = complete_text

	// View the message
	LAZYADDASSOC(owned_by.seen_messages, message_loc, src)
	owned_by.images |= message
	animate(message, alpha = 255, time = CHAT_MESSAGE_SPAWN_TIME)

	// Prepare for destruction
	scheduled_destruction = world.time + (lifespan - CHAT_MESSAGE_EOL_FADE)
	enter_subsystem()

/**
  * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion
  */
/datum/chatmessage/proc/end_of_life(fadetime = CHAT_MESSAGE_EOL_FADE)
	eol_complete = scheduled_destruction + fadetime
	animate(message, alpha = 0, time = fadetime, flags = ANIMATION_PARALLEL)
	enter_subsystem(eol_complete) // re-enter the runechat SS with the EOL completion time to QDEL self

/**
  * Creates a message overlay at a defined location for a given speaker
  *
  * Arguments:
  * * speaker - The atom who is saying this message
  * * raw_message - The text content of the message
  * * italics - Vacuum and other things
  * * size - Size of the message
  * * symbol - The symbol type of the message
  */
/mob/proc/create_chat_message(atom/movable/speaker, raw_message, italics = FALSE, size, symbol)

	if(isobserver(src))
		return


	// Display visual above source
	new /datum/chatmessage(raw_message, speaker, src, italics, size, CHAT_MESSAGE_LIFESPAN, symbol)


// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN	0.6
#define CM_COLOR_SAT_MAX	0.7
#define CM_COLOR_LUM_MIN	0.65
#define CM_COLOR_LUM_MAX	0.75

/**
  * Gets a color for a name, will return the same color for a given string consistently within a round.atom
  *
  * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
  *
  * Arguments:
  * * name - The name to generate a color for
  * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
  * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
  */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + station_name()), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"


/**
  * Ensures a colour is bright enough for the system
  *
  * This proc is used to brighten parts of a colour up if its too dark, and looks bad
  *
  * Arguments:
  * * hex - Hex colour to be brightened up
  */
/datum/chatmessage/proc/sanitize_color(color)
	var/list/HSL = rgb2hsl(hex2num(copytext(color,2,4)),hex2num(copytext(color,4,6)),hex2num(copytext(color,6,8)))
	HSL[3] = max(HSL[3],0.4)
	var/list/RGB = hsl2rgb(arglist(HSL))
	return "#[num2hex(RGB[1],2)][num2hex(RGB[2],2)][num2hex(RGB[3],2)]"

/**
  * Proc to allow atoms to set their own runechat colour
  *
  * This is a proc designed to be overridden in places if you want a specific atom to use a specific runechat colour
  * Exampls include consoles using a colour based on their screen colour, and mobs using a colour based off of a customisation property
  *
  */
/atom/proc/get_runechat_color()
	return chat_color
