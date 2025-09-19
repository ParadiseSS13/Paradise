/obj/item/gun/medbeam
	name = "Medical Beamgun"
	desc = "Delivers volatile medical nanites in a focused beam. Don't cross the beams!"
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	worn_icon_state = null
	inhand_icon_state = null
	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = FALSE
	var/beam_UID = null
	var/mounted = FALSE

	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/medbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/medbeam/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/medbeam/handle_suicide()
	return

/obj/item/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/gun/medbeam/equipped(mob/user, slot, initial)
	..()
	LoseTarget()

/obj/item/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(locateUID(beam_UID))
		beam_UID = null
		active = FALSE
		on_beam_release(current_target)
	current_target = null

/obj/item/gun/medbeam/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override)
	if(isliving(user) && isrobot(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	var/datum/beam/current_beam = user.Beam(current_target, "medbeam", time = 10 MINUTES, beam_type = /obj/effect/ebeam/medical)
	beam_UID = current_beam.UID()

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/obj/item/gun/medbeam/process()
	var/source = loc
	if(!mounted && !ishuman(source) && !isrobot(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source,current_target)>max_range || !los_check(source,current_target))
		LoseTarget()
		if(ishuman(source) && isrobot(source))
			to_chat(source, "<span class='warning'>You lose control of the beam!</span>")
		return

	if(current_target)
		on_beam_tick(source, current_target)

/obj/item/gun/medbeam/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	var/datum/beam/current_beam = locateUID(beam_UID)
	if(QDELETED(current_beam))
		return FALSE
	if(mounted)
		user_turf = get_turf(user)
	else if(!istype(user_turf))
		return FALSE
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE | PASSGLASS | PASSGRILLE | PASSFENCE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in get_line(user_turf,target))
		if(mounted && turf == user_turf)
			continue //Mechs are dense and thus fail the check
		if(turf.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return FALSE
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner && B.owner != current_beam && !QDELETED(B)) // only blow up if it has a CONFIRMED different owner than us. Don't want it blowing up on creation/deletion of beams.
				turf.visible_message("<span class='userdanger'>The medbeams cross and EXPLODE!</span>")
				explosion(B.loc,0,3,5,8, cause = "Crossed beams")
				qdel(dummy)
				return FALSE
	qdel(dummy)
	return TRUE

/obj/item/gun/medbeam/proc/on_beam_tick(mob/living/user, mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustBruteLoss(-4, robotic = TRUE)
		H.adjustFireLoss(-4, robotic = TRUE)
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(!mounted && prob(10))
				E.mend_fracture()
				E.fix_internal_bleeding()
				E.fix_burn_wound()
	else
		target.adjustBruteLoss(-4)
		target.adjustFireLoss(-4)

/obj/item/gun/medbeam/proc/on_beam_release(mob/living/target)
	return

/obj/effect/ebeam/medical
	name = "medical beam"

//Damaged beamgun loot, DO NOT let it break
#define SCREWDRIVER_OPEN 8
#define REMOVE_OLD_PARTS 7
#define WELD_SHELL 6
#define INSTALL_LENS 5
#define INSTALL_ELECTRONICS 4
#define INSTALL_CELL 3
#define MULTITOOL_ELECTRONICS 2
#define SCREWDRIVER_CLOSED 1

/obj/item/gun/medbeam/damaged
	name = "damaged beamgun"
	///How hot the beamgun is, if it hits max heat it will break
	var/current_heat = 0
	///How much heat the beamgun needs to break
	var/max_heat = 50
	///when current_heat / max_heat > damaging_heat_percent, it will burn the wielders hands
	var/damaging_heat_percent = 0.6
	///If the gun has overheated and broke down
	var/broken = FALSE
	///If the gun is still too hot to repair
	var/overheated = FALSE
	var/obj/effect/abstract/particle_holder/fire_particles

/obj/item/gun/medbeam/damaged/Destroy()
	. = ..()
	if(fire_particles)
		QDEL_NULL(fire_particles)

/obj/item/gun/medbeam/damaged/examine(mob/user) //The 8 Trials of Asclepius
	. = ..()
	. += "<span class= 'warning'>This ones cooling systems are damaged beyond repair, and will overheat rapidly. \
	Despite the damaged cooling system, it's still mostly functional. However, if overheated, it will need to be repaired.</span>"
	if(broken)
		. += "<span class='notice'>It is broken, and will not function without repairs.</span>"
	switch(broken)
		if(SCREWDRIVER_OPEN)
			. += "<span class='notice'>The panel can be <b>screwed</b> open to access the internals.</span>"
		if(REMOVE_OLD_PARTS)
			. += "<span class='notice'>The old fried electronics and melted lens have to be <b>pried</b> out.</span>"
		if(WELD_SHELL)
			. += "<span class='notice'>The distorted shell needs to be <b>welded</b> back to form.</span>"
		if(INSTALL_LENS)
			. += "<span class='notice'>It needs a new <b>glass</b> lens.</span>"
		if(INSTALL_ELECTRONICS)
			. += "<span class='notice'>It needs new <b>cabling</b> for the electronics.</span>"
		if(INSTALL_CELL)
			. += "<span class='notice'>It needs a fully charged specialized <b>battery</b> to function."
		if(MULTITOOL_ELECTRONICS)
			. += "<span class='notice'>The electronics need to be tested and reactivated with a <b>multitool</b>.</span>"
		if(SCREWDRIVER_CLOSED)
			. += "<span class='notice'>The panel needs to be <b>screwed</b> shut before it is usable.</span>"

	if(!in_range(src, user))
		return
	var/heat_percent = (current_heat / max_heat) * 100
	switch(heat_percent)
		if(20 to 39)
			. += "<span class='notice'>[src] feels warm.</span>"
		if(40 to 59)
			. += "<span class='notice'>[src] feels hot.</span>"
		if(60 to 74) // i want it to be in the 'smoke' range at ~40 heat so as magic smoke is sudden but quick reaction time can stop it
			. += "<span class='warning'>[src] is so hot it hurts to hold.</span>"
		if(75 to INFINITY)
			. += "<span class='warning'>[src] is emitting its magic smoke and is practically melting.</span>"

/obj/item/gun/medbeam/damaged/process()
	. = ..()
	if(current_target)
		return

	current_heat = max(current_heat - 1, 0)

/obj/item/gun/medbeam/damaged/can_trigger_gun(mob/living/user)
	if(broken)
		to_chat(user, "<span class='warning'>[src] fails to start! It's broken!</span>")
		return FALSE
	return ..()

/obj/item/gun/medbeam/damaged/on_beam_tick(mob/living/user, mob/living/target)
	. = ..()
	if(current_heat >= max_heat)
		user.visible_message("<span class='warning'>[src] pops as it shuts off!</span>", "<span class='warning'>[src] pops and hisses as it shuts off. It is broken.</span>")
		broken = SCREWDRIVER_OPEN
		playsound(src, 'sound/effects/snap.ogg', 70, TRUE) // that didn't sound good...
		user.adjustFireLoss(30) // you do NOT want to be holding this if it breaks. 5 more damage than hive lord cores heal, so not /thattt/ bad
		user.adjust_fire_stacks(20)
		user.IgniteMob()
		LoseTarget()
		update_fire_overlay(COLOR_ORANGE)
		overheated = TRUE
		return

	if(current_heat / max_heat > damaging_heat_percent)
		to_chat(user, "<span class='warning'>[src] burns to hold!</span>")
		user.adjustFireLoss(0.1 * (current_heat / max_heat))

	current_heat = min(current_heat + 1, max_heat)

/obj/item/gun/medbeam/damaged/attackby__legacy__attackchain(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(broken == INSTALL_CELL)
		if(istype(attacking_item, /obj/item/stock_parts/cell/medbeam))
			var/obj/item/stock_parts/cell/medbeam/battery = attacking_item
			if(battery.charge != battery.maxcharge)
				to_chat(user, "<span class='warning'>[src] won't function without a fully charged [battery].</span>")
				return
			to_chat(user, "<span class='notice'>You start replacing [src]'s battery.</span>")
			attempt_repair(user, attacking_item, MULTITOOL_ELECTRONICS)
			return

	if(broken == INSTALL_ELECTRONICS)
		if(istype(attacking_item, /obj/item/stack/cable_coil))
			to_chat(user, "<span class='notice'>You start replacing the fried electronics in [src].</span>")
			attempt_repair(user, attacking_item, INSTALL_CELL)
			return

	if(broken == INSTALL_LENS)
		if(istype(attacking_item, /obj/item/stack/sheet/glass))
			to_chat(user, "<span class='notice'>You start replacing the broken lens in [src].</span>")
			attempt_repair(user, attacking_item, INSTALL_ELECTRONICS)
			return

/obj/item/gun/medbeam/damaged/screwdriver_act(mob/user, obj/item/screwdriver)
	if(broken == SCREWDRIVER_OPEN)
		if(overheated)
			to_chat(user,  "<span class='warning'>[src] is still too hot for the screws to be safely removed from it.</span>")
			return
		to_chat(user, "<span class='notice'>You start removing the screws from [src]'s shell.</span>")
		attempt_repair(user, screwdriver, REMOVE_OLD_PARTS)
		return TRUE

	if(broken == SCREWDRIVER_CLOSED)
		to_chat(user, "<span class='notice'>You start replacing the screws on [src]'s shell.</span>")
		attempt_repair(user, screwdriver, FALSE)
		return TRUE

/obj/item/gun/medbeam/damaged/crowbar_act(mob/living/user, obj/item/crowbar)
	if(broken == REMOVE_OLD_PARTS)
		to_chat(user, "<span class='notice'>You start prying out the old electronics and lens from [src].</span>")
		attempt_repair(user, crowbar, WELD_SHELL)
		return TRUE

/obj/item/gun/medbeam/damaged/welder_act(mob/living/user, obj/item/welder)
	. = ..()
	if(broken == WELD_SHELL)
		if(!welder.tool_start_check(src, user, 1))
			to_chat(user, "<span class='warning'>[welder] isn't functioning.</span>")
			return
		to_chat(user, "<span class='notice'>You start welding [src] back to form.</span>")
		attempt_repair(user, welder, INSTALL_LENS)
		return TRUE

/obj/item/gun/medbeam/damaged/multitool_act(mob/living/user, obj/item/multitool)
	if(broken == MULTITOOL_ELECTRONICS)
		if(user.electrocute_act(rand(1, 10), src))
			do_sparks(6, FALSE, user)
			return TRUE
		to_chat(user, "<span class='notice'>You start to activate the electronics in [src].</span>")
		attempt_repair(user, multitool, SCREWDRIVER_CLOSED)
		return TRUE

/obj/item/gun/medbeam/damaged/proc/update_fire_overlay(new_color)
	if(!fire_particles)
		fire_particles = new(src, /particles/fire_particles)
		fire_particles.color = COLOR_RED

	animate(fire_particles, 20 SECONDS, color = COLOR_ORANGE)
	animate(fire_particles, 10 SECONDS, color = COLOR_GRAY, delay = 20 SECONDS)
	addtimer(VARSET_CALLBACK(src, overheated, FALSE), 30 SECONDS)

/obj/item/gun/medbeam/damaged/proc/attempt_repair(mob/living/user, obj/item/tool_used, next_broken_state)
	if(!do_after_once(user, 5 SECONDS, TRUE, src))
		to_chat(user, "<span class='notice'>You stop repairing [src].</span>")
		return

	if(!user.Adjacent(src))
		return

	if(!user.get_active_hand() == tool_used)
		return

	switch(broken)
		if(REMOVE_OLD_PARTS)
			user.put_in_hands(new /obj/item/stock_parts/cell/medbeam)

		if(WELD_SHELL)
			if(!tool_used.tool_use_check(user, 1))
				return

		if(INSTALL_LENS)
			var/obj/item/stack/sheet/glass/lens = tool_used
			if(!istype(lens))
				return
			if(!lens.use(5))
				to_chat(user, "<span class='warning'>You need [5 - lens.get_amount()] more [lens] to repair [src]'s electronics.</span>")
				return

		if(INSTALL_ELECTRONICS)
			var/obj/item/stack/cable_coil/cable = tool_used
			if(!istype(cable))
				return
			if(!cable.use(10))
				to_chat(user, "<span class='warning'>You need [10 - cable.get_amount()] more [cable] to repair [src]'s electronics.</span>")
				return

		if(INSTALL_CELL)
			var/obj/item/stock_parts/cell/medbeam/battery = tool_used
			if(!istype(battery))
				return
			if(!user.get_active_hand() == battery)
				to_chat(user, "<span class='warning'>You lost [src]'s battery.</span>")
				return
			qdel(battery)

		if(SCREWDRIVER_CLOSED)
			QDEL_NULL(fire_particles)

	broken = next_broken_state

#undef SCREWDRIVER_OPEN
#undef REMOVE_OLD_PARTS
#undef WELD_SHELL
#undef INSTALL_LENS
#undef INSTALL_ELECTRONICS
#undef INSTALL_CELL
#undef MULTITOOL_ELECTRONICS
#undef SCREWDRIVER_CLOSED

/obj/item/stock_parts/cell/medbeam
	name = "beamgun cell"
	desc = "A cell that fell out of a beamgun. It cannot be reused until fully charged. Only this brand of battery is compatible with medical beamguns."
	starting_charge = 0

//////////////////////////////Mech Version///////////////////////////////
/obj/item/gun/medbeam/mech
	mounted = TRUE

/obj/item/gun/medbeam/mech/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj
