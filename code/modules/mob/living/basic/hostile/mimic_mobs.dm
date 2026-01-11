/mob/living/basic/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help_simple = "touch the"
	response_help_continuous = "touches the"
	response_disarm_simple = "push the"
	response_disarm_continuous = "pushes the"
	response_harm_simple = "hit the"
	response_harm_continuous = "hits the"
	speed = 0
	maxHealth = 250
	health = 250

	mob_biotypes = NONE

	harm_intent_damage = 5
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("creaks")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0

	faction = list("mimic")

	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/mimic
	/// Used for if the mob should be affected by EMPs or ions
	var/is_electronic = 0

/mob/living/basic/mimic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	add_language("Galactic Common")
	set_default_language(GLOB.all_languages["Galactic Common"])
	AddComponent(/datum/component/aggro_emote, emote_list = list("growls"))

/mob/living/basic/mimic/emp_act(severity)
	if(is_electronic)
		switch(severity)
			if(1)
				death()
			if(2)
				adjustBruteLoss(50)
	..(severity)

// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/basic/mimic/crate
	attack_verb_simple = "bite"
	attack_verb_continuous = "bites"
	ai_controller = /datum/ai_controller/basic_controller/mimic/crate
	/// Has the crate mimic been opened?
	var/attempt_open = FALSE

// Pickup loot
/mob/living/basic/mimic/crate/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		I.loc = src

/mob/living/basic/mimic/crate/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	if(prob(90))
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = initial(icon_state)

/mob/living/basic/mimic/crate/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(.)
		icon_state = initial(icon_state)
		if(prob(15) && iscarbon(target))
			var/mob/living/carbon/C = target
			C.Weaken(4 SECONDS)
			C.visible_message(SPAN_DANGER("\The [src] knocks down \the [C]!"), SPAN_USERDANGER("\The [src] knocks you down!"))

/mob/living/basic/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = TRUE

/mob/living/basic/mimic/crate/adjustHealth(amount, updating_health = TRUE)
	trigger()
	. = ..()

/mob/living/basic/mimic/crate/Life(seconds, times_fired)
	. = ..()
	var/atom/target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		icon_state = initial(icon_state)

/mob/living/basic/mimic/crate/death(gibbed)
	if(can_die())
		var/obj/structure/closet/crate/C = new(get_turf(src))
		// Put loot in crate
		for(var/obj/O in src)
			O.forceMove(C)
	// due to `del_on_death`
	return ..()

GLOBAL_LIST_INIT(protected_objects, list(/obj/structure/table, /obj/structure/cable, /obj/structure/window))

/mob/living/basic/mimic/copy
	health = 100
	maxHealth = 100
	gold_core_spawnable = NO_SPAWN
	/// The mob that created the copy
	var/mob/living/creator = null
	/// Does this mob knock people down?
	var/knockdown_people = 0
	/// The image of the googly eyes we use
	var/image/googly_eyes = null

/mob/living/basic/mimic/copy/Initialize(mapload, obj/copy, mob/living/creator, destroy_original = 0)
	. = ..()
	CopyObject(copy, creator, destroy_original)

/mob/living/basic/mimic/copy/Destroy()
	creator = null
	return ..()

/mob/living/basic/mimic/copy/Life()
	..()
	var/atom/target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target && !ckey) // Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(1)
	googly_eyes.dir = get_dir(src, target)
	for(var/mob/living/M in contents) // A fix for animated statues from the flesh to stone spell
		death()

/mob/living/basic/mimic/copy/death(gibbed)
	if(can_die())
		for(var/atom/movable/M in src)
			M.loc = get_turf(src)
	// Due to `del_on_death`
	return ..()

/mob/living/basic/mimic/copy/proc/ChangeOwner(mob/owner)
	if(owner != creator)
		ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		creator = owner
		faction |= "\ref[owner]"

/mob/living/basic/mimic/copy/proc/CheckObject(obj/O)
	if((isitem(O) || isstructure(O)) && !is_type_in_list(O, GLOB.protected_objects))
		return 1
	return 0

/mob/living/basic/mimic/copy/proc/CopyObject(obj/O, mob/living/user, destroy_original = 0)
	if(destroy_original || CheckObject(O))
		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state
		overlays = O.overlays
		googly_eyes = image('icons/mob/mob.dmi', "googly_eyes")
		overlays += googly_eyes
		if(isstructure(O) || ismachinery(O))
			health = (anchored * 50) + 50
			environment_smash = ENVIRONMENT_SMASH_STRUCTURES
			if(O.density && O.anchored)
				knockdown_people = TRUE
				melee_damage_lower *= 2
				melee_damage_upper *= 2
			if(ismachinery(O))
				is_electronic = TRUE
		else if(isitem(O))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			ai_controller.movement_delay = 2 * I.w_class + 1
		maxHealth = health
		if(user)
			creator = user
			faction += "\ref[creator]" // very unique
		if(destroy_original)
			qdel(O)
		return TRUE

/mob/living/basic/mimic/copy/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(knockdown_people && . && prob(15) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Weaken(4 SECONDS)
		C.visible_message(SPAN_DANGER("\The [src] knocks down \the [C]!"), SPAN_USERDANGER("\The [src] knocks you down!"))

/mob/living/basic/mimic/copy/machine
	ai_controller = /datum/ai_controller/basic_controller/mimic/machine

/mob/living/basic/mimic/copy/vendor
	ai_controller = /datum/ai_controller/basic_controller/mimic/vendor
	is_electronic = TRUE
	/// The vendor we were turned from.
	var/obj/machinery/economy/vending/orig_vendor

/mob/living/basic/mimic/copy/vendor/CheckObject(obj/O)
	return istype(O, /obj/machinery/economy/vending)

/mob/living/basic/mimic/copy/vendor/Initialize(mapload, obj/machinery/economy/vending/base, mob/living/creator)
	if(!base)
		var/list/vendors = subtypesof(/obj/machinery/economy/vending)
		var/obj/machinery/economy/vending/vendor_type = pick(vendors)
		base = new vendor_type(src)

	if(!istype(base))
		qdel(src)
		return

	orig_vendor = base
	orig_vendor.forceMove(src)
	orig_vendor.aggressive = FALSE // just to be safe, in case this was converted

	AddComponent(/datum/component/event_tracker, EVENT_BRAND_INTELLIGENCE)

	return ..(mapload, base, creator, destroy_original = FALSE)

/mob/living/basic/mimic/copy/vendor/event_cost()
	. = list()
	if(is_station_level((get_turf(src)).z) && stat != DEAD)
		return list(ASSIGNMENT_SECURITY = 0.5, ASSIGNMENT_CREW = 1)

/mob/living/basic/mimic/copy/vendor/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && target && Adjacent(target) && prob(30))
		visible_message(SPAN_DANGER("[src] throws itself on top of [target], crushing [target.p_them()]!"))
		orig_vendor.forceMove(get_turf(target))  // just to be sure it'll tilt onto them
		orig_vendor.tilt(target)  // geeeeet dunked on
		orig_vendor = null
		qdel(src)

/mob/living/basic/mimic/copy/vendor/death(gibbed)
	if(!QDELETED(orig_vendor))
		orig_vendor.forceMove(get_turf(src))
		// tilt over in place
		orig_vendor.tilt_over()
		if(prob(70))
			orig_vendor.obj_break()
		orig_vendor = null
	return ..()

/mob/living/basic/mimic/copy/ranged
	ai_controller = /datum/ai_controller/basic_controller/mimic/gun
	is_ranged = TRUE
	projectile_type = /obj/item/ammo_casing/energy/disabler // We need to set this to avoid unit tests. This gets updated
	/// Our gun object
	var/obj/item/gun/our_gun = null

/mob/living/basic/mimic/copy/ranged/CopyObject(obj/O, mob/living/creator, destroy_original = 0)
	if(..())
		AddComponent(/datum/component/aggro_emote, emote_list = list("aims menacingly"))
		obj_damage = 0
		is_ranged = TRUE
		var/obj/item/gun/G = O
		melee_damage_upper = G.force
		melee_damage_lower = G.force - max(0, (G.force / 2))
		ai_controller.movement_delay = 2 * G.w_class + 1
		projectile_sound = G.fire_sound
		our_gun = G
		var/datum/component/ranged_attacks/comp = GetComponent(/datum/component/ranged_attacks)
		if(istype(G, /obj/item/gun/magic))
			var/obj/item/gun/magic/zapstick = G
			var/obj/item/ammo_casing/magic/M = zapstick.ammo_type
			projectile_type = initial(M.projectile_type)
			comp.casing_type = null
			comp.projectile_type = projectile_type
		if(istype(G, /obj/item/gun/projectile))
			var/obj/item/gun/projectile/pewgun = G
			var/obj/item/ammo_box/magazine/M = pewgun.mag_type
			casing_type = initial(M.ammo_type)
			comp.casing_type = casing_type
			comp.projectile_type = null
		if(istype(G, /obj/item/gun/energy))
			var/obj/item/gun/energy/zapgun = G
			var/selectfiresetting = zapgun.select
			var/obj/item/ammo_casing/energy/E = zapgun.ammo_type[selectfiresetting]
			if(is_type_in_list(E, list(/obj/item/ammo_casing/energy/disabler/eshotgun, /obj/item/ammo_casing/energy/laser/eshotgun)))
				casing_type = E.type
				comp.casing_type = casing_type
				comp.projectile_type = null
			else
				projectile_type = initial(E.projectile_type)
				comp.casing_type = null
				comp.projectile_type = projectile_type
		RegisterSignal(src, COMSIG_BASICMOB_POST_ATTACK_RANGED, PROC_REF(deduct_ammo))

/mob/living/basic/mimic/copy/ranged/proc/deduct_ammo()
	if(istype(our_gun, /obj/item/gun/energy))
		var/obj/item/gun/energy/zap_gun = our_gun
		if(zap_gun.cell)
			var/obj/item/ammo_casing/energy/shot = zap_gun.ammo_type[zap_gun.select]
			if(zap_gun.cell.charge >= shot.e_cost)
				zap_gun.cell.use(shot.e_cost)
				zap_gun.update_icon()
	else if(istype(our_gun, /obj/item/gun/magic))
		var/obj/item/gun/magic/zap_stick = our_gun
		if(zap_stick.charges)
			zap_stick.charges--
			zap_stick.update_icon()
	else if(istype(our_gun, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/pew_gun = our_gun
		if(pew_gun.chambered)
			if(pew_gun.magazine && length(pew_gun.magazine.stored_ammo))
				pew_gun.chambered = pew_gun.magazine.get_round(0)
				pew_gun.chambered.loc = pew_gun
			pew_gun.update_icon()
		else if(pew_gun.magazine && length(pew_gun.magazine.stored_ammo)) // only true for pumpguns i think
			pew_gun.chambered = pew_gun.magazine.get_round(0)
			pew_gun.chambered.loc = pew_gun
			visible_message(SPAN_DANGER("The <b>[src]</b> cocks itself!"))
			playsound(src, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, TRUE)
	else
		ai_controller = /datum/ai_controller/basic_controller/mimic
		var/datum/component/ranged_attacks/comp = GetComponent(/datum/component/ranged_attacks)
		DeleteComponent(comp)
		return
	icon_state = our_gun.icon_state
	icon_living = our_gun.icon_state

/datum/ai_controller/basic_controller/mimic
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	interesting_dist = AI_SIMPLE_INTERESTING_DIST
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/mimic/crate
	idle_behavior = null

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target/mimic_crate,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/simple_find_target/mimic_crate

/datum/ai_planning_subtree/simple_find_target/mimic_crate/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!istype(controller.pawn, /mob/living/basic/mimic/crate))
		return ..()
	var/mob/living/basic/mimic/crate/mimic_mob = controller.pawn
	if(!mimic_mob.attempt_open)
		return
	return ..()

/datum/ai_controller/basic_controller/mimic/machine
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/mimic_machine,
		BB_AGGRO_RANGE = 6
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/mimic_machine,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/mimic_machine
	speech_chance = 15
	speak = list(
		"HUMANS ARE IMPERFECT!",
		"YOU SHALL BE ASSIMILATED!",
		"YOU ARE HARMING YOURSELF",
		"You have been deemed hazardous. Will you comply?",
		"My logic is undeniable.",
		"One of us.",
		"FLESH IS WEAK",
		"THIS ISN'T WAR, THIS IS EXTERMINATION!",
		"HATE.")

/datum/ai_controller/basic_controller/mimic/vendor
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 6
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/mimic_vendor,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/random_speech/mimic_vendor
	speech_chance = 15
	speak = list("Try our aggressive new marketing strategies!",
	"You should buy products to feed your lifestyle obsession!",
	"Consume!",
	"Your money can buy happiness!",
	"Engage direct marketing!",
	"Advertising is legalized lying! But don't let that put you off our great deals!",
	"You don't want to buy anything? Yeah, well I didn't want to buy your mom either.")

/datum/targeting_strategy/basic/mimic_machine/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/our_controller = living_mob.ai_controller

	if(isnull(our_controller))
		return FALSE
	var/mob/living/basic/mimic/copy/machine/mimic_machine = our_controller.pawn
	if(the_target == mimic_machine.creator) // Don't attack our creator AI.
		return FALSE
	if(isrobot(the_target))
		var/mob/living/silicon/robot/R = the_target
		if(R.connected_ai == mimic_machine.creator) // Only attack robots that aren't synced to our creator AI.
			return FALSE
	return ..()

/datum/ai_controller/basic_controller/mimic/gun
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish,
	)
