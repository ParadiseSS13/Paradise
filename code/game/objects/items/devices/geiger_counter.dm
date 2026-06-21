#define RAD_LEVEL_NORMAL 9
#define RAD_LEVEL_MODERATE 100
#define RAD_LEVEL_HIGH 400
#define RAD_LEVEL_VERY_HIGH 800
#define RAD_LEVEL_CRITICAL 1500

/// DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
/obj/item/geiger_counter
	name = "\improper Geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon = 'icons/obj/device.dmi'
	icon_state = "geiger_off"
	inhand_icon_state = "multitool"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	flags = NOBLUDGEON
	materials = list(MAT_METAL = 210, MAT_GLASS = 150)
	rad_insulation_alpha = RAD_ONE_PERCENT
	rad_insulation_beta = RAD_ONE_PERCENT
	rad_insulation_gamma = RAD_ONE_PERCENT

	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

	var/scanning = FALSE
	var/radiation_count_alpha = 0
	var/radiation_count_beta = 0
	var/radiation_count_gamma = 0
	var/current_tick_amount_alpha = 0
	var/current_tick_amount_beta = 0
	var/current_tick_amount_gamma = 0
	var/last_tick_amount_alpha = 0
	var/last_tick_amount_beta = 0
	var/last_tick_amount_gamma = 0
	var/fail_to_receive = 0
	var/current_warning = 1
	new_attack_chain = TRUE

/obj/item/geiger_counter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

	soundloop = new(list(src), FALSE)

/obj/item/geiger_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(soundloop)
	return ..()


/obj/item/geiger_counter/process()
	if(scanning)
		radiation_count_alpha -= radiation_count_alpha / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count_alpha += current_tick_amount_alpha / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count_beta -= radiation_count_beta / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count_beta += current_tick_amount_beta / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count_gamma -= radiation_count_gamma / RAD_GEIGER_MEASURE_SMOOTHING
		radiation_count_gamma += current_tick_amount_gamma / RAD_GEIGER_MEASURE_SMOOTHING

		if(current_tick_amount_alpha)
			grace = RAD_GEIGER_GRACE_PERIOD
			last_tick_amount_alpha = current_tick_amount_alpha
		if(current_tick_amount_beta)
			grace = RAD_GEIGER_GRACE_PERIOD
			last_tick_amount_beta = current_tick_amount_beta
		if(current_tick_amount_gamma)
			grace = RAD_GEIGER_GRACE_PERIOD
			last_tick_amount_gamma = current_tick_amount_gamma

		else if(!emagged)
			grace--
			if(grace <= 0)
				radiation_count_alpha = 0
				radiation_count_beta = 0
				radiation_count_gamma = 0

	current_tick_amount_alpha = 0
	current_tick_amount_beta = 0
	current_tick_amount_gamma = 0

	update_icon(UPDATE_ICON_STATE)
	update_sound()

/obj/item/geiger_counter/examine(mob/user)
	. = ..()
	if(!scanning)
		return
	. += SPAN_NOTICE("Alt-click it to clear stored radiation levels.")
	if(emagged)
		. += SPAN_WARNING("The display seems to be incomprehensible.")
		return
	var/radiation_count = max(radiation_count_alpha, radiation_count_beta, radiation_count_gamma)
	switch(radiation_count)
		if(-INFINITY to RAD_LEVEL_NORMAL)
			. += SPAN_NOTICE("Ambient radiation level count reports that all is well.")
		if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
			. += SPAN_ALERT("Ambient radiation levels slightly above average.")
		if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
			. += SPAN_WARNING("Ambient radiation levels above average.")
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
			. += SPAN_DANGER("Ambient radiation levels highly above average.")
		if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
			. += SPAN_SUICIDE("Ambient radiation levels nearing critical level.")
		if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
			. += SPAN_BOLDANNOUNCEIC("Ambient radiation levels above critical level!")

	. += SPAN_NOTICE("The alpha radiation amount detected was [last_tick_amount_alpha]")
	. += SPAN_NOTICE("The beta radiation amount detected was [last_tick_amount_beta]")
	. += SPAN_NOTICE("The gamma radiation amount detected was [last_tick_amount_gamma]")

/obj/item/geiger_counter/update_icon_state()
	if(!scanning)
		icon_state = "geiger_off"
	else if(emagged)
		icon_state = "geiger_on_emag"
	else
		var/radiation_count = max(radiation_count_alpha + radiation_count_beta + radiation_count_gamma)
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
	var/radiation_count = max(radiation_count_alpha, radiation_count_beta, radiation_count_gamma)
	if(!scanning || !radiation_count)
		loop.stop()
		return
	loop.last_radiation = radiation_count
	loop.start()

/obj/item/geiger_counter/rad_act(atom/source, amount, emission_type)
	amount *= 100
	if(amount <= RAD_BACKGROUND_RADIATION || !scanning)
		return
	switch(emission_type)
		if(ALPHA_RAD)
			current_tick_amount_alpha += amount
		if(BETA_RAD)
			current_tick_amount_beta += amount
		if(GAMMA_RAD)
			current_tick_amount_gamma += amount
	update_icon(UPDATE_ICON_STATE)

/obj/item/geiger_counter/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	scanning = !scanning
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, SPAN_NOTICE("[bicon(src)] You switch [scanning ? "on" : "off"] [src]."))

/obj/item/geiger_counter/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(geiger_act(target, user))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/geiger_counter/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(geiger_act(target, user))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/item/geiger_counter/proc/geiger_act(atom/target, mob/living/user)
	if(user.a_intent != INTENT_HELP || isstorage(target))
		return FALSE
	if(!emagged)
		user.visible_message(SPAN_NOTICE("[user] scans [target] with [src]."), SPAN_NOTICE("You scan [target]'s radiation levels with [src]..."))
		addtimer(CALLBACK(src, PROC_REF(scan), target, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents
	else
		user.visible_message(SPAN_NOTICE("[user] scans [target] with [src]."), SPAN_DANGER("You project [src]'s stored radiation into [target]!"))
		target.base_rad_act(src, radiation_count_alpha, ALPHA_RAD)
		target.base_rad_act(src, radiation_count_beta, BETA_RAD)
		target.base_rad_act(src, radiation_count_gamma, GAMMA_RAD)
		radiation_count_alpha = 0
		radiation_count_beta = 0
		radiation_count_gamma = 0
	return TRUE

/obj/item/geiger_counter/proc/scan(atom/A, mob/user)
	var/rad_strength = get_rad_contamination(A)

	if(isliving(A))
		var/mob/living/M = A
		if(!M.radiation)
			to_chat(user, SPAN_NOTICE("[bicon(src)] Radiation levels within normal boundaries."))
		else
			to_chat(user, SPAN_BOLDANNOUNCEIC("[bicon(src)] Subject is irradiated. Radiation levels: [M.radiation] rads."))

	if(rad_strength)
		to_chat(user, SPAN_BOLDANNOUNCEIC("[bicon(src)] Target contains radioactive contamination. Radioactive strength: [rad_strength] rads."))
	else
		to_chat(user, SPAN_NOTICE("[bicon(src)] Target is free of radioactive contamination."))

/obj/item/geiger_counter/screwdriver_act(mob/living/user, obj/item/I)
	if(emagged)
		if(scanning)
			to_chat(user, SPAN_WARNING("Turn off [src] before you perform this action!"))
			return FALSE
		user.visible_message(SPAN_NOTICE("[user] unscrews [src]'s maintenance panel and begins fiddling with its innards..."), SPAN_NOTICE("You begin resetting [src]..."))
		if(!I.use_tool(src, user, 40, volume = I.tool_volume))
			return FALSE
		user.visible_message(SPAN_NOTICE("[user] refastens [src]'s maintenance panel!"), SPAN_NOTICE("You reset [src] to its factory settings!"))
		emagged = FALSE
		radiation_count_alpha = 0
		radiation_count_beta = 0
		radiation_count_gamma = 0
		update_icon(UPDATE_ICON_STATE)
		return TRUE
	else
		return ..()

/obj/item/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || !user.Adjacent(src))
		return ..()
	if(!scanning)
		to_chat(user, SPAN_WARNING("[src] must be on to reset its radiation level!"))
		return
	radiation_count_alpha = 0
	radiation_count_beta = 0
	radiation_count_gamma = 0
	to_chat(user, SPAN_NOTICE("You flush [src]'s radiation counts, resetting it to normal."))
	update_icon(UPDATE_ICON_STATE)

/obj/item/geiger_counter/emag_act(mob/user)
	if(emagged)
		return
	if(scanning)
		to_chat(user, SPAN_WARNING("Turn off [src] before you perform this action!"))
		return
	to_chat(user, SPAN_WARNING("You override [src]'s radiation storing protocols. It will now generate small doses of radiation, and stored rads are now projected into creatures you scan."))
	emagged = TRUE
	return TRUE



/obj/item/geiger_counter/cyborg

/obj/item/geiger_counter/cyborg/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	if(scanning)
		RegisterSignal(user, COMSIG_ATOM_RAD_ACT, PROC_REF(redirect_rad_act))
	else
		UnregisterSignal(user, COMSIG_ATOM_RAD_ACT)

/obj/item/geiger_counter/cyborg/proc/redirect_rad_act(datum/source, amount, emission_type)
	base_rad_act(source, amount, emission_type)

/obj/item/geiger_counter/cyborg/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_ATOM_RAD_ACT)

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL
