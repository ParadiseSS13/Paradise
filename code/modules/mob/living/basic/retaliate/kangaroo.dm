/mob/living/basic/kangaroo
	name = "Kangaroo"
	real_name = "Kangaroo"
	desc = "A large marsupial herbivore. It has powerful hind legs, with nails that resemble long claws."
	icon_state = "kangaroo" // Credit: FoS
	icon_living = "kangaroo"
	icon_dead = "kangaroo_dead"
	icon_gib = "kangaroo_dead"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	response_help_simple = "pet"
	response_help_continuous = "pets"
	speak_emote = list("barks")
	maxHealth = 150
	health = 150
	butcher_results = list(/obj/item/food/meat/kangaroo = 6)
	melee_damage_lower = 5 // avg damage 12.5 without kick, (12.5+12.5+60)/3=25 with kick
	melee_damage_upper = 20
	melee_attack_cooldown_min = 1.5 SECONDS
	melee_attack_cooldown_max = 2.5 SECONDS
	attack_verb_simple = "slash"
	attack_verb_continuous = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg' // they have nails that work like claws, so, slashing sound
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	speed = -1 // '-1' converts to 1.5 total move delay, or 6.6 tiles/sec movespeed
	var/attack_cycles = 0
	var/attack_cycles_max = 3
	step_type = FOOTSTEP_MOB_SHOE
	ai_controller = /datum/ai_controller/basic_controller/simple/retaliate

/mob/living/basic/kangaroo/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	// Leap spell, player-only usage
	AddSpell(new /datum/spell/leap)

/mob/living/basic/kangaroo/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(client && a_intent != INTENT_HARM)
		return ..() // Do not allow player-controlled roos on non-attack intents to 'prime' their kick by nuzzling people.

	var/mob/living/L = target
	if(!istype(L))
		return ..() // Do not do further checks if we somehow end up attacking something not alive (like a window).

	if(L.stat == DEAD)
		return ..() // Do not allow player-controlled roos to prime their kick by attacking corpses.

	attack_cycles++
	if(attack_cycles < attack_cycles_max)
		// Most of the time, do a standard attack...
		return ..()

	// ... but, every attack_cycles_max attacks on a living mob, do a powerful disemboweling kick instead
	attack_cycles = 0
	attack_verb_simple = "VICIOUSLY KICK"
	attack_verb_continuous = "VICIOUSLY KICKS"
	melee_damage_lower = 60
	melee_damage_upper = 60
	. = ..()

	var/rookick_dir = get_dir(src, L)
	var/turf/general_direction = get_edge_target_turf(L, rookick_dir)
	L.visible_message("<span class='danger'>[L] is kicked hard!</span>", "<span class='userdanger'>The kangaroo kick sends you flying mate!</span>")
	L.throw_at(general_direction, 10, 2)

	attack_verb_simple = initial(attack_verb_simple)
	attack_verb_continuous = initial(attack_verb_continuous)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)

