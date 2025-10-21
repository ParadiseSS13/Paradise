//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/**
 * Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already.
 * Each mob may only have one alert per category.
 *
 * Arguments:
 * * category - a text string corresponding to what type of alert it is
 * * type - a type path of the actual alert type to throw
 * * severity - is an optional number that will be placed at the end of the icon_state for this alert
 *   For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 * * obj/new_master - optional argument. Sets the alert's icon state to "template" in the ui_style icons with the master as an overlay. Clicks are forwarded to master
 * * no_anim - whether the alert should play a small sliding animation when created on the player's screen
 * * icon_override - makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 * * list/alert_args - a list of arguments to pass to the alert when creating it
 */
/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, timeout_override, no_anim, icon_override, list/alert_args)
	if(!category)
		return

	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(alert)
		if(alert.override_alerts)
			return 0
		if(new_master && new_master != alert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [alert.master]")
			clear_alert(category)
			return .()
		else if(alert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == alert.severity)
			if(alert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		if(alert_args)
			alert_args.Insert(1, null) // So it's still created in nullspace.
			alert = new type(arglist(alert_args))
		else
			alert = new type()
		alert.override_alerts = override
		if(override)
			alert.timeout = null

		alert.attach_owner(src)

	if(icon_override)
		alert.icon = icon_override

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		alert.overlays += new_master
		new_master.layer = old_layer
		new_master.plane = old_plane
		alert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		alert.master = new_master
	else
		alert.icon_state = "[initial(alert.icon_state)][severity]"
		alert.severity = severity

	LAZYSET(alerts, category, alert) // This also creates the list if it doesn't exist
	if(client && hud_used)
		hud_used.reorganize_alerts()

	if(!no_anim)
		alert.transform = matrix(32, 6, MATRIX_TRANSLATE)
		animate(alert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	var/timeout = timeout_override || alert.timeout
	if(timeout)
		addtimer(CALLBACK(alert, TYPE_PROC_REF(/atom/movable/screen/alert, do_timeout), src, category), timeout)
		alert.timeout = world.time + timeout - world.tick_lag

	return alert

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = LAZYACCESS(alerts, category)
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/atom/movable/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please."
	/// How long before this alert automatically clears itself (in deciseconds). If zero, remains until cleared.
	var/timeout = 0
	/// Some alerts may have different icon states based on severity, this adjusts that.
	var/severity = 0
	/// Tool-tip for the alert.
	var/alerttooltipstyle = ""
	/// If true, this should override any other alerts of the same type thrown.
	var/override_alerts = FALSE
	/// The mob that this alert was originally thrown to.
	var/mob/owner

/atom/movable/screen/alert/proc/attach_owner(mob/new_owner)
	owner = new_owner
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(remove_owner))

/atom/movable/screen/alert/proc/remove_owner(mob/source, force)
	SIGNAL_HANDLER  // COMSIG_PARENT_QDELETING
	if(owner == source && !isnull(owner))
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null

/atom/movable/screen/alert/Destroy()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
	owner = null
	severity = 0
	master = null
	screen_loc = ""
	return ..()

/atom/movable/screen/alert/Click(location, control, params)
	..()
	if(!usr || !usr.client)
		return FALSE
	if(usr != owner)
		to_chat(usr, "<span class='notice'>Only [owner] can use that!</span>")
		return FALSE
	var/paramslist = params2list(params)
	if(paramslist["shift"]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='notice'>[desc]</span>")
		return FALSE
	if(master)
		usr.client.Click(master, location, control, params)
	return TRUE

/atom/movable/screen/alert/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)


/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)
	return ..()

/atom/movable/screen/alert/proc/do_timeout(mob/M, category)
	if(!M || !M.alerts)
		return

	if(timeout && M.alerts[category] == src && world.time >= timeout)
		M.clear_alert(category)

//Gas alerts
/atom/movable/screen/alert/not_enough_oxy
	name = "Choking (No O2)"
	desc = "You're not getting enough oxygen. Find some good air before you pass out! The box in your backpack has an oxygen tank and breath mask in it."
	icon_state = "not_enough_oxy"

/atom/movable/screen/alert/too_much_oxy
	name = "Choking (O2)"
	desc = "There's too much oxygen in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_oxy"

/atom/movable/screen/alert/not_enough_nitro
	name = "Choking (No N2)"
	desc = "You're not getting enough nitrogen. Find some good air before you pass out!"
	icon_state = "not_enough_nitro"

/atom/movable/screen/alert/too_much_nitro
	name = "Choking (N2)"
	desc = "There's too much nitrogen in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_nitro"

/atom/movable/screen/alert/not_enough_co2
	name = "Choking (No CO2)"
	desc = "You're not getting enough carbon dioxide. Find some good air before you pass out!"
	icon_state = "not_enough_co2"

/atom/movable/screen/alert/too_much_co2
	name = "Choking (CO2)"
	desc = "There's too much carbon dioxide in the air, and you're breathing it in! Find some good air before you pass out!"
	icon_state = "too_much_co2"

/atom/movable/screen/alert/not_enough_tox
	name = "Choking (No Plasma)"
	desc = "You're not getting enough plasma. Find some good air before you pass out!"
	icon_state = "not_enough_tox"

/atom/movable/screen/alert/too_much_tox
	name = "Choking (Plasma)"
	desc = "There's highly flammable, toxic plasma in the air and you're breathing it in. Find some fresh air. The box in your backpack has an oxygen tank and gas mask in it."
	icon_state = "too_much_tox"
//End gas alerts

// Hunger alerts

/atom/movable/screen/alert/hunger
	icon = 'icons/mob/screen_hunger.dmi'

/atom/movable/screen/alert/hunger/fat
	name = "Fat"
	desc = "You ate too much food, lardass. Run around the station and lose some weight."
	icon_state = "fat"

/atom/movable/screen/alert/hunger/full
	name = "Full"
	desc = "You feel full and satisfied, but you shouldn't eat much more."
	icon_state = "full"

/atom/movable/screen/alert/hunger/well_fed
	name = "Well Fed"
	desc = "You feel quite satisfied, but you may be able to eat a bit more."
	icon_state = "well_fed"

/atom/movable/screen/alert/hunger/fed
	name = "Fed"
	desc = "You feel moderately satisfied, but a bit more food may not hurt."
	icon_state = "fed"

/atom/movable/screen/alert/hunger/hungry
	name = "Hungry"
	desc = "Some food would be good right about now."
	icon_state = "hungry"

/atom/movable/screen/alert/hunger/starving
	name = "Starving"
	desc = "You're severely malnourished. The hunger pains make moving around a chore."
	icon_state = "starving"

/// Machine "hunger"

/atom/movable/screen/alert/hunger/fat/machine
	name = "Over Charged"
	desc = "Your cell has excessive charge due to electrical shocks. Run around the station and spend some energy."

/atom/movable/screen/alert/hunger/full/machine
	name = "Full Charge"
	desc = "Your cell is at full charge. Might want to give APCs some space."

/atom/movable/screen/alert/hunger/well_fed/machine
	name = "High Charge"
	desc = "You're almost all charged, but could top up a bit more."

/atom/movable/screen/alert/hunger/fed/machine
	name = "Half Charge"
	desc = "You feel moderately charged, but a bit more juice couldn't hurt."

/atom/movable/screen/alert/hunger/hungry/machine
	name = "Low Charge"
	desc = "Could use a little charging right about now."

/atom/movable/screen/alert/hunger/starving/machine
	name = "Nearly Discharged"
	desc = "You're almost drained. The low power makes moving around a chore."

// End of Machine "hunger"
///Vampire "hunger"

/atom/movable/screen/alert/hunger/fat/vampire
	desc = "You somehow drank too much blood, lardass. Run around the station and lose some weight."

/atom/movable/screen/alert/hunger/full/vampire
	desc = "You feel full and satisfied, but you know you will thirst for more blood soon..."

/atom/movable/screen/alert/hunger/well_fed/vampire
	desc = "You feel quite satisfied, but you could do with a bit more blood."

/atom/movable/screen/alert/hunger/fed/vampire
	desc = "You feel moderately satisfied, but a bit more blood wouldn't hurt."

/atom/movable/screen/alert/hunger/hungry/vampire
	desc = "You currently thirst for blood."

/atom/movable/screen/alert/hunger/starving/vampire
	desc = "You're severely thirsty. The thirst pains make moving around a chore."

//End of Vampire "hunger"

/atom/movable/screen/alert/hot
	name = "Too Hot"
	desc = "You're flaming hot! Get somewhere cooler and take off any insulating clothing like a fire suit."
	icon_state = "hot"

/atom/movable/screen/alert/hot/robot
	desc = "The air around you is too hot for a humanoid. Be careful to avoid exposing them to this environment."

/atom/movable/screen/alert/cold
	name = "Too Cold"
	desc = "You're freezing cold! Get somewhere warmer and take off any insulating clothing like a space suit."
	icon_state = "cold"

/atom/movable/screen/alert/cold/drask
	name = "Cold"
	desc = "You're breathing supercooled gas! It's stimulating your metabolism to regenerate damaged tissue."

/atom/movable/screen/alert/cold/robot
	desc = "The air around you is too cold for a humanoid. Be careful to avoid exposing them to this environment."

/atom/movable/screen/alert/lowpressure
	name = "Low Pressure"
	desc = "The air around you is hazardously thin. A space suit would protect you."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "High Pressure"
	desc = "The air around you is hazardously thick. A fire suit would protect you."
	icon_state = "highpressure"

/atom/movable/screen/alert/lightexposure
	name = "Light Exposure"
	desc = "You're exposed to light."
	icon_state = "lightexposure"

/atom/movable/screen/alert/nolight
	name = "No Light"
	desc = "You're not exposed to any light."
	icon_state = "nolight"

/atom/movable/screen/alert/blind
	name = "Blind"
	desc = "You can't see! This may be caused by a genetic defect, eye trauma, being unconscious, \
or something covering your eyes."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "High"
	desc = "Whoa man, you're tripping balls! Careful you don't get addicted... if you aren't already."
	icon_state = "high"

/atom/movable/screen/alert/drunk
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, motor skills, and mental cognition."
	icon_state = "drunk"

/atom/movable/screen/alert/embeddedobject
	name = "Embedded Object"
	desc = "Something got lodged into your flesh and is causing major bleeding. It might fall out with time, but surgery is the safest way. \
			If you're feeling frisky, click yourself in help intent to pull the object out."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/embeddedobject/Click()
	if(isliving(usr) && ..())
		var/mob/living/carbon/human/M = usr
		return M.help_shake_act(M)

/atom/movable/screen/alert/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

/atom/movable/screen/alert/weightless
	name = "Weightless"
	desc = "Gravity has ceased affecting you, and you're floating around aimlessly. You'll need something large and heavy, like a \
wall or lattice, to push yourself off if you want to move. A jetpack would enable free range of motion. A pair of \
magboots would let you walk around normally on the floor. Barring those, you can throw things, use a fire extinguisher, \
or shoot a gun to move around via Newton's 3rd Law of Motion."
	icon_state = "weightless"

/atom/movable/screen/alert/fire
	name = "On Fire"
	desc = "You're on fire. Stop, drop and roll to put the fire out or move to a vacuum area."
	icon_state = "fire"

/atom/movable/screen/alert/fire/Click()
	if(isliving(usr) && ..())
		var/mob/living/L = usr
		return L.resist()

/atom/movable/screen/alert/direction_lock
	name = "Direction Lock"
	desc = "You are facing only one direction, slowing your movement down. Click here to stop the direction lock."
	icon_state = "direction_lock"

/atom/movable/screen/alert/direction_lock/Click()
	if(isliving(usr) && ..())
		var/mob/living/L = usr
		return L.clear_forced_look()

//Constructs
/atom/movable/screen/alert/holy_fire
	name = "Holy Fire"
	desc = "Your body is crumbling from the holy energies. Get out."
	icon_state = "fire"

//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Plasma"
	desc = "There's flammable plasma in the air. If it lights up, you'll be toast."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Too Hot"
	desc = "It's too hot! Flee to space or at least away from the flames. Standing on weeds will heal you."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Severed Matriarchy"
	desc = "Your queen has been killed, you will suffer movement penalties and loss of hivemind. A new queen cannot be made until you recover."
	icon_state = "alien_noqueen"
	alerttooltipstyle = "alien"

//BLOBS

/atom/movable/screen/alert/nofactory
	name = "No Factory"
	desc = "You have no factory, and are slowly dying!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Missing Power Cell"
	desc = "Unit has no power cell. No modules available until a power cell is reinstalled. Robotics may provide assistance."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Out of Power"
	desc = "Unit's power cell has no charge remaining. No modules available until power cell is recharged. \
Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Low Charge"
	desc = "Unit's power cell is running low. Recharging stations are available in robotics, the dormitory bathrooms, and the AI satellite."
	icon_state = "lowcell"

//Diona Nymph
/atom/movable/screen/alert/nymph
	name = "Gestalt merge"
	desc = "You have merged with a diona gestalt and are now part of it's biomass. You can still wiggle yourself free though."

/atom/movable/screen/alert/nymph/Click()
	if(!..())
		return
	if(isnymph(usr))
		var/mob/living/basic/diona_nymph/D = usr
		return D.resist()

/atom/movable/screen/alert/gestalt
	name = "Merged nymph"
	desc = "You have merged with one or more diona nymphs. Click here to drop it (or one of them)."

/atom/movable/screen/alert/gestalt/Click()
	if(!..())
		return

	var/list/nymphs = list()
	for(var/mob/living/basic/diona_nymph/D in usr.contents)
		nymphs += D

	if(length(nymphs) == 1)
		var/mob/living/basic/diona_nymph/D = nymphs[1]
		D.split(TRUE)
	else
		var/mob/living/basic/diona_nymph/D = tgui_input_list(usr, "Select a nymph to drop:", "Nymph Dropping", nymphs)
		if(D in usr.contents)
			D.split(TRUE)

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Hacked"
	desc = "Hazardous non-standard equipment detected. Please ensure any usage of this equipment is in line with unit's laws, if any."
	icon_state = "hacked"

/atom/movable/screen/alert/locked
	name = "Locked Down"
	desc = "Unit has been remotely locked down. Usage of a Robotics Control Console like the one in the Research Director's \
office by your AI master or any qualified human may resolve this matter. Robotics may provide further assistance if necessary."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Law Update"
	desc = "Laws have potentially been uploaded to or removed from this unit. Please be aware of any changes \
so as to remain in compliance with the most up-to-date laws."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/hackingapc
	name = "Hacking APC"
	desc = "An Area Power Controller is being hacked. When the process is \
		complete, you will have exclusive control of it, and you will gain \
		additional processing time to unlock more malfunction abilities."
	icon_state = "hackingapc"
	timeout = 600
	var/atom/target = null

/atom/movable/screen/alert/programs_reset
	name = "Programs Reset"
	desc = "Your programs have been reset by a Program Reset Disk!"
	icon_state = "silicon_generic_alert"
	timeout = 30 SECONDS

/atom/movable/screen/alert/hackingapc/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/hackingapc/Click()
	if(!..())
		return
	if(!target)
		return
	var/mob/living/silicon/ai/AI = usr
	var/turf/T = get_turf(target)
	if(T)
		AI.eyeobj.set_loc(T)

//MECHS
/atom/movable/screen/alert/low_mech_integrity
	name = "Mech Damaged"
	desc = "Mech integrity is low."
	icon_state = "low_mech_integrity"

/atom/movable/screen/alert/mech_port_available
	name = "Connect to Port"
	desc = "Click here to connect to an air port and refill your oxygen!"
	icon_state = "mech_port"
	var/obj/machinery/atmospherics/unary/portables_connector/target = null

/atom/movable/screen/alert/mech_port_available/Destroy()
	target = null
	return ..()

/atom/movable/screen/alert/mech_port_available/Click()
	if(!..())
		return
	if(!ismecha(usr.loc) || !target)
		return
	var/obj/mecha/M = usr.loc
	if(M.connect(target))
		to_chat(usr, "<span class='notice'>[M] connects to the port.</span>")
	else
		to_chat(usr, "<span class='notice'>[M] failed to connect to the port.</span>")

/atom/movable/screen/alert/mech_port_disconnect
	name = "Disconnect from Port"
	desc = "Click here to disconnect from your air port."
	icon_state = "mech_port_x"

/atom/movable/screen/alert/mech_port_disconnect/Click()
	if(!..())
		return
	if(!ismecha(usr.loc))
		return
	var/obj/mecha/M = usr.loc
	if(M.disconnect())
		to_chat(usr, "<span class='notice'>[M] disconnects from the port.</span>")
	else
		to_chat(usr, "<span class='notice'>[M] is not connected to a port at the moment.</span>")

/atom/movable/screen/alert/mech_nocell
	name = "Missing Power Cell"
	desc = "Mech has no power cell."
	icon_state = "nocell"

/atom/movable/screen/alert/mech_emptycell
	name = "Out of Power"
	desc = "Mech is out of power."
	icon_state = "emptycell"

/atom/movable/screen/alert/mech_lowcell
	name = "Low Charge"
	desc = "Mech is running out of power."
	icon_state = "lowcell"

/atom/movable/screen/alert/mech_maintenance
	name = "Maintenance Protocols"
	desc = "Maintenance protocols are currently in effect, most actions disabled."
	icon_state = "locked"

//GUARDIANS
/atom/movable/screen/alert/cancharge
	name = "Charge Ready"
	desc = "You are ready to charge at a location!"
	icon_state = "guardian_charge"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/canstealth
	name = "Stealth Ready"
	desc = "You are ready to enter stealth!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/instealth
	name = "In Stealth"
	desc = "You are in stealth and your next attack will do bonus damage!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/notify_cloning
	name = "Revival"
	desc = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!"
	icon_state = "template"
	timeout = 300

/atom/movable/screen/alert/notify_cloning/Click()
	if(!..())
		return
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/alert/ghost
	name = "Ghost"
	desc = "Would you like to ghost?"
	icon_state = "template"
	timeout = 5 MINUTES

/atom/movable/screen/alert/ghost/Initialize(mapload)
	. = ..()
	var/image/I = image('icons/mob/mob.dmi', icon_state = "ghost", layer = FLOAT_LAYER, dir = SOUTH)
	I.layer = FLOAT_LAYER
	I.plane = FLOAT_PLANE
	overlays += I

/atom/movable/screen/alert/ghost/proc/handle_ghosting(mob/living/carbon/human/target)
	target.ghost()

/atom/movable/screen/alert/ghost/Click()
	if(!..())
		return
	handle_ghosting(usr)

/atom/movable/screen/alert/ghost/cryo
	desc = "Would you like to ghost? Your body will automatically be moved into cryostorage."

/atom/movable/screen/alert/ghost/xeno
	desc = "Would you like to ghost? You will be notified when your body is removed from the nest."

/atom/movable/screen/alert/ghost/xeno/Click()
	if(!..())
		return
	var/mob/living/carbon/human/infected_user = usr
	if(!istype(infected_user) || infected_user.stat == DEAD)
		infected_user.clear_alert("ghost_nest")
		return
	var/obj/item/clothing/mask/facehugger/hugger_mask = infected_user.wear_mask
	if(!istype(hugger_mask) || !(locate(/obj/item/organ/internal/body_egg/alien_embryo) in infected_user.internal_organs) || hugger_mask.sterile)
		infected_user.clear_alert("ghost_nest")
		return
	infected_user.ghostize()

/atom/movable/screen/alert/notify_action
	name = "Body created"
	desc = "A body was created. You can enter it."
	icon_state = "template"
	timeout = 300
	var/atom/target = null
	var/action = NOTIFY_JUMP
	var/show_time_left = FALSE // If true you need to call START_PROCESSING manually
	var/image/time_left_overlay // The last image showing the time left
	var/image/signed_up_overlay // image showing that you're signed up
	var/datum/candidate_poll/poll // If set, on Click() it'll register the player as a candidate

/atom/movable/screen/alert/notify_action/process()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL

		if(time_left_overlay)
			overlays -= time_left_overlay

		var/obj/O = new
		O.maptext = "<span style='font-family: \"Small Fonts\"; font-weight: bold; font-size: 32px; color: [(timeleft <= 10 SECONDS) ? "red" : "white"];'>[CEILING(timeleft / 10, 1)]</span>"
		O.maptext_width = O.maptext_height = 128
		var/matrix/M = new
		M.Translate(4, 16)
		O.transform = M

		var/image/I = image(O)
		I.layer = FLOAT_LAYER
		I.plane = FLOAT_PLANE + 1
		overlays += I

		time_left_overlay = I
		qdel(O)
	..()

/atom/movable/screen/alert/notify_action/Destroy()
	target = null
	if(signed_up_overlay)
		overlays -= signed_up_overlay
		qdel(signed_up_overlay)
	return ..()

/atom/movable/screen/alert/notify_action/Click()
	if(!..())
		return
	var/mob/dead/observer/G = usr

	if(poll)
		var/success
		if(G in poll.signed_up)
			success = poll.remove_candidate(G)
		else
			success = poll.sign_up(G)
		if(success)
			// Add a small overlay to indicate we've signed up
			update_signed_up_alert(usr)
	else if(target)
		switch(action)
			if(NOTIFY_ATTACK)
				target.attack_ghost(G)
			if(NOTIFY_JUMP)
				var/turf/T = get_turf(target)
				if(T && isturf(T))
					if(!istype(G))
						var/mob/dead/observer/actual_ghost = G.ghostize()
						actual_ghost.forceMove(T)
						return
					G.forceMove(T)
			if(NOTIFY_FOLLOW)
				if(!istype(G))
					var/mob/dead/observer/actual_ghost = G.ghostize()
					actual_ghost.manual_follow(target)
					return
				G.manual_follow(target)

/atom/movable/screen/alert/notify_action/Topic(href, href_list)
	if(!href_list["signup"])
		return
	if(!poll)
		return
	var/mob/dead/observer/G = usr
	if(G in poll.signed_up)
		poll.remove_candidate(G)
	else
		poll.sign_up(G)
	update_signed_up_alert(G)

/atom/movable/screen/alert/notify_action/proc/update_signed_up_alert(mob/user)
	if(!signed_up_overlay)
		signed_up_overlay = image('icons/mob/screen_gen.dmi', icon_state = "selector")
		signed_up_overlay.layer = FLOAT_LAYER
		signed_up_overlay.plane = FLOAT_PLANE + 2
	if(user in poll.signed_up)
		overlays += signed_up_overlay
	else
		overlays -= signed_up_overlay

/atom/movable/screen/alert/notify_action/proc/display_stacks(stacks = 1)
	if(stacks <= 1)
		return

	var/obj/O = new
	O.maptext = "<span style='font-family: \"Small Fonts\"; font-size: 32px; color: yellow;'>[stacks]x</span>"
	O.maptext_width = O.maptext_height = 128
	var/matrix/M = new
	M.Translate(4, 2)
	O.transform = M

	var/image/I = image(O)
	I.layer = FLOAT_LAYER
	I.plane = FLOAT_PLANE + 1
	overlays += I

	qdel(O)

/atom/movable/screen/alert/notify_soulstone
	name = "Soul Stone"
	desc = "Someone is trying to capture your soul in a soul stone. Click to allow it."
	icon_state = "template"
	timeout = 10 SECONDS
	var/obj/item/soulstone/stone = null
	var/stoner = null

/atom/movable/screen/alert/notify_soulstone/Click()
	if(!..())
		return
	if(stone)
		if(tgui_alert(usr, "Do you want to be captured by [stoner]'s soul stone? This will destroy your corpse and make it \
		impossible for you to get back into the game as your regular character.", "Respawn", list("No", "Yes")) ==  "Yes")
			stone?.opt_in = TRUE

/atom/movable/screen/alert/notify_soulstone/Destroy()
	stone = null
	return ..()

/atom/movable/screen/alert/notify_mapvote
	name = "Map Vote"
	desc = "Vote on which map you would like to play on next!"
	icon_state = "map_vote"

/atom/movable/screen/alert/notify_mapvote/Click()
	// ehh sure let observers click on it if they really want, who cares
	usr.client.vote()

//OBJECT-BASED

/atom/movable/screen/alert/restrained/buckled
	name = "Buckled"
	desc = "You've been buckled to something. Click the alert to unbuckle unless you're handcuffed."
	icon_state = "buckled"

/atom/movable/screen/alert/restrained/handcuffed
	name = "Handcuffed"
	desc = "You're handcuffed and can't act. If anyone drags you, you won't be able to move. Click the alert to free yourself."

/atom/movable/screen/alert/restrained/legcuffed
	name = "Legcuffed"
	desc = "You're legcuffed, which slows you down considerably. Click the alert to free yourself."

/atom/movable/screen/alert/restrained/cryocell
	name = "Cryogenics"
	desc = "You're inside a freezing cold medical cell. Click the alert to free yourself."
	icon_state = "asleep"

/atom/movable/screen/alert/restrained/Click()
	if(!isliving(usr) || !..())
		return
	var/mob/living/L = usr
	return L.resist()

/atom/movable/screen/alert/restrained/buckled/Click()
	if(!isliving(usr) || !..())
		return
	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist())
		return
	L.changeNext_move(CLICK_CD_RESIST)
	return L.resist_buckle()

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return
	var/list/alerts = mymob.alerts
	if(!alerts)
		return FALSE
	var/icon_pref
	if(!hud_shown)
		for(var/i in 1 to length(alerts))
			screenmob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i in 1 to length(alerts))
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(!icon_pref)
				icon_pref = ui_style2icon(screenmob.client.prefs.UI_style)
			alert.icon = icon_pref
		switch(i)
			if(1)
				. = UI_ALERT1
			if(2)
				. = UI_ALERT2
			if(3)
				. = UI_ALERT3
			if(4)
				. = UI_ALERT4
			if(5)
				. = UI_ALERT5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		screenmob.client.screen |= alert
	if(!viewmob)
		for(var/viewer in mymob.observers)
			reorganize_alerts(viewer)
	return TRUE


/// Gives the player the option to succumb while in critical condition
/atom/movable/screen/alert/succumb
	name = "Succumb"
	desc = "Shuffle off this mortal coil."
	icon_state = "succumb"

/atom/movable/screen/alert/succumb/Click()
	if(!..())
		return
	var/mob/living/living_owner = usr
	if(!istype(usr))
		return
	living_owner.do_succumb(TRUE)

/atom/movable/screen/alert/changeling_defib_revive
	name = "Your heart is being defibrillated."
	desc = "Click this status to be revived from fake death."
	icon_state = "template"
	timeout = 10 SECONDS
	var/do_we_revive = FALSE
	var/image/toggle_overlay

/atom/movable/screen/alert/changeling_defib_revive/Initialize(mapload, parent_unit)
	. = ..()
	var/image/defib_appearance = image(parent_unit)
	defib_appearance.layer = FLOAT_LAYER
	defib_appearance.plane = FLOAT_PLANE
	overlays += defib_appearance

/atom/movable/screen/alert/changeling_defib_revive/attach_owner(mob/new_owner)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_DEFIBBED, PROC_REF(on_defib_revive))

/atom/movable/screen/alert/changeling_defib_revive/Destroy()
	if(owner)
		UnregisterSignal(owner, COMSIG_LIVING_DEFIBBED)
	if(toggle_overlay)
		overlays -= toggle_overlay
		qdel(toggle_overlay)
	return ..()

/atom/movable/screen/alert/changeling_defib_revive/Click()
	if(!..())
		return
	do_we_revive = !do_we_revive
	if(!toggle_overlay)
		toggle_overlay = image('icons/mob/screen_gen.dmi', icon_state = "selector")
		toggle_overlay.layer = FLOAT_LAYER
		toggle_overlay.plane = FLOAT_PLANE + 2
	if(do_we_revive)
		overlays |= toggle_overlay
	else
		overlays -= toggle_overlay

/atom/movable/screen/alert/changeling_defib_revive/proc/on_defib_revive()
	. = COMPONENT_DEFIB_FAKEDEATH_DENIED
	if(do_we_revive)
		var/datum/antagonist/changeling/cling = owner.mind.has_antag_datum(/datum/antagonist/changeling)
		cling.remove_specific_power(/datum/action/changeling/revive)
		cling.regenerating = FALSE
		var/heart_name = "heart"
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			var/datum/organ/heart/heart = C.get_int_organ_datum(ORGAN_DATUM_HEART)
			heart_name = heart.linked_organ.name
		to_chat(owner, "<span class='danger'>Electricity flows through our [heart_name]! We have been brought back to life and have stopped our regeneration.</span>")
		. = COMPONENT_DEFIB_FAKEDEATH_ACCEPTED
	owner.clear_alert("cling_defib")
