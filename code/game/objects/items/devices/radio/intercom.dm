/obj/item/radio/intercom
	name = "station intercom (General)"
	desc = "A reliable form of communication even during local communication blackouts."
	icon_state = "intercom"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	blocks_emissive = FALSE
	var/circuitry_installed = 1
	var/buildstage = 0
	var/custom_name
	dog_fashion = null

/obj/item/radio/intercom/custom
	name = "station intercom (Custom)"
	custom_name = TRUE
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

/obj/item/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/radio/intercom/department/security
	name = "station intercom (Security)"
	frequency = SEC_I_FREQ

/obj/item/radio/intercom/New(turf/loc, direction, building = 3)
	. = ..()
	buildstage = building
	if(buildstage)
		update_operating_status()
	else
		if(direction)
			setDir(direction)
			set_pixel_offsets_from_dir(28, -28, 28, -28)
		b_stat = TRUE
		on = FALSE
	GLOB.global_intercoms.Add(src)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/item/radio/intercom/Initialize(mapload)
	. = ..()
	if(!custom_name)
		name = "station intercom (General)"

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
	desc = "Communicate with your minions. Evilly"
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

/obj/item/radio/intercom/attack_ai(mob/user)
	add_hiddenprint(user)
	add_fingerprint(user)
	attack_self__legacy__attackchain(user)

/obj/item/radio/intercom/attack_hand(mob/user)
	add_fingerprint(user)
	attack_self__legacy__attackchain(user)

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

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(0)
			. += "<span class='notice'>The frame is <b>welded</b> to the wall, but missing <i>circuitry</i>.</span>"
		if(1)
			. += "<span class='notice'>The speaker needs to be <i>wired</i>, though the board could be <b>pried</b> out.</span>"
		if(2)
			. += "<span class='notice'>The intercom is <b>wired</b>, and the maintenance panel is <i>unscrewed</i>.</span>"

/obj/item/radio/intercom/attackby__legacy__attackchain(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/tape_roll)) //eww
		return
	else if(iscoil(W) && buildstage == 1)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need more cable for this!</span>")
			return
		if(do_after(user, 10 * coil.toolspeed, target = src) && buildstage == 1)
			coil.use(5)
			to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
			buildstage = 2
		return 1
	else if(istype(W,/obj/item/intercom_electronics) && buildstage == 0)
		playsound(get_turf(src), W.usesound, 50, 1)
		if(do_after(user, 10 * W.toolspeed, target = src) && buildstage == 0)
			qdel(W)
			to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]!</span>")
			buildstage = 1
		return 1
	else
		return ..()

/obj/item/radio/intercom/AltClick(mob/user)
	. = ..()
	if(broadcasting)
		investigate_log("had its hotmic toggled on via hotkey by [key_name(user)].", INVESTIGATE_HOTMIC) ///Allows us to track who spams all these on if they do.

/obj/item/radio/intercom/crowbar_act(mob/user, obj/item/I)
	if(buildstage != 1)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You begin removing the electronics...</span>")
	if(!I.use_tool(src, user, 10, volume = I.tool_volume) || buildstage != 1)
		return
	new /obj/item/intercom_electronics(get_turf(src))
	to_chat(user, "<span class='notice'>The circuit board pops out!</span>")
	buildstage = 0

/obj/item/radio/intercom/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != 2)
		return ..()
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 10, volume = I.tool_volume) || buildstage != 2)
		return
	update_icon(UPDATE_ICON_STATE)
	on = TRUE
	b_stat = FALSE
	buildstage = 3
	to_chat(user, "<span class='notice'>You secure the electronics!</span>")
	update_icon(UPDATE_ICON_STATE)
	update_operating_status()
	for(var/i, i<= 5, i++)
		wires.on_cut(i, 1)

/obj/item/radio/intercom/wirecutter_act(mob/user, obj/item/I)
	if(!(buildstage == 3 && b_stat && wires.is_all_cut()))
		return ..()
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(get_turf(src),5)
	on = FALSE
	b_stat = TRUE
	buildstage = 1
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	update_operating_status(FALSE)

/obj/item/radio/intercom/welder_act(mob/user, obj/item/I)
	if(buildstage != 0)
		return
	. = TRUE
	if(!I.tool_use_check(user, 3))
		return
	to_chat(user, "<span class='notice'>You start slicing [src] from the wall...</span>")
	if(I.use_tool(src, user, 10, amount = 3, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You cut [src] free from the wall!</span>")
		new /obj/item/mounted/frame/intercom(get_turf(src))
		qdel(src)

/obj/item/radio/intercom/update_icon_state()
	if(!circuitry_installed)
		icon_state="intercom-frame"
	else
		icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/radio/intercom/update_overlays()
	. = ..()
	underlays.Cut()

	if(on && buildstage == 3)
		underlays += emissive_appearance(icon, "intercom_lightmask")

/obj/item/radio/intercom/proc/update_operating_status(on = TRUE)
	if(!loc) // We init a few radios in nullspace to prevent them from needing power.
		return
	var/area/current_area = get_area(src)
	if(on)
		RegisterSignal(current_area.powernet, COMSIG_POWERNET_POWER_CHANGE, PROC_REF(local_powernet_check))
	else
		UnregisterSignal(current_area.powernet, COMSIG_POWERNET_POWER_CHANGE)

/**
  * Proc called whenever the intercom's local powernet loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
  *
  * Normally called after the intercom's local powernet sends the `COMSIG_POWERNET_POWER_CHANGE` signal, but it can also be called directly.
  * Arguments:
  *
  * source - the area that just had a power change.
  */
/obj/item/radio/intercom/proc/local_powernet_check(datum/source)
	var/area/current_area = get_area(src)
	if(!current_area)
		on = FALSE
		set_light(0)
	else
		on = current_area.powernet.has_power(PW_CHANNEL_EQUIPMENT) // set "on" to the equipment power status of our area.
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/item/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
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
	name = "prison intercom"
	desc = "A reliable form of communication even during local communication blackouts. It looks like it has been modified to not broadcast. Not so reliable, I guess..."

/obj/item/radio/intercom/locked/prison/New()
	..()
	wires.cut(WIRE_RADIO_TRANSMIT)
