/mob/living/basic/swarmer
	name = "swarmer"
	desc = "Robotic constructs of unknown design, swarmers seek only to consume materials and replicate themselves indefinitely."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 70
	maxHealth = 70
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = BURN
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	light_color = LIGHT_COLOR_CYAN
	attack_verb_continuous = "shocks"
	attack_verb_simple = "shock"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	attack_sound = 'sound/effects/empulse.ogg'
	faction = list("swarmer")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 500
	speak_emote = list("tones")
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	death_message = "explodes with a sharp pop!"
	basic_mob_flags = DEL_ON_DEATH
	step_type = FOOTSTEP_MOB_CLAW
	is_ranged = TRUE
	projectile_type = /obj/item/projectile/beam/disabler
	projectile_sound = 'sound/weapons/taser2.ogg'
	ai_controller = /datum/ai_controller/basic_controller/swarmer

	/// Resources the swarmer gains from consuming things
	var/resources = 0
	/// Maximum possible resources a swarmer can have
	var/resource_max = 100

/mob/living/basic/swarmer/Initialize(mapload)
	. = ..()
	add_language("Swarmer", 1)
	verbs -= /mob/living/verb/pulled
	updatename()

/mob/living/basic/swarmer/proc/updatename()
	real_name = "Swarmer [rand(100,999)]-[pick("kappa","sigma","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]"
	name = real_name

/mob/living/basic/swarmer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Resources:", "[resources] / [resource_max]")

/mob/living/basic/swarmer/emp_act()
	if(health > 35)
		adjustHealth(-35)
	else
		death()

/mob/living/basic/swarmer/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	face_atom(target)
	if(iswallturf(target))
		disintegrate_wall(target)
		return FALSE
	if(ismachinery(target))
		disintegrate_machine(target)
		return FALSE
	if(isitem(target))
		integrate(target)
		return FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			disintegrate_mob(target)
			return FALSE
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if((!C.IsWeakened()))
				L.apply_damage(30, STAMINA)
				C.Confused(6 SECONDS)
				C.Jitter(6 SECONDS)
				return ..()
			else if(C.canBeHandcuffed() && !C.handcuffed)
				var/obj/item/restraints/handcuffs/energy/Z = new /obj/item/restraints/handcuffs/energy(src)
				Z.apply_cuffs(target, src)
				return FALSE
			else if(!(C in GLOB.swarmer_list))
				disintegrate_mob(target)
				return FALSE
			// It's stunned, cuffed, but already nabbed? Make it go away.
			disappear_mob(target)
			return FALSE
		if(issilicon(target))
			var/mob/living/silicon/S = target
			S.apply_damage(30, STAMINA)
	return ..()

/mob/living/basic/swarmer/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(!(flags & SHOCK_TESLA))
		return FALSE
	return ..()

/mob/living/basic/swarmer/proc/disintegrate_wall(turf/simulated/wall/target)
	if(istype(target, /turf/simulated/wall/indestructible))
		return

	new /obj/effect/temp_visual/swarmer/disintegration(target.loc)
	if(!do_after_once(src, 1 SECONDS, target = target, attempt_cancel_message = "You stop disintegrating the wall."))
		return
	resources += 8
	target.Destroy()

/mob/living/basic/swarmer/proc/disintegrate_machine(obj/machinery/target)
	if(isairlock(target))
		if(spacecheck(target))
			return

	new /obj/effect/temp_visual/swarmer/dismantle(target.loc)
	if(!do_after_once(src, 2.5 SECONDS, target = target, attempt_cancel_message = "You stop disintegrating the machine."))
		return
	resources += 10
	target.Destroy()

/mob/living/basic/swarmer/proc/integrate(obj/item/target)
	new /obj/effect/temp_visual/swarmer/integrate(target.loc)
	resources += 10
	qdel(target)

/mob/living/basic/swarmer/proc/disintegrate_mob(mob/living/target)
	new /obj/effect/temp_visual/swarmer/integrate(target.loc)
	if(!do_after_once(src, 5 SECONDS, target = target, attempt_cancel_message = "You stop disintegrating the mob."))
		return
	resources += 50
	target.apply_damage(150, BRUTE)
	target.apply_damage(150, BURN)
	GLOB.swarmer_list += target

/mob/living/basic/swarmer/proc/disappear_mob(mob/target)
	if(!is_station_level(z))
		to_chat(src, "<span class='warning'>Our bluespace transceiver cannot locate a viable bluespace link, our teleportation abilities are useless in this area.</span>")
		return

	to_chat(src, "<span class='info'>Attempting to remove this being from our presence.</span>")

	if(!do_mob(src, target, 3 SECONDS))
		return

	var/turf/simulated/floor/F
	F = find_safe_turf(zlevels = z)

	if(!F)
		return
	// If we're getting rid of a human, slap some energy cuffs on
	// them to keep them away from us a little longer
	do_sparks(4, 0, target)
	playsound(src,'sound/effects/sparks4.ogg', 50, TRUE)
	do_teleport(target, F, 0)


/mob/living/basic/swarmer/proc/spacecheck(atom/target)
	var/isonshuttle = istype(loc, /area/shuttle)
	for(var/turf/T in range(1, target))
		var/area/A = get_area(T)
		if(isspaceturf(T) || (!isonshuttle && (istype(A, /area/shuttle) || istype(A, /area/space))) || (isonshuttle && !istype(A, /area/shuttle)))
			to_chat(src, "<span class='warning'>Destroying this object has the potential to cause a hull breach. Aborting.</span>")
			return TRUE
		else if(istype(A, /area/station/engineering/engine/supermatter))
			to_chat(src, "<span class='warning'>Disrupting the containment of a supermatter crystal would not be to our benefit. Aborting.</span>")
			return TRUE
	return FALSE

/obj/structure/swarmer // Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "ui_light"
	layer = MOB_LAYER
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 30
	anchored = TRUE
	/// Light range
	var/lon_range = 1

/obj/structure/swarmer/Initialize(mapload)
	. = ..()
	set_light(lon_range)

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/swarmer/emp_act()
	..()
	qdel(src)

/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	max_integrity = 10

/obj/structure/swarmer/trap/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/basic/swarmer))
			playsound(loc,'sound/effects/snap.ogg',50, 1, -1)
			L.electrocute_act(100, src, 1, flags = SHOCK_NOGLOVES | SHOCK_ILLUSION)
			L.Weaken(10 SECONDS)
			qdel(src)
	..()

/obj/structure/swarmer/blockade
	name = "swarmer blockade"
	desc = "A quickly assembled energy blockade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	icon_state = "barricade"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 50

/obj/structure/swarmer/blockade/CanPass(atom/movable/O)
	if(istype(O, /mob/living/basic/swarmer))
		return 1
	if(istype(O, /obj/item/projectile/beam/disabler))
		return 1
