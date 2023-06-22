#define CHASER_BURST 1
#define MAGIC_BOX 2
#define PANDORA_TELEPORT 3
#define AOE_SQUARES 4
#define MAX_CHASERS 3

/**
 * # Pandora
 *
 * A box with a similar design to the Hierophant which trades large, single attacks for more frequent smaller ones.
 * As it's health gets lower, the time between it's attacks decrease.
 * It's attacks are as follows:
 * - Fires hierophant blasts in a straight line.  Can only fire in a straight line in 8 directions, being the diagonals and cardinals.
 * - Creates a box of hierophant blasts around the target.  If they try to run away to avoid it, they'll very likely get hit.
 * - Teleports the pandora from one location to another, almost identical to Hierophant.
 * - Spawns a 7x7 AOE at the location of choice, spreading out from the center.
 * Pandora's fight mirrors Hierophant's closely, but has stark differences in attack effects.  Instead of long-winded dodge times and long cooldowns, Pandora constantly attacks the opponent, but leaves itself open for attack.
 */

/mob/living/simple_animal/hostile/asteroid/elite/pandora
	name = "pandora"
	desc = "A large magic box with similar power and design to the Hierophant.  Once it opens, it's not easy to close it."
	icon_state = "pandora"
	icon_living = "pandora"
	icon_aggro = "pandora"
	icon_dead = "pandora_dead"
	icon_gib = "syndicate_gib"

	maxHealth = 1000
	health = 1000
	melee_damage_lower = 15
	melee_damage_upper = 15
	armour_penetration_percentage = 50
	attacktext = "smashes into the side of"
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	throw_message = "merely dinks off of the"
	ranged_cooldown_time = 20
	speed = 2
	move_to_delay = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/magic/repulse.ogg'
	deathmessage = "'s lights flicker, before its top part falls down."
	loot_drop = /obj/item/clothing/accessory/necklace/pandora_hope

	attack_action_types = list(/datum/action/innate/elite_attack/chaser_burst,
								/datum/action/innate/elite_attack/magic_box,
								/datum/action/innate/elite_attack/pandora_teleport,
								/datum/action/innate/elite_attack/aoe_squares)

	var/sing_shot_length = 8
	var/cooldown_time = 2 SECONDS
	var/chaser_speed = 3
	var/recalculation_speed = 4 //How many times chasers moves before recalculating

/datum/action/innate/elite_attack/chaser_burst
	name = "Chaser Burst"
	button_icon_state = "singular_shot"
	chosen_message = "<span class='boldwarning'>You fire a chaser after all mobs in view.</span>"
	chosen_attack_num = CHASER_BURST

/datum/action/innate/elite_attack/magic_box
	name = "Magic Box"
	button_icon_state = "magic_box"
	chosen_message = "<span class='boldwarning'>You are now attacking with a box of magic squares.</span>"
	chosen_attack_num = MAGIC_BOX

/datum/action/innate/elite_attack/pandora_teleport
	name = "Line Teleport"
	button_icon_state = "pandora_teleport"
	chosen_message = "<span class='boldwarning'>You will now teleport to your target.</span>"
	chosen_attack_num = PANDORA_TELEPORT

/datum/action/innate/elite_attack/aoe_squares
	name = "AOE Blast"
	button_icon_state = "aoe_squares"
	chosen_message = "<span class='boldwarning'>Your attacks will spawn an AOE blast at your target location.</span>"
	chosen_attack_num = AOE_SQUARES

/mob/living/simple_animal/hostile/asteroid/elite/pandora/OpenFire()
	if(client)
		switch(chosen_attack)
			if(CHASER_BURST)
				chaser_burst(target)
			if(MAGIC_BOX)
				magic_box(target)
			if(PANDORA_TELEPORT)
				pandora_teleport(target)
			if(AOE_SQUARES)
				aoe_squares(target)
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(CHASER_BURST)
			chaser_burst(target)
		if(MAGIC_BOX)
			magic_box(target)
		if(PANDORA_TELEPORT)
			pandora_teleport(target)
		if(AOE_SQUARES)
			aoe_squares(target)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/Life(seconds, times_fired)
	. = ..()
	if(health >= maxHealth * 0.5)
		cooldown_time = 2 SECONDS * revive_multiplier()
		chaser_speed = 3
		recalculation_speed = 4
		return
	if(health < maxHealth * 0.5 && health > maxHealth * 0.25)
		cooldown_time = 1.5 SECONDS * revive_multiplier()
		chaser_speed = 2
		recalculation_speed = 3
		return
	else
		chaser_speed = 1
		cooldown_time = 1 SECONDS * revive_multiplier()
		recalculation_speed = 2

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/chaser_burst(target)
	ranged_cooldown = world.time + cooldown_time * 2.5 // this shreads people incredibly effectivly at low hp, so needs higher cooldown than other attacks
	var/active_chasers = 0
	for(var/mob/living/M in orange(7, src))
		if(M.faction_check_mob(src))
			continue
		if(M.stat == DEAD) //Let us not have dead mobs be used to make a disco inferno.
			continue
		if(active_chasers >= MAX_CHASERS)
			return
		var/obj/effect/temp_visual/hierophant/chaser/C = new(loc, src, M, chaser_speed, FALSE)
		C.moving = 2
		C.standard_moving_before_recalc = recalculation_speed
		C.moving_dir = text2dir(pick("NORTH", "SOUTH", "EAST", "WEST"))
		active_chasers += 1

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/singular_shot_line(procsleft, angleused, turf/T)
	if(procsleft <= 0)
		return
	new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(T, src, TRUE)
	T = get_step(T, angleused)
	procsleft = procsleft - 1
	addtimer(CALLBACK(src, PROC_REF(singular_shot_line), procsleft, angleused, T), cooldown_time * 0.1)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/magic_box(target)
	ranged_cooldown = world.time + cooldown_time
	var/turf/T = get_turf(target)
	for(var/t in spiral_range_turfs(3, T))
		if(get_dist(t, T) > 1)
			new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src, TRUE)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport(target)
	var/turf/turf_target = get_turf(target)
	if(!(turf_target in view(12, src)))
		return
	ranged_cooldown = world.time + cooldown_time * 2
	var/turf/source = get_turf(src)
	new /obj/effect/temp_visual/hierophant/telegraph(turf_target, src)
	new /obj/effect/temp_visual/hierophant/telegraph(source, src)
	playsound(source,'sound/machines/airlock_open.ogg', 200, 1)
	addtimer(CALLBACK(src, PROC_REF(pandora_teleport_2), turf_target, source), 2)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport_2(turf/T, turf/source)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, src)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, src)
	for(var/t in RANGE_TURFS(1, T))
		new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src, TRUE)
	for(var/t in RANGE_TURFS(1, source))
		new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src, TRUE)
	animate(src, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	visible_message("<span class='hierophant'>[src] fades out!</span>")
	set_density(FALSE)
	addtimer(CALLBACK(src, PROC_REF(pandora_teleport_3), T), 2)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport_3(turf/T)
	forceMove(T)
	animate(src, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	set_density(TRUE)
	visible_message("<span class='hierophant'>[src] fades in!</span>")

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/aoe_squares(target)
	ranged_cooldown = world.time + cooldown_time * 2
	var/turf/T = get_turf(target)
	new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(T, src, TRUE)
	var/max_size = 3
	addtimer(CALLBACK(src, PROC_REF(aoe_squares_2), T, 0, max_size), 2)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/aoe_squares_2(turf/T, ring, max_size)
	if(ring > max_size)
		return
	for(var/t in spiral_range_turfs(ring, T))
		if(get_dist(t, T) == ring)
			new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src, TRUE)
	addtimer(CALLBACK(src, PROC_REF(aoe_squares_2), T, (ring + 1), max_size), cooldown_time * 0.1)

//The specific version of hiero's squares pandora uses
/obj/effect/temp_visual/hierophant/blast/damaging/pandora
	damage = 30
	monster_damage_boost = FALSE
	friendly_fire_check = TRUE


//Pandora's loot: Hope //Hope I know what to make it do
/obj/item/clothing/accessory/necklace/pandora_hope
	name = "Hope"
	desc = "Found at the bottom of Pandora. After all the evil was released, this was the only thing left inside."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "hope"
	item_state = "hope"
	item_color = "hope"
	slot_flags = SLOT_TIE
	allow_duplicates = FALSE
	resistance_flags = FIRE_PROOF

/obj/item/clothing/accessory/necklace/pandora_hope/on_attached(obj/item/clothing/under/S, mob/user)
	. = ..()
	if(isliving(S.loc))
		var/mob/living/M = S.loc
		M.apply_status_effect(STATUS_EFFECT_HOPE)

/obj/item/clothing/accessory/necklace/pandora_hope/on_removed(mob/user)
	if(isliving(has_suit.loc))
		var/mob/living/M = has_suit.loc
		M.remove_status_effect(STATUS_EFFECT_HOPE)
	return ..()

#undef CHASER_BURST
#undef MAGIC_BOX
#undef PANDORA_TELEPORT
#undef AOE_SQUARES
#undef MAX_CHASERS
