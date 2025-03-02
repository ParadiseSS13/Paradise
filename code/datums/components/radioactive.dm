#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000
#define GLOW_ALPHA "#225dff5d"
#define GLOW_BETA "#39ff1430"
#define GLOW_GAMMA "#c125ff6b"

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/source
	///the half-life measured in ticks
	var/hl3_release_date
	var/alpha_strength
	var/beta_strength
	var/gamma_strength

/datum/component/radioactive/Initialize(_strength, _source, emission_type, _half_life = RAD_HALF_LIFE)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE
	switch(emission_type)
		if(ALPHA_RAD)
			alpha_strength = _strength
		if(BETA_RAD)
			beta_strength = _strength
		if(GAMMA_RAD)
			gamma_strength = _strength
	source = _source
	hl3_release_date = _half_life
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(rad_examine))
	RegisterSignal(parent, COMSIG_ADMIN_DECONTAMINATE, PROC_REF(admin_decontaminate))
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ATTACK, PROC_REF(rad_attack))
		RegisterSignal(parent, COMSIG_ATTACK_OBJ, PROC_REF(rad_attack))
	//Let's make er glow
	//This relies on parent not being a turf or something. IF YOU CHANGE THAT, CHANGE THIS
	var/atom/movable/master = parent
	master.add_filter("rad_glow", 2, list("type" = "outline", "color" = get_glow_color(), "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(glow_loop), master), rand(1, 19)) //Things should look uneven
	LAZYADD(SSradiation.all_radiations, src)
	START_PROCESSING(SSradiation, src)

/datum/component/radioactive/Destroy()
	STOP_PROCESSING(SSradiation, src)
	LAZYREMOVE(SSradiation.all_radiations, src)
	var/atom/movable/master = parent
	master.remove_filter("rad_glow")
	return ..()

/datum/component/radioactive/proc/get_glow_color()
	var/list/glow_alpha = rgb2num(GLOW_ALPHA)
	var/list/glow_beta = rgb2num(GLOW_BETA)
	var/list/glow_gamma = rgb2num(GLOW_GAMMA)
	var/list/rad_color = list()
	var/alpha_part = alpha_strength / (alpha_strength + beta_strength + gamma_strength)
	var/beta_part = beta_strength / (alpha_strength + beta_strength + gamma_strength)
	var/gamma_part = 1 - (alpha_part + beta_part)
	var/max_ratio = 0
	for(var/i in 1 to 4)
		rad_color += glow_alpha[i] * alpha_part + glow_beta[i] * beta_part + glow_gamma[i] * gamma_part
		// Find the ratio between the color value closest to 256 and 256.
		if(i < 4 && max_ratio < (rad_color[i] / 256))
			max_ratio = rad_color[i] / 256
	return rgb(rad_color[1] / max_ratio, rad_color[2] / max_ratio, rad_color[3] / max_ratio, rad_color[4])

/datum/component/radioactive/process()
	if(alpha_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, alpha_strength, ALPHA_RAD)
	if(beta_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, beta_strength, BETA_RAD)
	if(gamma_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, gamma_strength, GAMMA_RAD)

	if(!hl3_release_date)
		return

	alpha_strength -= alpha_strength / hl3_release_date
	beta_strength -= beta_strength / hl3_release_date
	gamma_strength -= gamma_strength / hl3_release_date

	SSradiation.update_rad_cache_contaminated(src)

	if(alpha_strength + beta_strength + gamma_strength <= RAD_BACKGROUND_RADIATION)
		qdel(src)
		return PROCESS_KILL

/datum/component/radioactive/proc/glow_loop(atom/movable/master)
	var/filter = master.get_filter("rad_glow")
	if(filter)
		animate(filter, alpha = 110, time = 15, loop = -1)
		animate(alpha = 40, time = 25)

/datum/component/radioactive/InheritComponent(datum/component/C, i_am_original, _strength, _source, emission_type, _half_life = RAD_HALF_LIFE)
	if(!i_am_original)
		return
	if(!hl3_release_date) // Permanently radioactive things don't get to grow stronger
		return
	if(C)
		var/datum/component/radioactive/other = C
		alpha_strength = max(alpha_strength, other.alpha_strength)
		beta_strength = max(beta_strength, other.beta_strength)
		gamma_strength = max(gamma_strength, other.gamma_strength)
		hl3_release_date = other.hl3_release_date
	else
		switch(emission_type)
			if(ALPHA_RAD)
				alpha_strength = max(alpha_strength, _strength)
			if(BETA_RAD)
				beta_strength = max(beta_strength, _strength)
			if(GAMMA_RAD)
				gamma_strength = max(gamma_strength, _strength)

		hl3_release_date = _half_life
	var/atom/movable/master = parent
	var/filter = master.get_filter("rad_glow")
	animate(filter, color = get_glow_color())

/datum/component/radioactive/proc/rad_examine(datum/source, mob/user, list/out)
	SIGNAL_HANDLER

	var/atom/master = parent

	var/list/fragments = list()
	if(get_dist(master, user) <= 1)
		fragments += "The air around [master] feels warm"
	switch(alpha_strength + beta_strength + gamma_strength)
		if(0 to RAD_AMOUNT_LOW)
			if(length(fragments))
				fragments += "."
		if(RAD_AMOUNT_LOW to RAD_AMOUNT_MEDIUM)
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]feel[master.p_s()] weird to look at."
		if(RAD_AMOUNT_MEDIUM to RAD_AMOUNT_HIGH)
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]seem[master.p_s()] to be glowing a bit."
		if(RAD_AMOUNT_HIGH to INFINITY) //At this level the object can contaminate other objects
			fragments += "[length(fragments) ? " and [master.p_they()] " : "[master] "]hurt[master.p_s()] to look at."

	if(length(fragments))
		out += "<span class='warning'>[fragments.Join()]</span>"

/datum/component/radioactive/proc/rad_attack(datum/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER
	if(alpha_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, alpha_strength / 20, ALPHA_RAD)
		target.base_rad_act(parent ,alpha_strength / 2, ALPHA_RAD)
	if(beta_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, beta_strength / 20, BETA_RAD)
		target.base_rad_act(parent, beta_strength / 2, BETA_RAD)
	if(gamma_strength > RAD_BACKGROUND_RADIATION)
		radiation_pulse(parent, gamma_strength / 20, GAMMA_RAD)
		target.base_rad_act(parent, gamma_strength / 2, GAMMA_RAD)
	if(!hl3_release_date)
		return
	alpha_strength -= alpha_strength / hl3_release_date
	beta_strength -= beta_strength / hl3_release_date
	gamma_strength -= gamma_strength / hl3_release_date

/datum/component/radioactive/proc/admin_decontaminate()
	SIGNAL_HANDLER
	. = TRUE
	if(ismob(parent))
		var/mob/M = parent
		M.radiation = 0
	if(ismob(source))
		var/mob/M = source
		M.radiation = 0
	qdel(src)

#undef RAD_AMOUNT_LOW
#undef RAD_AMOUNT_MEDIUM
#undef RAD_AMOUNT_HIGH
#undef RAD_AMOUNT_EXTREME
#undef GLOW_ALPHA
#undef GLOW_BETA
#undef GLOW_GAMMA
