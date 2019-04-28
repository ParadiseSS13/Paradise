/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_time = 0

	var/power_type

/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5


/datum/AI_Module/large/nuke_station
	module_name = "Doomsday Device"
	mod_pick_name = "nukestation"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay."
	cost = 130
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/nuke_station

/mob/living/silicon/ai/proc/nuke_station()
	set category = "Malfunction"
	set name = "Doomsday Device"

	to_chat(src, "<span class='notice'>Nuclear device armed.</span>")
	event_announcement.Announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", new_sound = 'sound/AI/aimalf.ogg')
	set_security_level("delta")
	nuking = 1
	var/obj/machinery/doomsday_device/DOOM = new /obj/machinery/doomsday_device(src)
	doomsday_device = DOOM
	doomsday_device.start()
	verbs -= /mob/living/silicon/ai/proc/nuke_station
	for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
		for(var/mob/living/silicon/ai/A in ai_list)
			if((A.stat != DEAD) && A.nuking)
				point.the_disk = A //The pinpointer now tracks the AI core

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	anchored = 1
	density = 1
	atom_say_verb = "blares"
	var/timing = 0
	var/default_timer = 4500
	var/detonation_timer
	var/announced = 0

/obj/machinery/doomsday_device/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.emergencyNoEscape = 0
	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		SSshuttle.emergency.mode = SHUTTLE_DOCKED
		SSshuttle.emergency.timer = world.time
		priority_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/shuttledock.ogg')
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + default_timer
	timing = 1
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.emergencyNoEscape = 1

/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round(detonation_timer - world.time) / 10))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		minor_announcement.Announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", 'sound/misc/notice1.ogg')
		SSshuttle.emergencyNoEscape = 0
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			SSshuttle.emergency.mode = SHUTTLE_DOCKED
			SSshuttle.emergency.timer = world.time
			priority_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/shuttledock.ogg')
		qdel(src)
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(sec_left <= 0)
		timing = 0
		detonate(T.z)
		qdel(src)
	else
		if(!(sec_left % 60) && !announced)
			var/message = "[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!"
			minor_announcement.Announce(message, "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", 'sound/misc/notice1.ogg')
			announced = 10
		announced = max(0, announced-1)

/obj/machinery/doomsday_device/proc/detonate(z_level = 1)
	for(var/mob/M in GLOB.player_list)
		M << 'sound/machines/alarm.ogg'
	sleep(100)
	for(var/mob/living/L in GLOB.mob_list)
		var/turf/T = get_turf(L)
		if(!T || T.z != z_level)
			continue
		if(issilicon(L))
			continue
		to_chat(L, "<span class='danger'><B>The blast wave from [src] tears you atom from atom!</B></span>")
		L.dust()
	to_chat(world, "<B>The AI cleansed the station of life with the doomsday device!</B>")
	ticker.force_ending = 1


/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/upgrade_turrets

/mob/living/silicon/ai/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"

	if(stat)
		return

	src.verbs -= /mob/living/silicon/ai/proc/upgrade_turrets
	for(var/obj/machinery/porta_turret/turret in GLOB.machines)
		var/turf/T = get_turf(turret)
		if(is_station_level(T.z))
			turret.health += 30
			turret.eprojectile = /obj/item/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
			turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'
	to_chat(src, "<span class='notice'>Turrets upgraded.</span>")


/datum/AI_Module/large/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/lockdown

/mob/living/silicon/ai/proc/lockdown()
	set category = "Malfunction"
	set name = "Initiate Hostile Lockdown"

	if(stat)
		return

	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, /obj/machinery/door.proc/hostile_lockdown, src)
		addtimer(CALLBACK(D, /obj/machinery/door.proc/disable_lockdown), 900)

	post_status("alert", "lockdown")

	verbs -= /mob/living/silicon/ai/proc/lockdown
	minor_announcement.Announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert")
	to_chat(src, "<span class='warning'>Lockdown Initiated. Network reset in 90 seconds.</span>")
	spawn(900)
		minor_announcement.Announce("Automatic system reboot complete. Have a secure day.","Network reset:")


/datum/AI_Module/large/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/disable_rcd

/mob/living/silicon/ai/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Destroy RCDs"
	set desc = "Detonate all RCDs on the station, while sparing onboard cyborg RCDs."

	if(stat || malf_cooldown > world.time)
		return

	for(var/obj/item/rcd/RCD in GLOB.rcd_list)
		if(!istype(RCD, /obj/item/rcd/borg)) //Ensures that cyborg RCDs are spared.
			RCD.detonate_pulse()

	to_chat(src, "<span class='danger'>RCD detonation pulse emitted.</span>")
	malf_cooldown = world.time + 100


/datum/AI_Module/large/mecha_domination
	module_name = "Viral Mech Domination"
	mod_pick_name = "mechjack"
	description = "Hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave. \
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/mech_takeover

/mob/living/silicon/ai/proc/mech_takeover()
	set name = "Compile Mecha Virus"
	set category = "Malfunction"
	set desc = "Target a mech by clicking it. Click the appropriate command when ready."

	if(stat)
		return

	can_dominate_mechs = 1 //Yep. This is all it does. Honk!
	to_chat(src, "Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b>")

	verbs -= /mob/living/silicon/ai/proc/mech_takeover


/datum/AI_Module/large/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert. \
	Anyone can check the fire alarm's interface and may be tipped off by its status."
	one_time = 1
	cost = 25

	power_type = /mob/living/silicon/ai/proc/break_fire_alarms

/mob/living/silicon/ai/proc/break_fire_alarms()
	set name = "Override Thermal Sensors"
	set category = "Malfunction"

	if(stat)
		return

	for(var/obj/machinery/firealarm/F in GLOB.machines)
		if(!is_station_level(F.z))
			continue
		F.emagged = 1
	to_chat(src, "<span class='notice'>All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized.</span>")
	verbs -= /mob/living/silicon/ai/proc/break_fire_alarms


/datum/AI_Module/large/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_time = 1
	cost = 50

	power_type = /mob/living/silicon/ai/proc/break_air_alarms

/mob/living/silicon/ai/proc/break_air_alarms()
	set name = "Disable Air Alarm Safeties"
	set category = "Malfunction"

	if(stat)
		return

	for(var/obj/machinery/alarm/AA in GLOB.machines)
		if(!is_station_level(AA.z))
			continue
		AA.emagged = 1
	to_chat(src, "<span class='notice'>All air alarm safeties on the station have been overriden. Air alarms may now use the Flood environmental mode.")
	verbs -= /mob/living/silicon/ai/proc/break_air_alarms


/datum/AI_Module/small/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	cost = 20

	power_type = /mob/living/silicon/ai/proc/overload_machine

/mob/living/silicon/ai/proc/overload_machine(obj/machinery/M in GLOB.machines)
	set name = "Overload Machine"
	set category = "Malfunction"

	if(stat)
		return

	if(istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/overload_machine/overload in current_modules)
			if(overload.uses > 0)
				overload.uses --
				audible_message("<span class='italics'>You hear a loud electrical buzzing sound!</span>")
				to_chat(src, "<span class='warning'>Overloading machine circuitry...</span>")
				spawn(50)
					if(M)
						explosion(get_turf(M), 0,1,1,0)
						qdel(M)
			else
				to_chat(src, "<span class='notice'>Out of uses.</span>")
	else
		to_chat(src, "<span class='notice'>That's not a machine.</span>")


/datum/AI_Module/small/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. 4 uses."
	uses = 4
	cost = 30

	power_type = /mob/living/silicon/ai/proc/override_machine


/mob/living/silicon/ai/proc/override_machine(obj/machinery/M in GLOB.machines)
	set name = "Override Machine"
	set category = "Malfunction"

	if(stat)
		return

	if (istype(M, /obj/machinery))
		if(!M.can_be_overridden())
			to_chat(src, "Can't override this device.")
		for(var/datum/AI_Module/small/override_machine/override in current_modules)
			if(override.uses > 0)
				override.uses --
				audible_message("<span class='italics'>You hear a loud electrical buzzing sound!</span>")
				to_chat(src, "<span class='warning'>Reprogramming machine behaviour...</span>")
				spawn(50)
					if(M && !QDELETED(M))
						new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, src, 1)
			else
				to_chat(src, "<span class='notice'>Out of uses.</span>")
	else
		to_chat(src, "<span class='notice'>That's not a machine.</span>")


/datum/AI_Module/large/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	power_type = /mob/living/silicon/ai/proc/place_transformer
	var/list/turfOverlays = list()

/datum/AI_Module/large/place_cyborg_transformer/New()
	for(var/i=0;i<3;i++)
		var/image/I = image("icon"='icons/turf/overlays.dmi')
		turfOverlays += I
	..()

/mob/living/silicon/ai/proc/place_transformer()
	set name = "Place Robotic Factory"
	set category = "Malfunction"

	if(!canPlaceTransformer())
		return

	var/sure = alert(src, "Are you sure you want to place the machine here?", "Are you sure?", "Yes", "No")
	if(sure == "Yes")
		if(!canPlaceTransformer())
			return
		var/turf/T = get_turf(eyeobj)
		new /obj/machinery/transformer/conveyor(T)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		var/datum/AI_Module/large/place_cyborg_transformer/PCT = locate() in current_modules
		PCT.uses --
		can_shunt = 0
		to_chat(src, "<span class='warning'>You cannot shunt anymore.</span>")

/mob/living/silicon/ai/proc/canPlaceTransformer()
	if(!eyeobj || !isturf(src.loc))
		return
	var/datum/AI_Module/large/place_cyborg_transformer/PCT = locate() in current_modules
	if(!PCT || PCT.uses < 1)
		alert(src, "Out of uses.")
		return
	var/turf/middle = get_turf(eyeobj)
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room. Make sure you are placing the machine in a clear area and on a floor."
	var/success = 1
	if(turfs.len == 3)
		for(var/n=1;n<4,n++)
			var/fail
			var/turf/T = turfs[n]
			if(!istype(T, /turf/simulated/floor))
				fail = 1
			var/datum/camerachunk/C = cameranet.getCameraChunk(T.x, T.y, T.z)
			if(!C.visibleTurfs[T])
				alert_msg = "We cannot get camera vision of this location."
				fail = 1
			for(var/atom/movable/AM in T.contents)
				if(AM.density)
					fail = 1
			var/image/I = PCT.turfOverlays[n]
			I.loc = T
			client.images += I
			if(fail)
				success = 0
				I.icon_state = "redOverlay"
			else
				I.icon_state = "greenOverlay"
			spawn(30)
				if(client && (I.loc == T))
					client.images -= I
	if(success)
		return 1
	alert(src, alert_msg)


/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
	uses = 3
	cost = 15

	power_type = /mob/living/silicon/ai/proc/blackout

/mob/living/silicon/ai/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"

	if(stat)
		return

	for(var/datum/AI_Module/small/blackout/blackout in current_modules)
		if(blackout.uses > 0)
			blackout.uses --
			for(var/obj/machinery/power/apc/apc in GLOB.apcs)
				if(prob(30*apc.overload))
					apc.overload_lighting()
				else
					apc.overload++
			to_chat(src, "<span class='notice'>Overcurrent applied to the powernet.</span>")
		else
			to_chat(src, "<span class='warning'>Out of uses.</span>")


/datum/AI_Module/small/reactivate_cameras
	module_name = "Reactivate Camera Network"
	mod_pick_name = "recam"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 30 cameras."
	uses = 30
	cost = 10
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/reactivate_cameras

/mob/living/silicon/ai/proc/reactivate_cameras()
	set name = "Reactivate Cameranet"
	set category = "Malfunction"

	if(stat || malf_cooldown > world.time)
		return
	var/fixedcams = 0 //Tells the AI how many cams it fixed. Stats are fun.

	for(var/datum/AI_Module/small/reactivate_cameras/camera in current_modules)
		for(var/obj/machinery/camera/C in cameranet.cameras)
			var/initial_range = initial(C.view_range) //To prevent calling the proc twice
			if(camera.uses > 0)
				if(!C.status)
					C.toggle_cam(src, 1) //Reactivates the camera based on status. Badly named proc.
					fixedcams++
					camera.uses--
				if(C.view_range != initial_range)
					C.view_range = initial_range //Fixes cameras with bad focus.
					camera.uses--
					fixedcams++
					//If a camera is both deactivated and has bad focus, it will cost two uses to fully fix!
			else
				to_chat(src, "<span class='warning'>Out of uses.</span>")
				verbs -= /mob/living/silicon/ai/proc/reactivate_cameras //It is useless now, clean it up.
				break
	to_chat(src, "<span class='notice'>Diagnostic complete! Operations completed: [fixedcams].</span>")

	malf_cooldown = world.time + 30


/datum/AI_Module/large/upgrade_cameras
	module_name = "Upgrade Camera Network"
	mod_pick_name = "upgradecam"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-Proofing and light-amplified X-ray vision." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	one_time = 1
	cost = 35 //Decent price for omniscience!

	power_type = /mob/living/silicon/ai/proc/upgrade_cameras

/mob/living/silicon/ai/proc/upgrade_cameras()
	set name = "Upgrade Cameranet"
	set category = "Malfunction"

	if(stat)
		return

	var/upgradedcams = 0
	see_override = SEE_INVISIBLE_MINIMUM //Night-vision, without which X-ray would be very limited in power.
	update_sight()

	for(var/obj/machinery/camera/C in cameranet.cameras)
		if(C.assembly)
			var/upgraded = 0

			if(!C.isXRay())
				C.upgradeXRay()
				//Update what it can see.
				cameranet.updateVisibility(C, 0)
				upgraded = 1

			if(!C.isEmpProof())
				C.upgradeEmpProof()
				upgraded = 1

			if(upgraded)
				upgradedcams++

	to_chat(src, "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: [upgradedcams]. Light amplification system online.</span>")
	verbs -= /mob/living/silicon/ai/proc/upgrade_cameras


/datum/AI_Module/large/eavesdrop
	module_name = "Enhanced Surveillance"
	mod_pick_name = "eavesdrop"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/surveillance

/mob/living/silicon/ai/proc/surveillance()
	set category = "Malfunction"
	set name = "Enhanced Surveillance"

	if(eyeobj)
		eyeobj.relay_speech = 1
	to_chat(src, "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.</span>")
	verbs -= /mob/living/silicon/ai/proc/surveillance


/datum/module_picker
	var/temp = null
	var/processing_time = 50
	var/list/possible_modules = list()

/datum/module_picker/New()
	for(var/type in subtypesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if(AM.power_type != null)
			src.possible_modules += AM

/datum/module_picker/proc/remove_verbs(var/mob/living/silicon/ai/A)

	for(var/datum/AI_Module/AM in possible_modules)
		A.verbs.Remove(AM.power_type)


/datum/module_picker/proc/use(user as mob)
	var/dat
	dat += {"<B>Select use of processing time: (currently #[src.processing_time] left.)</B><BR>
			<HR>
			<B>Install Module:</B><BR>
			<I>The number afterwards is the amount of processing time it consumes.</I><BR>"}
	for(var/datum/AI_Module/large/module in src.possible_modules)
		dat += "<A href='byond://?src=[UID()];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[UID()];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in src.possible_modules)
		dat += "<A href='byond://?src=[UID()];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[UID()];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	dat += "<HR>"
	if(src.temp)
		dat += "[src.temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat)
	popup.open()
	return

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, "You are already dead!") //Omae Wa Mou Shindeiru
		return

	for(var/datum/AI_Module/AM in possible_modules)
		if(href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > src.processing_time)
				temp = "You cannot afford this module."
				break

			// Add new uses if we can, and it is allowed.
			var/datum/AI_Module/already_AM = locate(AM.type) in A.current_modules
			if(already_AM)
				if(!AM.one_time)
					already_AM.uses += AM.uses
					src.processing_time -= AM.cost
					temp = "Additional use added to [already_AM.module_name]"
					break
				else
					temp = "This module is only needed once."
					break

			// Give the power and take away the money.
			A.view_core() //A BYOND bug requires you to be viewing your core before your verbs update
			A.verbs += AM.power_type
			A.current_modules += new AM.type
			temp = AM.description
			src.processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	use(usr)
