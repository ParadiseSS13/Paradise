#define MAX_HEALTH_ACTIVATE 0
#define MIN_HEALTH_ACTIVATE -150

/obj/item/assembly/health
	name = "health sensor"
	desc = "Used for scanning and monitoring health."
	icon_state = "health"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1;biotech=1"

	/// Are we scanning our user's health?
	var/scanning = FALSE
	/// Our user's health
	var/user_health
	/// The health amount on which to activate
	var/alarm_health = MAX_HEALTH_ACTIVATE

/obj/item/assembly/health/activate()
	if(!..())
		return FALSE//Cooldown check
	toggle_scan()
	return FALSE

/obj/item/assembly/health/toggle_secure()
	secured = !secured
	if(secured && scanning)
		START_PROCESSING(SSobj, src)
	else
		scanning = FALSE
		user_health = null // Clear out the user data, we're no longer scanning
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/assembly/health/process()
	if(!scanning || !secured)
		STOP_PROCESSING(SSobj, src) // It should never reach here, but if it somehow does stop processing
		return

	var/atom/A = src
	if(connected && connected.holder)
		A = connected.holder

	for(A, A && !ismob(A), A = A.loc); // For A, check A exists and that its not a mob, if these are both true then set A to A.loc and repeat
	// like get_turf(), but for mobs.

	if(!isliving(A))
		user_health = null // We aint on a living thing, remove the previous data
		return

	var/mob/living/M = A
	user_health = M.health
	if(user_health <= alarm_health) // Its a health detector, not a death detector
		pulse()
		audible_message("[bicon(src)] *beep* *beep* *beep*")
		playsound(src, 'sound/machines/triple_beep.ogg', 40, extrarange = -10)
		toggle_scan()

/obj/item/assembly/health/pickup(mob/user)
	..()
	ADD_TRAIT(user, TRAIT_CAN_VIEW_HEALTH, "HEALTH[UID()]")

/obj/item/assembly/health/proc/toggle_scan()
	if(!secured)
		return FALSE
	scanning = !scanning
	if(scanning)
		START_PROCESSING(SSobj, src)
	else
		user_health = null // Clear out the user data, we're no longer scanning
		STOP_PROCESSING(SSobj, src)

/obj/item/assembly/health/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/assembly/health/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/assembly/health/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HealthSensor", name)
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
