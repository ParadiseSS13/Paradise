// TO DO:
/*
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
rcd light flash thingy on matter drain



*/

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


/datum/AI_Module/large/fireproof_core
	module_name = "Core Upgrade"
	mod_pick_name = "coreup"
	description = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
	cost = 50
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/fireproof_core

/mob/living/silicon/ai/proc/fireproof_core()
	set category = "Malfunction"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in player_list)
		ai.fire_res_on_core = 1
	src.verbs -= /mob/living/silicon/ai/proc/fireproof_core
	to_chat(src, "<span class='notice'>Core fireproofed.</span>")

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the firing power and health of all AI turrets. This effect is permanent."
	cost = 50
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/upgrade_turrets

/mob/living/silicon/ai/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"

	if(stat)
		return

	src.verbs -= /mob/living/silicon/ai/proc/upgrade_turrets
	for(var/obj/machinery/porta_turret/turret in machines)
		var/turf/T = get_turf(turret)
		if(T.z in config.station_levels)
			// Increase health by 37.5% of original max, decrease delays between shots to 66%
			turret.health += initial(turret.health) * 3 / 8
			turret.eprojectile = /obj/item/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
			turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'
	to_chat(src, "<span class='notice'>Turrets upgraded.</span>")
/datum/AI_Module/large/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Cconstruction Devices on the station."
	cost = 25
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/disable_rcd

/mob/living/silicon/ai/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Destroy RCDs"
	set desc = "Detonate all RCDs on the station, while sparing onboard cyborg RCDs."

	if(stat || malf_cooldown)
		return

	for(var/obj/item/RCD in rcd_list)
		if(!istype(RCD, /obj/item/weapon/rcd/borg)) //Ensures that cyborg RCDs are spared.
			RCD.audible_message("<span class='danger'><b>[RCD] begins to vibrate and buzz loudly!</b></span>","<span class='danger'><b>[RCD] begins vibrating violently!</b></span>")
			spawn(50) //5 seconds to get rid of it!
				if(RCD) //Make sure it still exists (In case of chain-reaction)
					explosion(RCD, 0, 0, 3, 1, flame_range = 1)
					qdel(RCD)

	to_chat(src, "<span class='danger'>RCD detonation pulse emitted.</span>")
	malf_cooldown = 1
	spawn(100)
		malf_cooldown = 0

/datum/AI_Module/large/mecha_domination
	module_name = "Viral Mech Domination"
	mod_pick_name = "mechjack"
	description = "Hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
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
	to_chat(src, "Virus package compiled. Select a target mech at any time. \
	<b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b>")

	verbs -= /mob/living/silicon/ai/proc/mech_takeover

/datum/AI_Module/small/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	cost = 15

	power_type = /mob/living/silicon/ai/proc/overload_machine

/mob/living/silicon/ai/proc/overload_machine(obj/machinery/M as obj in world)
	set name = "Overload Machine"
	set category = "Malfunction"

	if(stat)
		return

	if(istype(M, /obj/machinery))
		if(istype(M,/obj/machinery/field/generator))
			to_chat(src, "This machine can not be overloaded due to a firewall.")
			return
		for(var/datum/AI_Module/small/overload_machine/overload in current_modules)
			if(overload.uses > 0)
				overload.uses --
				for(var/mob/V in hearers(M, null))
					V.show_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>", 2)
				spawn(50)
					explosion(get_turf(M), 0,1,1,0)
					qdel(M)
			else
				to_chat(src, "<span class='warning'>Out of uses.</span>")
	else
		to_chat(src, "<span class='notice'>That's not a machine.</span>")

/datum/AI_Module/small/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. 4 uses."
	uses = 4
	cost = 15

	power_type = /mob/living/silicon/ai/proc/override_machine

/mob/living/silicon/ai/proc/override_machine(obj/machinery/M as obj in world)
	set name = "Override Machine"
	set category = "Malfunction"

	if(stat)
		return

	if(istype(M, /obj/machinery))
		if(istype(M,/obj/machinery/field/generator))
			to_chat(src, "This machine can not be overloaded due to a firewall.")
			return
		for(var/datum/AI_Module/small/override_machine/override in current_modules)
			if(override.uses > 0)
				override.uses --
				for(var/mob/V in hearers(M, null))
					V.show_message("<span class='notice'>You hear a loud electrical buzzing sound!</span>", 2)
				to_chat(src, "<span class='warning'>Reprogramming machine behaviour...</span>")
				spawn(50)
					if(M)
						new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, src, 1)
			else
				to_chat(src, "<span class='warning'>Out of uses.</span>")
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
	return

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
			for(var/obj/machinery/power/apc/apc in world)
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

	if(stat || malf_cooldown)
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

	malf_cooldown = 1
	spawn(30) //Lag protection
		malf_cooldown = 0

/datum/AI_Module/small/upgrade_cameras
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

/datum/module_picker
	var/temp = null
	var/processing_time = 100
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
		dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=\ref[src];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in src.possible_modules)
		dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=\ref[src];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
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
			A.verbs += AM.power_type
			A.current_modules += new AM.type
			temp = AM.description
			src.processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description

	src.use(usr)
	return
