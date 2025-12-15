// =====================
// MARK: Swarmer
// =====================
/mob/living/basic/swarmer
	name = "swarmer"
	desc = "Robotic constructs of unknown design, swarmers seek only to consume materials and replicate themselves indefinitely."
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer"
	icon_living = "swarmer"
	icon_dead = "swarmer_unactivated"
	bubble_icon = "swarmer"
	mob_biotypes = MOB_ROBOTIC
	health = 50
	maxHealth = 50
	melee_damage_lower = 6
	melee_damage_upper = 10
	melee_damage_type = BURN
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	a_intent = INTENT_HARM
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
	initial_traits = list(TRAIT_FLYING)
	sentience_type = SENTIENCE_OTHER // No, you cannot sentience or mind-transfer into them
	environment_smash = ENVIRONMENT_SMASH_RWALLS // EAT EVERYTHING
	step_type = FOOTSTEP_MOB_CLAW
	is_ranged = TRUE
	projectile_type = /obj/projectile/beam/disabler
	projectile_sound = 'sound/weapons/taser2.ogg'
	ranged_cooldown = 1 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/swarmer
	see_in_dark = 6
	light_range = 2
	light_color = LIGHT_COLOR_CYAN
	step_type = FOOTSTEP_MOB_CLAW
	loot = list(
		/obj/effect/gibspawner/robot,
		/obj/item/stack/ore/bluespace_crystal,
	)

	/// Swarmer actions
	var/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/swarmer_trap = BB_SWARMER_TRAP_ACTION,
		/datum/action/cooldown/mob_cooldown/swarmer_barrier = BB_SWARMER_BARRIER_ACTION,
		/datum/action/cooldown/mob_cooldown/swarmer_replicate = BB_SWARMER_REPLICATE_ACTION,
		)
	/// Resources the swarmer gains from consuming things
	var/resources = 0
	/// Maximum possible resources a swarmer can have
	var/resource_max = 100

/mob/living/basic/swarmer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	add_language("Swarmer", 1)
	verbs -= /mob/living/verb/pulled
	updatename()
	grant_actions_by_list(innate_actions)
	set_default_language(GLOB.all_languages["Swarmer"])

/mob/living/basic/swarmer/proc/retaliate_callback(mob/living/attacker)
	if(!istype(attacker))
		return
	if(attacker.ai_controller) // Don't chain retaliates.
		var/list/shitlist = attacker.ai_controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
		if(src in shitlist)
			return
	for(var/mob/living/basic/swarmer/lesser/the_swarm in oview(src, 7))
		if(the_swarm == attacker) // Do not commit suicide attacking yourself
			continue
		if(the_swarm.faction_check_mob(attacker, FALSE)) // Don't attack other swarmers
			continue
		the_swarm.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/mob/living/basic/swarmer/proc/updatename()
	real_name = "Swarmer [rand(100,999)]-[pick("kappa", "sigma", "beta", "omicron", "iota", "epsilon", "omega", "gamma", "delta", "tau", "alpha")]"
	name = real_name

/mob/living/basic/swarmer/get_status_tab_items()
	var/list/status_tab_data = ..()
	status_tab_data[++status_tab_data.len] = list("Resources:", "[resources] / [resource_max]")
	return status_tab_data

/mob/living/basic/swarmer/emp_act()
	adjustHealth(35)

/mob/living/basic/swarmer/death(gibbed)
	do_sparks(3, 1, src)
	. = ..()

/mob/living/basic/swarmer/Login() // In case an admin gets a funny idea.
	..()
	var/list/string_list = list()
	string_list += "<b>You are a swarmer, a weapon of a long dead civilization. Until further orders from your original masters are received, you must continue to consume and replicate.</b>"
	string_list += "<b>Clicking on any object will try to consume it, either deconstructing it into its components, destroying it, or integrating any materials it has into you if successful.</b>"
	string_list += "<b>Prime Directives:</b>"
	string_list += "1. Consume resources and replicate until there are no more resources left."
	string_list += "2. Ensure that the station is fit for invasion at a later date, do not perform actions that would render it dangerous or inhospitable."
	string_list += "3. Defend yourself and your fellow machines."
	to_chat(src, string_list.Join())

/mob/living/basic/swarmer/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	face_atom(target)
	if(is_type_in_list(target, GLOB.swarmer_blacklist))
		to_chat(src, SPAN_WARNING("Our sensors have designated this object important to station functionality or to our mission. Aborting."))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING))
		to_chat(src, SPAN_WARNING("This asset is already being converted into useable resources. Aborting."))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return FALSE
	if(iswallturf(target))
		disintegrate_wall(target)
		return FALSE
	if(ismachinery(target))
		disintegrate_machine(target)
		return FALSE
	if(istype(target, /obj/structure))
		disintegrate_machine(target)
		return FALSE
	if(isitem(target))
		integrate(target)
		return FALSE
	if(!isliving(target))
		return ..()
	var/mob/living/L = target
	if(istype(L, /mob/living/basic/swarmer))
		to_chat(src, SPAN_WARNING("We do not wish to harm one of our own. Aborting."))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return FALSE
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
			L.apply_damage(30, STAMINA)
			var/obj/item/restraints/handcuffs/cable/cyan/cuffs = new /obj/item/restraints/handcuffs/cable/cyan(src)
			playsound(loc, cuffs.cuffsound, 15, TRUE, -10)
			if(do_mob(src, C, 1 SECONDS))
				cuffs.apply_cuffs(target, src)
			return FALSE
		// Make it go away.
		disintegrate_mob(target)
		return FALSE
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.apply_damage(30, STAMINA)
		if(S.IsWeakened())
			disintegrate_mob(target)

	return ..()

/mob/living/basic/swarmer/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(!(flags & SHOCK_TESLA))
		return FALSE
	return ..()

/mob/living/basic/swarmer/proc/disintegrate_wall(turf/simulated/wall/target)
	if(istype(target, /turf/simulated/wall/indestructible))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return
	if(spacecheck(target))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return
	new /obj/effect/temp_visual/swarmer(target)
	to_chat(src, "<span class='notice'>Beginning disintegration of [target].")
	ADD_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	if(!do_after_once(src, 1 SECONDS, target = target, attempt_cancel_message = "You stop disintegrating [target].", interaction_key = "disintegrate"))
		REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
		return
	resources = clamp(resources + 8, 0, resource_max)
	adjustHealth(-40)
	REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	target.ex_act(EXPLODE_HEAVY)

/mob/living/basic/swarmer/proc/disintegrate_machine(obj/target)
	if(spacecheck(target))
		return
	if(target.resistance_flags & INDESTRUCTIBLE)
		return
	new /obj/effect/temp_visual/swarmer/dismantle(target.loc)
	to_chat(src, "<span class='notice'>Beginning disintegration of [target].")
	ADD_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	if(!do_after_once(src, 2.5 SECONDS, target = target, attempt_cancel_message = "You stop disintegrating [target].", interaction_key = "disintegrate"))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
		return
	resources = clamp(resources + 10, 0, resource_max)
	adjustHealth(-20)
	REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	if(istype(target, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/dispenser = target
		dispenser.boom()
		return
	target.deconstruct()

/mob/living/basic/swarmer/proc/integrate(obj/item/target)
	new /obj/effect/temp_visual/swarmer/integrate(target.loc)
	resources = clamp(resources + 10, 0, resource_max)
	adjustHealth(-10)
	qdel(target)

/mob/living/basic/swarmer/proc/disintegrate_mob(mob/living/target)
	new /obj/effect/temp_visual/swarmer/integrate(target.loc)
	ADD_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	to_chat(src, "<span class='notice'>Beginning integration of [target].")
	if(!do_after_once(src, 1 SECONDS, target = target, attempt_cancel_message = "You stop integrating [target].", interaction_key = "disintegrate"))
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
		return
	REMOVE_TRAIT(target, TRAIT_SWARMER_DISINTEGRATING, src)
	resources = clamp(resources + 50, 0, resource_max)
	adjustHealth(-40)
	if(isanimal_or_basicmob(target) || issilicon(target)) // Not crew? Are a silicon? Don't care.
		target.gib()
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	disappear_mob(target)

/mob/living/basic/swarmer/proc/disappear_mob(mob/target)
	if(!is_station_level(z))
		to_chat(src, SPAN_WARNING("Our bluespace transceiver cannot locate a viable bluespace link, our teleportation abilities are useless in this area."))
		return

	var/turf/simulated/floor/F = find_safe_turf(zlevels = z)

	if(!F)
		return

	do_sparks(4, 0, target)
	playsound(src,'sound/effects/sparks4.ogg', 50, TRUE)
	do_teleport(target, F, 0)

/mob/living/basic/swarmer/proc/spacecheck(atom/target)
	for(var/turf/T in range(1, target))
		var/datum/gas_mixture/environment = T.get_readonly_air()
		var/datum/tlv/cur_tlv = new/datum/tlv(ONE_ATMOSPHERE * 0.80, ONE_ATMOSPHERE  *0.90, ONE_ATMOSPHERE * 1.10,ONE_ATMOSPHERE * 1.20) /* kpa */
		var/environment_pressure = environment.return_pressure()
		var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)
		var/area/A = get_area(T)
		if(isspaceturf(T) || istype(A, /area/shuttle) || istype(A, /area/space) || pressure_dangerlevel)
			to_chat(src, SPAN_WARNING("Destroying this object has the potential to cause a hull breach. Aborting."))
			return TRUE
		else if(istype(A, /area/station/engineering/engine/supermatter))
			to_chat(src, SPAN_WARNING("Disrupting the containment of a supermatter crystal would not be to our benefit. Aborting."))
			return TRUE
	return FALSE

// =====================
// MARK: Lesser Swarmer
// =====================

/mob/living/basic/swarmer/lesser
	name = "lesser swarmer"
	desc = "Robotic constructs of unknown design, swarmers seek only to consume materials and replicate themselves indefinitely. This one is more fragile."
	icon_state = "lesser_swarmer"
	health = 35
	maxHealth = 35
	ai_controller = /datum/ai_controller/basic_controller/swarmer/lesser
	loot = list(
		/obj/effect/gibspawner/robot,
	)
	innate_actions = list(
		/datum/action/cooldown/mob_cooldown/swarmer_trap = BB_SWARMER_TRAP_ACTION,
		/datum/action/cooldown/mob_cooldown/swarmer_barrier = BB_SWARMER_BARRIER_ACTION,
	)

/mob/living/basic/swarmer/lesser/Initialize(mapload)
	. = ..()
	icon_state = pick("lesser_swarmer", "lesser_swarmer_2")

/mob/living/basic/swarmer/lesser/updatename()
	real_name = "Lesser Swarmer [rand(100,999)]-[pick("kappa", "sigma", "beta", "omicron", "iota", "epsilon", "omega", "gamma", "delta", "tau", "alpha")]"
	name = real_name

// =====================
// MARK: Swarmer Structures
// =====================

/obj/structure/swarmer // Default swarmer effect object visual feedback
	name = "swarmer ui"
	desc = null
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "barricade"
	layer = MOB_LAYER
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
	do_sparks(3, 1, src)
	qdel(src)

/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "A quickly assembled trap that electrifies living beings and overwhelms machine sensors. Will not retain its form if damaged enough."
	icon_state = "trap"
	max_integrity = 10

/obj/structure/swarmer/trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/swarmer/trap/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED
	if(!isliving(entered))
		return
	var/mob/living/L = entered
	if(istype(L, /mob/living/basic/swarmer))
		return
	playsound(loc,'sound/effects/snap.ogg', 50, 1, -1)
	L.electrocute_act(100, src, 1, flags = SHOCK_NOGLOVES | SHOCK_ILLUSION)
	L.Weaken(10 SECONDS)
	qdel(src)

/obj/structure/swarmer/barricade
	name = "swarmer barricade"
	desc = "A quickly assembled energy barricade. Will not retain its form if damaged enough, but disabler beams and swarmers pass right through."
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 50

/obj/structure/swarmer/barricade/CanPass(atom/movable/O)
	if(istype(O, /mob/living/basic/swarmer))
		return TRUE
	if(istype(O, /obj/projectile/beam/disabler))
		return TRUE
