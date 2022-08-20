#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define WARNING_FONT_COLOR "#f90"
#define FONT_STYLE "Small Fonts"
#define SCROLL_SPEED 2

GLOBAL_LIST_INIT(statdisp_picture_colors, list(
	"" = COLOR_GRAY,
	"outline" = COLOR_GRAY,
	"ai_awesome" = COLOR_DEEP_SKY_BLUE,
	"ai_beer" = COLOR_DEEP_SKY_BLUE,
	"ai_bsod" = COLOR_CYAN_BLUE,
	"ai_confused" = COLOR_DEEP_SKY_BLUE,
	"ai_dwarf" = COLOR_DEEP_SKY_BLUE,
	"ai_facepalm" = COLOR_WHEAT,
	"ai_fishtank" = COLOR_BLUE_LIGHT,
	"ai_friend" = COLOR_TITANIUM,
	"ai_happy" = COLOR_DEEP_SKY_BLUE,
	"ai_neutral" = COLOR_DEEP_SKY_BLUE,
	"ai_off" = COLOR_GRAY,
	"ai_plump" = COLOR_DEEP_SKY_BLUE,
	"ai_sad" = COLOR_DEEP_SKY_BLUE,
	"ai_surprised" = COLOR_DEEP_SKY_BLUE,
	"ai_tribunal" = COLOR_WHITE,
	"ai_tribunal_malf" = COLOR_WHITE,
	"ai_trollface" = COLOR_BLUE_LIGHT,
	"ai_unsure" = COLOR_DEEP_SKY_BLUE,
	"ai_urist" = COLOR_BLUE_LIGHT,
	"ai_veryhappy" = COLOR_DEEP_SKY_BLUE,
	"biohazard" = COLOR_RED_LIGHT,
	"default" = COLOR_CYAN_BLUE,
	"lockdown" = COLOR_YELLOW,
	"redalert" = COLOR_RED_LIGHT,
	"gammaalert" = COLOR_YELLOW_GRAY,
	"deltaalert" = COLOR_ORANGE,
	"epsilonalert" = COLOR_WHEAT,
	"radiation" = COLOR_YELLOW_GRAY
))

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "дисплей статуса"
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

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	#define CHARS_PER_LINE 5
	#define STATUS_DISPLAY_BLANK 0
	#define STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME 1
	#define STATUS_DISPLAY_MESSAGE 2
	#define STATUS_DISPLAY_ALERT 3
	#define STATUS_DISPLAY_TIME 4
	#define STATUS_DISPLAY_CUSTOM 99

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
	if(stat & (BROKEN|NOPOWER))
		return
	update()

/obj/machinery/status_display/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		remove_display()
	else if(picture_state)
		set_picture(picture_state)

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	mode = STATUS_DISPLAY_ALERT
	remove_display()
	set_picture("ai_tribunal_malf")
	return TRUE

// set what is displayed
/obj/machinery/status_display/proc/update()
	if(friendc && !ignore_friendc)
		if(picture_state != "ai_friend")
			mode = STATUS_DISPLAY_ALERT
			set_picture("ai_friend")
		return TRUE

	switch(mode)
		if(STATUS_DISPLAY_BLANK)	//blank
			remove_display()
			return TRUE
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
			return TRUE
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
			return TRUE
		if(STATUS_DISPLAY_TIME)
			message1 = "ВРЕМЯ"
			message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2)
			return TRUE
	return FALSE

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		return
	if(mode != STATUS_DISPLAY_BLANK && mode != STATUS_DISPLAY_ALERT)
		. += "<span class='notice'>На дисплее написано: <br>\t[sanitize(message1)]<br>\t[sanitize(message2)].</span>"
	if(mode == STATUS_DISPLAY_ALERT)
		. += "<span class='notice'>Текущий уровень угрозы: [get_security_level_ru()]. </span>"

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
	if(state == "outline")
		mode = STATUS_DISPLAY_TIME
	else
		overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)
		set_light(1.5, 2, GLOB.statdisp_picture_colors[picture_state])

/obj/machinery/status_display/proc/update_display(line1, line2, warning = 0)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[warning ? WARNING_FONT_COLOR : FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text
		var/lum = 0.5
		if(line1)
			lum += 0.5
		if(line2)
			lum += 0.5
		set_light(1.5, lum, warning ? COLOR_SUN : COLOR_LIGHT_CYAN)

/obj/machinery/status_display/proc/remove_display()
	if(overlays.len)
		overlays.Cut()
	if(maptext)
		maptext = ""
	if(mode != STATUS_DISPLAY_ALERT && picture_state)
		picture_state = ""
	if(light)
		set_light(0)

/obj/machinery/status_display/receive_signal(datum/signal/signal)
	if(stat & (BROKEN|NOPOWER))
		return
	switch(signal.data["command"])
		if("blank")
			mode = STATUS_DISPLAY_BLANK

		if("shuttle")
			remove_display()
			mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME

		if("message")
			remove_display()
			mode = STATUS_DISPLAY_MESSAGE
			set_message(signal.data["msg1"], signal.data["msg2"])

		if("alert")
			mode = STATUS_DISPLAY_ALERT
			set_picture(signal.data["picture_state"])

		if("time")
			remove_display()
			mode = STATUS_DISPLAY_TIME

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = 1
	density = 0

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.ai_statuschange()

/obj/machinery/ai_status_display/process()
	if(stat & (BROKEN|NOPOWER))
		return
	update()

/obj/machinery/ai_status_display/proc/remove_display()
	if(light)
		set_light(0)
	if(!mode && picture_state)
		picture_state = ""
	if(overlays.len)
		overlays.Cut()

/obj/machinery/ai_status_display/power_change()
	..()
	if(stat & (BROKEN|NOPOWER))
		remove_display()
	else if(picture_state)
		set_picture(picture_state)

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	remove_display()
	set_picture("ai_tribunal_malf")
	return TRUE

/obj/machinery/ai_status_display/proc/update()
	if(mode==0) //Blank
		remove_display()
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
			if("Beer")
				set_picture("ai_beer")
			if("Dwarf")
				set_picture("ai_dwarf")
			if("Fish Tank")
				set_picture("ai_fishtank")
			if("Plump")
				set_picture("ai_plump")
			if("Tribunal")
				set_picture("ai_tribunal")
			if("Tribunal Malf")
				set_picture("ai_tribunal_malf")
		return

	if(mode==2)	// BSOD
		set_picture("ai_bsod")
		return


/obj/machinery/ai_status_display/proc/set_picture(state)
	if(picture_state == state)
		return
	picture_state = state
	if(overlays.len)
		overlays.Cut()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)
	set_light(1.5, 2, GLOB.statdisp_picture_colors[picture_state])

#undef FONT_SIZE
#undef FONT_COLOR
#undef WARNING_FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED

#undef STATUS_DISPLAY_BLANK
#undef STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
#undef STATUS_DISPLAY_MESSAGE
#undef STATUS_DISPLAY_ALERT
#undef STATUS_DISPLAY_TIME
