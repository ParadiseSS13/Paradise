GLOBAL_LIST_EMPTY(remote_signalers)

/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices."
	icon_state = "signaller"
	item_state = "signaler"
	materials = list(MAT_METAL=400, MAT_GLASS=120)
	origin_tech = "magnets=1;bluespace=1"
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	secured = TRUE
	bomb_name = "remote-control bomb"
	/// Are we set to receieve a signal?
	var/receiving = FALSE
	/// Signal code
	var/code = 30
	/// Signal freqency itself
	var/frequency = RSD_FREQ

/obj/item/assembly/signaler/Initialize()
	. = ..()
	GLOB.remote_signalers |= src

/obj/item/assembly/signaler/Destroy()
	GLOB.remote_signalers -= src
	return ..()

/obj/item/assembly/signaler/examine(mob/user)
	. = ..()
	. += "The power light is [receiving ? "on" : "off"]"

/// Called from activate(), actually invokes the signal on other signallers in the world
/obj/item/assembly/signaler/proc/signal()
	for(var/obj/item/assembly/signaler/S as anything in GLOB.remote_signalers)
		if(S == src)
			continue
		if(S.receiving && (S.code == code) && (S.frequency == frequency))
			S.signal_callback()

	var/turf/T = get_turf(src)
	var/invoking_ckey = "unknown"
	if(usr) // sometimes (like when a prox sensor sends a signal) there is no usr
		invoking_ckey = usr.key
	GLOB.lastsignalers.Add("[SQLtime()] <b>:</b> [invoking_ckey] used [src] @ location ([T.x],[T.y],[T.z]) <b>:</b> [format_frequency(frequency)]/[code]")

/obj/item/assembly/signaler/proc/signal_callback()
	pulse(1)
	visible_message("[bicon(src)] *beep* *beep*")

// Activation pre-runner, handles cooldown and calls signal(), invoked from ui_act()
/obj/item/assembly/signaler/activate()
	if(cooldown > 0)
		return

	cooldown = 2
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 1 SECONDS)

	signal()

/obj/item/assembly/signaler/update_icon_state()
	if(holder)
		holder.update_icon()

// UI STUFF //

/obj/item/assembly/signaler/attack_self(mob/user)
	ui_interact(user)

/obj/item/assembly/signaler/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.deep_inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RemoteSignaler", name, 300, 200, master_ui, state)
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["on"] = receiving
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	return data

/obj/item/assembly/signaler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("recv_power")
			receiving = !receiving

		if("signal")
			activate()

		if("freq")
			frequency = sanitize_frequency(text2num(params["freq"]) * 10)

		if("code")
			code = clamp(text2num(params["code"]), 1, 100)

