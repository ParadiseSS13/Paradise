#define AI_CHECK_WIRELESS 1
#define AI_CHECK_RADIO 2

var/list/ai_list = list()
var/list/ai_verbs_default = list(
	/mob/living/silicon/ai/proc/announcement,
	/mob/living/silicon/ai/proc/ai_call_shuttle,
	/mob/living/silicon/ai/proc/ai_camera_track,
	/mob/living/silicon/ai/proc/ai_camera_list,
	/mob/living/silicon/ai/proc/ai_goto_location,
	/mob/living/silicon/ai/proc/ai_remove_location,
	/mob/living/silicon/ai/proc/ai_hologram_change,
	/mob/living/silicon/ai/proc/ai_network_change,
	/mob/living/silicon/ai/proc/ai_roster,
	/mob/living/silicon/ai/proc/ai_statuschange,
	/mob/living/silicon/ai/proc/ai_store_location,
	/mob/living/silicon/ai/proc/checklaws,
	/mob/living/silicon/ai/proc/control_integrated_radio,
	/mob/living/silicon/ai/proc/core,
	/mob/living/silicon/ai/proc/pick_icon,
	/mob/living/silicon/ai/proc/sensor_mode,
	/mob/living/silicon/ai/proc/show_laws_verb,
	/mob/living/silicon/ai/proc/toggle_acceleration,
	/mob/living/silicon/ai/proc/toggle_camera_light,
	/mob/living/silicon/ai/proc/botcall,
	/mob/living/silicon/ai/proc/change_arrival_message
)

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use

/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	density = 1
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	var/list/network = list("SS13","Telecomms","Research Outpost","Mining Outpost")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/lawcheck[1]
	var/ioncheck[1]
	var/lawchannel = "Common" // Default channel on which to state laws
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/custom_sprite = 0 //For our custom sprites

	var/obj/item/device/radio/headset/heads/ai_integrated/aiRadio = null

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/processing_time = 100
	var/list/datum/AI_Module/current_modules = list()
	var/fire_res_on_core = 0

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click() -- TLE
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	var/malf_cooldown = 0 //Cooldown var for malf modules

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null

	var/apc_override = 0 //hack for letting the AI use its APC even when visionless
	var/camera_light_on = 0	//Defines if the AI toggled the light on the camera it's looking through.
	var/datum/trackable/track = null
	var/last_paper_seen = null
	var/can_shunt = 1
	var/last_announcement = ""
	var/obj/machinery/bot/Bot
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = 0 //Waypoint mode is for selecting a turf via clicking.

	var/obj/item/borg/sight/hud/sec/sechud = null
	var/obj/item/borg/sight/hud/med/healthhud = null

	var/arrivalmsg = "$name, $rank, has arrived on the station."

/mob/living/silicon/ai/proc/add_ai_verbs()
	src.verbs |= ai_verbs_default
	src.verbs |= silicon_subsystems
	
/mob/living/silicon/ai/proc/remove_ai_verbs()
	src.verbs -= ai_verbs_default
	src.verbs -= silicon_subsystems

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = 0)
	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A in mob_list)
			if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	aiPDA = new/obj/item/device/pda/ai(src)
	SetName(pickedName)
	anchored = 1
	canmove = 0
	density = 1
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	proc_holder_list = new()

	if(L)
		if (istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiMulti = new(src)
	aiRadio = new(src)
	common_radio = aiRadio
	aiRadio.myAi = src

	aiCamera = new/obj/item/device/camera/siliconcam/ai_camera(src)

	if (istype(loc, /turf))
		add_ai_verbs(src)

	//Languages
	add_language("Robot Talk", 1)
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Gutter", 0)
	add_language("Sinta'unathi", 0)
	add_language("Siik'tajr", 0)
	add_language("Canilunzt", 0)
	add_language("Skrellian", 0)
	add_language("Vox-pidgin", 0)
	add_language("Rootspeak", 0)
	add_language("Trinary", 1)
	add_language("Chittin", 0)
	add_language("Bubblish", 0)
	add_language("Clownish", 0)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if (!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			on_mob_init()

	spawn(5)
		new /obj/machinery/ai_powersupply(src)


	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[NATIONS_HUD]	  = image('icons/mob/hud.dmi', src, "hudblank")

	ai_list += src
	..()
	return

/mob/living/silicon/ai/proc/on_mob_init()
	src << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	src << "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>"
	src << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	src << "To use something, simply click on it."
	src << "Use say :b to speak to your cyborgs through binary. Use say :h to speak from an active holopad."
	src << "For department channels, use the following say commands:"

	var/radio_text = ""
	for(var/i = 1 to common_radio.channels.len)
		var/channel = common_radio.channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != common_radio.channels.len)
			radio_text += ", "

	src << radio_text

	if (!(ticker && ticker.mode && (mind in ticker.mode.malf_ai)))
		show_laws()
		src << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

	job = "AI"

/mob/living/silicon/ai/proc/SetName(pickedName as text)
	real_name = pickedName
	name = pickedName
	if(eyeobj)
		eyeobj.name = "[pickedName] (AI Eye)"

	// Set ai pda name
	if(aiPDA)
		aiPDA.ownjob = "AI"
		aiPDA.owner = pickedName
		aiPDA.name = pickedName + " (" + aiPDA.ownjob + ")"

/mob/living/silicon/ai/Destroy()
	ai_list -= src
	return ..()


/*
	The AI Power supply is a dummy object used for powering the AI since only machinery should be using power.
	The alternative was to rewrite a bunch of AI code instead here we are.
*/
/obj/machinery/ai_powersupply
	name="Power Supply"
	active_power_usage=1000
	use_power = 2
	power_channel = EQUIP
	var/mob/living/silicon/ai/powered_ai = null
	invisibility = 100

/obj/machinery/ai_powersupply/New(var/mob/living/silicon/ai/ai=null)
	powered_ai = ai
	if(isnull(powered_ai))
		qdel(src)
		return

	loc = powered_ai.loc
	use_power(1) // Just incase we need to wake up the power system.

	..()

/obj/machinery/ai_powersupply/process()
	if(!powered_ai || powered_ai.stat & DEAD)
		qdel(src)
		return
	if(!powered_ai.anchored)
		loc = powered_ai.loc
		use_power = 0
	if(powered_ai.anchored)
		use_power = 2

/mob/living/silicon/ai/proc/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return
	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = text2list(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = text2list(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2)
				continue;

			if(Entry[1] == src.ckey && Entry[2] == src.real_name)
				custom_sprite = 1 //They're in the list? Custom sprite time
				icon = 'icons/mob/custom-synthetic.dmi'

		//if(icon_state == initial(icon_state))
	var/icontype = ""
	if (custom_sprite == 1) icontype = ("Custom")//automagically selects custom sprite if one is available
	else icontype = input("Select an icon!", "AI", null, null) in list("Monochrome", "Blue", "Clown", "Inverted", "Text", "Smiley", "Angry", "Dorf", "Matrix", "Bliss", "Firewall", "Green", "Red", "Static", "Triumvirate", "Triumvirate Static", "Red October", "Sparkles", "ANIMA", "President")
	switch(icontype)
		if("Custom") icon_state = "[src.ckey]-ai"
		if("Clown") icon_state = "ai-clown2"
		if("Monochrome") icon_state = "ai-mono"
		if("Inverted") icon_state = "ai-u"
		if("Firewall") icon_state = "ai-magma"
		if("Green") icon_state = "ai-wierd"
		if("Red") icon_state = "ai-red"
		if("Static") icon_state = "ai-static"
		if("Text") icon_state = "ai-text"
		if("Smiley") icon_state = "ai-smiley"
		if("Matrix") icon_state = "ai-matrix"
		if("Angry") icon_state = "ai-angryface"
		if("Dorf") icon_state = "ai-dorf"
		if("Bliss") icon_state = "ai-bliss"
		if("Triumvirate") icon_state = "ai-triumvirate"
		if("Triumvirate Static") icon_state = "ai-triumvirate-malf"
		if("Red October") icon_state = "ai-redoctober"
		if("Sparkles") icon_state = "ai-sparkles"
		if("ANIMA") icon_state = "ai-anima"
		if("President") icon_state = "ai-president"
		else icon_state = "ai"
	//else
			//usr <<"You can only change your display once!"
			//return


// displays the malf_ai information if the AI is the malf
/mob/living/silicon/ai/show_malf_ai()
	if(ticker.mode.name == "AI malfunction")
		var/datum/game_mode/malfunction/malf = ticker.mode
		for (var/datum/mind/malfai in malf.malf_ai)
			if (mind == malfai) // are we the evil one?
				if (malf.apcs >= 3)
					stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")

// this verb lets the ai see the stations manifest
/mob/living/silicon/ai/proc/ai_roster()
	set name = "Show Crew Manifest"
	set category = "AI Commands"
	show_station_manifest()

/mob/living/silicon/ai/proc/ai_call_shuttle()
	set name = "Call Emergency Shuttle"
	set category = "AI Commands"

	if(src.stat == DEAD)
		src << "<span class='warning'>You can't call the shuttle because you are dead!</span>"
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/input = input(usr, "Please enter the reason for calling the shuttle.", "Shuttle Call Reason.","") as text|null
	if(!input || stat)
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	call_shuttle_proc(src, input)

	// hack to display shuttle timer
	if(emergency_shuttle.online())
		var/obj/machinery/computer/communications/C = locate() in machines
		if(C)
			C.post_status("shuttle")
	return

/mob/living/silicon/ai/proc/ai_cancel_call()
	set name = "Recall Emergency Shuttle"
	set category = "AI Commands"

	if(src.stat == 2)
		src << "You can't send the shuttle back because you are dead!"
		return

	if(check_unable(AI_CHECK_WIRELESS))
		return

	var/confirm = alert("Are you sure you want to recall the shuttle?", "Confirm Shuttle Recall", "Yes", "No")

	if(check_unable(AI_CHECK_WIRELESS))
		return

	if(confirm == "Yes")
		cancel_call_proc(src)

/mob/living/silicon/ai/cancel_camera()
	src.view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"

	if(!isturf(loc)) // if their location isn't a turf
		return // stop

	anchored = !anchored // Toggles the anchor

	src << "[anchored ? "<b>You are now anchored.</b>" : "<b>You are now unanchored.</b>"]"

/mob/living/silicon/ai/update_canmove()
	return 0

/mob/living/silicon/ai/proc/announcement()
	set name = "Announcement"
	set desc = "Create a vocal announcement by typing in the available words to create a sentence."
	set category = "AI Commands"

	if(src.stat == 2)
		src << "You can't call make an announcement because you are dead!"
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	ai_announcement()

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if (!current)
		return null
	user.reset_view(current)
	return 1

/mob/living/silicon/ai/blob_act()
	if (stat != 2)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/emp_act(severity)
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	return


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if (href_list["showalerts"])
		subsystem_alarm_monitor()
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if (href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				src << "<span class='notice'>Unable to locate the holopad.</span>"

	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes") lawcheck[L+1] = "No"
			if ("No") lawcheck[L+1] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["lawr"]) // Selects on which channel to state laws
		var/setchannel = input(usr, "Specify channel.", "Channel selection") in list("State","Common","Science","Command","Medical","Engineering","Security","Supply","Binary","Holopad", "Cancel")
		if(setchannel == "Cancel")
			return
		lawchannel = setchannel
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes") ioncheck[L] = "No"
			if ("No") ioncheck[L] = "Yes"
//		src << text ("Switching Law [L]'s report status to []", lawcheck[L+1])
		checklaws()

	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return

	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		if(target && trackable(target))
			ai_actual_track(target)
		else
			src << "<span class='warning'>Target is not on or near any active cameras on the station.</span>"
		return

	if (href_list["trackbot"])
		var/obj/machinery/bot/target = locate(href_list["trackbot"]) in aibots
		if(target && trackable(target))
			ai_actual_track(target)
		else
			src << "<span class='warning'>Target is not on or near any active cameras on the station.</span>"
		return

	if (href_list["callbot"]) //Command a bot to move to a selected location.
		Bot = locate(href_list["callbot"]) in aibots
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = 1
		src << "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>"
		return

	if (href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in aibots
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return
		Bot.attack_ai(src)

	if (href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			A << "Now tracking [target.name] on camera."
			if (usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40)
				continue

		return

	return

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2


/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)

		if ("help")
			visible_message("<span class='notice'>[M] caresses [src]'s plating with its scythe like arm.</span>")

		else //harm
			M.do_attack_animation(src)
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has slashed at [src]!</span>",\
								"<span class='userdanger'>[M] has slashed at [src]!</span>")
				if(prob(8))
					flick("noise", flash)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] took a swipe at [src]!</span>", \
								"<span class='userdanger'>[M] took a swipe at [src]!</span>")

	return

/mob/living/silicon/ai/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='danger'><B>[M]</B> [M.attacktext] [src]!")
		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/silicon/ai/reset_view(atom/A)
	if(current)
		current.set_light(0)
	if(istype(A,/obj/machinery/camera))
		current = A
	..()
	if(istype(A,/obj/machinery/camera))
		if(camera_light_on)	A.set_light(AI_CAMERA_LUMINOSITY)
		else				A.set_light(0)

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	if(stat == 2)
		src << "<span class='danger'>Critical error. System offline.</span>"
		return

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	var/ai_allowed_Zlevel = list(1,3,5)
	var/d
	var/area/bot_area
	d += "<A HREF=?src=\ref[src];botrefresh=\ref[Bot]>Query network status</A><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='20%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"

	for (Bot in aibots)
		if((Bot.z in ai_allowed_Zlevel) && !Bot.remote_disabled) //Only non-emagged bots on the allowed Z-level are detected!
			bot_area = get_area(Bot)
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!) </span>[Bot.name]" : Bot.name] ([Bot.bot_type_name])</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='20%'>[Bot.on ? "[Bot.mode ? "<span class='average'>[ Bot.mode_name[Bot.mode] ]</span>": "<span class='good'>Idle</span>"]" : "<span class='bad'>Inactive</span>"]</td>"
			d += "<td width='30%'>[bot_area.name]</td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];interface=\ref[Bot]>Interface</A></td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];callbot=\ref[Bot]>Call</A></td>"
			d += "<td width='10%'><a href='byond://?src=\ref[src];track2=\ref[src];trackbot=\ref[Bot]'>Track</A></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Remote Robot Control", 700, 400)
	popup.set_content(d)
	popup.open()

/mob/living/silicon/ai/proc/set_waypoint(var/atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(cameranet && cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		src << "<span class='danger'>Selected location is not visible.</span>"

/mob/living/silicon/ai/proc/call_bot(var/turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		src << "<span class='danger'>Interface error. Unit is already in use.</span>"
		return

	Bot.call_bot(src, waypoint)

/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)

	if (!C || stat == 2) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return 1

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	var/cameralist[0]

	if(check_unable())
		return

	if(usr.stat == 2)
		usr << "You can't change your camera network because you are dead!"
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = difflist(C.network,restricted_camera_networks,1)
		if(tempnetwork.len)
			for(var/i in tempnetwork)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(check_unable())
		return

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	src << "\blue Switched to [network] camera network."
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.stat == 2)
		usr <<"You cannot change your emotional status because you are dead!"
		return

	if(check_unable())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions

	if(check_unable())
		return

	for (var/obj/machinery/M in machines) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(check_unable())
		return

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				qdel(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"default",
		"floating face",
		"xeno queen"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			qdel(holo_icon)
			switch(input)
				if("default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("xeno queen")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		src << "\blue You are already in your Main Core."
		return
	apc.malfvacate()

//Toggles the luminosity and applies it by re-entereing the camera.
/mob/living/silicon/ai/proc/toggle_camera_light()
	set name = "Toggle Camera Lights"
	set desc = "Toggles the lights on the cameras throughout the station."
	set category = "AI Commands"

	if(stat != CONSCIOUS)
		return

	if(check_unable())
		return

	camera_light_on = !camera_light_on
	src << "Camera lights [camera_light_on ? "activated" : "deactivated"]."
	if(!camera_light_on)
		if(current)
			current.set_light(0)
			current = null
	else
		lightNearbyCamera()

/mob/living/silicon/ai/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "AI Commands"
	toggle_sensor_mode()

/mob/living/silicon/ai/proc/change_arrival_message()
	set name = "Set Arrival Message"
	set desc = "Change the message that's transmitted when a new crew member arrives on station."
	set category = "AI Commands"

	var/newmsg = input("What would you like the arrival message to be? Use $name to substitute the crew member's name, and use $rank to substitute the crew member's rank.", "Change Arrival Message", arrivalmsg) as text
	if(newmsg != arrivalmsg)
		arrivalmsg = newmsg
		usr << "The arrival message has been successfully changed."

// Handled camera lighting, when toggled.
// It will get the nearest camera from the eyeobj, lighting it.

/mob/living/silicon/ai/proc/lightNearbyCamera()
	if(camera_light_on && camera_light_on < world.timeofday)
		if(src.current)
			var/obj/machinery/camera/camera = near_range_camera(src.eyeobj)
			if(camera && src.current != camera)
				src.current.set_light(0)
				if(!camera.light_disabled)
					src.current = camera
					src.current.set_light(AI_CAMERA_LUMINOSITY)
				else
					src.current = null
			else if(isnull(camera))
				src.current.set_light(0)
				src.current = null
		else
			var/obj/machinery/camera/camera = near_range_camera(src.eyeobj)
			if(camera && !camera.light_disabled)
				src.current = camera
				src.current.set_light(AI_CAMERA_LUMINOSITY)
		camera_light_on = world.timeofday + 1 * 20 // Update the light every 2 seconds.


/mob/living/silicon/ai/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(anchored)
			user.visible_message("\blue \The [user] starts to unbolt \the [src] from the plating...")
			if(!do_after(user,40))
				user.visible_message("\blue \The [user] decides not to unbolt \the [src].")
				return
			user.visible_message("\blue \The [user] finishes unfastening \the [src]!")
			anchored = 0
			return
		else
			user.visible_message("\blue \The [user] starts to bolt \the [src] to the plating...")
			if(!do_after(user,40))
				user.visible_message("\blue \The [user] decides not to bolt \the [src].")
				return
			user.visible_message("\blue \The [user] finishes fastening down \the [src]!")
			anchored = 1
			return
	else
		return ..()


/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Radio Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(check_unable(AI_CHECK_RADIO))
		return

	src << "Accessing Subspace Transceiver control..."
	if (src.aiRadio)
		src.aiRadio.interact(src)


/mob/living/silicon/ai/proc/open_nearest_door(mob/living/target as mob)
	if(!istype(target)) return
	spawn(0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(id) && id.is_untrackable())
				src << "Unable to locate an airlock"
				return
			if(H.digitalcamo)
				src << "Unable to locate an airlock"
				return
		if (!near_camera(target))
			src << "Target is not near any active cameras."
			return
		var/obj/machinery/door/airlock/tobeopened
		var/dist = -1
		for(var/obj/machinery/door/airlock/D in range(3,target))
			if(!D.density) continue
			if(dist < 0)
				dist = get_dist(D, target)
				//world << dist
				tobeopened = D
			else
				if(dist > get_dist(D, target))
					dist = get_dist(D, target)
					//world << dist
					tobeopened = D
					//world << "found [tobeopened.name] closer"
				else
					//world << "[D.name] not close enough | [get_dist(D, target)] | [dist]"
		if(tobeopened)
			switch(alert(src, "Do you want to open \the [tobeopened] for [target]?","Doorknob_v2a.exe","Yes","No"))
				if("Yes")
					var/nhref = "src=\ref[tobeopened];aiEnable=7"
					tobeopened.Topic(nhref, params2list(nhref), tobeopened, 1)
					src << "\blue You've opened \the [tobeopened] for [target]."
				if("No")
					src << "\red You deny the request."
		else
			src << "\red You've failed to open an airlock for [target]"
		return


/mob/living/silicon/ai/proc/check_unable(var/flags = 0)
	if(stat == DEAD)
		usr << "\red You are dead!"
		return 1

	if((flags & AI_CHECK_WIRELESS) && src.control_disabled)
		usr << "\red Wireless control is disabled!"
		return 1
	if((flags & AI_CHECK_RADIO) && src.aiRadio.disabledAi)
		src << "\red System Error - Transceiver Disabled!"
		return 1
	return 0

/mob/living/silicon/ai/proc/is_in_chassis()
	return istype(loc, /turf)

#undef AI_CHECK_WIRELESS
#undef AI_CHECK_RADIO

