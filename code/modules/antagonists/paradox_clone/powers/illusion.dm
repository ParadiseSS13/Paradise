/datum/spell/paradox_spell/self/illusion
	name = "Illusion"
	desc = "You strain and release a piece of yourself into this world - an illusion that attacks everybody. Exists for twenty seconds, useful for finishing off recumbent targets, blocking the passage or stalling for time."
	action_icon_state = "paradox_illusion"
	base_cooldown = 140 SECONDS

/datum/spell/paradox_spell/self/illusion/cast(list/targets, mob/living/user = usr)

	var/mob/living/simple_animal/hostile/illusion/paradox/P
	var/path = /mob/living/simple_animal/hostile/illusion/paradox

	P = new path(get_turf(user))

	do_sparks(rand(2, 4), FALSE, user)

	P.Copy_Parent(user, life = 20 SECONDS, health = 400, damage = 12, replicate = 0.2)

	add_attack_logs(user, P, "(Paradox Clone) Illusion")
