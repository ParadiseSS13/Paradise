GLOBAL_LIST_EMPTY(status_displays)

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	/// Status display mode
	VAR_PRIVATE/mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
	/// icon_state of alert picture
	var/picture_state
	/// Are we spooked?
	var/spookymode = FALSE
	/// Line 1 of a custom message, if any
	var/message1
	/// Line 2 of a custom message, if any
	var/message2
	/// Is this a supply display?
	var/is_supply = FALSE
	// Display indexes for scrolling messages, or 0 if non-scrolling
	var/index1
	var/index2

/obj/machinery/status_display/Initialize()
	. = ..()
	GLOB.status_displays |= src

/obj/machinery/status_display/Destroy()
	GLOB.status_displays -= src
	return ..()

/obj/machinery/status_display/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	if(picture_state)
		. += picture_state

	underlays += emissive_appearance(icon, "lightmask")

/obj/machinery/status_display/power_change()
	..()

	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)

	update_icon(UPDATE_OVERLAYS)

// timed process
/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return

	if(spookymode)
		spookymode = FALSE
		remove_display()
		return

	update()

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	spookymode = TRUE
	return TRUE

// set what is displayed
/obj/machinery/status_display/proc/update()
	switch(mode)
		// Blank
		if(STATUS_DISPLAY_BLANK)
			remove_display()
			return

		if(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			var/use_warn = FALSE

			if(SSshuttle.emergency && SSshuttle.emergency.timer)
				use_warn = TRUE
				message1 = "-[SSshuttle.emergency.getModeStr()]-"
				message2 = SSshuttle.emergency.getTimerStr()

				if(length(message2) > DISPLAY_CHARS_PER_LINE)
					message2 = "Error!"

			else
				message1 = "TIME"
				message2 = station_time_timestamp("hh:mm")

			update_display(message1, message2, use_warn)

		if(STATUS_DISPLAY_MESSAGE)	//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1

			else
				line1 = copytext("[message1]|[message1]", index1, index1 + DISPLAY_CHARS_PER_LINE)
				var/message1_len = length(message1)
				index1 += DISPLAY_SCROLL_SPEED

				if(index1 > message1_len)
					index1 -= message1_len


			if(!index2)
				line2 = message2

			else
				line2 = copytext("[message2]|[message2]", index2, index2 + DISPLAY_CHARS_PER_LINE)
				var/message2_len = length(message2)
				index2 += DISPLAY_SCROLL_SPEED

				if(index2 > message2_len)
					index2 -= message2_len


			update_display(line1, line2)

		if(STATUS_DISPLAY_TIME)
			message1 = "TIME"
			message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2)

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(mode != STATUS_DISPLAY_BLANK && mode != STATUS_DISPLAY_ALERT)
		. += "The display says:<br>\t[sanitize(message1)]<br>\t[sanitize(message2)]"

// Always call update() after using this
/obj/machinery/status_display/proc/set_mode(newmode)
	mode = newmode
	if(mode == STATUS_DISPLAY_ALERT)
		// Its an alert image, clear all text
		set_message(null, null)
	else
		// Not an alert image, clear any leftover image
		set_picture(null)

/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length(m1) > DISPLAY_CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length(m2) > DISPLAY_CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/set_picture(state)
	maptext = null
	picture_state = state
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/status_display/proc/update_display(line1, line2, warning = 0)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[DISPLAY_FONT_SIZE];color:[warning ? DISPLAY_WARNING_FONT_COLOR : DISPLAY_FONT_COLOR];font:'[DISPLAY_FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/remove_display()
	picture_state = null
	update_icon(UPDATE_OVERLAYS)


/proc/post_status(mode, data1, data2)
	if(usr && mode == STATUS_DISPLAY_MESSAGE)
		log_and_message_admins("set status screen message: [data1] [data2]")

	for(var/obj/machinery/status_display/SD as anything in GLOB.status_displays)
		if(SD.is_supply)
			continue

		SD.set_mode(mode)
		switch(mode)
			if(STATUS_DISPLAY_MESSAGE)
				SD.set_message(data1, data2)
			if(STATUS_DISPLAY_ALERT)
				SD.set_picture(data1)

		SD.update()

/obj/machinery/status_display/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		new /obj/item/stack/sheet/metal(drop_location(), 1)
		deconstruct()
