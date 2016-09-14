#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	var/id = null     		// id of door it controls.
	var/releasetime = 0		// when world.timeofday reaches it - release the prisoner
	var/timing = 0    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()
	var/timetoset = 0		// Used to set releasetime upon starting the timer
	var/obj/item/device/radio/Radio
	maptext_height = 26
	maptext_width = 32

/obj/machinery/door_timer/initialize()
	..()

	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0
	Radio.config(list("Security" = 0))

	pixel_x = ((dir & 3)? (0) : (dir == 4 ? 32 : -32))
	pixel_y = ((dir & 3)? (dir ==1 ? 24 : -32) : (0))

	spawn(20)
		for(var/obj/machinery/door/window/brigdoor/M in airlocks)
			if(M.id == id)
				targets += M

		for(var/obj/machinery/flasher/F in machines)
			if(F.id == id)
				targets += F

		for(var/obj/structure/closet/secure_closet/brig/C in world)
			if(C.id == id)
				targets += C

		for(var/obj/machinery/treadmill_monitor/T in machines)
			if(T.id == id)
				targets += T

		if(targets.len==0)
			stat |= BROKEN
		update_icon()


//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(timing)
		if(timeleft() <= 0)
			Radio.autosay("Timer has expired. Releasing prisoner.", name, "Security", list(z))
			timer_end() // open doors, reset timer, clear status screen
			timing = 0
			. = PROCESS_KILL

		updateUsrDialog()
		update_icon()
	else
		timer_end()
		return PROCESS_KILL

// has the door power situation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	..()
	update_icon()


// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.

// Closes and locks doors, power check
/obj/machinery/door_timer/proc/timer_start()
	if(stat & (NOPOWER|BROKEN))
		return 0

	// Set releasetime
	releasetime = world.timeofday + timetoset
	if(!(src in machine_processing))
		machine_processing += src

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)
			continue
		spawn(0)
			door.close()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened && !C.close())
			continue
		C.locked = 1
		C.icon_state = C.icon_locked

	for(var/obj/machinery/treadmill_monitor/T in targets)
		T.total_joules = 0
		T.on = 1

	return 1


// Opens and unlocks doors, power check
/obj/machinery/door_timer/proc/timer_end()
	if(stat & (NOPOWER|BROKEN))
		return 0

	// Reset releasetime
	releasetime = 0

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)
			continue
		spawn(0)
			door.open()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened)
			continue
		C.locked = 0
		C.icon_state = C.icon_closed

	for(var/obj/machinery/treadmill_monitor/T in targets)
		if(!T.stat)
			T.redeem()
		T.on = 0

	return 1


// Check for releasetime timeleft
/obj/machinery/door_timer/proc/timeleft()
	var/time = releasetime - world.timeofday
	if(time > MIDNIGHT_ROLLOVER / 2)
		time -= MIDNIGHT_ROLLOVER
	if(time < 0)
		return 0
	return time / 10

// Set timetoset
/obj/machinery/door_timer/proc/timeset(seconds)
	timetoset = seconds * 10

	if(timetoset <= 0)
		timetoset = 0

	return

//Allows AIs to use door_timer, see human attack_hand function below
/obj/machinery/door_timer/attack_ai(mob/user)
	return attack_hand(user)


//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
/obj/machinery/door_timer/attack_hand(mob/user)
	if(..())
		return

	// Used for the 'time left' display
	var/second = round(timeleft() % 60)
	var/minute = round((timeleft() - second) / 60)

	// Used for 'set timer'
	var/setsecond = round((timetoset / 10) % 60)
	var/setminute = round(((timetoset / 10) - setsecond) / 60)

	user.set_machine(src)

	// dat
	var/dat = "<HR>Timer System:</hr>"
	dat += " <b>Door [id] controls</b><br/>"

	// Start/Stop timer
	if(timing)
		dat += "<a href='?src=[UID()];timing=0'>Stop Timer and open door</a><br/>"
	else
		dat += "<a href='?src=[UID()];timing=1'>Activate Timer and close door</a><br/>"

	// Time Left display (uses releasetime)
	dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
	dat += "<br/>"

	// Set Timer display (uses timetoset)
	if(timing)
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]  <a href='?src=[UID()];change=1'>Set</a><br/>"
	else
		dat += "Set Timer: [(setminute ? text("[setminute]:") : null)][setsecond]<br/>"

	// Controls
	dat += "<a href='?src=[UID()];tp=-60'>-</a> <a href='?src=[UID()];tp=-1'>-</a> <a href='?src=[UID()];tp=1'>+</a> <A href='?src=[UID()];tp=60'>+</a><br/>"

	// Mounted flash controls
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			dat += "<br/><A href='?src=[UID()];fc=1'>Flash Charging</A>"
		else
			dat += "<br/><A href='?src=[UID()];fc=1'>Activate Flash</A>"

	dat += "<br/><br/><a href='?src=[user.UID()];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "door_timer", name, 400, 500)
	popup.set_content(dat)
	popup.open()


//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// 	"change" resets the timer to the timetoset amount while the timer is counting down
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if(!allowed(usr))
		return

	usr.set_machine(src)

	if(href_list["timing"])
		timing = text2num(href_list["timing"])

		if(timing)
			timer_start()
		else
			timer_end()

	else
		if(href_list["tp"])  //adjust timer, close door if not already closed
			var/tp = text2num(href_list["tp"])
			var/addtime = (timetoset / 10)
			addtime += tp
			addtime = min(max(round(addtime), 0), 3600)

			timeset(addtime)

		if(href_list["fc"])
			for(var/obj/machinery/flasher/F in targets)
				F.flash()

		if(href_list["change"])
			timer_start()

	add_fingerprint(usr)
	updateUsrDialog()
	update_icon()


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return
	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	if(timing)
		var/disp1 = id
		var/timeleft = timeleft()
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)	maptext = ""


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	picture_state = state
	overlays.Cut()
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text


//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/door_timer/proc/texticon(tn, px = 0, py = 0)
	var/image/I = image('icons/obj/status_display.dmi', "blank")
	var/len = lentext(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)
		ID.pixel_x = -(d-1)*5 + px
		ID.pixel_y = py
		I.overlays += ID
	return I


/obj/machinery/door_timer/cell_1
	name = "Cell 1"
	id = "Cell 1"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_2
	name = "Cell 2"
	id = "Cell 2"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_3
	name = "Cell 3"
	id = "Cell 3"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_4
	name = "Cell 4"
	id = "Cell 4"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_5
	name = "Cell 5"
	id = "Cell 5"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_6
	name = "Cell 6"
	id = "Cell 6"
	dir = 4
	pixel_x = 32

#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE