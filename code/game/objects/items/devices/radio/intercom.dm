/*
Intercom
Intercom electronics
*/

#define INTERCOM_FRAME		0
#define INTERCOM_UNWIRED	1
#define INTERCOM_READY		2

// TODO: This should probably be converted into machinery someday, so its not an anchored item on a wall
/obj/item/radio/intercom
	name = "station intercom"
	desc = "A reliable wall-mounted form of communication, even during local communication blackouts."
	icon_state = "intercom"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	flags = CONDUCT
	blocks_emissive = FALSE
	var/buildstage = 0
	var/custom_name
	var/wiresexposed = FALSE
	dog_fashion = null

/obj/item/radio/intercom/custom
	name = "station intercom (Custom)"
	custom_name = TRUE
	broadcasting = FALSE
	listening = FALSE

/obj/item/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	custom_name = TRUE
	frequency  = AIRLOCK_FREQ

/obj/item/radio/intercom/private
	name = "station intercom (Private)"
	custom_name = TRUE
	frequency = AI_FREQ

/obj/item/radio/intercom/command
	name = "station intercom (Command)"
	custom_name = TRUE
	frequency = COMM_FREQ

/obj/item/radio/intercom/specops
	name = "\improper Special Operations intercom"
	custom_name = TRUE
	frequency = ERT_FREQ

/obj/item/radio/intercom/department
	canhear_range = 5
	custom_name = TRUE
	broadcasting = FALSE
	listening = TRUE

/obj/item/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/radio/intercom/department/security
	name = "station intercom (Security)"
	frequency = SEC_I_FREQ

/obj/item/radio/intercom/New(turf/loc, direction, building = 2)
	. = ..()
	buildstage = building
	if(buildstage == INTERCOM_READY)
		update_operating_status()
	else
		if(direction)
			setDir(direction)
			set_pixel_offsets_from_dir(28, -28, 28, -28)
		wiresexposed = TRUE
		on = FALSE
	GLOB.global_intercoms.Add(src)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/item/radio/intercom/Initialize()
	. = ..()
	if(!custom_name)
		name = "station intercom"

/obj/item/radio/intercom/department/medbay/New()
	..()
	internal_channels = GLOB.default_medbay_channels.Copy()

/obj/item/radio/intercom/department/security/New()
	..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(ACCESS_SECURITY)
	)

/obj/item/radio/intercom/syndicate
	name = "illicit intercom"
	desc = "Talk through this. Evilly"
	frequency = SYND_FREQ
	syndiekey = new /obj/item/encryptionkey/syndicate/nukeops

/obj/item/radio/intercom/syndicate/New()
	..()
	internal_channels[num2text(SYND_FREQ)] = list(ACCESS_SYNDICATE)

/obj/item/radio/intercom/pirate
	name = "pirate radio intercom"
	desc = "You wouldn't steal a space shuttle. Piracy. It's a crime!"

/obj/item/radio/intercom/pirate/New()
	..()
	internal_channels.Cut()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(AI_FREQ)  = list(),
		num2text(COMM_FREQ)= list(),
		num2text(ENG_FREQ) = list(),
		num2text(MED_FREQ) = list(),
		num2text(MED_I_FREQ)=list(),
		num2text(SEC_FREQ) = list(),
		num2text(SEC_I_FREQ)=list(),
		num2text(SCI_FREQ) = list(),
		num2text(SUP_FREQ) = list(),
		num2text(SRV_FREQ) = list()
	)

/obj/item/radio/intercom/Destroy()
	GLOB.global_intercoms.Remove(src)
	return ..()

/obj/item/radio/intercom/set_frequency(new_frequency)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/radio/intercom/attack_ai(mob/user)
	add_hiddenprint(user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/attack_hand(mob/user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/receive_range(freq, level)
	if(!is_listening())
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		// TODO: Integrate radio with the space manager
		if(isnull(position) || !(position.z in level))
			return -1
	if(freq in SSradio.ANTAG_FREQS)
		if(!(syndiekey))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range

/obj/item/radio/intercom/interact(mob/user)
	b_stat = wiresexposed
	..()

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(INTERCOM_FRAME)
			. += "<span class='notice'>It is <i>bolted</i> onto the wall and the circuit slot is <b>empty</b>.</span>"
		if(INTERCOM_UNWIRED)
			. += "<span class='notice'>The circuit is <i>connected loosely</i> to its slot, but it also has space for <b>wiring</b>.</span>"
		if(INTERCOM_READY)
			if(wiresexposed)
				. += "<span class='notice'>The wiring could be <i>cut and removed</i> or panel could <b>screwed</b> closed.</span>"
			else
				. += "<span class='notice'>You can speak into it with :i while standing nearby.</span>"

/obj/item/radio/intercom/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/tape_roll)) //eww
		return
	else if(iscoil(W) && buildstage == INTERCOM_UNWIRED)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need more cable for this!</span>")
			return
		if(do_after(user, 10 * coil.toolspeed, target = src) && buildstage == INTERCOM_UNWIRED)
			coil.use(5)
			to_chat(user, "<span class='notice'>You wire [src]!</span>")
			buildstage = INTERCOM_READY
			on = TRUE
			update_icon(UPDATE_ICON_STATE)
			if(wires.is_all_cut())
				wires.cut_all() // Mend all wires (yes it works like this)
		return TRUE
	else if(istype(W,/obj/item/intercom_electronics) && buildstage == INTERCOM_FRAME)
		playsound(loc, W.usesound, 50, 1)
		if(do_after(user, 10 * W.toolspeed, target = src) && buildstage == INTERCOM_FRAME)
			qdel(W)
			to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
			buildstage = INTERCOM_UNWIRED
			update_icon(UPDATE_ICON_STATE)
		return TRUE

	return ..()

/obj/item/radio/intercom/crowbar_act(mob/user, obj/item/I)
	if(!(buildstage == INTERCOM_UNWIRED))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You begin removing the circuit board from [src]...</span>")
	if(!I.use_tool(src, user, 10, volume = I.tool_volume) || buildstage != INTERCOM_UNWIRED)
		return
	new /obj/item/intercom_electronics(loc)
	to_chat(user, "<span class='notice'>You pry out the circuit board from [src].</span>")
	buildstage = INTERCOM_FRAME
	update_icon(UPDATE_ICON)

/obj/item/radio/intercom/screwdriver_act(mob/user, obj/item/I)
	if(!(buildstage == INTERCOM_READY))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume) || buildstage != INTERCOM_READY)
		return
	user.set_machine(src)
	wiresexposed = !wiresexposed
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
		update_operating_status(FALSE)
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		update_operating_status()
	updateDialog()
	update_icon(UPDATE_ICON)

/obj/item/radio/intercom/wirecutter_act(mob/user, obj/item/I)
	if(!(buildstage == INTERCOM_READY && wiresexposed && wires.is_all_cut()))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(loc, 5)
	on = FALSE
	wiresexposed = TRUE
	buildstage = INTERCOM_UNWIRED
	update_icon(UPDATE_ICON)

/obj/item/radio/intercom/wrench_act(mob/user, obj/item/I)
	if(!(buildstage == INTERCOM_FRAME))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/intercom(loc)
	qdel(src)

/obj/item/radio/intercom/update_icon_state()
	switch(buildstage)
		if(INTERCOM_FRAME)
			icon_state = "intercom-frame"
		if(INTERCOM_UNWIRED)
			icon_state = "intercom-circuit"
		if(INTERCOM_READY)
			if(wiresexposed)
				icon_state = "intercom-wires"
			else
				icon_state = "intercom"

/obj/item/radio/intercom/update_overlays()
	. = ..()
	underlays.Cut()

	if(on && buildstage == INTERCOM_READY && !wiresexposed)
		underlays += emissive_appearance(icon, "intercom_lightmask")
		if(listening)
			. += "intercom-receiving"
		if(broadcasting)
			. += "intercom-transmitting" //these can probably be reduced down to one image but im not smart enough for that
		switch(frequency)
			if(AI_FREQ, BOT_FREQ) // just in case something like a sentient mulebot somehow gets the bot freq on the intercom (which would be pretty funny)
				. += "freq-aiprivate"
			if(ERT_FREQ, DTH_FREQ)
				. += "freq-special"
			if(COMM_FREQ)
				. += "freq-command"
			if(ENG_FREQ)
				. += "freq-engineering"
			if(MED_FREQ, MED_I_FREQ)
				. += "freq-medical"
			if(SEC_FREQ, SEC_I_FREQ)
				. += "freq-security"
			if(SCI_FREQ)
				. += "freq-science"
			if(SUP_FREQ)
				. += "freq-supply"
			if(SRV_FREQ)
				. += "freq-service"
			if(PROC_FREQ)
				. += "freq-proceedure"
			if(SYND_FREQ, SYNDTEAM_FREQ)
				. += "freq-syndicate"
			else
				. += "freq-common"

/obj/item/radio/intercom/proc/update_operating_status(on = TRUE)
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	if(on)
		RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, .proc/AreaPowerCheck)
	else
		UnregisterSignal(current_area, COMSIG_AREA_POWER_CHANGE)

/**
  * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
  *
  * Normally called after the intercom's area recieves the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
  * Arguments:
  *
  * source - the area that just had a power change.
  */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	var/area/current_area = get_area(src)
	if(!current_area)
		on = FALSE
		set_light(0)
	else
		on = current_area.powered(EQUIP) // set "on" to the equipment power status of our area.
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/item/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/radio/intercom/locked
	freqlock = TRUE
	custom_name = TRUE

/obj/item/radio/intercom/locked/ai_private
	name = "\improper AI intercom"
	frequency = AI_FREQ

/obj/item/radio/intercom/locked/confessional
	name = "confessional intercom"
	frequency = 1480

/obj/item/radio/intercom/locked/prison
	name = "\improper prison intercom"
	desc = "Talk through this. It looks like it has been modified to not broadcast."

/obj/item/radio/intercom/locked/prison/New()
	..()
	wires.cut(WIRE_RADIO_TRANSMIT)

#undef INTERCOM_FRAME
#undef INTERCOM_UNWIRED
#undef INTERCOM_READY
