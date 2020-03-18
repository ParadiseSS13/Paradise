//The malf AI action subtype. All malf actions are subtypes of this.
/datum/action/innate/ai
	name = "AI Action"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	background_icon_state = "bg_tech_blue"
	var/mob/living/silicon/ai/owner_AI //The owner AI, so we don't have to typecast every time
	var/uses //If we have multiple uses of the same power
	var/auto_use_uses = TRUE //If we automatically use up uses on each activation
	var/cooldown_period //If applicable, the time in deciseconds we have to wait before using any more modules

/datum/action/innate/ai/Grant(mob/living/L)
	. = ..()
	if(!isAI(owner))
		WARNING("AI action [name] attempted to grant itself to non-AI mob [L.real_name] ([L.key])!")
		qdel(src)
	else
		owner_AI = owner

/datum/action/innate/ai/IsAvailable()
	. = ..()
	if(owner_AI && owner_AI.malf_cooldown > world.time)
		return

/datum/action/innate/ai/Trigger()
	. = ..()
	if(auto_use_uses)
		adjust_uses(-1)
	if(cooldown_period)
		owner_AI.malf_cooldown = world.time + cooldown_period

/datum/action/innate/ai/proc/adjust_uses(amt, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, "<span class='notice'>[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining.</span>")
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, "<span class='warning'>[name] has run out of uses!</span>")
		qdel(src)

//Framework for ranged abilities that can have different effects by left-clicking stuff.
/datum/action/innate/ai/ranged
	name = "Ranged AI Action"
	auto_use_uses = FALSE //This is so we can do the thing and disable/enable freely without having to constantly add uses
	var/obj/effect/proc_holder/ranged_ai/linked_ability //The linked proc holder that contains the actual ability code
	var/linked_ability_type //The path of our linked ability

/datum/action/innate/ai/ranged/New()
	if(!linked_ability_type)
		WARNING("Ranged AI action [name] attempted to spawn without a linked ability!")
		qdel(src) //uh oh!
		return
	linked_ability = new linked_ability_type()
	linked_ability.attached_action = src
	..()

/datum/action/innate/ai/ranged/adjust_uses(amt, silent)
	uses += amt
	if(!silent && uses)
		to_chat(owner, "<span class='notice'>[name] now has <b>[uses]</b> use[uses > 1 ? "s" : ""] remaining.</span>")
	if(!uses)
		if(initial(uses) > 1) //no need to tell 'em if it was one-use anyway!
			to_chat(owner, "<span class='warning'>[name] has run out of uses!</span>")
		Remove(owner)
		QDEL_IN(src, 100) //let any active timers on us finish up

/datum/action/innate/ai/ranged/Destroy()
	QDEL_NULL(linked_ability)
	return ..()

/datum/action/innate/ai/ranged/Activate()
	linked_ability.toggle(owner)
	return TRUE

//The actual ranged proc holder.
/obj/effect/proc_holder/ranged_ai
	var/enable_text = "<span class='notice'>Hello World!</span>" //Appears when the user activates the ability
	var/disable_text = "<span class='danger'>Goodbye Cruel World!</span>" //Context clues!
	var/datum/action/innate/ai/ranged/attached_action

/obj/effect/proc_holder/ranged_ai/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(user, disable_text)
	else
		add_ranged_ability(user, enable_text)

//The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/temp
	var/processing_time = 50
	var/list/possible_modules

/datum/module_picker/New()
	possible_modules = list()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if((AM.power_type && AM.power_type != /datum/action/innate/ai) || AM.upgrade)
			possible_modules += AM

/datum/module_picker/proc/remove_malf_verbs(mob/living/silicon/ai/AI) //Removes all malfunction-related abilities from the target AI.
	for(var/datum/AI_Module/AM in possible_modules)
		for(var/datum/action/A in AI.actions)
			if(istype(A, initial(AM.power_type)))
				qdel(A)

/datum/module_picker/proc/use(user as mob)
	var/dat
	dat += {"<B>Select use of processing time: (currently #[processing_time] left.)</B><BR>
			<HR>
			<B>Install Module:</B><BR>
			<I>The number afterwards is the amount of processing time it consumes.</I><BR>"}
	for(var/datum/AI_Module/large/module in possible_modules)
		dat += "<A href='byond://?src=[UID()];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=[UID()];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in possible_modules)
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

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, "<span class='warning'>You are already dead!</span>")
		return

	for(var/datum/AI_Module/AM in possible_modules)
		if (href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > processing_time)
				temp = "You cannot afford this module."
				break

			var/datum/action/innate/ai/action = locate(AM.power_type) in A.actions

			// Give the power and take away the money.
			if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
				AM.upgrade(A)
				possible_modules -= AM
				to_chat(A, AM.unlock_text)
				A.playsound_local(A, AM.unlock_sound, 50, 0)
			else
				if(AM.power_type)
					if(!action) //Unlocking for the first time
						var/datum/action/AC = new AM.power_type
						AC.Grant(A)
						A.current_modules += new AM.type
						temp = AM.description
						if(AM.one_purchase)
							possible_modules -= AM
						if(AM.unlock_text)
							to_chat(A, AM.unlock_text)
						if(AM.unlock_sound)
							A.playsound_local(A, AM.unlock_sound, 50, 0)
					else //Adding uses to an existing module
						action.uses += initial(action.uses)
						action.desc = "[initial(action.desc)] It has [action.uses] use\s remaining."
						action.UpdateButtonIcon()
						temp = "Additional use[action.uses > 1 ? "s" : ""] added to [action.name]!"
			processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	use(usr)

//The base module type, which holds info about each ability.
/datum/AI_Module
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_purchase = FALSE //If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.
	var/power_type = /datum/action/innate/ai //If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/upgrade //If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/unlock_text = "<span class='notice'>Hello World!</span>" //Text shown when an ability is unlocked
	var/unlock_sound //Sound played when an ability is unlocked
	var/uses

/datum/AI_Module/proc/upgrade(mob/living/silicon/AI/AI) //Apply upgrades!
	return

/datum/AI_Module/large //Big, powerful stuff that can only be used once.

/datum/AI_Module/small //Weak, usually localized stuff with multiple uses.

//Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/AI_Module/large/nuke_station
	module_name = "Doomsday Device"
	mod_pick_name = "nukestation"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = "<span class='notice'>You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.</span>"
	unlock_sound = 'sound/items/timer.ogg'

/datum/action/innate/ai/nuke_station
	name = "Doomsday Device"
	desc = "Activates the doomsday device. This is not reversible."
	button_icon_state = "doomsday_device"
	auto_use_uses = FALSE

/datum/action/innate/ai/nuke_station/Activate()
	var/turf/T = get_turf(owner)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(owner, "<span class='warning'>You cannot activate the doomsday device while off-station!</span>")
		return
	if(alert(owner, "Send arming signal? (true = arm, false = cancel)", "purge_all_life()", "confirm = TRUE;", "confirm = FALSE;") != "confirm = TRUE;")
		return
	if(active)
		return //prevent the AI from activating an already active doomsday
	active = TRUE
	set_us_up_the_bomb()

/datum/action/innate/ai/nuke_station/proc/set_us_up_the_bomb()
	to_chat(owner_AI, "<span class='notice'>Nuclear device armed.</span>")
	event_announcement.Announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", new_sound = 'sound/AI/aimalf.ogg')
	set_security_level("delta")
	owner_AI.nuking = TRUE
	var/obj/machinery/doomsday_device/DOOM = new /obj/machinery/doomsday_device(owner_AI)
	owner_AI.doomsday_device = DOOM
	owner_AI.doomsday_device.start()
	for(var/obj/item/pinpointer/point in GLOB.pinpointer_list)
		for(var/mob/living/silicon/ai/A in ai_list)
			if((A.stat != DEAD) && A.nuking)
				point.the_disk = A //The pinpointer now tracks the AI core
	qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	anchored = 1
	density = 1
	atom_say_verb = "blares"
	speed_process = TRUE // Disgusting fix. Please remove once #12952 is merged
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
	SSticker.force_ending = 1

//AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>You establish a power diversion to your turrets, upgrading their health and damage.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/upgrade_turrets/upgrade(mob/living/silicon/AI/AI)
	for(var/obj/machinery/porta_turret/turret in GLOB.machines)
		var/turf/T = get_turf(turret)
		if(is_station_level(T.z))
			turret.health += 30
			turret.eprojectile = /obj/item/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
			turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'

//Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/AI_Module/large/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds, briefly \
	opening all doors on the station."
	cost = 30
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = "<span class='notice'>You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.</span>"

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Closes, bolts, and depowers every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	uses = 1

/datum/action/innate/ai/lockdown/Activate()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(!is_station_level(D.z))
			continue
		INVOKE_ASYNC(D, /obj/machinery/door.proc/hostile_lockdown, owner)
		addtimer(CALLBACK(D, /obj/machinery/door.proc/disable_lockdown), 900)

	post_status("alert", "lockdown")

	minor_announcement.Announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.", "Network Alert")
	to_chat(owner, "<span class='warning'>Lockdown Initiated. Network reset in 90 seconds.</span>")
	spawn(900)
		minor_announcement.Announce("Automatic system reboot complete. Have a secure day.","Network reset:")

//Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/AI_Module/large/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/destroy_rcds
	unlock_text = "<span class='notice'>After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.</span>"

/datum/action/innate/ai/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	button_icon_state = "detonate_rcds"
	uses = 1
	cooldown_period = 100

/datum/action/innate/ai/destroy_rcds/Activate()
	for(var/obj/item/rcd/RCD in GLOB.rcd_list)
		if(!istype(RCD, /obj/item/rcd/borg)) //Ensures that cyborg RCDs are spared.
			RCD.detonate_pulse()

	to_chat(owner, "<span class='danger'>RCD detonation pulse emitted.</span>")
	owner.playsound_local(owner, 'sound/machines/twobeep.ogg', 50, 0)

//Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/AI_Module/large/mecha_domination
	module_name = "Unlock Mech Domination"
	mod_pick_name = "mechjack"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b></span>"
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/AI_Module/large/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!

//Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/AI_Module/large/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert. \
	Anyone can check the fire alarm's interface and may be tipped off by its status."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = "<span class='notice'>You replace the thermal sensing capabilities of all fire alarms with a manual override, allowing you to turn them off at will.</span>"

/datum/action/innate/ai/break_fire_alarms
	name = "Override Thermal Sensors"
	desc = "Disables the automatic temperature sensing on all fire alarms, making them effectively useless."
	button_icon_state = "break_fire_alarms"
	uses = 1

/datum/action/innate/ai/break_fire_alarms/Activate()
	for(var/obj/machinery/firealarm/F in GLOB.machines)
		if(!is_station_level(F.z))
			continue
		F.emagged = TRUE
	to_chat(owner, "<span class='notice'>All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized.</span>")
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)

//Air Alarm Safety Override: Unlocks the ability to enable flooding on all air alarms.
/datum/AI_Module/large/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = TRUE
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = "<span class='notice'>You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.</span>"

/datum/action/innate/ai/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables the Flood setting on all air alarms."
	button_icon_state = "break_air_alarms"
	uses = 1

/datum/action/innate/ai/break_air_alarms/Activate()
	for(var/obj/machinery/alarm/AA in GLOB.machines)
		if(!is_station_level(AA.z))
			continue
		AA.emagged = TRUE
	to_chat(owner, "<span class='notice'>All air alarm safeties on the station have been overriden. Air alarms may now use the Flood environmental mode.")
	owner.playsound_local(owner, 'sound/machines/terminal_off.ogg', 50, 0)


//Overload Machine: Allows the AI to overload a machine, detonating it after a delay. Two uses per purchase.
/datum/AI_Module/small/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overheats an electrical machine, causing a small explosion and destroying it. Two uses per purchase."
	cost = 20
	power_type = /datum/action/innate/ai/ranged/overload_machine
	unlock_text = "<span class='notice'>You enable the ability for the station's APCs to direct intense energy into machinery.</span>"

/datum/action/innate/ai/ranged/overload_machine
	name = "Overload Machine"
	desc = "Overheats a machine, causing a small explosion after a short time."
	button_icon_state = "overload_machine"
	uses = 2
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/overload_machine

/datum/action/innate/ai/ranged/overload_machine/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/ranged/overload_machine/proc/detonate_machine(obj/machinery/M)
	if(M && !QDELETED(M))
		explosion(get_turf(M), 0,1,1,0)
		if(M) //to check if the explosion killed it before we try to delete it
			qdel(M)

/obj/effect/proc_holder/ranged_ai/overload_machine
	active = FALSE
	ranged_mousepointer = 'icons/effects/overload_machine_target.dmi'
	enable_text = "<span class='notice'>You tap into the station's powernet. Click on a machine to detonate it, or use the ability again to cancel.</span>"
	disable_text = "<span class='notice'>You release your hold on the powernet.</span>"

/obj/effect/proc_holder/ranged_ai/overload_machine/InterceptClickOn(mob/living/caller, params, obj/machinery/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	if(!istype(target))
		to_chat(ranged_ability_user, "<span class='warning'>You can only overload machines!</span>")
		return

	ranged_ability_user.playsound_local(ranged_ability_user, "sparks", 50, 0)
	attached_action.adjust_uses(-1)
	if(attached_action && attached_action.uses)
		attached_action.desc = "[initial(attached_action.desc)] It has [attached_action.uses] use\s remaining."
		attached_action.UpdateButtonIcon()
	target.audible_message("<span class='italics'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	addtimer(CALLBACK(attached_action, /datum/action/innate/ai/ranged/overload_machine.proc/detonate_machine, target), 50) //kaboom!
	remove_ranged_ability(ranged_ability_user, "<span class='warning'>Overloading machine circuitry...</span>")
	return TRUE


//Override Machine: Allows the AI to override a machine, animating it into an angry, living version of itself.
/datum/AI_Module/small/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. Four uses."
	cost = 30
	power_type = /datum/action/innate/ai/ranged/override_machine
	unlock_text = "<span class='notice'>You procure a virus from the Space Dark Web and distribute it to the station's machines.</span>"

/datum/action/innate/ai/ranged/override_machine
	name = "Override Machine"
	desc = "Animates a targeted machine, causing it to attack anyone nearby."
	button_icon_state = "override_machine"
	uses = 4
	linked_ability_type = /obj/effect/proc_holder/ranged_ai/override_machine

/datum/action/innate/ai/ranged/override_machine/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/ranged/override_machine/proc/animate_machine(obj/machinery/M)
	if(M && !QDELETED(M))
		new/mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, owner, 1)

/obj/effect/proc_holder/ranged_ai/override_machine
	active = FALSE
	ranged_mousepointer = 'icons/effects/override_machine_target.dmi'
	enable_text = "<span class='notice'>You tap into the station's powernet. Click on a machine to animate it, or use the ability again to cancel.</span>"
	disable_text = "<span class='notice'>You release your hold on the powernet.</span>"

/obj/effect/proc_holder/ranged_ai/override_machine/InterceptClickOn(mob/living/caller, params, obj/machinery/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	if(!istype(target))
		to_chat(ranged_ability_user, "<span class='warning'>You can only animate machines!</span>")
		return
	if(!target.can_be_overridden())
		to_chat(ranged_ability_user, "<span class='warning'>That machine can't be overridden!</span>")
		return

	ranged_ability_user.playsound_local(ranged_ability_user, 'sound/misc/interference.ogg', 50, 0)
	attached_action.adjust_uses(-1)
	if(attached_action && attached_action.uses)
		attached_action.desc = "[initial(attached_action.desc)] It has [attached_action.uses] use\s remaining."
		attached_action.UpdateButtonIcon()
	target.audible_message("<span class='userdanger'>You hear a loud electrical buzzing sound coming from [target]!</span>")
	addtimer(CALLBACK(attached_action, /datum/action/innate/ai/ranged/override_machine.proc/animate_machine, target), 50) //kabeep!
	remove_ranged_ability(ranged_ability_user, "<span class='danger'>Sending override signal...</span>")
	return TRUE


//Robotic Factory: Places a large machine that converts humans that go through it into cyborgs. Unlocking this ability removes shunting.
/datum/AI_Module/large/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/place_transformer
	unlock_text = "<span class='notice'>You prepare a robotics factory for deployment.</span>"
	unlock_sound = 'sound/machines/ping.ogg'

/datum/action/innate/ai/place_transformer
	name = "Place Robotics Factory"
	desc = "Places a machine that converts humans into cyborgs. Conveyor belts included!"
	button_icon_state = "robotic_factory"
	uses = 1
	auto_use_uses = FALSE //So we can attempt multiple times
	var/list/turfOverlays

/datum/action/innate/ai/place_transformer/New()
	..()
	for(var/i in 1 to 3)
		var/image/I = image("icon"='icons/turf/overlays.dmi')
		LAZYADD(turfOverlays, I)

/datum/action/innate/ai/place_transformer/Activate()
	if(!owner_AI.can_place_transformer(src))
		return
	active = TRUE
	if(alert(owner, "Are you sure you want to place the machine here?", "Are you sure?", "Yes", "No") == "No")
		active = FALSE
		return
	if(!owner_AI.can_place_transformer(src))
		active = FALSE
		return
	var/turf/T = get_turf(owner_AI.eyeobj)
	new /obj/machinery/transformer/conveyor(T)
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	owner_AI.can_shunt = FALSE
	to_chat(owner, "<span class='warning'>You are no longer able to shunt your core to APCs.</span>")
	adjust_uses(-1)

/mob/living/silicon/ai/proc/remove_transformer_image(client/C, image/I, turf/T)
	if(C && I.loc == T)
		C.images -= I

/mob/living/silicon/ai/proc/can_place_transformer(datum/action/innate/ai/place_transformer/action)
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
		var/datum/camerachunk/C = cameranet.getCameraChunk(T.x, T.y, T.z)
		if(!C.visibleTurfs[T])
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
		addtimer(CALLBACK(src, .proc/remove_transformer_image, client, I, T), 30)
	if(!success)
		to_chat(src, "<span class='warning'>[alert_msg]</span>")
	return success

//Blackout: Overloads a random number of lights across the station. Three uses.
/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. Three uses."
	cost = 15
	power_type = /datum/action/innate/ai/blackout
	unlock_text = "<span class='notice'>You hook into the powernet and route bonus power towards the station's lighting.</span>"

/datum/action/innate/ai/blackout
	name = "Blackout"
	desc = "Overloads random lights across the station."
	button_icon_state = "blackout"
	uses = 3
	auto_use_uses = FALSE

/datum/action/innate/ai/blackout/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/blackout/Activate()
	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		if(prob(30 * apc.overload))
			apc.overload_lighting()
		else
			apc.overload++
	to_chat(owner, "<span class='notice'>Overcurrent applied to the powernet.</span>")
	owner.playsound_local(owner, "sparks", 50, 0)
	adjust_uses(-1)
	if(src && uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		desc = "[initial(desc)] It has [uses] use\s remaining."
		UpdateButtonIcon()

//Reactivate Camera Network: Reactivates up to 30 cameras across the station.
/datum/AI_Module/small/reactivate_cameras
	module_name = "Reactivate Camera Network"
	mod_pick_name = "recam"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 30 cameras."
	cost = 10
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/reactivate_cameras
	unlock_text = "<span class='notice'>You deploy nanomachines to the cameranet.</span>"

/datum/action/innate/ai/reactivate_cameras
	name = "Reactivate Cameras"
	desc = "Reactivates disabled cameras across the station; remaining uses can be used later."
	button_icon_state = "reactivate_cameras"
	uses = 30
	auto_use_uses = FALSE
	cooldown_period = 30

/datum/action/innate/ai/reactivate_cameras/New()
	..()
	desc = "[desc] It has [uses] use\s remaining."
	button.desc = desc

/datum/action/innate/ai/reactivate_cameras/Activate()
	var/fixed_cameras = 0
	for(var/V in cameranet.cameras)
		if(!uses)
			break
		var/obj/machinery/camera/C = V
		if(!C.status || C.view_range != initial(C.view_range))
			C.toggle_cam(owner_AI, 0) //Reactivates the camera based on status. Badly named proc.
			C.view_range = initial(C.view_range)
			fixed_cameras++
			uses-- //Not adjust_uses() so it doesn't automatically delete or show a message
	to_chat(owner, "<span class='notice'>Diagnostic complete! Cameras reactivated: <b>[fixed_cameras]</b>. Reactivations remaining: <b>[uses]</b>.</span>")
	owner.playsound_local(owner, 'sound/items/wirecutter.ogg', 50, 0)
	adjust_uses(0, TRUE) //Checks the uses remaining
	if(src && uses) //Not sure if not having src here would cause a runtime, so it's here to be safe
		desc = "[initial(desc)] It has [uses] use\s remaining."
		UpdateButtonIcon()

//Upgrade Camera Network: EMP-proofs all cameras, in addition to giving them X-ray vision.
/datum/AI_Module/large/upgrade_cameras
	module_name = "Upgrade Camera Network"
	mod_pick_name = "upgradecam"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-proofing and light-amplified X-ray vision." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	one_purchase = TRUE
	cost = 35 //Decent price for omniscience!
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: CAMSUPGRADED. Light amplification system online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/upgrade_cameras/upgrade(mob/living/silicon/ai/AI)
	AI.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //Night-vision, without which X-ray would be very limited in power.
	AI.update_sight()
	var/upgraded_cameras = 0

	for(var/V in cameranet.cameras)
		var/obj/machinery/camera/C = V
		if(C.assembly)
			var/upgraded = FALSE

			if(!C.isXRay())
				C.upgradeXRay()
				//Update what it can see.
				cameranet.updateVisibility(C, 0)
				upgraded = TRUE

			if(!C.isEmpProof())
				C.upgradeEmpProof()
				upgraded = TRUE

			if(upgraded)
				upgraded_cameras++

	unlock_text = replacetext(unlock_text, "CAMSUPGRADED", "<b>[upgraded_cameras]</b>") //This works, since unlock text is called after upgrade()

/datum/AI_Module/large/eavesdrop
	module_name = "Enhanced Surveillance"
	mod_pick_name = "eavesdrop"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations."
	cost = 30
	one_purchase = TRUE
	upgrade = TRUE
	unlock_text = "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/eavesdrop/upgrade(mob/living/silicon/ai/AI)
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE

