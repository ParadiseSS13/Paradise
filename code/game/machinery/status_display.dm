#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define WARNING_FONT_COLOR "#f90"
#define FONT_STYLE "Small Fonts"
#define SCROLL_SPEED 2

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = 1
	density = 0
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/mode = 1	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Station time

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	frequency = DISPLAY_FREQ		// radio frequency

	var/friendc = 0      // track if Friend Computer mode
	var/ignore_friendc = 0

	var/spookymode = 0

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	var/const/CHARS_PER_LINE = 5
	var/const/STATUS_DISPLAY_BLANK = 0
	var/const/STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME = 1
	var/const/STATUS_DISPLAY_MESSAGE = 2
	var/const/STATUS_DISPLAY_ALERT = 3
	var/const/STATUS_DISPLAY_TIME = 4
	var/const/STATUS_DISPLAY_CUSTOM = 99

/obj/machinery/status_display/Destroy()
	if(SSradio)
		SSradio.remove_object(src,frequency)
	return ..()

// register for radio system
/obj/machinery/status_display/Initialize()
	..()
	if(SSradio)
		SSradio.add_object(src, frequency)

// timed process
/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return
	if(spookymode)
		spookymode = 0
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
	if(friendc && !ignore_friendc)
		set_picture("ai_friend")
		return 1

	switch(mode)
		if(STATUS_DISPLAY_BLANK)	//blank
			remove_display()
			return 1
		if(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)				//emergency shuttle timer
			var/use_warn = 0
			if(SSshuttle.emergency && SSshuttle.emergency.timer)
				use_warn = 1
				message1 = "-[SSshuttle.emergency.getModeStr()]-"
				message2 = SSshuttle.emergency.getTimerStr()

				if(length(message2) > CHARS_PER_LINE)
					message2 = "Error!"
			else
				message1 = "ВРЕМЯ"
				message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2, use_warn)
			return 1
		if(STATUS_DISPLAY_MESSAGE)	//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext_char(message1+"|"+message1, index1, index1+CHARS_PER_LINE)
				var/message1_len = length_char(message1)
				index1 += SCROLL_SPEED
				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2
			else
				line2 = copytext_char(message2+"|"+message2, index2, index2+CHARS_PER_LINE)
				var/message2_len = length_char(message2)
				index2 += SCROLL_SPEED
				if(index2 > message2_len)
					index2 -= message2_len
			update_display(line1, line2)
			return 1
		if(STATUS_DISPLAY_TIME)
			message1 = "ВРЕМЯ"
			message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2)
			return 1
	return 0

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(mode != STATUS_DISPLAY_BLANK && mode != STATUS_DISPLAY_ALERT)
		. += "На дисплее написано:<br>\t[sanitize(message1)]<br>\t[sanitize(message2)]"

/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/set_picture(state)
	picture_state = state
	remove_display()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)

/obj/machinery/status_display/proc/update_display(line1, line2, warning = 0)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[warning ? WARNING_FONT_COLOR : FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/remove_display()
	if(overlays.len)
		overlays.Cut()
	if(maptext)
		maptext = ""

/obj/machinery/status_display/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			mode = STATUS_DISPLAY_BLANK

		if("shuttle")
			mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME

		if("message")
			mode = STATUS_DISPLAY_MESSAGE
			set_message(signal.data["msg1"], signal.data["msg2"])

		if("alert")
			mode = STATUS_DISPLAY_ALERT
			set_picture(signal.data["picture_state"])

		if("time")
			mode = STATUS_DISPLAY_TIME

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = 1
	density = 0

	var/spookymode = 0

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.ai_statuschange()

/obj/machinery/ai_status_display/process()
	if(stat & NOPOWER)
		overlays.Cut()
		return
	if(spookymode)
		spookymode = 0
		overlays.Cut()
		return
	update()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	spookymode = TRUE
	return TRUE

/obj/machinery/ai_status_display/proc/update()
	if(mode==0) //Blank
		overlays.Cut()
		return

	if(mode==1)	// AI emoticon
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("Surprised")
				set_picture("ai_surprised")
			if("Upset")
				set_picture("ai_upset")
			if("Angry")
				set_picture("ai_angry")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Dorfy")
				set_picture("ai_urist")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
		return

	if(mode==2)	// BSOD
		set_picture("ai_bsod")
		return


/obj/machinery/ai_status_display/proc/set_picture(var/state)
	picture_state = state
	if(overlays.len)
		overlays.Cut()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)

#undef FONT_SIZE
#undef FONT_COLOR
#undef WARNING_FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
