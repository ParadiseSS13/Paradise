/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "APC", name, 510, 460, master_ui, state)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = is_locked(user)
	data["normallyLocked"] = locked
	data["isOperating"] = operating
	data["externalPower"] = main_status
	data["powerCellStatus"] = cell ? cell.percent() : null
	data["chargeMode"] = chargemode
	data["chargingStatus"] = charging
	data["totalLoad"] = round(last_used_equipment + last_used_lighting + last_used_environment)
	data["coverLocked"] = coverlocked
	data["siliconUser"] = issilicon(user)
	data["siliconLock"] = locked
	data["malfStatus"] = get_malf_status(user)
	data["nightshiftLights"] = nightshift_lights
	data["emergencyLights"] = !emergency_lights

	var/list/power_channels = list()
	power_channels += list(list(
		"title" = "Equipment",
		"powerLoad" = round(last_used_equipment),
		"status" = equipment_channel,
		"topicParams" = list(
			"auto" = list("eqp" = 3),
			"on"   = list("eqp" = 2),
			"off"  = list("eqp" = 1)
		)
	))
	power_channels += list(list(
		"title" = "Lighting",
		"powerLoad" = round(last_used_lighting),
		"status" = lighting_channel,
		"topicParams" = list(
			"auto" = list("lgt" = 3),
			"on"   = list("lgt" = 2),
			"off"  = list("lgt" = 1)
		)
	))
	power_channels += list(list(
		"title" = "Environment",
		"powerLoad" = round(last_used_environment),
		"status" = environment_channel,
		"topicParams" = list(
			"auto" = list("env" = 3),
			"on"   = list("env" = 2),
			"off"  = list("env" = 1)
		)
	))

	data["powerChannels"] = power_channels

	return data

/obj/machinery/power/apc/ui_act(action, params, datum/tgui/ui)
	var/mob/user = ui.user
	if(..() || !can_use(user, TRUE))
		return
	if(locked && !user.has_unlimited_silicon_privilege && action != "toggle_nightshift" && !user.can_admin_interact())
		return
	. = TRUE
	switch(action)
		if("lock")
			if(user.has_unlimited_silicon_privilege)
				if(emagged || stat & BROKEN)
					to_chat(user, "<span class='warning'>The APC does not respond to the command!</span>")
					return FALSE
				else
					locked = !locked
					update_icon()
			else
				to_chat(user, "<span class='warning'>Access Denied!</span>")
				return FALSE
		if("cover")
			coverlocked = !coverlocked
		if("breaker")
			toggle_breaker(user)
		if("toggle_nightshift")
			if(last_nightshift_switch > world.time + 100) // don't spam...
				to_chat(user, "<span class='warning'>[src]'s night lighting circuit breaker is still cycling!</span>")
				return FALSE
			last_nightshift_switch = world.time
			set_nightshift(!nightshift_lights)
		if("charge")
			chargemode = !chargemode
		if("channel")
			if(params["eqp"])
				equipment_channel = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting_channel = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environment_channel = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
		if("overload")
			if(user.has_unlimited_silicon_privilege)
				INVOKE_ASYNC(src, PROC_REF(overload_lighting))
		if("hack")
			if(get_malf_status(user))
				malfhack(user)
		if("occupy")
			if(get_malf_status(user))
				malfoccupy(usr)
		if("deoccupy")
			if(get_malf_status(user))
				malfvacate()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/L in apc_area)
				INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
				CHECK_TICK
