#define RAD_LEVEL_NORMAL 9
#define RAD_LEVEL_MODERATE 100
#define RAD_LEVEL_HIGH 400
#define RAD_LEVEL_VERY_HIGH 800
#define RAD_LEVEL_CRITICAL 1500

/obj/item/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "\improper Geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon = 'icons/obj/device.dmi'
	icon_state = "geiger_off"
	item_state = "multitool"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	flags = NOBLUDGEON
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)

	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

	var/scanning = FALSE
	var/radiation_count = 0
	var/current_tick_amount = 0
	var/last_tick_amount = 0
	var/fail_to_receive = 0
	var/current_warning = 1

/obj/item/geiger_counter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

	soundloop = new(list(src), FALSE)

/obj/item/geiger_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/geiger_counter/process()
	update_icon()
	update_sound()

	if(!scanning)
		current_tick_amount = 0
		return

	radiation_count -= radiation_count / RAD_GEIGER_MEASURE_SMOOTHING
	radiation_count += current_tick_amount / RAD_GEIGER_MEASURE_SMOOTHING

	if(current_tick_amount)
		grace = RAD_GEIGER_GRACE_PERIOD
		last_tick_amount = current_tick_amount

	else if(!emagged)
		grace--
		if(grace <= 0)
			radiation_count = 0

	current_tick_amount = 0

/obj/item/geiger_counter/examine(mob/user)
	. = ..()
	if(!scanning)
		return
	. += "<span class='info'>Alt-click it to clear stored radiation levels.</span>"
	if(emagged)
		. += "<span class='warning'>The display seems to be incomprehensible.</span>"
		return
	switch(radiation_count)
		if(-INFINITY to RAD_LEVEL_NORMAL)
			. += "<span class='notice'>Ambient radiation level count reports that all is well.</span>"
		if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
			. += "<span class='alert'>Ambient radiation levels slightly above average.</span>"
		if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
			. += "<span class='warning'>Ambient radiation levels above average.</span>"
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
			. += "<span class='danger'>Ambient radiation levels highly above average.</span>"
		if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
			. += "<span class='suicide'>Ambient radiation levels nearing critical level.</span>"
		if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
			. += "<span class='boldannounce'>Ambient radiation levels above critical level!</span>"

	. += "<span class='notice'>The last radiation amount detected was [last_tick_amount]</span>"

/obj/item/geiger_counter/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
	else if(emagged)
		icon_state = "geiger_on_emag"
	else
		switch(radiation_count)
			if(-INFINITY to RAD_LEVEL_NORMAL)
				icon_state = "geiger_on_1"
			if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
				icon_state = "geiger_on_2"
			if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
				icon_state = "geiger_on_3"
			if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
				icon_state = "geiger_on_4"
			if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
				icon_state = "geiger_on_4"
			if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
				icon_state = "geiger_on_5"

/obj/item/geiger_counter/proc/update_sound()
	var/datum/looping_sound/geiger/loop = soundloop
	if(!scanning)
		loop.stop()
		return
	if(!radiation_count)
		loop.stop()
		return
	loop.last_radiation = radiation_count
	loop.start()

/obj/item/geiger_counter/rad_act(amount)
	. = ..()
	if(amount <= RAD_BACKGROUND_RADIATION || !scanning)
		return
	current_tick_amount += amount
	update_icon()

/obj/item/geiger_counter/attack_self(mob/user)
	scanning = !scanning
	update_icon()
	to_chat(user, "<span class='notice'>[bicon(src)] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/geiger_counter/afterattack(atom/target, mob/user)
	. = ..()
	if(user.a_intent == INTENT_HELP)
		if(!emagged)
			user.visible_message("<span class='notice'>[user] scans [target] with [src].</span>", "<span class='notice'>You scan [target]'s radiation levels with [src]...</span>")
			addtimer(CALLBACK(src, .proc/scan, target, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents
		else
			user.visible_message("<span class='notice'>[user] scans [target] with [src].</span>", "<span class='danger'>You project [src]'s stored radiation into [target]!</span>")
			target.rad_act(radiation_count)
			radiation_count = 0
		return TRUE

/obj/item/geiger_counter/proc/scan(atom/A, mob/user)
	var/rad_strength = get_rad_contamination(A)

	if(isliving(A))
		var/mob/living/M = A
		if(!M.radiation)
			to_chat(user, "<span class='notice'>[bicon(src)] Radiation levels within normal boundaries.</span>")
		else
			to_chat(user, "<span class='boldannounce'>[bicon(src)] Subject is irradiated. Radiation levels: [M.radiation].</span>")

	if(rad_strength)
		to_chat(user, "<span class='boldannounce'>[bicon(src)] Target contains radioactive contamination. Radioactive strength: [rad_strength]</span>")
	else
		to_chat(user, "<span class='notice'>[bicon(src)] Target is free of radioactive contamination.</span>")

/obj/item/geiger_counter/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && emagged)
		if(scanning)
			to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
			return FALSE
		user.visible_message("<span class='notice'>[user] unscrews [src]'s maintenance panel and begins fiddling with its innards...</span>", "<span class='notice'>You begin resetting [src]...</span>")
		if(!I.use_tool(src, user, 40, volume = 50))
			return FALSE
		user.visible_message("<span class='notice'>[user] refastens [src]'s maintenance panel!</span>", "<span class='notice'>You reset [src] to its factory settings!</span>")
		emagged = FALSE
		radiation_count = 0
		update_icon()
		return TRUE
	else
		return ..()

/obj/item/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || !!user.Adjacent(src))
		return ..()
	if(!scanning)
		to_chat(usr, "<span class='warning'>[src] must be on to reset its radiation level!</span>")
		return
	radiation_count = 0
	to_chat(usr, "<span class='notice'>You flush [src]'s radiation counts, resetting it to normal.</span>")
	update_icon()

/obj/item/geiger_counter/emag_act(mob/user)
	if(emagged)
		return
	if(scanning)
		to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
		return
	to_chat(user, "<span class='warning'>You override [src]'s radiation storing protocols. It will now generate small doses of radiation, and stored rads are now projected into creatures you scan.</span>")
	emagged = TRUE



/obj/item/geiger_counter/cyborg
	var/mob/listeningTo

/obj/item/geiger_counter/cyborg/equipped(mob/user)
	. = ..()
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_ATOM_RAD_ACT)
	RegisterSignal(user, COMSIG_ATOM_RAD_ACT, .proc/redirect_rad_act)
	listeningTo = user

/obj/item/geiger_counter/cyborg/proc/redirect_rad_act(datum/source, amount)
	rad_act(amount)

/obj/item/geiger_counter/cyborg/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_ATOM_RAD_ACT)

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL
