//update_state
#define UPSTATE_CELL_IN		(1<<0)
#define UPSTATE_OPENED1		(1<<1)
#define UPSTATE_OPENED2		(1<<2)
#define UPSTATE_MAINT		(1<<3)
#define UPSTATE_BROKE		(1<<4)
#define UPSTATE_BLUESCREEN	(1<<5)
#define UPSTATE_WIREEXP		(1<<6)
#define UPSTATE_ALLGOOD		(1<<7)





//update_overlay
#define APC_UPOVERLAY_CHARGEING0	(1<<0)
#define APC_UPOVERLAY_CHARGEING1	(1<<1)
#define APC_UPOVERLAY_CHARGEING2	(1<<2)
#define APC_UPOVERLAY_EQUIPMENT0	(1<<3)
#define APC_UPOVERLAY_EQUIPMENT1	(1<<4)
#define APC_UPOVERLAY_EQUIPMENT2	(1<<5)
#define APC_UPOVERLAY_LIGHTING0		(1<<6)
#define APC_UPOVERLAY_LIGHTING1		(1<<7)
#define APC_UPOVERLAY_LIGHTING2		(1<<8)
#define APC_UPOVERLAY_ENVIRON0		(1<<9)
#define APC_UPOVERLAY_ENVIRON1		(1<<10)
#define APC_UPOVERLAY_ENVIRON2		(1<<11)
#define APC_UPOVERLAY_LOCKED		(1<<12)

#define APC_UPDATE_ICON_COOLDOWN 20 SECONDS // 20 seconds

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon(force_update = FALSE)

	if(!status_overlays || force_update)
		status_overlays = TRUE
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")

	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update && !force_update)
		return

	if(force_update || update & 1) // Updating the icon state
		..(UPDATE_ICON_STATE)

	if(!(update_state & UPSTATE_ALLGOOD))
		if(managed_overlays)
			..(UPDATE_OVERLAYS)
		return

	if(force_update || update & 2)
		..(UPDATE_OVERLAYS)

/obj/machinery/power/apc/update_icon_state()
	if(update_state & UPSTATE_ALLGOOD)
		icon_state = "apc0"
	else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[ cell ? "2" : "1" ]"
		if(update_state & UPSTATE_OPENED1)
			if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
				icon_state = "apcmaint" //disabled APC cannot hold cell
			else
				icon_state = basestate
		else if(update_state & UPSTATE_OPENED2)
			icon_state = "[basestate]-nocover"
	else if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
	else if(update_state & UPSTATE_BLUESCREEN)
		icon_state = "apcemag"
	else if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"

/obj/machinery/power/apc/update_overlays()
	. = ..()
	underlays.Cut()

	if(update_state & UPSTATE_BLUESCREEN)
		underlays += emissive_appearance(icon, "emit_apcemag")
		return
	if(!(update_state & UPSTATE_ALLGOOD))
		return

	if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
		var/image/statover_lock = status_overlays_lock[locked + 1]
		var/image/statover_charg = status_overlays_charging[charging + 1]
		. += statover_lock
		. += statover_charg
		underlays += emissive_appearance(icon, statover_lock.icon_state)
		underlays += emissive_appearance(icon, statover_charg.icon_state)
		if(operating)
			var/image/statover_equip = status_overlays_equipment[equipment_channel + 1]
			var/image/statover_light = status_overlays_lighting[lighting_channel + 1]
			var/image/statover_envir = status_overlays_environ[environment_channel + 1]
			. += statover_equip
			. += statover_light
			. += statover_envir
			underlays += emissive_appearance(icon, statover_equip.icon_state)
			underlays += emissive_appearance(icon, statover_light.icon_state)
			underlays += emissive_appearance(icon, statover_envir.icon_state)

/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = NONE
	update_overlay = NONE

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened == APC_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened == APC_COVER_OFF)
			update_state |= UPSTATE_OPENED2
	else if(emagged || malfai || being_hijacked || hacked_by_ruin_AI)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(charging == APC_NOT_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_IS_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if(!equipment_channel)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment_channel == APC_CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment_channel == APC_CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting_channel)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting_channel == APC_CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting_channel == APC_CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environment_channel)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environment_channel == APC_CHANNEL_SETTING_AUTO_OFF)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environment_channel == APC_CHANNEL_SETTING_ON)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()

	if(!updating_icon)
		updating_icon = TRUE
		// Start the update
		spawn(APC_UPDATE_ICON_COOLDOWN)
			update_icon()
			updating_icon = FALSE

/obj/machinery/power/apc/flicker(second_pass = FALSE)
	if(opened || panel_open)
		return FALSE
	if(stat & (NOPOWER | BROKEN))
		return FALSE
	if(!second_pass) //The first time, we just cut overlays
		addtimer(CALLBACK(src, PROC_REF(flicker), TRUE), 1)
		cut_overlays()
		managed_overlays = null
	else
		flick("apcemag", src) //Second time we cause the APC to update its icon, then add a timer to update icon later
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), TRUE), 10)

	return TRUE

#undef APC_UPDATE_ICON_COOLDOWN

#undef UPSTATE_CELL_IN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD
#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
