/mob/living/simple_animal/hostile/retaliate/kangaroo
	name = "Kangaroo"
	real_name = "Kangaroo"
	voice_name = "unidentifiable voice"
	desc = "A large marsupial herbivore. It has powerful hind legs, with nails that resemble long claws."
	icon_state = "kangaroo" // Credit: FoS
	icon_living = "kangaroo"
	icon_dead = "kangaroo_dead"
	icon_gib = "kangaroo_dead"
	turns_per_move = 8
	response_help = "pets"
	emote_hear = list("bark")
	maxHealth = 150
	health = 150
	harm_intent_damage = 3
	melee_damage_lower = 5 // avg damage 12.5 without kick, (12.5+12.5+60)/3=25 with kick
	melee_damage_upper = 20
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg' // they have nails that work like claws, so, slashing sound
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	move_to_delay = 4 // at 20ticks/sec, this is 5 tile/sec movespeed, about the same as a 'fast human'.
	speed = -1 // '-1' converts to 1.5 total move delay, or 6.6 tiles/sec movespeed
	var/attack_cycles = 0
	var/attack_cycles_max = 3

/mob/living/simple_animal/hostile/retaliate/kangaroo/New()
	. = ..()
	// Leap spell, player-only usage
	AddSpell(new /obj/effect/proc_holder/spell/targeted/leap)

/mob/living/simple_animal/hostile/retaliate/kangaroo/AttackingTarget()
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
	attacktext = "VICIOUSLY KICKS"
	melee_damage_lower = 60
	melee_damage_upper = 60
	. = ..()

	var/rookick_dir = get_dir(src, L)
	var/turf/general_direction = get_edge_target_turf(L, rookick_dir)
	L.visible_message("<span class='danger'>[L] is kicked hard!</span>", "<span class='userdanger'>The kangaroo kick sends you flying mate!</span>")
	L.throw_at(general_direction, 10, 2)

	attacktext = initial(attacktext)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)

