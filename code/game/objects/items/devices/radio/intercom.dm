/obj/item/radio/intercom
	name = "station intercom (General)"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	flags = CONDUCT
	var/circuitry_installed = 1
	var/buildstage = 0
	dog_fashion = null

/obj/item/radio/intercom/custom
	name = "station intercom (Custom)"
	broadcasting = 0
	listening = 0

/obj/item/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	frequency  = AIRLOCK_FREQ

/obj/item/radio/intercom/private
	name = "station intercom (Private)"
	frequency = AI_FREQ

/obj/item/radio/intercom/command
	name = "station intercom (Command)"
	frequency = COMM_FREQ

/obj/item/radio/intercom/specops
	name = "\improper Special Operations intercom"
	frequency = ERT_FREQ

/obj/item/radio/intercom/department
	canhear_range = 5
	broadcasting = 0
	listening = 1

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
		b_stat=1
		on = 0
	GLOB.global_intercoms.Add(src)
	update_icon()

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
	internal_channels[num2text(SYND_TAIPAN_FREQ)] = list(ACCESS_SYNDICATE)

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

/obj/item/radio/intercom/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/tape_roll)) //eww
		return
	else if(iscoil(W) && buildstage == 1)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.get_amount() >= 5)
			to_chat(user, "<span class='notice'>You start to add cables to the frame...</span>")
			if(do_after(user, 10 * coil.toolspeed, target = src) && buildstage == 1 && coil.use(5))
				to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
				buildstage = 2
			return 1
		else
			to_chat(user, "<span class='warning'>You need more cable for this!</span>")
			return
	else if(istype(W,/obj/item/intercom_electronics) && buildstage == 0)
		playsound(get_turf(src), W.usesound, 50, 1)
		if(do_after(user, 10 * W.toolspeed, target = src) && buildstage == 0)
			qdel(W)
			to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]!</span>")
			buildstage = 1
		return 1
	else
		return ..()

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
	update_icon()
	on = 1
	b_stat = 0
	buildstage = 3
	to_chat(user, "<span class='notice'>You secure the electronics!</span>")
	update_icon()
	update_operating_status()
	for(var/i, i<= 5, i++)
		wires.on_cut(i, 1)

/obj/item/radio/intercom/wirecutter_act(mob/user, obj/item/I)
	if(!(buildstage == 3 && b_stat && wires.is_all_cut()))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(get_turf(src),5)
	on = 0
	b_stat = 1
	buildstage = 1
	update_icon()
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

/obj/item/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

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
	else
		on = current_area.powered(EQUIP) // set "on" to the equipment power status of our area.
	update_icon()

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
