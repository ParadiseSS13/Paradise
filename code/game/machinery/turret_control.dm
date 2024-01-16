////////////////////////
//Turret Control Panel//
////////////////////////

/area
	// Turrets use this list to see if individual power/lethal settings are allowed
	var/list/turret_controls = list()

/obj/machinery/turretid
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/enabled = FALSE
	var/lethal = FALSE
	var/lethal_is_configurable = TRUE
	var/locked = TRUE
	var/area/control_area //can be area name, path or nothing.

	var/targetting_is_configurable = TRUE // if false, you cannot change who this turret attacks via its UI
	var/check_arrest = TRUE	//checks if the perp is set to arrest
	var/check_records = TRUE	//checks if a security record exists at all
	var/check_weapons = FALSE	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = TRUE	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = TRUE	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_synth = FALSE 	//if active, will shoot at anything not an AI or cyborg
	var/check_borgs = FALSE //if TRUE, target all cyborgs.
	var/ailock = FALSE 	//Silicons cannot use this

	var/syndicate = FALSE
	var/faction = "" // Turret controls can only access turrets that are in the same faction

	req_access = list(ACCESS_AI_UPLOAD)

/obj/machinery/turretid/stun
	enabled = TRUE
	icon_state = "control_stun"

/obj/machinery/turretid/lethal
	enabled = TRUE
	lethal = TRUE
	icon_state = "control_kill"

/obj/machinery/turretid/syndicate
	enabled = TRUE
	lethal = TRUE
	lethal_is_configurable = FALSE
	targetting_is_configurable = FALSE
	icon_state = "control_kill"

	check_arrest = FALSE
	check_records = FALSE
	check_weapons = FALSE
	check_access = FALSE
	check_anomalies = TRUE
	check_synth	= TRUE
	check_borgs = FALSE
	ailock = TRUE

	syndicate = TRUE
	faction = "syndicate"
	req_access = list(ACCESS_SYNDICATE_LEADER)

/obj/machinery/turretid/Destroy()
	if(control_area)
		var/area/A = control_area
		if(A && istype(A))
			A.turret_controls -= src
	return ..()

/obj/machinery/turretid/Initialize()
	..()
	if(!control_area)
		control_area = get_area(src)
	else if(istext(control_area))
		for(var/area/A in world)
			if(A.name && A.name == control_area)
				control_area = A
				break

	if(control_area)
		var/area/A = control_area
		if(istype(A))
			A.turret_controls += src
		else
			control_area = null

	updateTurrets()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/turretid/proc/isLocked(mob/user)
	if(isrobot(user) || isAI(user))
		if(ailock)
			to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
			return TRUE
		else
			return FALSE

	if(isobserver(user))
		if(user.can_admin_interact())
			return FALSE
		else
			return TRUE

	if(locked)
		return TRUE

	return FALSE

/obj/machinery/turretid/attackby(obj/item/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(src.allowed(usr))
			if(emagged)
				to_chat(user, "<span class='notice'>The turret control is unresponsive.</span>")
			else
				locked = !locked
				to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>")
		return
	return ..()

/obj/machinery/turretid/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='danger'>You short out the turret controls' access analysis module.</span>")
		emagged = TRUE
		locked = FALSE
		ailock = FALSE
		return

/obj/machinery/turretid/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/turretid/attack_ghost(mob/user as mob)
	ui_interact(user)

/obj/machinery/turretid/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/turretid/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PortableTurret", name, 500, 400)
		ui.open()

/obj/machinery/turretid/ui_data(mob/user)
	var/list/data = list(
		"locked" = isLocked(user), // does the current user have access?
		"on" = enabled,
		"targetting_is_configurable" = targetting_is_configurable, // If false, targetting settings don't show up
		"lethal" = lethal,
		"lethal_is_configurable" = lethal_is_configurable,
		"check_weapons" = check_weapons,
		"neutralize_noaccess" = check_access,
		"one_access" = FALSE,
		"selectedAccess" = list(),
		"access_is_configurable" = FALSE,
		"neutralize_norecord" = check_records,
		"neutralize_criminals" = check_arrest,
		"neutralize_all" = check_synth,
		"neutralize_unidentified" = check_anomalies,
		"neutralize_cyborgs" = check_borgs
	)
	return data

/obj/machinery/turretid/ui_act(action, params)
	if(..())
		return
	if(isLocked(usr))
		return
	. = TRUE
	switch(action)
		if("power")
			enabled = !enabled
		if("lethal")
			if(lethal_is_configurable)
				lethal = !lethal
	if(targetting_is_configurable)
		switch(action)
			if("authweapon")
				check_weapons = !check_weapons
			if("authaccess")
				check_access = !check_access
			if("authnorecord")
				check_records = !check_records
			if("autharrest")
				check_arrest = !check_arrest
			if("authxeno")
				check_anomalies = !check_anomalies
			if("authsynth")
				check_synth = !check_synth
			if("authborgs")
				check_borgs = !check_borgs
	updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	var/datum/turret_checks/TC = new
	TC.enabled = enabled
	TC.lethal = lethal
	TC.check_synth = check_synth
	TC.check_borgs = check_borgs
	TC.check_access = check_access
	TC.check_records = check_records
	TC.check_arrest = check_arrest
	TC.check_weapons = check_weapons
	TC.check_anomalies = check_anomalies
	TC.ailock = ailock

	if(istype(control_area))
		for(var/obj/machinery/porta_turret/aTurret in control_area)
			if(faction == aTurret.faction)
				aTurret.setState(TC)

	update_icon(UPDATE_ICON_STATE)

/obj/machinery/turretid/power_change()
	if(!..())
		return
	updateTurrets()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/turretid/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "control_off"
		set_light(0)
	else if(enabled)
		if(lethal)
			icon_state = "control_kill"
			set_light(1.5, 1,"#990000")
		else
			icon_state = "control_stun"
			set_light(1.5, 1,"#FF9900")
	else
		icon_state = "control_standby"
		set_light(1.5, 1,"#003300")

/obj/machinery/turretid/emp_act(severity)
	if(enabled)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect

		check_arrest = prob(50)
		check_records = prob(50)
		check_weapons = prob(50)
		check_access = prob(20)	// check_access is a pretty big deal, so it's least likely to get turned on
		check_anomalies = prob(50)

		enabled=0
		updateTurrets()

		spawn(rand(60,600))
			if(!enabled)
				enabled=1
				updateTurrets()

	..()
