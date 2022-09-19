#define MAX_HEALTH_ACTIVATE 0
#define MIN_HEALTH_ACTIVATE -150

/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1;biotech=1"

	var/scanning = FALSE
	var/user_health
	var/alarm_health = MAX_HEALTH_ACTIVATE

/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return FALSE

/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/health/process()
	if(!scanning || !secured)
		return

	var/atom/A = src
	if(connected && connected.holder)
		A = connected.holder

	for(A, A && !ismob(A), A=A.loc); //??? wtf
	// like get_turf(), but for mobs.
	var/mob/living/M = A

	if(M)
		user_health = M.health
		if(user_health <= alarm_health)
			pulse()
			audible_message("[bicon(src)] *beep* *beep*")
			toggle_scan()

/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/assembly/health/attack_self(mob/user)
	ui_interact(user)

/obj/item/assembly/health/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.deep_inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "HealthSensor", name, 300, 140, master_ui, state)
		ui.open()

/obj/item/assembly/health/ui_data(mob/user)
	var/list/data = list()
	data["on"] = scanning
	data["alarm_health"] = alarm_health
	data["user_health"] = user_health
	data["maxHealth"] = MAX_HEALTH_ACTIVATE
	data["minHealth"] = MIN_HEALTH_ACTIVATE
	return data

/obj/item/assembly/health/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("scan_toggle")
			toggle_scan()

		if("alarm_health")
			alarm_health = clamp(text2num(params["alarm_health"]), MIN_HEALTH_ACTIVATE, MAX_HEALTH_ACTIVATE)

#undef MAX_HEALTH_ACTIVATE
#undef MIN_HEALTH_ACTIVATE
