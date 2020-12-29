/datum/action/morph
	background_icon_state = "bg_morph"
	/// Owning morph variable. Removes the need for casts
	var/mob/living/simple_animal/hostile/morph/morph
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/datum/action/morph/Grant(mob/M)
	..()
	morph = owner

/datum/action/morph/IsAvailable()
	if(!istype(morph) || morph.gathered_food < hunger_cost)
		return FALSE
	return ..()

/datum/action/morph/Trigger()
	. = ..()
	if(.)
		morph.use_food(hunger_cost)


/datum/action/morph/ambush
	name = "Prepare Ambush"
	desc = "Prepare an ambush. Dealing significantly more damage on the first hit and you will weaken the target. Only works while morphed. If the target tries to use you with their hands then you will do even more damage."
	button_icon_state = "morph_ambush"
	var/preparing = FALSE

/datum/action/morph/ambush/IsAvailable()
	var/mob/living/simple_animal/hostile/morph/M = owner
	if(!istype(M) || !M.morphed || M.ambush_prepared || preparing)
		return FALSE
	return ..()

/datum/action/morph/ambush/Trigger()
	if(!..())
		return
	var/mob/living/simple_animal/hostile/morph/M = owner
	to_chat(M, "<span class='sinister'>You start preparing an ambush.</span>")
	preparing = TRUE
	if(!do_after(owner, 4 SECONDS, FALSE, owner, list(CALLBACK(src, .proc/prepare_check), FALSE)))
		if(!M.morphed)
			to_chat(M, "<span class='warning'>You need to stay morphed to prepare the ambush!</span>")
			return
		to_chat(M, "<span class='warning'>You need to stay still to prepare the ambush!</span>")
		return
	M.prepare_ambush()
	UpdateButtonIcon()

/datum/action/morph/ambush/proc/prepare_check()
	var/mob/living/simple_animal/hostile/morph/M = owner
	return !M.morphed

/datum/action/morph/reproduce
	name = "Reproduce (150)"
	desc = "Split yourself in half making a new morph."
	hunger_cost = 150 // 5 humans
	icon_icon = 'icons/mob/animal.dmi'
	button_icon_state = "morph"
	var/in_use = FALSE

/datum/action/morph/reproduce/Trigger()
	if(!..())
		return
	in_use = TRUE
	to_chat(morph, "<span class='sinister'>You prepare to split in two.</span>")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)
	if(!length(candidates))
		to_chat(morph, "<span class='warning'>Your body refuses to split at the moment. Try again later.</span>")
		morph.add_food(hunger_cost)
		return
	var/mob/C = pick(candidates)

	var/mob/living/simple_animal/hostile/morph/M = new /mob/living/simple_animal/hostile/morph(get_turf(morph))
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE
	player_mind.transfer_to(M)
	player_mind.assigned_role = SPECIAL_ROLE_MORPH
	player_mind.special_role = SPECIAL_ROLE_MORPH
	SSticker.mode.traitors |= player_mind
	to_chat(M, M.playstyle_string)
	M.playsound_local(get_turf(M), 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

