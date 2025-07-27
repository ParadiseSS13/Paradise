/mob/living/simple_animal/hostile/guardian/bomb
	damage_transfer = 0.6
	range = 13
	playstyle_string = "As an <b>Explosive</b> type, you have only moderate close combat abilities, but are capable of converting any adjacent item into a disguised bomb via alt click even when not manifested."
	magic_fluff_string = "..And draw the Scientist, master of explosive death."
	tech_fluff_string = "Boot sequence complete. Explosive modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of stealthily booby trapping items."
	var/bomb_cooldown = 0
	var/default_bomb_cooldown = 20 SECONDS

/mob/living/simple_animal/hostile/guardian/bomb/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(bomb_cooldown >= world.time)
		status_tab_data[++status_tab_data.len] = list("Bomb Cooldown Remaining:", "[max(round((bomb_cooldown - world.time) * 0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(get_dist(get_turf(src), get_turf(A)) > 1)
		to_chat(src, "<span class='danger'>You're too far from [A] to disguise it as a bomb.</span>")
		return
	if(isobj(A) && can_plant(A))
		if(bomb_cooldown <= world.time && stat == CONSCIOUS)
			A.AddComponent( \
				/datum/component/direct_explosive_trap, \
				saboteur_ = src, \
				explosive_check_ = CALLBACK(src, PROC_REF(validate_target)))
			add_attack_logs(src, A, "booby trapped (summoner: [summoner])")
			to_chat(src, "<span class='danger'>Success! Bomb on [A] armed!</span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Your guardian has primed [A] to explode!</span>")
			bomb_cooldown = world.time + default_bomb_cooldown
		else
			to_chat(src, "<span class='danger'>Your power is on cooldown! You must wait another [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds before you can place next bomb.</span>")

/mob/living/simple_animal/hostile/guardian/bomb/proc/validate_target(atom/source, mob/living/target)
	if(target == summoner)
		add_attack_logs(target, source, "booby trap defused")
		to_chat(target, "<span class='danger'>You knew this because of your link with your guardian, so you smartly defuse the bomb.</span>")
		return DIRECT_EXPLOSIVE_TRAP_DEFUSE

/mob/living/simple_animal/hostile/guardian/bomb/proc/can_plant(atom/movable/A)
	if(ismecha(A))
		var/obj/mecha/target = A
		if(target.occupant)
			to_chat(src, "<span class='warning'>You can't disguise piloted mechs as a bomb!</span>")
			return FALSE
	if(istype(A, /obj/machinery/disposal)) // Have no idea why they just destroy themselves
		to_chat(src, "<span class='warning'>You can't disguise disposal units as a bomb!</span>")
		return FALSE
	return TRUE
