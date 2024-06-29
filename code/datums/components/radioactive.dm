#define RAD_AMOUNT_LOW 50
#define RAD_AMOUNT_MEDIUM 200
#define RAD_AMOUNT_HIGH 500
#define RAD_AMOUNT_EXTREME 1000

/datum/component/radioactive
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/source
	///the half-life measured in ticks
	var/hl3_release_date
	var/strength
	var/can_contaminate

/datum/component/radioactive/Initialize(_strength = 0, _source, _half_life = RAD_HALF_LIFE, _can_contaminate = TRUE)
	if(!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE
	strength = _strength
	source = _source
	hl3_release_date = _half_life
	can_contaminate = _can_contaminate
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(rad_examine))
	RegisterSignal(parent, COMSIG_ADMIN_DECONTAMINATE, PROC_REF(admin_decontaminate))
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(rad_attack))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(rad_attack))
	if(strength > RAD_MINIMUM_CONTAMINATION)
		SSradiation.warn(src)
	//Let's make er glow
	//This relies on parent not being a turf or something. IF YOU CHANGE THAT, CHANGE THIS
	var/atom/movable/master = parent
	master.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(glow_loop), master), rand(1, 19)) //Things should look uneven
	LAZYADD(SSradiation.all_radiations, src)
	START_PROCESSING(SSradiation, src)

/datum/component/radioactive/Destroy()
	STOP_PROCESSING(SSradiation, src)
	LAZYREMOVE(SSradiation.all_radiations, src)
	var/atom/movable/master = parent
	master.remove_filter("rad_glow")
	return ..()

/datum/component/radioactive/process()
	if(!prob(50))
		return
	radiation_pulse(parent, strength, RAD_DISTANCE_COEFFICIENT * 2, FALSE, can_contaminate)
	if(!hl3_release_date)
		return
	strength -= strength / hl3_release_date
	SSradiation.update_rad_cache(src)
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(src)
		return PROCESS_KILL

/datum/component/radioactive/proc/glow_loop(atom/movable/master)
	var/filter = master.get_filter("rad_glow")
	if(filter)
		animate(filter, alpha = 110, time = 15, loop = -1)
		animate(alpha = 40, time = 25)

/datum/component/radioactive/InheritComponent(datum/component/C, i_am_original, _strength, _source, _half_life, _can_contaminate)
	if(!i_am_original)
		return
	if(!hl3_release_date) // Permanently radioactive things don't get to grow stronger
		return
	if(C)
		var/datum/component/radioactive/other = C
		strength = max(strength, other.strength)
	else
		strength = max(strength, _strength)

/datum/component/radioactive/proc/rad_examine(datum/source, mob/user, list/out)
	SIGNAL_HANDLER

	var/atom/master = parent

	var/list/fragments = list()
	if(get_dist(master, user) <= 1)
		fragments += "The air around [master] feels warm"
	switch(strength)
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

	radiation_pulse(parent, strength / 20)
	target.rad_act(strength / 2)
	if(!hl3_release_date)
		return
	strength -= strength / hl3_release_date

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
