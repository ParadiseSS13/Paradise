GLOBAL_LIST_EMPTY(remote_signalers)

/obj/item/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a signaler on another."
	icon_state = "signaler"
	materials = list(MAT_METAL = 400, MAT_GLASS = 120)
	origin_tech = "magnets=1;bluespace=1"
	wires = ASSEMBLY_WIRE_RECEIVE | ASSEMBLY_WIRE_PULSE | ASSEMBLY_WIRE_RADIO_PULSE | ASSEMBLY_WIRE_RADIO_RECEIVE
	bomb_name = "remote-control bomb"
	/// Are we set to receieve a signal?
	var/receiving = FALSE
	/// Signal code
	var/code = 30
	/// Signal freqency itself
	var/frequency = RSD_FREQ

/obj/item/assembly/signaler/Initialize(mapload)
	. = ..()
	GLOB.remote_signalers |= src

/obj/item/assembly/signaler/Destroy()
	GLOB.remote_signalers -= src
	return ..()

/obj/item/assembly/signaler/examine(mob/user)
	. = ..()
	. += "The power light is [receiving ? "on" : "off"]"
	. += "<span class='notice'>Alt+Click to send a signal.</span>"

/obj/item/assembly/signaler/AltClick(mob/user)
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	activate()

/obj/item/assembly/signaler/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			frequency = signaler2.frequency
			to_chat(user, "You transfer the frequency and code to [src].")
	return ..()

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
	investigate_log("[SQLtime()] <b>:</b> [invoking_ckey] used [src] @ location ([T.x],[T.y],[T.z]) <b>:</b> [format_frequency(frequency)]/[code]", "signalers")

/obj/item/assembly/signaler/proc/signal_callback()
	pulse(1)
	visible_message("[bicon(src)] *beep* *beep* *beep*")
	playsound(src, 'sound/machines/triple_beep.ogg', 40, extrarange = -10)

// Activation pre-runner, handles cooldown and calls signal(), invoked from ui_act()
/obj/item/assembly/signaler/activate()
	if(!..())
		return

	signal()

/obj/item/assembly/signaler/update_icon_state()
	if(holder)
		holder.update_icon()

// UI STUFF //

/obj/item/assembly/signaler/attack_self__legacy__attackchain(mob/user)
	ui_interact(user)

/obj/item/assembly/signaler/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RemoteSignaler", name)
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

