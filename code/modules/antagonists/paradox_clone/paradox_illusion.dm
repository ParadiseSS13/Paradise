/mob/living/simple_animal/hostile/illusion/paradox
	name = "paradox illusion"
	desc = "It's something... Between real and fake..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	mob_biotypes = NONE
	melee_damage_lower = 5
	melee_damage_upper = 10
	a_intent = INTENT_HARM
	melee_damage_type = STAMINA
	pass_flags = PASSTABLE | PASSMOB | PASSGRILLE | LETPASSTHROW | PASSFENCE | PASSDOOR | PASSGLASS | PASSGIRDER
	attacktext = "grabs"
	attack_sound = 'sound/hallucinations/growl3.ogg'
	deathmessage = "vanishes..."
	del_on_death = TRUE
	dodging = FALSE
	move_to_delay = 2
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 0.2, BURN = 0.2, TOX = 0, CLONE = 0.2, STAMINA = 0, OXY = 0)
	speed = 0.5
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = NO_SPAWN
	see_in_dark = 99
	sight = SEE_MOBS
	maxHealth = 200
	health = 200
	faction = list(ROLE_PARADOX_CLONE) // don't attack paradox clones
	life_span = 12 SECONDS // how long until they despawn
	var/mob/living/parent // okay I'm autodoccing it this is who is the parent of this illusion just who summoned it

	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

/mob/living/simple_animal/hostile/illusion/Life()
	return

/mob/living/simple_animal/hostile/illusion/paradox/Found(var/atom/A)
	var/mob/living/T = A
	if(is_paradox_clone(A) || !T.mind || T.stat == DEAD)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/illusion/paradox/CanAttack(var/atom/the_target)
	var/mob/living/T = the_target
	if(is_paradox_clone(T) || !T.mind || T.stat == DEAD)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/illusion/paradox/proc/GetOppositeDir(var/dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(SOUTH)
			return NORTH
		if(EAST)
			return WEST
		if(WEST)
			return EAST
		if(SOUTHWEST)
			return NORTHEAST
		if(NORTHWEST)
			return SOUTHEAST
		if(NORTHEAST)
			return SOUTHWEST
		if(SOUTHEAST)
			return NORTHWEST
	return FALSE

/mob/living/simple_animal/hostile/illusion/paradox/attack_hand(mob/living/user)
	if(user.a_intent != INTENT_HELP && (!is_paradox_clone(user)))
		return ..()

	var/turf/i_turf = get_turf(src)
	for(var/atom/check in (i_turf.contents - src))
		if(check.density)
			return ..()

	var/direction = get_dir(src, user)
	step(src, direction)
	step(user, GetOppositeDir(direction))

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

/mob/living/simple_animal/hostile/illusion/paradox/AttackingTarget()
	..()
	var/mob/living/carbon/human/H = target
	if(prob(2))
		H.AdjustStunned(1)
	if(prob(20))
		H.AdjustConfused(10)
	if(prob(40))
		H.AdjustSilence(20)
	if(prob(10))
		H.AdjustSlowedDuration(4)
	if(prob(60))
		H.AdjustSlur(8)
	if(prob(6))
		H.AdjustParalysis(2)

	if(H.staminaloss >= 100)
		H.adjustOxyLoss(rand(0, 20))
