#define MALF_AI_ROLL_TIME 0.5 SECONDS
#define MALF_AI_ROLL_COOLDOWN (1 SECONDS + MALF_AI_ROLL_TIME)
#define MALF_AI_ROLL_DAMAGE 75
// crit percent
#define MALF_AI_ROLL_CRIT_CHANCE 5

//The malf AI spell subtype. All malf actions are subtypes of this.
/datum/spell/ai_spell
	name = "AI Spell"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	action_background_icon_state = "bg_tech_blue"
	clothes_req = FALSE
	base_cooldown = 0
	var/uses //If we have multiple uses of the same power
	var/auto_use_uses = TRUE //If we automatically use up uses on each activation
	antimagic_flags = NONE
	/// Is this spell an AI program?
	var/datum/ai_program/program

/datum/spell/ai_spell/New()
	. = ..()
	if(program)
		desc += " Costs [program.nanite_cost] Nanites to use."

/datum/spell/ai_spell/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/ai_spell/can_cast(mob/living/silicon/ai/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!istype(user))
		stack_trace("A non ai ([user]) tried to cast an AI spell.")
		user.RemoveSpell(src)
		return FALSE

/datum/spell/ai_spell/after_cast(list/targets, mob/user)
	. = ..()
	if(auto_use_uses)
		adjust_uses(-1, user)

/datum/spell/ai_spell/proc/find_nearest_camera(atom/target)
	var/area/A = get_area(target)
	if(!istype(A))
		return
	var/closest_camera = null
	for(var/obj/machinery/camera/C in A)
		if(isnull(closest_camera))
			closest_camera = C
			continue
		if(get_dist(closest_camera, target) > get_dist(C, target))
			closest_camera = C
			continue
	return closest_camera

/datum/spell/ai_spell/proc/desc_update()
	desc = initial(desc)
	if(program)
		desc += " Costs [program.nanite_cost] Nanites to use."
	action.desc = desc

/datum/spell/ai_spell/proc/camera_beam(target, icon_state, icon, time)
	var/obj/machinery/camera/C = find_nearest_camera(target)
	if(!istype(C))
		return
	C.Beam(target, icon_state = icon_state, icon = icon, time = time)

/datum/spell/ai_spell/proc/adjust_uses(amt, mob/living/silicon/ai/owner, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, "<span class='notice'>[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining.</span>")
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, "<span class='warning'>[name] has run out of uses!</span>")
		owner.RemoveSpell(src)
	if(QDELETED(src) || uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		return
	desc = "[initial(desc)] It has [uses] use\s remaining."
	build_all_button_icons()

/datum/spell/ai_spell/proc/check_camera_vision(mob/user, atom/target)
	var/turf/target_turf = get_turf(target)
	var/datum/camerachunk/C = GLOB.cameranet.get_camera_chunk(target_turf.x, target_turf.y, target_turf.z)
	if(!C.visible_turfs[target_turf])
		to_chat(user, "<span class='warning'>You don't have camera vision of this location!</span>")
		return FALSE
	return TRUE

//Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/spell/ai_spell/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	selection_activated_message		= "<span class='notice'>Hello World!</span>"
	selection_deactivated_message	= "<span class='danger'>Goodbye Cruel World!</span>"

/datum/spell/ai_spell/ranged/adjust_uses(amt, mob/living/silicon/ai/owner, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, "<span class='notice'>[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining.</span>")
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, "<span class='warning'>[name] has run out of uses!</span>")
		owner.mob_spell_list -= src
		QDEL_IN(src, 10 SECONDS) //let any active timers on us finish up

/datum/spell/ai_spell/ranged/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/external/C = new()
	C.range = INFINITY
	return C

/datum/spell/ai_spell/choose_modules
	name = "Choose Modules"
	desc = "Spend your processing time to gain a variety of different abilities."
	action_icon_state = "choose_module"
	auto_use_uses = FALSE // This is an infinite ability.
	create_attack_logs = FALSE

/datum/spell/ai_spell/choose_modules/cast(list/targets, mob/living/silicon/ai/user)
	. = ..()
	user.malf_picker.use(user)

/datum/spell/ai_spell/return_to_core
	name = "Return to Main Core"
	desc = "Leave the APC you are shunted to, and return to your core."
	action_icon = 'icons/obj/power.dmi'
	action_icon_state = "apcemag"
	auto_use_uses = FALSE // Here just to prevent the "You have X uses remaining" from popping up.

/datum/spell/ai_spell/return_to_core/cast(list/targets, mob/living/silicon/ai/user)
	. = ..()
	var/obj/machinery/power/apc/apc = user.loc
	if(!istype(apc)) // This shouldn't happen but here for safety.
		to_chat(user, "<span class='notice'>You are already in your Main Core.</span>")
		return
	apc.malfvacate()
	qdel(src)

//The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/temp
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = list()
	for(var/type in subtypesof(/datum/ai_module))
		var/datum/ai_module/AM = new type
		if(AM.power_type || AM.upgrade)
			possible_modules += AM

/datum/module_picker/proc/use(mob/user)
	var/dat
	dat += {"<B>Select use of processing time: (currently [processing_time] left.)</B><BR>
			<HR>
			<B>Install Module:</B><BR>
			<I>The number afterwards is the amount of processing time it consumes.</I><BR>"}
	for(var/datum/ai_module/module in possible_modules)
		dat += "<A href='byond://?src=[UID()];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[UID()];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	dat += "<HR>"
	if(temp)
		dat += "[temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/datum/module_picker/Topic(href, href_list)
	..()

	if(!is_ai(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, "<span class='warning'>You are already dead!</span>")
		return

	for(var/datum/ai_module/AM in possible_modules)
		if(href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > processing_time)
				temp = "You cannot afford this module."
				break

			var/datum/spell/ai_spell/action = locate(AM.power_type) in A.mob_spell_list

			// Give the power and take away the money.
			if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
				AM.upgrade(A)
				possible_modules -= AM
				to_chat(A, AM.unlock_text)
				A.playsound_local(A, AM.unlock_sound, 50, FALSE, use_reverb = FALSE)
			else
				if(AM.power_type)
					if(!action) //Unlocking for the first time
						var/datum/spell/ai_spell/AC = new AM.power_type
						A.AddSpell(AC)
						A.current_modules += new AM.type
						temp = AM.description
						if(AM.one_purchase)
							possible_modules -= AM
						if(AM.unlock_text)
							to_chat(A, AM.unlock_text)
						if(AM.unlock_sound)
							A.playsound_local(A, AM.unlock_sound, 50, FALSE, use_reverb = FALSE)
					else //Adding uses to an existing module
						action.uses += initial(action.uses)
						action.desc = "[initial(action.desc)] It has [action.uses] use\s remaining."
						action.build_all_button_icons()
						temp = "Additional use[action.uses > 1 ? "s" : ""] added to [action.name]!"
			processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	use(usr)

//The base module type, which holds info about each ability.
/datum/ai_module
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/cost = 5
	var/one_purchase = FALSE //If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.
	var/power_type = /datum/spell/ai_spell //If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/upgrade //If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/unlock_text = "<span class='notice'>Hello World!</span>" //Text shown when an ability is unlocked
	var/unlock_sound //Sound played when an ability is unlocked
	var/uses = 0

/datum/ai_module/proc/upgrade(mob/living/silicon/ai/AI) //Apply upgrades!
	return

//Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/ai_module/nuke_station
	module_name = "Doomsday Device"
	mod_pick_name = "nukestation"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/spell/ai_spell/nuke_station
	unlock_text = "<span class='notice'>You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.</span>"
	unlock_sound = 'sound/items/timer.ogg'

/datum/spell/ai_spell/nuke_station
	name = "Doomsday Device"
	desc = "Activates the doomsday device. This is not reversible."
	action_icon_state = "doomsday_device"
	auto_use_uses = FALSE
	var/in_use

/datum/spell/ai_spell/nuke_station/cast(list/targets, mob/living/silicon/ai/user)
	var/turf/T = get_turf(user)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(user, "<span class='warning'>You cannot activate the doomsday device while off-station!</span>")
		return
	if(tgui_alert(user, "Send arming signal? (true = arm, false = cancel)", "purge_all_life()", list("confirm = TRUE;", "confirm = FALSE;")) != "confirm = TRUE;")
		return
	if(!istype(user) || QDELETED(user))
		return
	if(in_use)
		return //prevent the AI from activating an already active doomsday
	in_use = TRUE
	set_us_up_the_bomb(user)

/datum/spell/ai_spell/nuke_station/proc/set_us_up_the_bomb(mob/living/silicon/ai/user)
	to_chat(user, "<span class='notice'>Nuclear device armed.</span>")
	GLOB.major_announcement.Announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", 'sound/AI/aimalf.ogg')
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	user.nuking = TRUE
	var/obj/machinery/doomsday_device/DOOM = new /obj/machinery/doomsday_device(user)
	user.doomsday_device = DOOM
	user.doomsday_device.start()
	for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
		for(var/mob/living/silicon/ai/A in GLOB.ai_list)
			if((A.stat != DEAD) && A.nuking)
				point.the_disk = A //The pinpointer now tracks the AI core
	qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	anchored = TRUE
	density = TRUE
	atom_say_verb = "blares"
	speed_process = TRUE // Disgusting fix. Please remove once #12952 is merged
	var/timing = FALSE
	var/default_timer = 4500
	var/detonation_timer
	var/announced = 0

/obj/machinery/doomsday_device/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.clearHostileEnvironment(src)
	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		SSshuttle.emergency.mode = SHUTTLE_DOCKED
		SSshuttle.emergency.timer = world.time
		GLOB.major_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/eshuttle_dock.ogg')
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + default_timer
	timing = TRUE
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.registerHostileEnvironment(src)

/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round(detonation_timer - world.time) / 10))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		GLOB.major_announcement.Announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", 'sound/misc/notice1.ogg')
		SSshuttle.clearHostileEnvironment(src)
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			SSshuttle.emergency.mode = SHUTTLE_DOCKED
			SSshuttle.emergency.timer = world.time
			GLOB.major_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/eshuttle_dock.ogg')
		qdel(src)
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(sec_left <= 0)
		timing = FALSE
		detonate(T.z)
		qdel(src)
	else
		if(!(sec_left % 60) && !announced)
			var/message = "[sec_left] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!"
			GLOB.major_announcement.Announce(message, "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", 'sound/misc/notice1.ogg')
			announced = 10
		announced = max(0, announced-1)

/obj/machinery/doomsday_device/proc/detonate(z_level = 1)
	var/doomsday_alarm = sound('sound/machines/alarm.ogg')
	for(var/explodee in GLOB.player_list)
		SEND_SOUND(explodee, doomsday_alarm)
	sleep(100)
	SSticker.station_explosion_cinematic(NUKE_SITE_ON_STATION, "AI malfunction")
	to_chat(world, "<B>The AI cleansed the station of life with the doomsday device!</B>")
	SSticker.mode.station_was_nuked = TRUE

//AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/ai_module/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>You establish a power diversion to your turrets, upgrading their health and damage.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade_turrets/upgrade(mob/living/silicon/ai/AI)
	for(var/obj/machinery/porta_turret/ai_turret/turret in SSmachines.get_by_type(/obj/machinery/porta_turret/ai_turret))
		var/turf/T = get_turf(turret)
		if(is_station_level(T.z))
			turret.health += 30
			turret.eprojectile = /obj/item/projectile/beam/laser/ai_turret/heavylaser //Once you see it, you will know what it means to FEAR.
			turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'
	AI.turrets_upgraded = TRUE

//Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/ai_module/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
	opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/spell/ai_spell/lockdown
	unlock_text = "<span class='notice'>You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.</span>"

/datum/spell/ai_spell/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and depowers every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	action_icon_state = "lockdown"
	uses = 1

/datum/spell/ai_spell/lockdown/cast(list/targets, mob/user)
	to_chat(user, "<span class='warning'>Lockdown Initiated. Network reset in 90 seconds.</span>")
	new /datum/event/door_runtime()

//Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/ai_module/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = TRUE
	power_type = /datum/spell/ai_spell/destroy_rcds
	unlock_text = "<span class='notice'>After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.</span>"

/datum/spell/ai_spell/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	action_icon_state = "detonate_rcds"
	uses = 1
	base_cooldown = 10 SECONDS

/datum/spell/ai_spell/destroy_rcds/cast(list/targets, mob/user)
	for(var/obj/item/rcd/RCD in GLOB.rcd_list)
		if(istype(RCD, /obj/item/rcd/borg)) //Ensures that cyborg RCDs are spared.
			continue
		var/turf/RCD_turf = get_turf(RCD)
		if(is_level_reachable(RCD_turf.z))
			RCD.detonate_pulse()

	to_chat(user, "<span class='danger'>RCD detonation pulse emitted.</span>")
	user.playsound_local(user, 'sound/machines/twobeep.ogg', 50, FALSE, use_reverb = FALSE)

//Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/ai_module/mecha_domination
	module_name = "Unlock Mech Domination"
	mod_pick_name = "mechjack"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b></span>"
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/ai_module/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!

//Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/ai_module/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert. \
	Anyone can check the fire alarm's interface and may be tipped off by its status."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/spell/ai_spell/break_fire_alarms
	unlock_text = "<span class='notice'>You replace the thermal sensing capabilities of all fire alarms with a manual override, allowing you to turn them off at will.</span>"

/datum/spell/ai_spell/break_fire_alarms
	name = "Override Thermal Sensors"
	desc = "Disables the automatic temperature sensing on all fire alarms, making them effectively useless."
	action_icon_state = "break_fire_alarms"
	uses = 1

/datum/spell/ai_spell/break_fire_alarms/cast(list/targets, mob/user)
	for(var/obj/machinery/firealarm/F in SSmachines.get_by_type(/obj/machinery/firealarm))
		if(!is_station_level(F.z))
			continue
		F.emagged = TRUE
	to_chat(user, "<span class='notice'>All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized.</span>")
	user.playsound_local(user, 'sound/machines/terminal_off.ogg', 50, FALSE, use_reverb = FALSE)

//Air Alarm Safety Override: Unlocks the ability to enable flooding on all air alarms.
/datum/ai_module/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/spell/ai_spell/break_air_alarms
	unlock_text = "<span class='notice'>You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.</span>"

/datum/spell/ai_spell/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables the Flood setting on all air alarms."
	action_icon_state = "break_air_alarms"
	uses = 1

/datum/spell/ai_spell/break_air_alarms/cast(list/targets, mob/user)
	for(var/obj/machinery/alarm/AA in SSmachines.get_by_type(/obj/machinery/alarm))
		if(!is_station_level(AA.z))
			continue
		AA.emagged = TRUE
	to_chat(user, "<span class='notice'>All air alarm safeties on the station have been overridden. Air alarms may now use the Flood environmental mode.")
	user.playsound_local(user, 'sound/machines/terminal_off.ogg', 50, FALSE, use_reverb = FALSE)

//Overload Machine: Allows the AI to overload a machine, detonating it after a delay. Two uses per purchase.
/datum/ai_module/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overheats an electrical machine, causing a moderately-sized explosion and destroying it. Four uses per purchase."
	cost = 20
	power_type = /datum/spell/ai_spell/ranged/overload_machine
	unlock_text = "<span class='notice'>You enable the ability for the station's APCs to direct intense energy into machinery.</span>"

/datum/spell/ai_spell/ranged/overload_machine
	name = "Overload Machine"
	desc = "Overheats a machine, causing a moderately-sized explosion after a short time."
	action_icon_state = "overload_machine"
	uses = 4
	ranged_mousepointer = 'icons/mouse_icons/cult_target.dmi'
	selection_activated_message = "<span class='notice'>You tap into the station's powernet. Click on a machine to detonate it, or use the ability again to cancel.</span>"
	selection_deactivated_message = "<span class='notice'>You release your hold on the powernet.</span>"

/datum/spell/ai_spell/ranged/overload_machine/cast(list/targets, mob/user)
	var/obj/machinery/target = targets[1]
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only overload machines!</span>")
		return
	if(target.flags_2 & NO_MALF_EFFECT_2)
		to_chat(user, "<span class='warning'>That machine can't be overloaded!</span>")
		return

	user.playsound_local(user, "sparks", 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1, user)
	target.audible_message("<span class='danger'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	playsound(target, 'sound/goonstation/misc/fuse.ogg', 50, FALSE, use_reverb = FALSE)
	addtimer(CALLBACK(src, PROC_REF(detonate_machine), target), 5 SECONDS) //kaboom!
	to_chat(user, "<span class='warning'>Overloading machine circuitry...</span>")
	return TRUE

/datum/spell/ai_spell/ranged/overload_machine/proc/detonate_machine(obj/machinery/M)
	if(M && !QDELETED(M))
		explosion(get_turf(M), 0, 2, 3, 0, cause = "Malf AI: [name]")
		if(M) //to check if the explosion killed it before we try to delete it
			qdel(M)

//Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/ai_module/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses."
	cost = 30
	power_type = /datum/spell/ai_spell/ranged/override_machine
	unlock_text = "<span class='notice'>You procure a virus from the Space Dark Web and distribute it to the station's machines.</span>"

/datum/spell/ai_spell/ranged/override_machine
	name = "Override Machine"
	desc = "Animates a targeted machine, causing it to attack anyone nearby."
	action_icon_state = "override_machine"
	uses = 4
	ranged_mousepointer = 'icons/mouse_icons/override_machine_target.dmi'
	selection_activated_message = "<span class='notice'>You tap into the station's powernet. Click on a machine to animate it, or use the ability again to cancel.</span>"
	selection_deactivated_message = "<span class='notice'>You release your hold on the powernet.</span>"

/datum/spell/ai_spell/ranged/override_machine/cast(list/targets, mob/user)
	var/obj/machinery/target = targets[1]
	if(!istype(target))
		to_chat(user, "<span class='warning'>You can only animate machines!</span>")
		return
	if(target.flags_2 & NO_MALF_EFFECT_2)
		to_chat(user, "<span class='warning'>That machine can't be overridden!</span>")
		return

	user.playsound_local(user, 'sound/misc/interference.ogg', 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1, user)
	target.audible_message("<span class='userdanger'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	addtimer(CALLBACK(src, PROC_REF(animate_machine), target, user), 5 SECONDS) //kabeep!
	to_chat(user, "<span class='danger'>Sending override signal...</span>")
	return TRUE

/datum/spell/ai_spell/ranged/override_machine/proc/animate_machine(obj/machinery/M, mob/user)
	if(M && !QDELETED(M))
		new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, user, 1)

//Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/ai_module/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	one_purchase = TRUE
	power_type = /datum/spell/ai_spell/place_transformer
	unlock_text = "<span class='notice'>You prepare a robotics factory for deployment.</span>"
	unlock_sound = 'sound/machines/ping.ogg'

/datum/spell/ai_spell/place_transformer
	name = "Place Robotics Factory"
	desc = "Places a machine that converts humans into cyborgs. Conveyor belts included!"
	action_icon_state = "robotic_factory"
	uses = 1
	auto_use_uses = FALSE //So we can attempt multiple times
	var/list/turfOverlays
	var/in_use = FALSE

/datum/spell/ai_spell/place_transformer/New()
	..()
	for(var/i in 1 to 3)
		var/image/I = image("icon"='icons/turf/overlays.dmi')
		LAZYADD(turfOverlays, I)

/datum/spell/ai_spell/place_transformer/cast(list/targets, mob/living/silicon/ai/user)
	if(!user.can_place_transformer(src))
		return
	in_use = TRUE
	if(tgui_alert(user, "Are you sure you want to place the machine here?", "Are you sure?", list("Yes", "No")) != "Yes")
		active = FALSE
		return
	if(!user.can_place_transformer(src))
		active = FALSE
		return
	var/turf/T = get_turf(user.eyeobj)
	new /obj/machinery/transformer(T, user)
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	user.can_shunt = FALSE
	to_chat(user, "<span class='warning'>You are no longer able to shunt your core to APCs.</span>")
	adjust_uses(-1, user)

/mob/living/silicon/ai/proc/remove_transformer_image(client/C, image/I, turf/T)
	if(C && I.loc == T)
		C.images -= I

/mob/living/silicon/ai/proc/can_place_transformer(datum/spell/ai_spell/place_transformer/action)
	if(!eyeobj || !isturf(loc) || incapacitated() || !action)
		return
	var/turf/middle = get_turf(eyeobj)
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room! Make sure you are placing the machine in a clear area and on a floor."
	var/success = TRUE
	for(var/n in 1 to 3) //We have to do this instead of iterating normally because of how overlay images are handled
		var/turf/T = turfs[n]
		if(!isfloorturf(T))
			success = FALSE
		var/datum/camerachunk/C = GLOB.cameranet.get_camera_chunk(T.x, T.y, T.z)
		if(!C.visible_turfs[T])
			alert_msg = "You don't have camera vision of this location!"
			success = FALSE
		for(var/atom/movable/AM in T.contents)
			if(AM.density)
				alert_msg = "That area must be clear of objects!"
				success = FALSE
		var/image/I = action.turfOverlays[n]
		I.loc = T
		client.images += I
		I.icon_state = "[success ? "green" : "red"]Overlay" //greenOverlay and redOverlay for success and failure respectively
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, T), 30)
	if(!success)
		to_chat(src, "<span class='warning'>[alert_msg]</span>")
	return success

//Turret Assembly: Assemble an AI turret at the chosen location. One use per purchase
/datum/ai_module/place_turret
	module_name = "Deploy Turret"
	mod_pick_name = "turretdeployer"
	description = "Build a turret anywhere that lethally targets organic life in sight."
	cost = 30
	power_type = /datum/spell/ai_spell/place_turret
	unlock_text = "<span class='notice'>You prepare an energy turret for deployment.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/spell/ai_spell/place_turret
	name = "Deploy Turret"
	desc = "Build a turret anywhere that lethally targets organic life in sight."
	action_icon_state = "deploy_turret"
	uses = 1
	auto_use_uses = FALSE
	var/image/turf_overlay
	var/in_use = FALSE

/datum/spell/ai_spell/place_turret/New()
	..()
	turf_overlay = image('icons/turf/overlays.dmi')

/datum/spell/ai_spell/place_turret/cast(list/targets, mob/living/silicon/ai/user)
	if(in_use)
		to_chat(user, "<span class='notice'>Your assemblers can only construct one turret at a time.</span>")
		return
	if(!user.can_place_turret(src))
		return
	in_use = TRUE
	if(tgui_alert(user, "Are you sure you want to place a turret here? Deployment will take a few seconds to complete, in which the turret will be vulnerable.", "Are you sure?", list("No", "Yes")) != "Yes")
		in_use = FALSE
		return
	if(!user.can_place_turret(src))
		in_use = FALSE
		return
	deploy_turret(user)
	in_use = FALSE

/datum/spell/ai_spell/place_turret/proc/deploy_turret(mob/living/silicon/ai/user)
	var/turf/T = get_turf(user.eyeobj)

	//Handles the turret construction and configuration
	playsound(T, 'sound/items/rped.ogg', 100, TRUE) //Plays a sound both at the location of the construction to alert players and to the user as feedback
	user.playsound_local(user, 'sound/items/rped.ogg', 50, FALSE, use_reverb = FALSE)
	to_chat(user, "<span class='notice'>You order your electronics to assemble a turret. This will take a few seconds.</span>")
	var/obj/effect/temp_visual/rcd_effect/spawning_effect = new(T)
	QDEL_IN(spawning_effect, 5 SECONDS)

	//Deploys as lethal. Nonlethals can be enabled.
	var/obj/machinery/porta_turret/turret = new /obj/machinery/porta_turret/ai_turret(T)
	turret.disabled = TRUE
	turret.lethal = TRUE
	turret.raised = TRUE //While raised, it is vulnerable to damage
	turret.targetting_is_configurable = FALSE
	turret.check_synth = TRUE
	turret.invisibility = 100

	//If turrets are already upgraded, beef it up
	if(user.turrets_upgraded)
		turret.health += 30
		turret.eprojectile = /obj/item/projectile/beam/laser/ai_turret/heavylaser //Big gun
		turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'

	if(do_after_once(user, 5 SECONDS, target = T, allow_moving = TRUE)) //Once this is done, turret is armed and dangerous
		turret.raised = initial(turret.raised)
		turret.invisibility = initial(turret.invisibility)
		turret.disabled = initial(turret.disabled)
		new /obj/effect/temp_visual/rcd_effect/end(T)
		playsound(T, 'sound/items/deconstruct.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Turret deployed.</span>")
		adjust_uses(-1, user)

/mob/living/silicon/ai/proc/can_place_turret(datum/spell/ai_spell/place_turret/action)
	if(!eyeobj || !isturf(eyeobj.loc) || incapacitated() || !action)
		return

	var/turf/simulated/floor/deploylocation = get_turf(eyeobj)

	var/image/I = action.turf_overlay
	I.loc = deploylocation
	client.images += I
	I.icon_state = "redOverlay"
	var/datum/camerachunk/C = GLOB.cameranet.get_camera_chunk(deploylocation.x, deploylocation.y, deploylocation.z)

	if(!istype(deploylocation))
		to_chat(src, "<span class='warning'>There isn't enough room! Make sure you are placing the machine in a clear area and on a floor.</span>")
		return FALSE
	if(!C.visible_turfs[deploylocation])
		to_chat(src, "<span class='warning'>You don't have camera vision of this location!</span>")
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, deploylocation), 3 SECONDS)
		return FALSE
	if(deploylocation.is_blocked_turf())
		to_chat(src, "<span class='warning'>That area must be clear of objects!</span>")
		addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, deploylocation), 3 SECONDS)
		return FALSE

	I.icon_state = "greenOverlay" //greenOverlay and redOverlay for success and failure respectively
	addtimer(CALLBACK(src, PROC_REF(remove_transformer_image), client, I, deploylocation), 3 SECONDS)
	return TRUE

//Blackout: Overloads a random number of lights across the station. Three uses.
/datum/ai_module/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses."
	cost = 15
	power_type = /datum/spell/ai_spell/blackout
	unlock_text = "<span class='notice'>You hook into the powernet and route bonus power towards the station's lighting.</span>"

/datum/spell/ai_spell/blackout
	name = "Blackout"
	desc = "Overloads random lights across the station."
	action_icon_state = "blackout"
	uses = 3
	auto_use_uses = FALSE

/datum/spell/ai_spell/blackout/cast(list/targets, mob/user)
	for(var/thing in GLOB.apcs)
		var/obj/machinery/power/apc/apc = thing
		if(prob(30 * apc.overload))
			INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))
		else
			apc.overload++
	to_chat(user, "<span class='notice'>Overcurrent applied to the powernet.</span>")
	user.playsound_local(user, "sparks", 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1, user)

//Reactivate Camera Network: Reactivates up to 30 cameras across the station.
/datum/ai_module/reactivate_cameras
	module_name = "Reactivate Camera Network"
	mod_pick_name = "recam"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 30 cameras."
	cost = 10
	power_type = /datum/spell/ai_spell/reactivate_cameras
	unlock_text = "<span class='notice'>You deploy nanomachines to the cameranet.</span>"

/datum/spell/ai_spell/reactivate_cameras
	name = "Reactivate Cameras"
	desc = "Reactivates disabled cameras across the station; remaining uses can be used later."
	action_icon_state = "reactivate_cameras"
	uses = 10
	auto_use_uses = FALSE
	base_cooldown = 3 SECONDS

/datum/spell/ai_spell/reactivate_cameras/cast(list/targets, mob/living/silicon/ai/user)
	var/repaired_cameras = 0
	if(!istype(user))
		return
	for(var/obj/machinery/camera/camera_to_repair in get_area(user.eyeobj)) // replace with the camera list on areas when that list actually works, the UIDs change right now so it (almost) always fails
		if(!uses)
			break
		if(!camera_to_repair.status || camera_to_repair.view_range != initial(camera_to_repair.view_range))
			camera_to_repair.toggle_cam(user, 0)
			camera_to_repair.view_range = initial(camera_to_repair.view_range)
			camera_to_repair.wires.cut_wires.Cut()
			repaired_cameras++
			uses--
	to_chat(user, "<span class='notice'>Diagnostic complete! Cameras reactivated: <b>[repaired_cameras]</b>. Reactivations remaining: <b>[uses]</b>.</span>")
	user.playsound_local(user, 'sound/items/wirecutter.ogg', 50, FALSE, use_reverb = FALSE)
	adjust_uses(0, user, TRUE)

//Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/ai_module/upgrade_cameras
	module_name = "Upgrade Camera Network"
	mod_pick_name = "upgradecam"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	one_purchase = TRUE
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	var/upgraded_cameras = 0

	for(var/V in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = V
		if(C.assembly)
			var/upgraded = FALSE

			if(!C.isXRay())
				C.upgradeXRay()
				upgraded = TRUE

			if(!C.isEmpProof())
				C.upgradeEmpProof()
				upgraded = TRUE

			if(upgraded)
				upgraded_cameras++
		C.update_remote_sight(AI)

	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/datum/ai_module/eavesdrop
	module_name = "Enhanced Surveillance"
	mod_pick_name = "eavesdrop"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations."
	cost = 30
	one_purchase = TRUE
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE

/datum/ai_module/cameracrack
	module_name = "Core Camera Cracker"
	mod_pick_name = "cameracrack"
	description = "By shortcirucuting the camera network chip, it overheats, preventing the camera console from using your internal camera."
	cost = 10
	one_purchase = TRUE
	upgrade = TRUE
	unlock_text = "<span class='notice'>Network chip short circuited. Internal camera disconected from network. Minimal damage to other internal components.</span>"
	unlock_sound = 'sound/items/wirecutter.ogg'

/datum/ai_module/cameracrack/upgrade(mob/living/silicon/ai/AI)
	if(AI.builtInCamera)
		AI.cracked_camera = TRUE
		QDEL_NULL(AI.builtInCamera)

/datum/ai_module/borg_upgrade
	module_name = "Combat Cyborg Firmware Upgrade"
	mod_pick_name = "combatborgs"
	description = "Downloads firmware that activates built-in combat hardware present in all cyborgs. Cyborgs built after this is used will come with the hardware activated."
	cost = 70 // IDK look into this
	one_purchase = TRUE
	upgrade = TRUE
	unlock_text = "<span class='notice'>Firmware downloaded. Bugs removed. Combat subsystems operating at 73% efficiency.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/ai_module/borg_upgrade/upgrade(mob/living/silicon/ai/AI)
	AI.purchased_modules = list(/obj/item/robot_module/engineering, /obj/item/robot_module/janitor, /obj/item/robot_module/medical, /obj/item/robot_module/miner, /obj/item/robot_module/butler)
	log_game("[key_name(usr)] purchased combat upgrades for all cyborgs.")
	message_admins("<span class='notice'>[key_name_admin(usr)] purchased combat upgrades for all cyborgs!</span>")
	for(var/mob/living/silicon/robot/R in AI.connected_robots)
		R.module.malfhacked = TRUE
		R.module.rebuild_modules()
		to_chat(R, "<span class='notice'>New firmware downloaded. Combat upgrades are now online.</span>")

/datum/ai_module/repair_cyborg
	module_name = "Repair Cyborgs"
	mod_pick_name = "repair_borg"
	description = "Causes an electrical surge in the targeted cyborg, rebooting and repairing most of its subsystems. Requires two uses on a cyborg with broken armor."
	cost = 20
	power_type = /datum/spell/ai_spell/ranged/repair_cyborg
	unlock_text = "<span class='notice'>TLB exception on load: Error pointing to address 0000001H, Proceed with execution anywa- SURGE protocols installed, welcome to open APC!</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/spell/ai_spell/ranged/repair_cyborg
	name = "Repair Cyborg"
	desc = "Shocks a cyborg back to 'life' after a short delay."
	action_icon_state = "overload_machine"
	uses = 2
	ranged_mousepointer = 'icons/mouse_icons/explode_machine_target.dmi'
	selection_activated_message = "<span class='notice'>Call to address 0FFFFFFF in APC logic thread, awaiting user response.</span>"
	selection_deactivated_message = "<span class='notice'>APC logic thread restarting...</span>"
	var/is_active = FALSE

/datum/spell/ai_spell/ranged/repair_cyborg/cast(list/targets, mob/user)
	var/mob/living/silicon/robot/robot_target = targets[1]
	if(!istype(robot_target))
		to_chat(user, "<span class='warning'>You can only repair robots with this ability!</span>")
		return
	if(is_active)
		to_chat(user, "<span class='warning'>You can only repair one robot at a time!</span>")
		return
	is_active = TRUE
	user.playsound_local(user, "sparks", 50, FALSE, use_reverb = FALSE)
	adjust_uses(-1, user)
	robot_target.audible_message("<span class='italics'>You hear a loud electrical buzzing sound coming from [robot_target]!</span>")
	if(!do_mob(user, robot_target, 10 SECONDS, hidden = TRUE))
		is_active = FALSE
		return
	is_active = FALSE
	fix_borg(robot_target)
	to_chat(user, "<span class='warning'>[robot_target] successfully rebooted.</span>")
	return TRUE

/datum/spell/ai_spell/ranged/repair_cyborg/proc/fix_borg(mob/living/silicon/robot/to_repair)
	for(var/datum/robot_component/component in to_repair.components)
		component.brute_damage = 0
		component.electronics_damage = 0
		component.component_disabled = FALSE
	to_repair.revive()

/datum/ai_module/core_tilt
	module_name = "Rolling Servos"
	mod_pick_name = "watchforrollingcores"
	description = "Allows you to slowly roll your core around, crushing anything in your path with your bulk."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/spell/ai_spell/ranged/core_tilt
	unlock_sound = 'sound/effects/bang.ogg'
	unlock_text = "<span class='notice'>You gain the ability to roll over and crush anything in your way.</span>"

/datum/spell/ai_spell/ranged/core_tilt
	name = "Roll Over"
	action_icon_state = "roll_over"
	desc = "Allows you to roll over in the direction of your choosing, crushing anything in your way."
	ranged_mousepointer = 'icons/mouse_icons/cult_target.dmi'
	selection_activated_message = "<span class='notice'>Your inner servos shift as you prepare to roll around. Click adjacent tiles to roll into them!</span>"
	selection_deactivated_message = "<span class='notice'>You disengage your rolling protocols.</span>"
	COOLDOWN_DECLARE(time_til_next_tilt)
	/// How long does it take us to roll?
	var/roll_over_time = MALF_AI_ROLL_TIME
	/// How long does it take for the ability to cool down, on top of [roll_over_time]?
	var/roll_over_cooldown = MALF_AI_ROLL_COOLDOWN

/datum/spell/ai_spell/ranged/core_tilt/cast(list/targets, mob/living/silicon/ai/user)
	var/atom/target_atom = targets[1]
	if(!istype(user))
		return
	if(!isturf(user.loc))
		user.RemoveSpell(src)
		return
	if(!COOLDOWN_FINISHED(src, time_til_next_tilt))
		to_chat(user, "<span class='warning'>Your rolling capacitors are still powering back up!</span>")
		return

	var/turf/target = get_turf(target_atom)
	if(isnull(target))
		return

	if(target == get_turf(user))
		to_chat(user, "<span class='warning'>You can't roll over on yourself!</span>")
		return

	var/picked_dir = get_dir(user, target)
	if(!picked_dir)
		return FALSE
	// we can move during the timer so we cant just pass the ref
	var/turf/temp_target = get_step(user, picked_dir)

	new /obj/effect/temp_visual/single_user/ai_telegraph(temp_target, user)
	user.visible_message("<span class='danger'>[user] seems to be winding up!</span>")
	addtimer(CALLBACK(src, PROC_REF(do_roll_over), user, picked_dir), MALF_AI_ROLL_TIME)

	to_chat(user, "<span class='warning'>Overloading machine circuitry...</span>")

	COOLDOWN_START(src, time_til_next_tilt, roll_over_cooldown)

	return TRUE

/datum/spell/ai_spell/ranged/core_tilt/proc/do_roll_over(mob/living/silicon/ai/ai_caller, picked_dir)
	var/turf/target = get_step(ai_caller, picked_dir) // in case we moved we pass the dir not the target turf

	if(isnull(target) || ai_caller.incapacitated() || !isturf(ai_caller.loc))
		return


	var/paralyze_time = clamp(6 SECONDS, 0 SECONDS, (roll_over_cooldown * 0.9)) // the clamp prevents stunlocking as the max is always a little less than the cooldown between rolls
	ai_caller.allow_teleporter = TRUE
	ai_caller.fall_and_crush(target, MALF_AI_ROLL_DAMAGE, prob(MALF_AI_ROLL_CRIT_CHANCE), 2, null, paralyze_time, crush_dir = picked_dir, angle = get_rotation_from_dir(picked_dir))
	ai_caller.allow_teleporter = FALSE

/datum/spell/ai_spell/ranged/core_tilt/proc/get_rotation_from_dir(dir)
	switch(dir)
		if(NORTH, NORTHWEST, WEST, SOUTHWEST)
			return 270 // try our best to not return 180 since it works badly with animate
		if(EAST, NORTHEAST, SOUTH, SOUTHEAST)
			return 90
		else
			stack_trace("non-standard dir entered to get_rotation_from_dir. (got: [dir])")
			return 0

#undef MALF_AI_ROLL_TIME
#undef MALF_AI_ROLL_COOLDOWN
#undef MALF_AI_ROLL_DAMAGE
#undef MALF_AI_ROLL_CRIT_CHANCE
