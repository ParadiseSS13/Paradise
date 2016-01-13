// AI (i.e. game AI, not the AI player) controlled bots
/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	light_range = 3
	use_power = 0
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/list/prev_access = list()
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	var/hacked = 0 //Used to differentiate between being hacked by silicons and emagged by humans.
	var/text_hack = ""		//Custom text returned to a silicon upon hacking a bot.
	var/text_dehack = "" 	//Text shown when resetting a bots hacked status to normal.
	var/text_dehack_fail = "" //Shown when a silicon tries to reset a bot emagged with the emag item, which cannot be reset.
	var/declare_message = "" //What the bot will display to the HUD user.
	var/frustration = 0 //Used by some bots for tracking failures to reach their target.
	var/speed = 2 //The speed at which the bot moves, or the number of times it moves per process() tick.
	var/turf/ai_waypoint //The end point of a bot's path, or the target location.
	var/list/path = list() //List of turfs through which a bot 'steps' to reach the waypoint.
	var/pathset = 0
	var/list/ignore_list = list() //List of unreachable targets for an ignore-list enabled bot to ignore.
	var/mode = 0 //Standardizes the vars that indicate the bot is busy with its function.
	var/tries = 0 //Number of times the bot tried and failed to move.
	var/remote_disabled = 0 //If enabled, the AI cannot *Remotely* control a bot. It can still control it through cameras.
	var/mob/living/silicon/ai/calling_ai //Links a bot to the AI calling it.
	var/obj/item/device/radio/Radio //The bot's radio, for speaking to people.
	var/radio_name = "Common"
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots
	var/auto_patrol = 0// set to make bot automatically patrol
	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/turf/summon_target	// The turf of a user summoning a bot.
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = BOT_FREQ		// bot control frequency

	var/bot_filter 				// The radio filter the bot uses to identify itself on the network.

	var/bot_type = 0 //The type of bot it is, for radio control.
	#define SEC_BOT				1	// Secutritrons (Beepsky) and ED-209s
	#define MULE_BOT			2	// MULEbots
	#define FLOOR_BOT			3	// Floorbots
	#define CLEAN_BOT			4	// Cleanbots
	#define MED_BOT				5	// Medibots
	var/bot_type_name = "Bot"

	#define DEFAULT_SCAN_RANGE		7	//default view range for finding targets.

	//Mode defines
	#define BOT_IDLE 			0	// idle
	#define BOT_HUNT 			1	// found target, hunting
	#define BOT_PREP_ARREST 	2	// at target, preparing to arrest
	#define BOT_ARREST			3	// arresting target
	#define BOT_START_PATROL	4	// start patrol
	#define BOT_PATROL			5	// patrolling
	#define BOT_SUMMON			6	// summoned by PDA
	#define BOT_CLEANING 		7	// cleaning (cleanbots)
	#define BOT_REPAIRING		8	// repairing hull breaches (floorbots)
	#define BOT_MOVING			9	// for clean/floor bots, when moving.
	#define BOT_HEALING			10	// healing people (medbots)
	#define BOT_RESPONDING		11	// responding to a call from the AI
	#define BOT_LOADING			12	// loading/unloading
	#define BOT_DELIVER			13	// moving to deliver
	#define BOT_GO_HOME			14	// returning to home
	#define BOT_BLOCKED			15	// blocked
	#define BOT_NAV				16	// computing navigation
	#define BOT_WAIT_FOR_NAV	17	// waiting for nav computation
	#define BOT_NO_ROUTE		18	// no destination beacon found (or no route)
	var/list/mode_name = list("In Pursuit","Preparing to Arrest","Arresting","Beginning Patrol","Patrolling","Summoned by PDA", \
	"Cleaning", "Repairing", "Proceeding to work site","Healing","Responding","Loading/Unloading","Navigating to Delivery Location","Navigating to Home", \
	"Waiting for clear path","Calculating navigation path","Pinging beacon network","Unable to reach destination")
	//This holds text for what the bot is mode doing, reported on the AI's bot control interface.

/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	set_light(initial(light_range))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	set_light(0)
	bot_reset() //Resets an AI's call, should it exist.

/obj/machinery/bot/New()
	..()
	aibots += src //Global bot list
	botcard = new /obj/item/weapon/card/id(src)
	set_custom_texts()
	Radio = new /obj/item/device/radio(src)
	Radio.listening = 0 //Makes bot radios transmit only so no one hears things while adjacent to one.
	Radio.config(list("[radio_name]" = 0))
	Radio.follow_target = src


/obj/machinery/bot/Destroy()
	aibots -= src
	qdel(Radio)
	Radio = null
	qdel(botcard)
	botcard = null
	return ..()

/obj/machinery/bot/proc/add_to_beacons(bot_filter) //Master filter control for bots. Must be placed in the bot's local New() to support map spawned bots.
	spawn(20)
		if(radio_controller)
			radio_controller.add_object(src, beacon_freq, RADIO_NAVBEACONS)
			if(bot_filter)
				radio_controller.add_object(src, control_freq, bot_filter)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (health <= 0)
		explode()

/obj/machinery/bot/proc/Emag(mob/user as mob) //Master Emag proc. Ensure this is called in your bot before setting unique functions.
	if(locked) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		locked = 0
		emagged = 1
		user << "<span class='warning'>You bypass [src]'s controls.</span>"
	if(!locked && open) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		emagged = 2
		remote_disabled = 1 //Manually emagging the bot locks out the AI built in panel.
		locked = 1 //Access denied forever!
		bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
	else //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		user << "<span class='notice'>You need to open maintenance panel first.</span>"

/obj/machinery/bot/examine(mob/user)
	..(user)
	if (health < maxhealth)
		if (health > maxhealth/3)
			user << "<span class='danger'>[src]'s parts look loose.</span>"
		else
			user << "<span class='danger'>[src]'s parts look very loose.</span>"
	else
		user << "[src] is in pristine condition."

/obj/machinery/bot/attack_alien(var/mob/living/carbon/alien/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	health -= rand(15,30)*brute_dam_coeff
	visible_message("<span class='userdanger'>[user] has slashed [src]!</span>")
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)
	healthcheck()


/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	M.do_attack_animation(src)
	if(M.melee_damage_upper == 0)
		return
	health -= M.melee_damage_upper
	visible_message("<span class='userdanger'>[M] has [M.attacktext] [src]!</span>")
	add_logs(M, src, "attacked", admin=0)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)
	healthcheck()

/obj/machinery/bot/Topic(href, href_list) //Master Topic to handle common functions.
	. = ..()
	if (.)
		return
	if(topic_denied(usr))
		usr << "<span class='warning'>[src]'s interface is not responding!</span>"
		href_list = list()
		return

	usr.set_machine(src)
	add_fingerprint(usr)
	if((href_list["power"]) && (allowed(usr) || !locked))
		if (on)
			turn_off()
		else
			turn_on()

	switch(href_list["operation"])
		if("patrol")
			auto_patrol = !auto_patrol
			mode = BOT_IDLE
		if("remote")
			remote_disabled = !remote_disabled
		if("hack")
			if(emagged != 2)
				emagged = 2
				hacked = 1
				locked = 1
				usr << "<span class='warning'>[text_hack]</span>"
				bot_reset()
			else if(!hacked)
				usr << "<span class='userdanger'>[text_dehack_fail]</span>"
			else
				emagged = 0
				hacked = 0
				usr << "<span class='notice'>[text_dehack]</span>"
				bot_reset()
	updateUsrDialog()

/obj/machinery/bot/proc/topic_denied(mob/user) //Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
	// 0 for access, 1 for denied.
	if(emagged == 2) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) //Manually emagged by a human - access denied to all.
			return 1
		else if(!issilicon(user)) //Bot is hacked, so only silicons are allowed access.
			return 1
	else
		return 0

/obj/machinery/bot/proc/bot_process() //Master process which handles code common across most bots.

	set background = BACKGROUND_ENABLED

	if(!on)
		return

	switch(mode) //High-priority overrides are processed first. Bots can do nothing else while under direct command.
		if(BOT_RESPONDING)	//Called by the AI.
			call_mode()
			return
		if(BOT_SUMMON)		//Called by PDA
			bot_summon()
			return
	return 1 //Successful completion. Used to prevent child process() continuing if this one is ended early.


/obj/machinery/bot/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			user << "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>"
		else
			user << "<span class='warning'>Maintenance panel is locked.</span>"
	else
		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != I_HARM)
			if(health >= maxhealth)
				user << "<span class='warning'>[src] does not need a repair.</span>"
				return
			if(!open)
				user << "<span class='warning'>Unable to repair with the maintenance panel closed.</span>"
				return
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				health = min(maxhealth, health+10)
				user.visible_message("<span class='notice'>[user] repairs [src]!</span>","<span class='notice'>You repair [src]!</span>")
			else
				user << "<span class='warning'>The welder must be on for this task.</span>"
		else
			if(W.force) //if force is non-zero
				var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
				s.set_up(5, 1, src)
				switch(W.damtype)
					if("fire")
						health -= W.force * fire_dam_coeff
						s.start()
					if("brute")
						health -= W.force * brute_dam_coeff
						s.start()
				..()
				healthcheck()

/obj/machinery/bot/emag_act(user as mob)
	if (emagged < 2)
		Emag(user)

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		if(prob(75) && Proj.damage > 0)
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		..()
		healthcheck()
	return

/obj/machinery/bot/blob_act()
	health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			health -= rand(5,10)*fire_dam_coeff
			health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				health -= rand(1,5)*fire_dam_coeff
				health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		pulse2.delete()
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()

/obj/machinery/bot/proc/hack(mob/user)
	var/hack
	if(issilicon(user)) //Allows silicons to toggle the emag status of a bot.
		hack += "[emagged == 2 ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <A href='?src=\ref[src];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) //Humans with access can use this option to hide a bot from the AI's remote control panel and PDA control.
		hack += "Remote network control radio: <A href='?src=\ref[src];operation=remote'>[remote_disabled ? "Disconnected" : "Connected"]</A><BR><BR>"
	return hack

/obj/machinery/bot/proc/set_custom_texts() //Superclass for setting hack texts. Appears only if a set is not given to a bot locally.
	text_hack = "You hack [name]."
	text_dehack = "You reset [name]."
	text_dehack_fail = "You fail to reset [name]."

/obj/machinery/bot/attack_ai(mob/user as mob)
	attack_hand(user)

/obj/machinery/bot/proc/speak(var/message, var/freqname = null) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if((!on) || (!message))
		return
	if(freqname)
		Radio.autosay(message, src.name, freqname, list(src.z))
	else
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span>",2)
	return

	//Generalized behavior code, override where needed!

/*
scan() will search for a given type (such as turfs, human mobs, or objects) in the bot's view range, and return a single result.
Arguments: The object type to be searched (such as "/mob/living/carbon/human"), the old scan result to be ignored, if one exists,
and the view range, which defaults to 7 (full screen) if an override is not passed.
If the bot maintains an ignore list, it is also checked here.

Example usage: patient = scan(/mob/living/carbon/human, oldpatient, 1)
The proc would return a human next to the bot to be set to the patient var.
Pass the desired type path itself, declaring a temporary var beforehand is not required.
*/
obj/machinery/bot/proc/scan(var/scan_type, var/old_target, var/scan_range)
	var/final_result
	for (var/scan in view (scan_range ? scan_range : DEFAULT_SCAN_RANGE, src) ) //Search for something in range!
		if(!istype(scan, scan_type)) //Check that the thing we found is the type we want!
			continue //If not, keep searching!
		if( !(scan in ignore_list) && !(scan in old_target) ) //Filter for blacklisted elements, usually unreachable or previously processed oness
			var/scan_result = process_scan(scan) //Some bots may require additional processing when a result is selected.
			if( scan_result )
				final_result = scan_result
			else
				continue //The current element failed assessment, move on to the next.
		else
			continue
		return final_result

//When the scan finds a target, run bot specific processing to select it for the next step. Empty by default.
obj/machinery/bot/proc/process_scan(var/scan_target)
	return scan_target


/obj/machinery/bot/proc/add_to_ignore(var/subject)
	if(ignore_list.len < 50) //This will help keep track of them, so the bot is always trying to reach a blocked spot.
		ignore_list |= subject
	else if (ignore_list.len >= subject) //If the list is full, insert newest, delete oldest.
		ignore_list -= ignore_list[1]
		ignore_list |= subject

/*
Movement proc for stepping a bot through a path generated through A-star.
Pass a positive integer as an argument to override a bot's default speed.
*/
obj/machinery/bot/proc/bot_move(var/dest, var/move_speed)
	if(!dest || !path || path.len == 0) //A-star failed or a path/destination was not set.
		path = list()
		return 0
	if(get_turf(src) == get_turf(dest)) //We have arrived, no need to move again.
		return 1
	var/success
	var/step_count = move_speed ? move_speed : speed //If a value is passed into move_speed, use that instead of the default speed var.
	if(step_count >= 1 && tries < 4)
		for(step_count, step_count >= 1,step_count--)
			success = bot_step(dest)
			if (success)
				tries = 0
			else
				tries++
				break
			sleep(4)
	else
		return 0
	return 1


obj/machinery/bot/proc/bot_step(var/dest)
	if(path && path.len > 1)
		step_towards(src, path[1])
		if(get_turf(src) == path[1]) //Successful move
			path -= path[1]
		else
			return 0
	else if(path.len == 1)
		step_towards(src, dest)
		path = list()
	return 1


/obj/machinery/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		botcard.access = prev_access

/obj/machinery/bot/proc/call_bot(var/caller, var/turf/waypoint)
	bot_reset() //Reset a bot before setting it to call mode.
	var/area/end_area = get_area(waypoint)

	//For giving the bot temporary all-access.
	var/obj/item/weapon/card/id/all_access = new /obj/item/weapon/card/id
	var/datum/job/captain/All = new/datum/job/captain
	all_access.access = All.get_access()

	path = get_path_to(src, waypoint, src, /turf/proc/Distance_cardinal, 0, 200, id=all_access)
	calling_ai = caller //Link the AI to the bot!
	ai_waypoint = waypoint

	if(path && path.len) //Ensures that a valid path is calculated!
		if(!on)
			turn_on() //Saves the AI the hassle of having to activate a bot manually.
		botcard = all_access //Give the bot all-access while under the AI's command.
		calling_ai << "<span class='notice'>\icon[src] [name] called to [end_area.name]. [path.len-1] meters to destination.</span>"
		pathset = 1
		mode = BOT_RESPONDING
		tries = 0
	else
		calling_ai << "<span class='danger'>Failed to calculate a valid route. Ensure destination is clear of obstructions and within range.</span>"
		calling_ai = null
		path = list()

/obj/machinery/bot/proc/call_mode() //Handles preparing a bot for a call, as well as calling the move proc.
//Handles the bot's movement during a call.
	var/success = bot_move(ai_waypoint, 3)
	if (!success)
		if(calling_ai)
			calling_ai << "\icon[src] [get_turf(src) == ai_waypoint ? "<span class='notice'>[src] successfully arrived to waypoint.</span>" : "<span class='danger'>[src] failed to reach waypoint.</span>"]"
			calling_ai = null
		bot_reset()

obj/machinery/bot/proc/bot_reset()
	if(calling_ai) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		calling_ai << "<span class='danger'>Call command to a bot has been reset.</span>"
		calling_ai = null
	path = list()
	summon_target = null
	pathset = 0
	botcard.access = prev_access
	tries = 0
	mode = BOT_IDLE





//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/obj/machinery/bot/proc/bot_patrol()
	patrol_step()
	spawn(5)
		if(mode == BOT_PATROL)
			patrol_step()
	return

obj/machinery/bot/proc/start_patrol()

	if(tries >= 4) //Bot is trapped, so stop trying to patrol.
		auto_patrol = 0
		tries = 0
		speak("Unable to start patrol.")

		return

	if(!auto_patrol) //A bot not set to patrol should not be patrolling.
		mode = BOT_IDLE
		return

	if(patrol_target)		// has patrol target
		spawn(0)
			calc_path()		// Find a route to it
			if(path.len == 0)
				patrol_target = 0
				return
			mode = BOT_PATROL
	else if(!awaiting_beacon) // no patrol target, so need a new one
		find_patrol_target()
		speak("Engaging patrol mode.")
		tries++
	return

// perform a single patrol step

/obj/machinery/bot/proc/patrol_step()

	if(loc == patrol_target)		// reached target

		at_patrol_target()
		return

	else if(path.len > 0 && patrol_target)		// valid path
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return


		var/moved = bot_move(patrol_target)//step_towards(src, next)	// attempt to move
		if(moved)	// successful move
			blockcount = 0

		else		// failed to move
			blockcount++

			if(blockcount > 5)	// attempt 5 times before recomputing
				// find new path excluding blocked turf

				spawn(2)
					calc_path(next)
					if(path.len == 0)
						find_patrol_target()
					else
						blockcount = 0
						tries = 0

				return

			return

	else	// no path, so calculate new one
		mode = BOT_START_PATROL

	return

// finds a new patrol target
/obj/machinery/bot/proc/find_patrol_target()
	send_status()
	if(awaiting_beacon)			// awaiting beacon response
		awaiting_beacon++
		if(awaiting_beacon > 40)	// wait 40 secs for beacon response
			find_nearest_beacon()	// then go to nearest instead
		return
	if(next_destination)
		set_destination(next_destination)
	else

		find_nearest_beacon()
	return


// finds the nearest beacon to self
// signals all beacons matching the patrol code
/obj/machinery/bot/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(200)
		awaiting_beacon = 0
		if(nearest_beacon)
			set_destination(nearest_beacon)
			tries = 0
		else
			auto_patrol = 0
			mode = BOT_IDLE
			speak("Disengaging patrol mode.")
			send_status()


/obj/machinery/bot/proc/at_patrol_target()

	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[// world.timeofday]\]: /obj/machinery/bot/receive_signal([signal.debug_print()])")
	if(!on)
		return
/*
	if(!signal.data["beacon"])

		for(var/x in signal.data)
			world << "* [x] = [signal.data[x]]"
	*/

	var/recv = signal.data["command"]
	// process all-bot input

	if(recv=="bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
		if(emagged == 2 || remote_disabled) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
			return
	// process control input
		switch(recv)
			if("stop")
				bot_reset() //HOLD IT!!
				auto_patrol = 0
				return

			if("go")
				auto_patrol = 1
				return

			if("summon")
				bot_reset()
				var/list/user_access = signal.data["useraccess"]
				summon_target = signal.data["target"]	//Location of the user
				if(user_access.len != 0)
					botcard.access = user_access + prev_access //Adds the user's access, if any.
				mode = BOT_SUMMON
				calc_summon_path()
				speak("Responding.", radio_name)
				return

	// receive response from beacon
	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return
	if(recv == new_destination)	// if the recvd beacon location matches the set destination
								// the we will navigate there
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0

	// if looking for nearest beacon
	else if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)
			// note we ignore the beacon we are located at
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				return
			else
				return
		else if(dist > 1)
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc
	return


// send a radio signal with a single data key/value pair
/obj/machinery/bot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/proc/post_signal_multiple(var/freq, var/list/keyval)
	if(!z || z != 1) //Bot control will only work on station.
		return
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)
	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
//	for(var/key in keyval)
//		signal.data[key] = keyval[key]
	signal.data = keyval
//	world << "sent [key],[keyval[key]] on [freq]"
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == bot_type)
		frequency.post_signal(src, signal, filter = bot_filter)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/proc/send_status()
	if(remote_disabled || emagged == 2)
		return
	var/list/kv = list(
	"type" = bot_type,
	"name" = name,
	"loca" = get_area(src),	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, kv)


obj/machinery/bot/proc/bot_summon()
		// summoned to PDA
	summon_step()
	return

// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/proc/calc_path(var/turf/avoid)
	check_bot_access()
	path = get_path_to(loc, patrol_target, src, /turf/proc/Distance_cardinal, 0, 120, id=botcard, exclude=avoid)
	if(!path)
		path = list()

/obj/machinery/bot/proc/calc_summon_path(var/turf/avoid)
	check_bot_access()
	path = get_path_to(loc, summon_target, src, /turf/proc/Distance_cardinal, 0, 150, id=botcard, exclude=avoid)
	if(!path || tries >= 5) //Cannot reach target. Give up and announce the issue.
		speak("Summon command failed, destination unreachable.", radio_name)
		bot_reset()

/obj/machinery/bot/proc/summon_step()

	if(loc == summon_target)		// Arrived to summon location.
		bot_reset()
		return

	else if(path.len > 0 && summon_target)		//Proper path acquired!
		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return

		var/moved = bot_move(summon_target, 3)	// Move attempt
		if(moved)
			blockcount = 0

		else		// failed to move
			blockcount++

			if(blockcount > 5)	// attempt 5 times before recomputing
				// find new path excluding blocked turf
				spawn(2)
					calc_summon_path(next)
					tries++
					return

				return

	else	// no path, so calculate new one
		calc_summon_path()

	return


/obj/machinery/bot/Bump(M as mob|obj) //Leave no door unopened!
	if((istype(M, /obj/machinery/door/airlock) || istype(M, /obj/machinery/door/window)) && (!isnull(botcard)))
		var/obj/machinery/door/D = M
		if(D.check_access(botcard))
			D.open()
			frustration = 0
	else if((istype(M, /mob/living/)) && (!anchored))
		var/mob/living/Mb = M
		loc = Mb.loc
		frustration = 0
	return
