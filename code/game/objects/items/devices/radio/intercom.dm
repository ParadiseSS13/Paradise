/obj/item/device/radio/intercom
	name = "station intercom (General)"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = 4
	canhear_range = 2
	flags = CONDUCT
	var/number = 0
	var/circuitry_installed = 1
	var/last_tick //used to delay the powercheck
	var/buildstage = 0

/obj/item/device/radio/intercom/custom
	name = "station intercom (Custom)"
	broadcasting = 0
	listening = 0

/obj/item/device/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	frequency  = 1449

/obj/item/device/radio/intercom/private
	name = "station intercom (Private)"
	frequency = AI_FREQ

/obj/item/device/radio/intercom/command
	name = "station intercom (Command)"
	frequency = COMM_FREQ

/obj/item/device/radio/intercom/specops
	name = "\improper Special Operations intercom"
	frequency = ERT_FREQ

/obj/item/device/radio/intercom/department
	canhear_range = 5
	broadcasting = 0
	listening = 1

/obj/item/device/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/device/radio/intercom/department/security
	name = "station intercom (Security)"
	frequency = SEC_I_FREQ

/obj/item/device/radio/intercom/New(turf/loc, var/ndir = 0, var/building = 3)
	..()
	buildstage = building
	if(buildstage)
		processing_objects.Add(src)
	else
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 : -28) : 0
		dir=ndir
		b_stat=1
		on = 0
	global_intercoms.Add(src)
	update_icon()

/obj/item/device/radio/intercom/department/medbay/New()
	..()
	internal_channels = default_medbay_channels.Copy()

/obj/item/device/radio/intercom/department/security/New()
	..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(access_security)
	)

/obj/item/device/radio/intercom/syndicate
	name = "illicit intercom"
	desc = "Talk through this. Evilly"
	frequency = SYND_FREQ
	subspace_transmission = 1
	syndie = 1

/obj/item/device/radio/intercom/syndicate/New()
	..()
	internal_channels[num2text(SYND_FREQ)] = list(access_syndicate)

/obj/item/device/radio/intercom/pirate
	name = "pirate radio intercom"
	desc = "You wouldn't steal a space shuttle. Piracy. It's a crime!"
	subspace_transmission = 1

/obj/item/device/radio/intercom/pirate/New()
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

/obj/item/device/radio/intercom/Destroy()
	processing_objects.Remove(src)
	global_intercoms.Remove(src)
	return ..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	add_fingerprint(user)
	spawn(0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	add_fingerprint(user)
	spawn(0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if(!on)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		// TODO: Integrate radio with the space manager
		if(isnull(position) || !(position.z in level))
			return -1
	if(!src.listening)
		return -1
	if(freq in ANTAG_FREQS)
		if(!(src.syndie))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range

/obj/item/device/radio/intercom/attackby(obj/item/weapon/W as obj, mob/user as mob)
	switch(buildstage)
		if(3)
			if(iswirecutter(W) && b_stat && wires.IsAllCut())
				to_chat(user, "<span class='notice'>You cut out the intercoms wiring and disconnect its electronics.</span>")
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				if(do_after(user, 10, target = src))
					if(buildstage != 3)
						return
					new /obj/item/stack/cable_coil(get_turf(src),5)
					on = 0
					b_stat = 1
					buildstage = 1
					update_icon()
					processing_objects.Remove(src)
				return 1
			else return ..()
		if(2)
			if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, 10, target = src))
					update_icon()
					on = 1
					b_stat = 0
					buildstage = 3
					to_chat(user, "<span class='notice'>You secure the electronics!</span>")
					update_icon()
					processing_objects.Add(src)
					for(var/i, i<= 5, i++)
						wires.UpdateCut(i,1)
				return 1
		if(1)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					return
				if(do_after(user, 10, target = src))
					coil.use(5)
					to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
					buildstage = 2
				return 1
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You begin removing the electronics...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 10, target = src))
					if(buildstage != 1)
						return
					new /obj/item/weapon/intercom_electronics(get_turf(src))
					to_chat(user, "<span class='notice'>The circuitboard pops out!</span>")
					buildstage = 0
				return 1
		if(0)
			if(istype(W,/obj/item/weapon/intercom_electronics))
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 10, target = src))
					qdel(W)
					to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]!</span>")
					buildstage = 1
				return 1
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT=W
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				if(!WT.remove_fuel(3, user))
					to_chat(user, "<span class='warning'>You're out of welding fuel.</span>")
					return 1
				if(do_after(user, 10, target = src))
					to_chat(user, "<span class='notice'>You cut the intercom frame from the wall!</span>")
					new /obj/item/mounted/frame/intercom(get_turf(src))
					qdel(src)
					return 1

/obj/item/device/radio/intercom/update_icon()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/device/radio/intercom/process()
	if(((world.timeofday - last_tick) > 30) || ((world.timeofday - last_tick) < 0))
		last_tick = world.timeofday


		if(!src.loc)
			on = 0
		else
			var/area/A = get_area(src)
			if(!A)
				on = 0
			else
				on = A.powered(EQUIP) // set "on" to the power status
		update_icon()

/obj/item/weapon/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = 2
	materials = list(MAT_METAL=50, MAT_GLASS=50)

/obj/item/device/radio/intercom/locked
    var/locked_frequency

/obj/item/device/radio/intercom/locked/set_frequency(var/frequency)
	if(frequency == locked_frequency)
		..(locked_frequency)

/obj/item/device/radio/intercom/locked/list_channels()
	return ""

/obj/item/device/radio/intercom/locked/ai_private
	name = "\improper AI intercom"
	frequency = AI_FREQ

/obj/item/device/radio/intercom/locked/confessional
	name = "confessional intercom"
	frequency = 1480

/obj/item/device/radio/intercom/locked/prison
	name = "\improper prison intercom"
	desc = "Talk through this. It looks like it has been modified to not broadcast."

/obj/item/device/radio/intercom/locked/prison/New()
	..()
	wires.CutWireIndex(WIRE_TRANSMIT)
