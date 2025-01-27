/mob/living/simple_animal/hostile/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm."
	icon = 'icons/mob/eldritch_mobs.dmi'
	gender = NEUTER
	mob_biotypes = NONE
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help = "thinks better of touching"
	response_disarm = "flails at"
	response_harm = "reaps"
	speak_emote = list("screams")
	speak_chance = 1
	speed = 0
	stop_automated_movement = TRUE
	a_intent = INTENT_HARM
	AIStatus = AI_OFF
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself."
	loot = list(/obj/effect/gibspawner/human)
	faction = list("heretic")

	/// Innate spells that are added when a beast is created.
	var/list/actions_to_add

/mob/living/simple_animal/hostile/heretic_summon/Initialize(mapload)
	. = ..()
	for(var/spell in actions_to_add)
		var/datum/spell/new_spell = new spell(src)
		AddSpell(new_spell)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "An incomprehensible abomination. Everywhere it steps, it appears to be actively seeping life out of its surroundings."
	icon_state = "rust_walker_s"
	icon_living = "rust_walker_s"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/spell/aoe/rust_conversion/construct,
		/datum/spell/fireball/rust_wave/short,
	)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_appearance(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Life(seconds, times_fired)
	if(stat == DEAD)
		return ..()

	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjustBruteLoss(-1.5)
		adjustFireLoss(-1.5)

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "An incomprehensible abomination. As it moves, a thin trail of ash follows, appearing from seemingly nowhere."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash,
		/datum/spell/pointed/cleave,
		/datum/spell/fire_sworn,
	)

/mob/living/simple_animal/hostile/heretic_summon/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "An abomination made from several limbs and organs. Every moment you stare at it, it appears to shift and change unnaturally."
	icon_state = "stalker"
	icon_living = "stalker"
	status_flags = CANPUSH
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash,
		/datum/spell/emplosion/heretic,
	)

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "An abomination stitched together from a few severed arms and one lost eye."
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 65
	health = 65
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	loot = list(/obj/effect/gibspawner/human, /obj/item/organ/external/arm, /obj/item/organ/internal/eyes)
	actions_to_add = list(
		/datum/spell/ethereal_jaunt/ash/long,
		/datum/spell/remotetalk/eldritch,
		/datum/spell/blind/eldritch,
	)
	/// The UID to the last target we smacked. Hitting targets consecutively does more damage.
	var/last_target

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(user == src) // Easy to hit yourself + very fragile = accidental suicide, prevent that
		return

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/AttackingTarget()
	if(target.UID() == last_target)
		melee_damage_lower = min(melee_damage_lower + 5, 30)
		melee_damage_upper = min(melee_damage_upper + 5, 35)
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)

	. = ..()
	if(!.)
		return

	SpinAnimation(5, 1)
	last_target = target.UID()

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/rotation_degree = (360 / 3)
	if(movement_dir & WEST || movement_dir & SOUTH)
		rotation_degree *= -1

	var/matrix/to_turn = matrix(transform)
	to_turn = turn(transform, rotation_degree)
	animate(src, transform = to_turn, time = 0.1 SECONDS)
